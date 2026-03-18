import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../api/core_apis.dart';
import '../../main.dart';
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

  // Filters
  int? categoryId;
  RxString selectedDepartment = ''.obs;
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
    super.onInit();
  }

  void onSearchChanged(String val) {
    page(1);
    getLabTests();
  }

  @override
  void dispose() {
    searchCont.dispose();
    super.dispose();
  }

  Future<void> getLabTests({bool showLoader = true}) async {
    if (showLoader) {
      isLoading(true);
    }

    await labTestFuture(
      CoreServiceApis.getLabTestList(
        page: page.value,
        perPage: 15,
        labTestList: labTests,
        search: searchCont.text.trim(),
        categoryId: categoryId,
        department: selectedDepartment.value,
        lastPageCallBack: (isLast) => isLastPage(isLast),
      ),
    ).then((value) {
      log('Lab tests fetched: ${value.length}');
    }).catchError((e) {
      log("getLabTests error $e");
    }).whenComplete(() => isLoading(false));
  }

  void onFilterChanged(String department) {
    selectedDepartment(department);
    page(1);
    getLabTests();
  }
}
