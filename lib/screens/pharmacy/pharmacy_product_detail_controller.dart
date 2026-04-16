import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';
import '../../api/core_apis.dart';
import 'model/pharmacy_product_model.dart';

class PharmacyProductDetailController extends GetxController {
  Rx<PharmacyProduct?> product = Rx<PharmacyProduct?>(null);
  RxBool isLoading = false.obs;
  RxInt selectedQuantity = 1.obs;

  @override
  void onInit() {
    super.onInit();
    final id = Get.arguments;
    if (id is int) loadProduct(id);
  }

  Future<void> loadProduct(int id) async {
    isLoading(true);
    try {
      final res = await CoreServiceApis.getPharmacyProductDetail(id);
      product.value = res.data;
    } catch (e) {
      toast(e.toString());
    } finally {
      isLoading(false);
    }
  }

  void incrementQuantity() {
    selectedQuantity.value++;
  }

  void decrementQuantity() {
    if (selectedQuantity.value > 1) selectedQuantity.value--;
  }
}
