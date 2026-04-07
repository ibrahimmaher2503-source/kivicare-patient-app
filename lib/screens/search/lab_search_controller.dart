import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../api/core_apis.dart';
import '../../screens/lab_test/model/lab_test_model.dart';

class LabSearchController extends GetxController {
  Rx<Future<RxList<LabTest>>> itemsFuture = Future.value(RxList<LabTest>()).obs;
  RxList<LabTest> items = RxList<LabTest>();
  RxBool isLoading = false.obs;
  RxBool isLastPage = false.obs;
  RxInt page = 1.obs;

  TextEditingController searchCont = TextEditingController();
  RxString searchQuery = ''.obs;
  RxnInt selectedGovernorateId = RxnInt();
  RxnInt selectedCityId = RxnInt();

  @override
  void onInit() {
    super.onInit();
    debounce(searchQuery, (_) { page(1); getItems(); }, time: const Duration(milliseconds: 500));
    getItems();
  }

  Future<void> getItems({bool showLoader = true}) async {
    if (showLoader) isLoading(true);
    await itemsFuture(CoreServiceApis.searchLabs(
      page: page.value,
      perPage: 15,
      labTestList: items,
      testName: searchCont.text.trim(),
      governorateId: selectedGovernorateId.value,
      cityId: selectedCityId.value,
      lastPageCallBack: (isLast) => isLastPage(isLast),
    )).then((v) {}).catchError((e) { toast(e.toString()); }).whenComplete(() => isLoading(false));
  }

  void onGovernorateChanged(int? id) { selectedGovernorateId.value = id; selectedCityId.value = null; page(1); getItems(); }
  void onCityChanged(int? id) { selectedCityId.value = id; page(1); getItems(); }
  void onSearchChanged(String val) { searchQuery.value = val; }

  @override void onClose() { searchCont.dispose(); super.onClose(); }
}
