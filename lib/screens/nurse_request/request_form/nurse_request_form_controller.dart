import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kivicare_patient/api/nurse_request_apis.dart';
import 'package:kivicare_patient/components/operation_verification_screen.dart';
import 'package:kivicare_patient/main.dart';
import 'package:kivicare_patient/network/critical_operation.dart';
import 'package:kivicare_patient/network/network_utils.dart';
import 'package:kivicare_patient/screens/auth/sign_in_sign_up/signin_screen.dart';
import 'package:kivicare_patient/screens/nurse_request/models/nurse_request_form_payload.dart';
import 'package:kivicare_patient/utils/app_common.dart';
import '../nurse_request_list_screen.dart';
import '../success/nurse_request_success_screen.dart';

// The form controller is registered via Get.lazyPut(fenix: false) — in-memory only.
// Draft is preserved in TextEditingControllers while the screen is in the nav stack.
// Nothing is written to GetStorage. Relaunch starts empty (clarification C3).
class NurseRequestFormController extends GetxController {
  // Text controllers
  final serviceEnController = TextEditingController();
  final serviceArController = TextEditingController();
  final addressLine1Controller = TextEditingController();
  final addressLine2Controller = TextEditingController();
  final cityController = TextEditingController();
  final stateController = TextEditingController();
  final countryController = TextEditingController();
  final postalCodeController = TextEditingController();
  final phoneController = TextEditingController(text: '+20');
  final notesController = TextEditingController();

  // Reactive state
  final Rxn<DateTime> preferredDate = Rxn<DateTime>();
  final Rxn<TimeOfDay> preferredTime = Rxn<TimeOfDay>();
  final RxInt durationHours = 1.obs;
  final Rxn<int> governorateId = Rxn<int>();
  final Rxn<int> cityId = Rxn<int>();
  final RxString cityText = ''.obs;
  final RxBool isSubmitting = false.obs;
  final RxnString topLevelError = RxnString();
  final RxMap<String, String> fieldErrors = <String, String>{}.obs;

  final RxnString descriptionError = RxnString();

  @override
  void onClose() {
    serviceEnController.dispose();
    serviceArController.dispose();
    addressLine1Controller.dispose();
    addressLine2Controller.dispose();
    cityController.dispose();
    stateController.dispose();
    countryController.dispose();
    postalCodeController.dispose();
    phoneController.dispose();
    notesController.dispose();
    super.onClose();
  }

  bool _validateAll() {
    fieldErrors.clear();
    topLevelError.value = null;
    bool valid = true;

    final en = serviceEnController.text.trim();
    final ar = serviceArController.text.trim();
    if (en.isEmpty && ar.isEmpty) {
      descriptionError.value = locale.value.atLeastOneDescriptionRequired;
      valid = false;
    } else {
      descriptionError.value = null;
    }
    if (en.length > 2000 || ar.length > 2000) {
      descriptionError.value = locale.value.descriptionTooLong;
      valid = false;
    }

    if (preferredDate.value == null) {
      fieldErrors['preferred_date'] = locale.value.preferredDateRequired;
      valid = false;
    }

    if (durationHours.value < 1 || durationHours.value > 24) {
      fieldErrors['duration_hours'] = locale.value.durationOutOfRange;
      valid = false;
    }

    final addr1 = addressLine1Controller.text.trim();
    if (addr1.isEmpty) {
      fieldErrors['address_line_1'] = locale.value.addressLine1Required;
      valid = false;
    } else if (addr1.length > 255) {
      fieldErrors['address_line_1'] = locale.value.addressTooLong;
      valid = false;
    }

    final city = cityText.value.trim().isNotEmpty
        ? cityText.value.trim()
        : cityController.text.trim();
    if (city.isEmpty) {
      fieldErrors['city'] = locale.value.cityRequired;
      valid = false;
    }

    final phone = phoneController.text.trim();
    final phoneRegex = RegExp(r'^\+?[0-9]{7,20}$');
    if (!phoneRegex.hasMatch(phone)) {
      fieldErrors['contact_number'] = locale.value.phoneInvalid;
      valid = false;
    }

    return valid;
  }

  Future<void> submit() async {
    if (!_validateAll()) return;
    if (isSubmitting.value) return;

    if (isLoggedIn.value) {
      await _doSubmit();
    } else {
      final loggedIn = await Get.to(() => SignInScreen()) ?? false;
      if (loggedIn) await _doSubmit();
    }
  }

  Future<void> _doSubmit() async {
    if (isSubmitting.value) return;
    isSubmitting(true);
    final city = cityText.value.trim().isNotEmpty
        ? cityText.value.trim()
        : cityController.text.trim();
    final timeOfDay = preferredTime.value;
    final timeStr = timeOfDay != null
        ? '${timeOfDay.hour.toString().padLeft(2, '0')}:${timeOfDay.minute.toString().padLeft(2, '0')}'
        : null;

    final payload = NurseRequestFormPayload(
      serviceDescriptionEn:
          serviceEnController.text.isEmpty ? null : serviceEnController.text,
      serviceDescriptionAr:
          serviceArController.text.isEmpty ? null : serviceArController.text,
      preferredDate: preferredDate.value!,
      preferredTime: timeStr,
      durationHours: durationHours.value,
      addressLine1: addressLine1Controller.text,
      addressLine2: addressLine2Controller.text.isEmpty
          ? null
          : addressLine2Controller.text,
      governorateId: governorateId.value,
      cityId: cityId.value,
      city: city,
      state: stateController.text.isEmpty ? null : stateController.text,
      country: countryController.text.isEmpty ? null : countryController.text,
      postalCode:
          postalCodeController.text.isEmpty ? null : postalCodeController.text,
      contactPhone: phoneController.text,
      patientNotes: notesController.text.isEmpty ? null : notesController.text,
    );

    final fingerprint = criticalOperationFingerprint(payload.toJson());
    String? operationKey;
    try {
      operationKey = await CriticalOperationStore.begin(
        CriticalOperationType.nurseRequest,
        requestFingerprint: fingerprint,
      );
      final result = await NurseRequestApis.create(
        payload: payload,
        idempotencyKey: operationKey,
      );
      await CriticalOperationStore.complete(CriticalOperationType.nurseRequest);
      Get.off(() => NurseRequestSuccessScreen(request: result));
    } on AmbiguousRequestOutcomeException {
      // Keep this controller and its in-memory draft in the route stack while
      // the patient verifies whether Laravel committed the request.
      Get.to(() => OperationVerificationScreen(
            operationType: CriticalOperationType.nurseRequest,
            operationKey: operationKey,
            recordsScreen: () => const NurseRequestListScreen(),
          ));
    } on PendingCriticalOperationException {
      Get.to(() => OperationVerificationScreen(
            operationType: CriticalOperationType.nurseRequest,
            operationKey: operationKey ??
                CriticalOperationStore.pendingKey(
                    CriticalOperationType.nurseRequest),
            recordsScreen: () => const NurseRequestListScreen(),
          ));
    } catch (e) {
      // HTTP/auth/validation/server responses are definite rejections. Keep
      // the patient on the form and surface the owning error.
      await CriticalOperationStore.complete(CriticalOperationType.nurseRequest);
      topLevelError.value =
          sanitizeBackendMessage(e, locale.value.somethingWentWrong);
    } finally {
      isSubmitting(false);
    }
  }
}
