import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../api/core_apis.dart';
import '../../screens/clinic/model/clinics_res_model.dart';

class ClinicSearchController extends GetxController {
  Rx<Future<RxList<Clinic>>> clinicsFuture = Future.value(RxList<Clinic>()).obs;
  RxList<Clinic> clinics = RxList<Clinic>();
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
    debounce(searchQuery, (_) { page(1); getClinics(); }, time: const Duration(milliseconds: 500));
    getClinics();
  }

  Future<void> getClinics({bool showLoader = true}) async {
    if (showLoader) isLoading(true);
    await clinicsFuture(CoreServiceApis.searchClinics(
      page: page.value, perPage: 15, clinicList: clinics,
      name: searchCont.text.trim(),
      governorateId: selectedGovernorateId.value,
      cityId: selectedCityId.value,
      lastPageCallBack: (isLast) => isLastPage(isLast),
    )).then((v) {}).catchError((e) { toast(e.toString()); }).whenComplete(() => isLoading(false));
  }

  void onGovernorateChanged(int? id) { selectedGovernorateId.value = id; selectedCityId.value = null; page(1); getClinics(); }
  void onCityChanged(int? id) { selectedCityId.value = id; page(1); getClinics(); }
  void onSearchChanged(String val) { searchQuery.value = val; }

  @override void onClose() { searchCont.dispose(); super.onClose(); }
}
