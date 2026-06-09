import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';
import '../../../api/labs_radiology_apis.dart';
import '../models/lab_test_model.dart';

class LabTestsListController extends GetxController {
  final int? categoryId;
  final int? facilityId;

  var isLoading = false.obs;
  var tests = <LabTestModel>[].obs;
  var page = 1.obs;
  var isLastPage = false.obs;
  var searchQuery = ''.obs;

  LabTestsListController({this.categoryId, this.facilityId});

  @override
  void onInit() {
    super.onInit();
    fetchTests();
  }

  Future<void> fetchTests({bool showLoader = true}) async {
    if (showLoader) isLoading.value = true;
    try {
      final res = await LabsRadiologyApis.getLabTests(
        page: page.value,
        categoryId: categoryId,
        facilityId: facilityId,
        search: searchQuery.value,
      );

      if (page.value == 1) {
        tests.assignAll(res.data);
      } else {
        tests.addAll(res.data);
      }

      isLastPage.value = !res.hasMore;
    } catch (e) {
      toast(e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadMore() async {
    if (isLoading.value || isLastPage.value) return;
    page.value++;
    fetchTests(showLoader: false);
  }

  void updateSearch(String query) {
    searchQuery.value = query;
    page.value = 1;
    fetchTests();
  }
}
