import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../api/core_apis.dart';
import '../../main.dart';
import '../../utils/constants.dart';
import 'model/nurse_model.dart';

class NurseListController extends GetxController {
  // List state
  Rx<Future<RxList<Nurse>>> nurseFuture = Future(() => RxList<Nurse>()).obs;
  RxList<Nurse> nurses = RxList<Nurse>();
  RxBool isLoading = false.obs;
  RxBool isLastPage = false.obs;
  RxInt page = 1.obs;

  // Search
  TextEditingController searchCont = TextEditingController();

  // Filter
  RxString selectedAvailability = ''.obs;
  RxList<Map<String, String>> availabilityFilters = RxList();

  @override
  void onInit() {
    availabilityFilters = [
      {'key': '', 'label': locale.value.all},
      {'key': NurseAvailabilityConst.available, 'label': locale.value.nurseAvailable},
      {'key': NurseAvailabilityConst.busy, 'label': locale.value.nurseBusy},
      {'key': NurseAvailabilityConst.offDuty, 'label': locale.value.nurseOffDuty},
    ].obs;

    getNurses();
    debounce(RxString(''), (_) => getNurses(), time: const Duration(milliseconds: 500));
    super.onInit();
  }

  void onSearchChanged(String val) {
    page(1);
    getNurses();
  }

  @override
  void dispose() {
    searchCont.dispose();
    super.dispose();
  }

  Future<void> getNurses({bool showLoader = true}) async {
    if (showLoader) {
      isLoading(true);
    }

    await nurseFuture(
      CoreServiceApis.getNurseList(
        page: page.value,
        perPage: 15,
        nurseList: nurses,
        search: searchCont.text.trim(),
        availabilityStatus: selectedAvailability.value,
        lastPageCallBack: (isLast) => isLastPage(isLast),
      ),
    ).then((value) {
      log('Nurses fetched: ${value.length}');
    }).catchError((e) {
      log("getNurses error $e");
    }).whenComplete(() => isLoading(false));
  }

  void onFilterChanged(String availability) {
    selectedAvailability(availability);
    page(1);
    getNurses();
  }
}
