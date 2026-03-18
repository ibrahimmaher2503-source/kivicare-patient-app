import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../api/core_apis.dart';
import '../../main.dart';
import '../../utils/constants.dart';
import 'model/nurse_request_model.dart';

class NurseRequestListController extends GetxController {
  // List state
  Rx<Future<RxList<NurseRequest>>> nurseRequestFuture = Future(() => RxList<NurseRequest>()).obs;
  RxList<NurseRequest> nurseRequests = RxList<NurseRequest>();
  RxBool isLoading = false.obs;
  RxBool isLastPage = false.obs;
  RxInt page = 1.obs;

  // Search
  TextEditingController searchCont = TextEditingController();

  // Filter tabs
  RxString selectedStatus = ''.obs;
  RxList<Map<String, String>> statusFilters = RxList();

  @override
  void onInit() {
    statusFilters = [
      {'key': '', 'label': locale.value.all},
      {'key': NurseRequestStatusConst.pending, 'label': locale.value.nurseRequestPending},
      {'key': NurseRequestStatusConst.confirmed, 'label': locale.value.nurseRequestConfirmed},
      {'key': NurseRequestStatusConst.inProgress, 'label': locale.value.nurseRequestInProgress},
      {'key': NurseRequestStatusConst.completed, 'label': locale.value.nurseRequestCompleted},
      {'key': NurseRequestStatusConst.cancelled, 'label': locale.value.cancel},
    ].obs;

    getNurseRequests();
    super.onInit();
  }

  @override
  void dispose() {
    searchCont.dispose();
    super.dispose();
  }

  Future<void> getNurseRequests({bool showLoader = true}) async {
    if (showLoader) {
      isLoading(true);
    }

    await nurseRequestFuture(
      CoreServiceApis.getNurseRequestList(
        page: page.value,
        perPage: 15,
        requestList: nurseRequests,
        status: selectedStatus.value,
        search: searchCont.text.trim(),
        lastPageCallBack: (isLast) => isLastPage(isLast),
      ),
    ).then((value) {
      log('Nurse requests fetched: ${value.length}');
    }).catchError((e) {
      log("getNurseRequests error $e");
    }).whenComplete(() => isLoading(false));
  }

  void onFilterChanged(String status) {
    selectedStatus(status);
    page(1);
    getNurseRequests();
  }
}
