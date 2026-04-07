import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';
import '../../api/core_apis.dart';
import 'model/pharmacy_cart_model.dart';

class PharmacyCartController extends GetxController {
  Rx<PharmacyCart?> cart = Rx<PharmacyCart?>(null);
  RxBool isLoading = false.obs;

  int get itemCount => cart.value?.itemCount ?? 0;

  @override
  void onInit() {
    super.onInit();
    loadCart();
  }

  Future<void> loadCart() async {
    isLoading(true);
    try {
      final res = await CoreServiceApis.getPharmacyCart();
      cart.value = res.data;
    } catch (e) {
      // Cart may be empty on first load — silently ignore 404
    } finally {
      isLoading(false);
    }
  }

  Future<void> addToCart(int productId, int quantity) async {
    isLoading(true);
    try {
      final res = await CoreServiceApis.addToPharmacyCart(
        productId: productId,
        quantity: quantity,
      );
      cart.value = res.data;
    } catch (e) {
      toast(e.toString());
      rethrow;
    } finally {
      isLoading(false);
    }
  }

  Future<void> updateItem(int itemId, int quantity) async {
    try {
      final res = await CoreServiceApis.updatePharmacyCartItem(
        itemId: itemId,
        quantity: quantity,
      );
      cart.value = res.data;
    } catch (e) {
      toast(e.toString());
    }
  }

  Future<void> removeItem(int itemId) async {
    try {
      await CoreServiceApis.removePharmacyCartItem(itemId);
      await loadCart();
    } catch (e) {
      toast(e.toString());
    }
  }
}
