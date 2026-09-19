import 'package:get/get.dart';
import '../../../utils/constants.dart';
import '../../../utils/local_storage.dart';

class IcuDashboardController extends GetxController {
  final lastRequestId = RxnInt();
  final lastReference = Rxn<String>();
  final lastCreatedAt = Rxn<DateTime>();

  @override
  void onInit() {
    super.onInit();
    recoverLastReference();
  }

  void recoverLastReference() {
    final recovery =
        getValueFromLocal(SharedPreferenceConst.lastIcuRequestRecoveryKey);
    if (recovery is Map) {
      lastRequestId.value = (recovery['id'] as num?)?.toInt();
      lastReference.value = recovery['reference']?.toString();
      lastCreatedAt.value =
          DateTime.tryParse(recovery['created_at']?.toString() ?? '');
      return;
    }

    // Migrate the old reference-only record without losing a user's last
    // visible confirmation. New confirmations always persist the id too.
    lastReference.value = getValueFromLocal<String?>(
      SharedPreferenceConst.lastIcuRequestReferenceKey,
    );
  }

  static void persistLastRequest({
    required int id,
    required String reference,
  }) {
    setValueToLocal(SharedPreferenceConst.lastIcuRequestRecoveryKey, {
      'id': id,
      'reference': reference,
      'created_at': DateTime.now().toUtc().toIso8601String(),
    });
    setValueToLocal(
      SharedPreferenceConst.lastIcuRequestReferenceKey,
      reference,
    );
  }

  void clearLastReference() {
    lastReference.value = null;
    lastRequestId.value = null;
    lastCreatedAt.value = null;
    setValueToLocal(SharedPreferenceConst.lastIcuRequestRecoveryKey, null);
    setValueToLocal(SharedPreferenceConst.lastIcuRequestReferenceKey, null);
  }
}
