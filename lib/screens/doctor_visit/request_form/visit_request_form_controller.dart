import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../api/doctor_visit_apis.dart';
import '../../../components/operation_verification_screen.dart';
import '../../../main.dart';
import '../../../network/critical_operation.dart';
import '../../../network/network_utils.dart';
import '../../../screens/auth/sign_in_sign_up/signin_screen.dart';
import '../../../utils/api_end_points.dart';
import '../../../utils/app_common.dart';
import '../models/visit_doctor_model.dart';
import '../success/visit_request_success_screen.dart';
import '../doctor_visit_list_screen.dart';

class VisitRequestFormController extends GetxController {
  final reasonController = TextEditingController();
  final phoneController = TextEditingController(text: '+20');
  final notesController = TextEditingController();

  final Rxn<DateTime> preferredDate = Rxn<DateTime>();
  final Rxn<VisitDoctorModel> selectedDoctor = Rxn<VisitDoctorModel>();

  final RxBool isSubmitting = false.obs;
  final RxMap<String, String> fieldErrors = <String, String>{}.obs;

  final RxList<VisitDoctorModel> doctorSearchResults = <VisitDoctorModel>[].obs;
  final RxBool isDoctorSearching = false.obs;

  @override
  void onClose() {
    reasonController.dispose();
    phoneController.dispose();
    notesController.dispose();
    super.onClose();
  }

  bool _validate() {
    fieldErrors.clear();
    bool valid = true;

    final reason = reasonController.text.trim();
    if (reason.isEmpty) {
      fieldErrors['reason'] = locale.value.visitReasonRequired;
      valid = false;
    } else if (reason.length > 1000) {
      fieldErrors['reason'] = locale.value.visitReasonTooLong;
      valid = false;
    }

    if (preferredDate.value == null) {
      fieldErrors['date'] = locale.value.preferredDateRequired;
      valid = false;
    } else {
      final today = DateTime.now();
      final selected = preferredDate.value!;
      if (selected.isBefore(DateTime(today.year, today.month, today.day))) {
        fieldErrors['date'] = locale.value.preferredDateMustBeFuture;
        valid = false;
      }
    }

    final phone = phoneController.text.trim();
    if (phone.isEmpty) {
      fieldErrors['phone'] = locale.value.contactPhoneRequired;
      valid = false;
    } else if (!RegExp(r'^\+?[0-9]{7,20}$').hasMatch(phone)) {
      fieldErrors['phone'] = locale.value.contactPhoneInvalid;
      valid = false;
    }

    final notes = notesController.text.trim();
    if (notes.isNotEmpty && notes.length > 2000) {
      fieldErrors['notes'] = locale.value.additionalNotesTooLong;
      valid = false;
    }

    return valid;
  }

  Future<void> submit() async {
    if (!_validate()) return;
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
    final payload = {
      'visit_reason': reasonController.text.trim(),
      'preferred_date': preferredDate.value!.toIso8601String(),
      'contact_phone': phoneController.text.trim(),
      'preferred_doctor_id': selectedDoctor.value?.id,
      'additional_notes': notesController.text.trim(),
    };
    final fingerprint = criticalOperationFingerprint(payload);
    String? operationKey;
    try {
      operationKey = await CriticalOperationStore.begin(
        CriticalOperationType.doctorVisit,
        requestFingerprint: fingerprint,
      );
      final result = await DoctorVisitApis.submitRequest(
        visitReason: reasonController.text.trim(),
        preferredDate: preferredDate.value!,
        contactPhone: phoneController.text.trim(),
        idempotencyKey: operationKey,
        preferredDoctorId: selectedDoctor.value?.id,
        additionalNotes: notesController.text.trim().isEmpty
            ? null
            : notesController.text.trim(),
      );
      await CriticalOperationStore.complete(CriticalOperationType.doctorVisit);
      Get.off(() => VisitRequestSuccessScreen(request: result));
    } on AmbiguousRequestOutcomeException {
      Get.to(() => OperationVerificationScreen(
            operationType: CriticalOperationType.doctorVisit,
            operationKey: operationKey,
            recordsScreen: () => const DoctorVisitListScreen(),
          ));
    } on PendingCriticalOperationException {
      Get.to(() => OperationVerificationScreen(
            operationType: CriticalOperationType.doctorVisit,
            operationKey: operationKey ??
                CriticalOperationStore.pendingKey(
                    CriticalOperationType.doctorVisit),
            recordsScreen: () => const DoctorVisitListScreen(),
          ));
    } catch (e) {
      await CriticalOperationStore.complete(CriticalOperationType.doctorVisit);
      toast(sanitizeBackendMessage(e, locale.value.somethingWentWrong));
    } finally {
      isSubmitting(false);
    }
  }

  Future<void> loadDoctors({String search = ''}) async {
    isDoctorSearching(true);
    try {
      final raw = await handleResponse(
        await buildHttpResponse(
          endpointWithQuery(
            APIEndPoints.getDoctorList,
            {
              'per_page': 20,
              'page': 1,
              'search': search.isEmpty ? null : search,
            },
          ),
          method: HttpMethodType.GET,
        ),
      );
      final list = raw['data'] is List ? raw['data'] as List : [];
      doctorSearchResults.assignAll(
        list
            .map((d) => VisitDoctorModel(
                  id: d['id'] is int ? d['id'] : -1,
                  name: d['full_name'] is String
                      ? d['full_name']
                      : '${d['first_name'] ?? ''} ${d['last_name'] ?? ''}'
                          .trim(),
                  specialty: d['expert'] is String ? d['expert'] : null,
                  avatar:
                      d['profile_image'] is String ? d['profile_image'] : null,
                  rating: d['average_rating'] != null
                      ? (d['average_rating'] as num).toDouble()
                      : null,
                ))
            .where((d) => d.id != -1)
            .toList(),
      );
    } catch (_) {
      // silently ignore — the picker will show an empty list
    } finally {
      isDoctorSearching(false);
    }
  }
}
