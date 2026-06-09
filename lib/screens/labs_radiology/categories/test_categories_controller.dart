import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';
import '../../../api/labs_radiology_apis.dart';
import '../models/lab_test_category_model.dart';

class TestCategoriesController extends GetxController {
  var isLoading = false.obs;
  var categories = <LabTestCategoryModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchCategories();
  }

  Future<void> fetchCategories() async {
    isLoading.value = true;
    try {
      final list = await LabsRadiologyApis.getTestCategories();
      categories.assignAll(list);
    } catch (e, st) {
      // ignore: avoid_print
      print('[TestCategoriesController] fetchCategories ERROR: $e\n$st');
      toast(e.toString());
    } finally {
      isLoading.value = false;
    }
  }
}
