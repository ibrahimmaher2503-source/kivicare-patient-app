import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../api/core_apis.dart';
import '../../utils/constants.dart';
import 'model/independent_doctor_model.dart';

class IndependentDoctorListController extends GetxController {
  // List state
  Rx<Future<RxList<IndependentDoctor>>> doctorFuture = Future(() => RxList<IndependentDoctor>()).obs;
  RxList<IndependentDoctor> doctors = RxList<IndependentDoctor>();
  RxBool isLoading = false.obs;
  RxBool isLastPage = false.obs;
  RxInt page = 1.obs;

  // Search
  TextEditingController searchCont = TextEditingController();
  RxString searchQuery = ''.obs;

  @override
  void onInit() {
    getDoctors();
    debounce(searchQuery, (_) {
      page(1);
      getDoctors();
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

  Future<void> getDoctors({bool showLoader = true}) async {
    if (showLoader) {
      isLoading(true);
    }

    await doctorFuture(
      CoreServiceApis.getIndependentDoctorList(
        page: page.value,
        perPage: Constants.perPageItem,
        doctorList: doctors,
        search: searchCont.text.trim(),
        lastPageCallBack: (isLast) => isLastPage(isLast),
      ),
    ).then((value) {
      log('Independent doctors fetched: ${value.length}');
    }).catchError((e) {
      log("getDoctors error $e");
    }).whenComplete(() => isLoading(false));
  }

  void onSearchCleared() {
    searchCont.clear();
    searchQuery('');
    page(1);
    getDoctors();
  }
}
