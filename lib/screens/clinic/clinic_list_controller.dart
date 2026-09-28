import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:stream_transform/stream_transform.dart';
import 'package:kivicare_patient/api/core_apis.dart';
import '../service/model/service_list_model.dart';
import 'model/clinic_detail_model.dart';
import 'model/clinics_res_model.dart';

class ClinicListController extends GetxController {
  Rx<Future<RxList<Clinic>>> clinicsFuture = Future(() => RxList<Clinic>()).obs;
  RxBool isLoading = false.obs;
  RxList<Clinic> clinics = RxList();
  RxBool isLastPage = false.obs;
  RxInt page = 1.obs;
  Rx<ServiceElement> service = ServiceElement().obs;
  Rx<Clinic> selectedClinic = Clinic(clinicSession: ClinicSession()).obs;

  ///Search
  TextEditingController searchClinicCont = TextEditingController();
  RxBool isSearchClinicText = false.obs;
  StreamController<String> searchClinicStream = StreamController<String>();
  final _scrollController = ScrollController();
  RxBool isSearchText = false.obs;
  RxInt isPopular = (-1).obs;
  RxString serviceType = "".obs;
  RxString priceMin = ''.obs;
  RxString priceMax = ''.obs;
  RxInt clinicId = (-1).obs;
  final Rxn<int> governorateId = Rxn<int>();
  final Rxn<int> cityId = Rxn<int>();

  int get activeFilterCount {
    var count = 0;
    if (service.value.id > 0) count++;
    if (priceMin.value.isNotEmpty || priceMax.value.isNotEmpty) count++;
    if (governorateId.value != null) count++;
    if (cityId.value != null) count++;
    return count;
  }

  @override
  void onInit() {
    _scrollController.addListener(
        () => Get.context != null ? hideKeyboard(Get.context) : null);
    searchClinicStream.stream.debounce(const Duration(seconds: 1)).listen((s) {
      getClinicList();
    });
    if (Get.arguments is ServiceElement) {
      service(Get.arguments);
    } else if (Get.arguments is Map) {
      // Filters are applied before the single initial request below.
    } else if (Get.arguments is int) {
      clinicId(Get.arguments as int);
    }
    getClinicList();
    super.onInit();
  }

  Future<void> getClinicList({bool showLoader = true}) async {
    if (showLoader) {
      isLoading(true);
    }
    await clinicsFuture(
      CoreServiceApis.getClinics(
        page: page.value,
        clinics: clinics,
        serviceId: service.value.id,
        search: searchClinicCont.text.trim(),
        servicePriceMin: priceMin.value,
        servicePriceMax: priceMax.value,
        clinicId: clinicId.value,
        isPopulars: isPopular.value,
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
      log("getClinics error $e");
    }).whenComplete(() => isLoading(false));
  }

  @override
  void onClose() {
    searchClinicStream.close();
    searchClinicCont.dispose();
    _scrollController.dispose();
    super.onClose();
  }
}
