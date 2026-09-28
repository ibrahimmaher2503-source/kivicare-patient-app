import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:stream_transform/stream_transform.dart';
import 'package:kivicare_patient/api/core_apis.dart';

import '../../utils/app_common.dart';
import '../service/model/service_list_model.dart';
import 'model/doctor_list_res.dart';

class DoctorListController extends GetxController {
  Rx<Future<RxList<Doctor>>> doctorsFuture = Future(() => RxList<Doctor>()).obs;
  RxBool isLoading = false.obs;
  RxList<Doctor> doctors = RxList();
  RxBool isLastPage = false.obs;
  RxInt page = 1.obs;
  Rx<Doctor> selectedDoctor = Doctor().obs;
  RxInt clinicId = (-1).obs;

  ///Search
  TextEditingController searchDoctorCont = TextEditingController();
  RxBool isSearchDoctorText = false.obs;
  StreamController<String> searchDoctorStream = StreamController<String>();
  final _scrollController = ScrollController();
  RxInt isPopular = (-1).obs;

  ///Service Filter
  RxString serviceType = "".obs;
  RxString ratingMin = ''.obs;
  RxString ratingMax = ''.obs;
  final Rxn<int> governorateId = Rxn<int>();
  final Rxn<int> cityId = Rxn<int>();
  @override
  void onInit() {
    _scrollController.addListener(
        () => Get.context != null ? hideKeyboard(Get.context) : null);
    searchDoctorStream.stream.debounce(const Duration(seconds: 1)).listen((s) {
      getDoctors();
    });
    if (Get.arguments is int) {
      clinicId(Get.arguments as int);
      getDoctors();
    } else if (Get.arguments is ServiceElement) {
      currentSelectedService(Get.arguments as ServiceElement);
      getDoctors();
    } else {
      getDoctors();
    }
    super.onInit();
  }

  Future<void> getDoctors({bool showLoader = true}) async {
    if (showLoader) {
      isLoading(true);
    }
    await doctorsFuture(
      CoreServiceApis.getDoctors(
        isPopulars: isPopular.value,
        page: page.value,
        doctorRatingMin: ratingMin.value,
        doctorRatingMax: ratingMax.value,
        doctors: doctors,
        serviceId: currentSelectedService.value.id == -1
            ? null
            : currentSelectedService.value.id,
        clinicId: clinicId.value,
        search: searchDoctorCont.text.trim(),
        governorateId: governorateId.value,
        cityId: cityId.value,
        lastPageCallBack: (p0) {
          isLastPage(p0);
        },
      ),
    ).then((value) {
      log('value.length ==> ${value.length}');
    }).catchError((e) {
      isLoading(false);
      log("getDoctors error $e");
    }).whenComplete(() => isLoading(false));
  }

  @override
  void onClose() {
    searchDoctorStream.close();
    searchDoctorCont.dispose();
    _scrollController.dispose();
    super.onClose();
  }
}
