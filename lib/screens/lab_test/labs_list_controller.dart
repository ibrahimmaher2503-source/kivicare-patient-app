import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../api/core_apis.dart';
import '../../main.dart';
import 'model/lab_model.dart';

class LabsListController extends GetxController {
  Rx<Future<RxList<Lab>>> labsFuture = Future(() => RxList<Lab>()).obs;
  RxList<Lab> labs = RxList<Lab>();
  RxBool isLoading = false.obs;
  RxBool isLastPage = false.obs;
  RxInt page = 1.obs;

  TextEditingController searchCont = TextEditingController();
  RxString searchQuery = ''.obs;

  RxnInt selectedGovernorateId = RxnInt();
  RxnInt selectedCityId = RxnInt();

  @override
  void onInit() {
    getLabs();
    debounce(searchQuery, (_) {
      page(1);
      getLabs();
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

  Future<void> getLabs({bool showLoader = true}) async {
    if (showLoader) isLoading(true);

    await labsFuture(
      CoreServiceApis.searchLabFacilities(
        page: page.value,
        perPage: 15,
        labList: labs,
        testName: searchCont.text.trim(),
        governorateId: selectedGovernorateId.value,
        cityId: selectedCityId.value,
        lastPageCallBack: (isLast) => isLastPage(isLast),
      ),
    ).then((value) {
      log('Labs fetched: ${value.length}');
    }).catchError((e) {
      log("getLabs error $e");
      toast(locale.value.somethingWentWrong);
    }).whenComplete(() => isLoading(false));
  }

  void onGovernorateChanged(int? id) {
    selectedGovernorateId.value = id;
    selectedCityId.value = null;
    page(1);
    getLabs();
  }

  void onCityChanged(int? id) {
    selectedCityId.value = id;
    page(1);
    getLabs();
  }
}
