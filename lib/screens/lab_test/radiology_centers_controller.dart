import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../api/core_apis.dart';
import '../../main.dart';
import '../../utils/constants.dart';
import '../radiology/model/radiology_center_model.dart';

class RadiologyCentersController extends GetxController {
  Rx<Future<RxList<RadiologyCenter>>> centersFuture = Future(() => RxList<RadiologyCenter>()).obs;
  RxList<RadiologyCenter> centers = RxList<RadiologyCenter>();
  RxBool isLoading = false.obs;
  RxBool isLastPage = false.obs;
  RxInt page = 1.obs;

  TextEditingController searchCont = TextEditingController();
  RxString searchQuery = ''.obs;

  RxString selectedScanType = ''.obs;
  RxnInt selectedGovernorateId = RxnInt();
  RxnInt selectedCityId = RxnInt();

  RxList<Map<String, String>> scanTypeFilters = RxList();

  @override
  void onInit() {
    scanTypeFilters = [
      {'key': '', 'label': locale.value.all},
      {'key': ScanTypeConst.mri, 'label': locale.value.mriScan},
      {'key': ScanTypeConst.ct, 'label': locale.value.ctScan},
      {'key': ScanTypeConst.xray, 'label': locale.value.xRay},
      {'key': ScanTypeConst.ultrasound, 'label': locale.value.ultrasound},
    ].obs;

    getCenters();
    debounce(searchQuery, (_) {
      page(1);
      getCenters();
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

  Future<void> getCenters({bool showLoader = true}) async {
    if (showLoader) isLoading(true);

    await centersFuture(
      CoreServiceApis.searchRadiologyCenters(
        page: page.value,
        perPage: 15,
        centerList: centers,
        scanType: selectedScanType.value,
        governorateId: selectedGovernorateId.value,
        cityId: selectedCityId.value,
        lastPageCallBack: (isLast) => isLastPage(isLast),
      ),
    ).then((value) {
      log('Radiology centers fetched: ${value.length}');
    }).catchError((e) {
      log("getCenters error $e");
      toast(locale.value.somethingWentWrong);
    }).whenComplete(() => isLoading(false));
  }

  void onScanTypeChanged(String scanType) {
    selectedScanType(scanType);
    page(1);
    getCenters();
  }

  void onGovernorateChanged(int? id) {
    selectedGovernorateId.value = id;
    selectedCityId.value = null;
    page(1);
    getCenters();
  }

  void onCityChanged(int? id) {
    selectedCityId.value = id;
    page(1);
    getCenters();
  }
}
