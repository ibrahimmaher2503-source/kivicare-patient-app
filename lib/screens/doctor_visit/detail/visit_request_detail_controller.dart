import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../components/operation_verification_screen.dart';
import '../../../api/doctor_visit_apis.dart';
import '../../../main.dart';
import '../../../network/critical_operation.dart';
import '../../../network/network_utils.dart';
import '../doctor_visit_list_screen.dart';
import '../models/visit_request_model.dart';
import '../models/visit_status.dart';

class VisitRequestDetailController extends GetxController {
  final String referenceNumber;

  VisitRequestDetailController({required this.referenceNumber});

  final Rxn<VisitRequestModel> request = Rxn<VisitRequestModel>();
  final RxBool isLoading = false.obs;
  final RxBool isCancelling = false.obs;
  final RxString error = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchRequest();
  }

  Future<void> fetchRequest() async {
    isLoading(true);
    error('');
    try {
      final result =
          await DoctorVisitApis.getRequestByReference(referenceNumber);
      request.value = result;
    } catch (e) {
      final message =
          sanitizeBackendMessage(e, locale.value.somethingWentWrong);
      error(message);
      toast(message);
    } finally {
      isLoading(false);
    }
  }

  bool get canPatientCancel =>
      request.value?.status == VisitStatus.pending && !isCancelling.value;

  Future<bool> cancelRequest(String reason) async {
    final current = request.value;
    final normalizedReason = reason.trim();
    if (current == null || !canPatientCancel || normalizedReason.isEmpty) {
      return false;
    }

    isCancelling(true);
    final fingerprint = criticalOperationFingerprint({
      'reference_number': current.referenceNumber,
      'status': current.status.apiValue,
      'updated_at': current.updatedAt.toUtc().toIso8601String(),
      'cancellation_reason': normalizedReason,
    });
    String? operationKey;
    try {
      operationKey = await CriticalOperationStore.begin(
        CriticalOperationType.doctorVisitCancellation,
        scope: current.referenceNumber,
        requestFingerprint: fingerprint,
      );
      request.value = await DoctorVisitApis.cancelRequest(
        referenceNumber: current.referenceNumber,
        reason: normalizedReason,
        idempotencyKey: operationKey,
        expectedUpdatedAt: current.updatedAt,
      );
      await CriticalOperationStore.complete(
        CriticalOperationType.doctorVisitCancellation,
        scope: current.referenceNumber,
      );
      toast(locale.value.requestCancelled);
      return true;
    } on AmbiguousRequestOutcomeException {
      Get.off(() => OperationVerificationScreen(
            operationType: CriticalOperationType.doctorVisitCancellation,
            operationKey: operationKey,
            recordsScreen: () => const DoctorVisitListScreen(),
          ));
      return false;
    } on PendingCriticalOperationException {
      Get.off(() => OperationVerificationScreen(
            operationType: CriticalOperationType.doctorVisitCancellation,
            operationKey: operationKey ??
                CriticalOperationStore.pendingKey(
                    CriticalOperationType.doctorVisitCancellation,
                    scope: current.referenceNumber),
            recordsScreen: () => const DoctorVisitListScreen(),
          ));
      return false;
    } catch (e) {
      await CriticalOperationStore.complete(
        CriticalOperationType.doctorVisitCancellation,
        scope: current.referenceNumber,
      );
      await fetchRequest();
      toast(sanitizeBackendMessage(e, locale.value.somethingWentWrong));
      return false;
    } finally {
      isCancelling(false);
    }
  }

  @override
  Future<void> refresh() => fetchRequest();
}
