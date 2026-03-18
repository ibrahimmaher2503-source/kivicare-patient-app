import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../api/core_apis.dart';
import '../../main.dart';
import '../../utils/constants.dart';
import 'model/request_service_model.dart';

class RequestServiceListController extends GetxController {
  // List state
  Rx<Future<RxList<RequestService>>> serviceFuture = Future(() => RxList<RequestService>()).obs;
  RxList<RequestService> services = RxList<RequestService>();
  RxBool isLoading = false.obs;
  RxBool isLastPage = false.obs;
  RxInt page = 1.obs;

  // Search
  TextEditingController searchCont = TextEditingController();
  RxString searchQuery = ''.obs;

  // Filter
  RxString selectedStatus = ''.obs;
  RxList<Map<String, String>> statusFilters = RxList();

  @override
  void onInit() {
    statusFilters = [
      {'key': '', 'label': locale.value.all},
      {'key': ServiceRequestStatusConst.pending, 'label': locale.value.serviceStatusPending},
      {'key': ServiceRequestStatusConst.accept, 'label': locale.value.serviceStatusAccepted},
      {'key': ServiceRequestStatusConst.reject, 'label': locale.value.serviceStatusRejected},
    ].obs;

    getServiceRequests();
    debounce(searchQuery, (_) => getServiceRequests(), time: const Duration(milliseconds: 500));
    super.onInit();
  }

  void onSearchChanged(String val) {
    page(1);
    searchQuery.value = val;
  }

  @override
  void dispose() {
    searchCont.dispose();
    super.dispose();
  }

  Future<void> getServiceRequests({bool showLoader = true}) async {
    if (showLoader) {
      isLoading(true);
    }

    await serviceFuture(
      CoreServiceApis.getRequestServiceList(
        page: page.value,
        perPage: 15,
        serviceList: services,
        search: searchCont.text.trim(),
        isStatus: selectedStatus.value,
        lastPageCallBack: (isLast) => isLastPage(isLast),
      ),
    ).then((value) {
      log('Services fetched: ${value.length}');
    }).catchError((e) {
      log("getServiceRequests error $e");
    }).whenComplete(() => isLoading(false));
  }

  void onFilterChanged(String status) {
    selectedStatus(status);
    page(1);
    getServiceRequests();
  }
}
