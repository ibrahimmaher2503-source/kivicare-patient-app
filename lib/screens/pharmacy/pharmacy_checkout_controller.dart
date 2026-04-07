import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';
import '../../api/core_apis.dart';
import '../../main.dart';
import 'model/pharmacy_cart_model.dart';
import 'pharmacy_cart_controller.dart';

class PharmacyCheckoutController extends GetxController {
  RxInt addressId = 0.obs;
  RxList<PharmacyAvailablePharmacy> availablePharmacies =
      <PharmacyAvailablePharmacy>[].obs;
  Rx<PharmacyAvailablePharmacy?> selectedPharmacy =
      Rx<PharmacyAvailablePharmacy?>(null);
  RxBool isLoadingPharmacies = false.obs;
  RxBool isPlacingOrder = false.obs;
  Rx<String?> matchMessage = Rx<String?>(null);

  Future<void> findPharmacies() async {
    if (addressId.value <= 0) {
      toast(locale.value.enterAddressId);
      return;
    }
    isLoadingPharmacies(true);
    availablePharmacies.clear();
    selectedPharmacy.value = null;
    matchMessage.value = null;
    try {
      final res = await CoreServiceApis.getAvailablePharmacies(addressId.value);
      availablePharmacies.assignAll(res.data);
      if (res.data.isEmpty) {
        matchMessage.value =
            res.message ?? locale.value.noPharmaciesAvailable;
      }
    } catch (e) {
      toast(e.toString());
    } finally {
      isLoadingPharmacies(false);
    }
  }

  Future<int?> placeOrder() async {
    if (selectedPharmacy.value == null) {
      toast(locale.value.selectPharmacy);
      return null;
    }
    isPlacingOrder(true);
    try {
      final res = await CoreServiceApis.placePharmacyOrder(
        pharmacyId: selectedPharmacy.value!.id,
        addressId: addressId.value,
      );
      if (res.data != null) {
        // Reset cart immediately so badge shows 0, then refresh from server
        if (Get.isRegistered<PharmacyCartController>()) {
          final cartCtrl = Get.find<PharmacyCartController>();
          cartCtrl.cart.value = PharmacyCart();
          cartCtrl.loadCart();
        }
        return res.data!.id;
      }
      return null;
    } catch (e) {
      toast(e.toString());
      return null;
    } finally {
      isPlacingOrder(false);
    }
  }
}
