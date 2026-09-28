import 'package:get/get.dart';
import 'package:kivicare_patient/api/nurse_request_apis.dart';
import 'package:kivicare_patient/components/operation_verification_screen.dart';
import 'package:kivicare_patient/main.dart';
import 'package:kivicare_patient/network/critical_operation.dart';
import 'package:kivicare_patient/network/network_utils.dart';
import 'package:nb_utils/nb_utils.dart';

import '../models/nurse_request_model.dart';
import '../models/nurse_status.dart';
import '../nurse_request_list_screen.dart';

class NurseRequestDetailController extends GetxController {
  final int requestId;
  final Rxn<NurseRequestModel> request = Rxn<NurseRequestModel>();
  final RxBool isLoading = false.obs;
  final RxBool isCancelling = false.obs;
  final RxnString error = RxnString();

  NurseRequestDetailController({required this.requestId});

  @override
  void onInit() {
    super.onInit();
    fetch();
  }

  Future<void> fetch() async {
    isLoading(true);
    error.value = null;
    try {
      final result = await NurseRequestApis.detail(id: requestId);
      request.value = result;
    } catch (e) {
      if (request.value == null) {
        error.value =
            sanitizeBackendMessage(e, locale.value.somethingWentWrong);
      } else {
        toast(sanitizeBackendMessage(e, locale.value.somethingWentWrong));
      }
    } finally {
      isLoading(false);
    }
  }

  /// The client only exposes cancellation for the exact pending state. The
  /// API remains the authority and must re-check ownership/state/version in a
  /// transaction, so a stale detail screen cannot cancel an assigned request.
  bool get canPatientCancel {
    final status = request.value?.status.trim().toLowerCase();
    return status == NurseStatus.pending.apiValue;
  }

  Future<bool> cancel(String reason) async {
    final current = request.value;
    final normalizedReason = reason.trim();
    if (current == null ||
        !canPatientCancel ||
        normalizedReason.isEmpty ||
        isCancelling.value) {
      return false;
    }

    isCancelling(true);
    final scope = current.id.toString();
    final fingerprint = criticalOperationFingerprint({
      'request_id': current.id,
      'status': current.status,
      'updated_at': current.updatedAt.toUtc().toIso8601String(),
      'cancellation_reason': normalizedReason,
    });
    String? operationKey;
    try {
      operationKey = await CriticalOperationStore.begin(
        CriticalOperationType.nurseCancellation,
        scope: scope,
        requestFingerprint: fingerprint,
      );
      final result = await NurseRequestApis.cancel(
        id: current.id,
        reason: normalizedReason,
        idempotencyKey: operationKey,
        expectedUpdatedAt: current.updatedAt,
      );
      await CriticalOperationStore.complete(
        CriticalOperationType.nurseCancellation,
        scope: scope,
      );
      request.value = result;
      await fetch();
      toast(locale.value.requestCancelled);
      return true;
    } on AmbiguousRequestOutcomeException {
      Get.off(
        () => OperationVerificationScreen(
          recordsScreen: () => const NurseRequestListScreen(),
          operationType: CriticalOperationType.nurseCancellation,
          operationKey: operationKey,
        ),
      );
      return false;
    } on PendingCriticalOperationException {
      Get.off(
        () => OperationVerificationScreen(
          recordsScreen: () => const NurseRequestListScreen(),
          operationType: CriticalOperationType.nurseCancellation,
          operationKey: operationKey ??
              CriticalOperationStore.pendingKey(
                  CriticalOperationType.nurseCancellation,
                  scope: scope),
        ),
      );
      return false;
    } catch (e) {
      await CriticalOperationStore.complete(
        CriticalOperationType.nurseCancellation,
        scope: scope,
      );
      if (e.toString().contains('409') || e.toString().contains('422')) {
        await fetch();
        toast(locale.value.unavailable);
      } else {
        toast(sanitizeBackendMessage(e, locale.value.somethingWentWrong));
      }
      return false;
    } finally {
      isCancelling(false);
    }
  }
}
