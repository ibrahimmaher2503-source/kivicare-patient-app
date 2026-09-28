import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:kivicare_patient/api/core_apis.dart';
import '../category/model/category_list_model.dart';
import '../home/model/system_service_res.dart';
import 'model/service_list_model.dart';

class ServiceListController extends GetxController {
  Rx<Future<RxList<ServiceElement>>> serviceListFuture =
      Future(() => RxList<ServiceElement>()).obs;
  RxBool isLoading = false.obs;
  RxList<ServiceElement> serviceList = RxList();
  RxBool isLastPage = false.obs;
  RxInt page = 1.obs;
  Rx<CategoryElement> category = CategoryElement().obs;
  Rx<ServiceElement> serviceData = ServiceElement().obs;
  Rx<SystemService> systemServiceData = SystemService().obs;
  RxInt clinicId = (-1).obs;
  RxInt categoryId = (-1).obs;
  RxInt isPopular = (-1).obs;

  ///Service Filter
  RxString serviceType = "".obs;
  RxString priceMin = ''.obs;
  RxString priceMax = ''.obs;
  final Rxn<int> governorateId = Rxn<int>();
  final Rxn<int> cityId = Rxn<int>();

  int get activeFilterCount {
    var count = 0;
    if (clinicId.value > 0) count++;
    if (category.value.id > 0) count++;
    if (priceMin.value.isNotEmpty || priceMax.value.isNotEmpty) count++;
    if (governorateId.value != null) count++;
    if (cityId.value != null) count++;
    return count;
  }

  ///Search
  TextEditingController searchCont = TextEditingController();
  RxBool isSearchText = false.obs;
  StreamController<String> searchStream = StreamController<String>();
  final scrollController = ScrollController();

  @override
  void onInit() {
    if (Get.arguments is CategoryElement) {
      category(Get.arguments);
      getServiceList();
    } else if (Get.arguments is SystemService) {
      systemServiceData(Get.arguments);
      getServiceList();
    } else if (Get.arguments is ServiceElement) {
      serviceData(Get.arguments);
      getServiceList();
    } else if (Get.arguments is int) {
      clinicId(Get.arguments as int);
      log('clinicId==== $clinicId');
      getServiceList();
    } else if (Get.arguments is Map) {
      getServiceList();
    }
    // getServiceList();
    super.onInit();
  }

  Future<void> getServiceList({bool showLoader = true}) async {
    if (showLoader) {
      isLoading(true);
    }
    await serviceListFuture(
      CoreServiceApis.getServiceList(
        page: page.value,
        serviceList: serviceList,
        categoryId: category.value.id,
        systemServiceId: systemServiceData.value.id,
        isFeatures: serviceData.value.featured,
        clinicId: clinicId.value,
        search: searchCont.text.trim(),
        serviceType: serviceType.value.trim(),
        servicePriceMin: priceMin.value,
        servicePriceMax: priceMax.value,
        isPopulars: isPopular.value,
        governorateId: governorateId.value,
        cityId: cityId.value,
        lastPageCallBack: (p0) {
          isLastPage(p0);
        },
      ),
    ).catchError((e, stackTrace) {
      isLoading(false);
      log('ServiceList getServiceList err ==> $e');
      Error.throwWithStackTrace(e, stackTrace);
    }).whenComplete(() => isLoading(false));
  }

  @override
  void onClose() {
    searchStream.close();
    page(1);
    searchCont.dispose();
    scrollController.dispose();
    super.onClose();
  }
}
