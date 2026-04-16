import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../api/core_apis.dart';
import '../../screens/doctor/model/doctor_list_res.dart';

class DoctorSearchController extends GetxController {
  Rx<Future<RxList<Doctor>>> doctorsFuture = Future.value(RxList<Doctor>()).obs;
  RxList<Doctor> doctors = RxList<Doctor>();
  RxBool isLoading = false.obs;
  RxBool isLastPage = false.obs;
  RxInt page = 1.obs;

  TextEditingController searchCont = TextEditingController();
  RxString searchQuery = ''.obs;

  RxnInt selectedGovernorateId = RxnInt();
  RxnInt selectedCityId = RxnInt();
  RxString selectedGender = ''.obs;
  RxnInt selectedSpecialtyId = RxnInt();
  Rxn<double> minPrice = Rxn<double>();
  Rxn<double> maxPrice = Rxn<double>();

  @override
  void onInit() {
    super.onInit();
    debounce(searchQuery, (_) {
      page(1);
      getDoctors();
    }, time: const Duration(milliseconds: 500));
    getDoctors();
  }

  Future<void> getDoctors({bool showLoader = true}) async {
    if (showLoader) isLoading(true);

    await doctorsFuture(
      CoreServiceApis.searchDoctors(
        page: page.value,
        perPage: 15,
        doctorList: doctors,
        name: searchCont.text.trim(),
        governorateId: selectedGovernorateId.value,
        cityId: selectedCityId.value,
        gender: selectedGender.value,
        specialtyId: selectedSpecialtyId.value,
        minPrice: minPrice.value,
        maxPrice: maxPrice.value,
        lastPageCallBack: (isLast) => isLastPage(isLast),
      ),
    ).then((value) {
      log('Doctors fetched: ${value.length}');
    }).catchError((e) {
      log('getDoctors error: $e');
      toast(e.toString());
    }).whenComplete(() => isLoading(false));
  }

  void onGovernorateChanged(int? id) {
    selectedGovernorateId.value = id;
    selectedCityId.value = null;
    page(1);
    getDoctors();
  }

  void onCityChanged(int? id) {
    selectedCityId.value = id;
    page(1);
    getDoctors();
  }

  void onSearchChanged(String val) {
    searchQuery.value = val;
  }

  void onGenderChanged(String val) {
    selectedGender.value = val;
    page(1);
    getDoctors();
  }

  void onSpecialtyChanged(int? id) {
    selectedSpecialtyId.value = id;
    page(1);
    getDoctors();
  }

  void onPriceChanged({double? min, double? max}) {
    minPrice.value = min;
    maxPrice.value = max;
    page(1);
    getDoctors();
  }

  @override
  void onClose() {
    searchCont.dispose();
    super.onClose();
  }
}
