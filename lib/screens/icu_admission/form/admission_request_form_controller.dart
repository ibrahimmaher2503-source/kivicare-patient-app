import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:nb_utils/nb_utils.dart';
import '../../../api/icu_apis.dart';
import '../../../main.dart';
import '../../../network/network_utils.dart';
import '../../../utils/constants.dart';
import '../../../utils/app_common.dart';
import '../../../utils/common_base.dart';
import '../../../components/operation_verification_screen.dart';
import '../../../network/critical_operation.dart';
import '../models/admission_request_form_payload.dart';
import '../models/admission_request_model.dart';
import '../models/hospital_model.dart';
import '../models/icu_department_model.dart';
import '../success/admission_success_screen.dart';
import '../requests/admission_request_list_screen.dart';
import '../requests/icu_dashboard_controller.dart';
import 'components/critical_urgency_alert.dart';
import 'admission_request_form_validators.dart';

class AdmissionRequestFormController extends GetxController {
  final hospital = Rxn<Hospital>();
  final department = Rxn<IcuDepartment>();

  final patientNameCont = TextEditingController();
  final patientAgeCont = TextEditingController();
  final diagnosisCont = TextEditingController();
  final nationalIdCont = TextEditingController();
  final currentConditionCont = TextEditingController();
  final attendingDoctorCont = TextEditingController();
  final medicalHistoryCont = TextEditingController();
  final currentMedicationsCont = TextEditingController();
  final allergiesCont = TextEditingController();
  final additionalNotesCont = TextEditingController();
  final accompanyingNameCont = TextEditingController();
  final accompanyingRelationCont = TextEditingController();
  final accompanyingPhoneCont = TextEditingController();
  final departmentCont = TextEditingController();
  final preferredDateCont = TextEditingController();

  final urgency = UrgencyLevel.routine.obs;
  final preferredDate = Rxn<DateTime>();
  final patientGender = 'male'.obs;

  final isLoading = false.obs;
  final formKey = GlobalKey<FormState>();

  @override
  void onInit() {
    super.onInit();
    if (Get.arguments is Hospital) {
      setHospital(Get.arguments as Hospital);
    }
  }

  void setHospital(Hospital selectedHospital) {
    hospital.value = selectedHospital;
    department.value = null;
    departmentCont.clear();
  }

  void clearHospital() {
    hospital.value = null;
    department.value = null;
    departmentCont.clear();
  }

  void setDepartment(IcuDepartment selectedDepartment) {
    department.value = selectedDepartment;
    departmentCont.text = selectedDepartment.name;
  }

  void setUrgency(UrgencyLevel val) {
    urgency.value = val;
    if (val == UrgencyLevel.critical) {
      Get.dialog(const CriticalUrgencyAlert());
    }
  }

  Future<void> selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: preferredDate.value ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );
    if (picked != null) {
      preferredDate.value = picked;
      preferredDateCont.text =
          DateFormat(DateFormatConst.yyyy_MM_dd).format(picked);
    }
  }

  Future<void> submit() async {
    if (isLoading.value) return;
    if (!await requireAuthenticated()) return;
    final formState = formKey.currentState;
    if (formState != null && formState.validate()) {
      if (hospital.value == null) {
        toast(locale.value.pleaseSelectHospital);
        return;
      }
      if (department.value == null) {
        toast(locale.value.pleaseSelectDepartment);
        return;
      }

      isLoading(true);

      final payload = AdmissionRequestFormPayload(
        hospitalId: hospital.value!.id,
        icuDepartmentId: department.value!.id,
        patientName: patientNameCont.text.trim(),
        patientAge: patientAgeCont.text.toInt(),
        patientGender: patientGender.value,
        nationalId: nationalIdCont.text.trim(),
        diagnosis: diagnosisCont.text.trim(),
        languageCode: selectedLanguageCode.value,
        currentCondition: currentConditionCont.text.trim(),
        attendingDoctor: attendingDoctorCont.text.trim(),
        medicalHistory: medicalHistoryCont.text.trim(),
        currentMedications: currentMedicationsCont.text.trim(),
        allergies: allergiesCont.text.trim(),
        urgency: urgency.value,
        preferredAdmissionAt: preferredDate.value,
        additionalNotes: additionalNotesCont.text.trim(),
        accompanyingName: accompanyingNameCont.text.trim(),
        accompanyingRelation: accompanyingRelationCont.text.trim(),
        accompanyingPhone: AdmissionRequestFormValidators.normalizePhone(
            accompanyingPhoneCont.text),
      );

      String? operationKey;
      try {
        operationKey = await CriticalOperationStore.begin(
          CriticalOperationType.icuAdmission,
          requestFingerprint: criticalOperationFingerprint(payload.toJson()),
        );
        final result = await IcuApis.submitAdmissionRequest(
          payload,
          idempotencyKey: operationKey,
        );
        await CriticalOperationStore.complete(
          CriticalOperationType.icuAdmission,
        );
        IcuDashboardController.persistLastRequest(
          id: result.id,
          reference: result.referenceNumber,
        );
        Get.off(() => AdmissionSuccessScreen(
            requestId: result.id, referenceNumber: result.referenceNumber));
      } on AmbiguousRequestOutcomeException {
        Get.off(() => OperationVerificationScreen(
              operationType: CriticalOperationType.icuAdmission,
              operationKey: operationKey,
              recordsScreen: () => const AdmissionRequestListScreen(),
            ));
      } on PendingCriticalOperationException {
        Get.off(() => OperationVerificationScreen(
              operationType: CriticalOperationType.icuAdmission,
              operationKey: operationKey ??
                  CriticalOperationStore.pendingKey(
                      CriticalOperationType.icuAdmission),
              recordsScreen: () => const AdmissionRequestListScreen(),
            ));
      } catch (e) {
        await CriticalOperationStore.complete(
          CriticalOperationType.icuAdmission,
        );
        toast(sanitizeBackendMessage(
            e, locale.value.somethingWentWrongPleaseTryAgainLater));
      } finally {
        isLoading(false);
      }
    }
  }

  @override
  void onClose() {
    for (final controller in [
      patientNameCont,
      patientAgeCont,
      diagnosisCont,
      nationalIdCont,
      currentConditionCont,
      attendingDoctorCont,
      medicalHistoryCont,
      currentMedicationsCont,
      allergiesCont,
      additionalNotesCont,
      accompanyingNameCont,
      accompanyingRelationCont,
      accompanyingPhoneCont,
      departmentCont,
      preferredDateCont,
    ]) {
      controller.dispose();
    }
    super.onClose();
  }
}
