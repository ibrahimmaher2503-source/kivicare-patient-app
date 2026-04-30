import 'package:get/get.dart';
import '../../../utils/constants.dart';
import '../../../utils/local_storage.dart';

class IcuDashboardController extends GetxController {
  final lastReference = Rxn<String>();

  @override
  void onInit() {
    super.onInit();
    recoverLastReference();
  }

  void recoverLastReference() {
    lastReference.value = getValueFromLocal<String?>(SharedPreferenceConst.lastIcuRequestReferenceKey);
  }

  void clearLastReference() {
    lastReference.value = null;
    setValueToLocal(SharedPreferenceConst.lastIcuRequestReferenceKey, null);
  }
}
