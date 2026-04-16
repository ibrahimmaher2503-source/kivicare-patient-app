import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../api/core_apis.dart';
import '../../main.dart';
import '../../utils/constants.dart';
import 'model/hospital_model.dart';

class HospitalListController extends GetxController {
  // List state
  Rx<Future<RxList<Hospital>>> hospitalFuture = Future(() => RxList<Hospital>()).obs;
  RxList<Hospital> hospitals = RxList<Hospital>();
  RxBool isLoading = false.obs;
  RxBool isLastPage = false.obs;
  RxInt page = 1.obs;

  // Search
  TextEditingController searchCont = TextEditingController();
  RxString searchQuery = ''.obs;

  // Filters
  RxString selectedSpecialty = ''.obs;
  RxString selectedCity = ''.obs;
  RxBool ventilatorFilter = false.obs;

  RxList<Map<String, String>> specialtyFilters = RxList();

  @override
  void onInit() {
    specialtyFilters = [
      {'key': '', 'label': locale.value.all},
      {'key': IcuSpecialtyConst.cardiac, 'label': locale.value.specialtyCardiac},
      {'key': IcuSpecialtyConst.neurology, 'label': locale.value.specialtyNeurology},
      {'key': IcuSpecialtyConst.pediatric, 'label': locale.value.specialtyPediatric},
      {'key': IcuSpecialtyConst.neonatal, 'label': locale.value.specialtyNeonatal},
      {'key': IcuSpecialtyConst.burns, 'label': locale.value.specialtyBurns},
      {'key': IcuSpecialtyConst.chest, 'label': locale.value.specialtyChest},
      {'key': IcuSpecialtyConst.surgical, 'label': locale.value.specialtySurgical},
      {'key': IcuSpecialtyConst.general, 'label': locale.value.specialtyGeneral},
    ].obs;

    getHospitals();
    debounce(searchQuery, (_) {
      page(1);
      getHospitals();
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

  Future<void> getHospitals({bool showLoader = true}) async {
    if (showLoader) {
      isLoading(true);
    }

    await hospitalFuture(
      CoreServiceApis.getHospitalList(
        page: page.value,
        perPage: Constants.perPageItem,
        hospitalList: hospitals,
        search: searchCont.text.trim(),
        specialty: selectedSpecialty.value,
        city: selectedCity.value,
        ventilator: ventilatorFilter.value ? 'true' : '',
        lastPageCallBack: (isLast) => isLastPage(isLast),
      ),
    ).then((value) {
      log('Hospitals fetched: ${value.length}');
    }).catchError((e) {
      log("getHospitals error $e");
    }).whenComplete(() => isLoading(false));
  }

  void onFilterChanged(String specialty) {
    selectedSpecialty(specialty);
    page(1);
    getHospitals();
  }

  void onSearchCleared() {
    searchCont.clear();
    searchQuery('');
    page(1);
    getHospitals();
  }
}
