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
  RxString searchQuery = ''.obs;

  // Filter
  RxString selectedAvailability = ''.obs;
  RxList<Map<String, String>> availabilityFilters = RxList();
  RxnInt selectedGovernorateId = RxnInt();
  RxnInt selectedCityId = RxnInt();

  @override
  void onInit() {
    availabilityFilters = [
      {'key': '', 'label': locale.value.all},
      {'key': NurseAvailabilityConst.available, 'label': locale.value.nurseAvailable},
      {'key': NurseAvailabilityConst.busy, 'label': locale.value.nurseBusy},
      {'key': NurseAvailabilityConst.offDuty, 'label': locale.value.nurseOffDuty},
    ].obs;

    getNurses();
    debounce(searchQuery, (_) {
      page(1);
      getNurses();
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

  Future<void> getNurses({bool showLoader = true}) async {
    if (showLoader) {
      isLoading(true);
    }

    await nurseFuture(
      CoreServiceApis.searchNurses(
        page: page.value,
        perPage: Constants.perPageItem,
        nurseList: nurses,
        search: searchCont.text.trim(),
        availability: selectedAvailability.value,
        governorateId: selectedGovernorateId.value,
        cityId: selectedCityId.value,
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

  void onGovernorateChanged(int? id) {
    selectedGovernorateId.value = id;
    selectedCityId.value = null;
    page(1);
    getNurses();
  }

  void onCityChanged(int? id) {
    selectedCityId.value = id;
    page(1);
    getNurses();
  }
}
