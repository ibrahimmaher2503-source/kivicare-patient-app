import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';
import '../../../api/icu_apis.dart';
import '../../../main.dart';
import '../../../utils/constants.dart';
import '../../../utils/local_storage.dart';
import '../models/admission_request_form_payload.dart';
import '../models/admission_request_model.dart';
import '../models/hospital_model.dart';
import '../models/icu_department_model.dart';
import '../success/admission_success_screen.dart';
import 'components/critical_urgency_alert.dart';

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

  final urgency = UrgencyLevel.routine.obs;
  final preferredDate = Rxn<DateTime>();
  final patientGender = 'male'.obs;

  final isLoading = false.obs;
  final formKey = GlobalKey<FormState>();

  @override
  void onInit() {
    super.onInit();
    if (Get.arguments is Hospital) {
      hospital.value = Get.arguments;
    }
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
    }
  }

  Future<void> submit() async {
    if (formKey.currentState!.validate()) {
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
        accompanyingPhone: accompanyingPhoneCont.text.trim(),
      );

      try {
        final request = await IcuApis.submitAdmissionRequest(payload);
        setValueToLocal(SharedPreferenceConst.lastIcuRequestReferenceKey, request.referenceNumber);
        Get.off(() => AdmissionSuccessScreen(request: request));
      } catch (e) {
        toast(e.toString());
      } finally {
        isLoading(false);
      }
    }
  }
}
