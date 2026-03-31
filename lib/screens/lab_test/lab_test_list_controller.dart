import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../api/core_apis.dart';
import '../../main.dart';
import '../../utils/constants.dart';
import 'model/lab_test_model.dart';

class LabTestListController extends GetxController {
  // List state
  Rx<Future<RxList<LabTest>>> labTestFuture = Future(() => RxList<LabTest>()).obs;
  RxList<LabTest> labTests = RxList<LabTest>();
  RxBool isLoading = false.obs;
  RxBool isLastPage = false.obs;
  RxInt page = 1.obs;

  // Search
  TextEditingController searchCont = TextEditingController();
  RxString searchQuery = ''.obs;

  // Filters
  int? categoryId;
  RxString selectedDepartment = ''.obs;
  RxnInt selectedGovernorateId = RxnInt();
  RxnInt selectedCityId = RxnInt();
  RxList<Map<String, String>> departmentFilters = RxList();

  @override
  void onInit() {
    // Check for category filter from arguments
    if (Get.arguments is Map && Get.arguments['categoryId'] != null) {
      categoryId = Get.arguments['categoryId'] as int;
    }

    departmentFilters = [
      {'key': '', 'label': locale.value.all},
      {'key': 'laboratory', 'label': locale.value.laboratory},
      {'key': 'radiology', 'label': locale.value.radiology},
    ].obs;

    getLabTests();
    debounce(searchQuery, (_) {
      page(1);
      getLabTests();
    }, time: const Duration(milliseconds: 500));
    super.onInit();
  }

  void onSearchChanged(String val) {
    searchQuery.value = val;
  }

  @override
  void onClose() {
    searchCont.dispose();
    super.onClose();
  }

  Future<void> getLabTests({bool showLoader = true}) async {
    if (showLoader) {
      isLoading(true);
    }

    await labTestFuture(
      CoreServiceApis.searchLabs(
        page: page.value,
        perPage: Constants.perPageItem,
        labTestList: labTests,
        testName: searchCont.text.trim(),
        department: selectedDepartment.value,
        categoryId: categoryId,
        governorateId: selectedGovernorateId.value,
        cityId: selectedCityId.value,
        lastPageCallBack: (isLast) => isLastPage(isLast),
      ),
    ).then((value) {
      log('Lab tests fetched: ${value.length}');
    }).catchError((e) {
      log("getLabTests error $e");
      toast(locale.value.somethingWentWrong);
    }).whenComplete(() => isLoading(false));
  }

  void onFilterChanged(String department) {
    selectedDepartment(department);
    page(1);
    getLabTests();
  }

  void onGovernorateChanged(int? id) {
    selectedGovernorateId.value = id;
    selectedCityId.value = null;
    page(1);
    getLabTests();
  }

  void onCityChanged(int? id) {
    selectedCityId.value = id;
    page(1);
    getLabTests();
  }
}
