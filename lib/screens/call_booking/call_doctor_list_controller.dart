import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../api/core_apis.dart';
import '../../utils/constants.dart';
import 'model/call_doctor_model.dart';

class CallDoctorListController extends GetxController {
  // List state
  Rx<Future<RxList<CallDoctor>>> doctorFuture = Future(() => RxList<CallDoctor>()).obs;
  RxList<CallDoctor> doctors = RxList<CallDoctor>();
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
      CoreServiceApis.getCallDoctorList(
        page: page.value,
        perPage: Constants.perPageItem,
        doctorList: doctors,
        search: searchCont.text.trim(),
        lastPageCallBack: (isLast) => isLastPage(isLast),
      ),
    ).then((value) {
      log('Call doctors fetched: ${value.length}');
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
