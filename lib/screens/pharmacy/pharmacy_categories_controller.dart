import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';
import '../../api/core_apis.dart';
import 'model/pharmacy_category_model.dart';

class PharmacyCategoriesController extends GetxController {
  RxList<PharmacyCategory> categories = <PharmacyCategory>[].obs;
  RxBool isLoading = false.obs;
  Rx<String?> errorMessage = Rx<String?>(null);
  RxBool showingSubcategories = false.obs;
  Rx<PharmacyCategory?> selectedParent = Rx<PharmacyCategory?>(null);

  @override
  void onInit() {
    super.onInit();
    loadCategories();
  }

  Future<void> loadCategories() async {
    isLoading(true);
    errorMessage.value = null;
    showingSubcategories(false);
    selectedParent.value = null;
    try {
      final res = await CoreServiceApis.getPharmacyCategories();
      categories.assignAll(res.data);
    } catch (e) {
      errorMessage.value = e.toString();
      toast(e.toString());
    } finally {
      isLoading(false);
    }
  }

  Future<void> loadSubcategories(int parentId) async {
    isLoading(true);
    errorMessage.value = null;
    try {
      final res = await CoreServiceApis.getPharmacyCategoryChildren(parentId);
      categories.assignAll(res.data);
      showingSubcategories(true);
    } catch (e) {
      errorMessage.value = e.toString();
      toast(e.toString());
    } finally {
      isLoading(false);
    }
  }

  void goBack() {
    showingSubcategories(false);
    selectedParent.value = null;
    loadCategories();
  }
}
