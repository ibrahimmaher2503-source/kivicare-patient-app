import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../api/core_apis.dart';
import '../../main.dart';
import '../../screens/nurse/model/nurse_model.dart';

class NurseSearchController extends GetxController {
  Rx<Future<RxList<Nurse>>> nursesFuture = Future.value(RxList<Nurse>()).obs;
  RxList<Nurse> nurses = RxList<Nurse>();
  RxBool isLoading = false.obs;
  RxBool isLastPage = false.obs;
  RxInt page = 1.obs;

  TextEditingController searchCont = TextEditingController();
  RxString searchQuery = ''.obs;
  RxnInt selectedGovernorateId = RxnInt();
  RxnInt selectedCityId = RxnInt();
  RxString selectedAvailability = ''.obs;
  RxString selectedGender = ''.obs;

  List<Map<String, String>> get availabilityFilters => [
    {'key': '', 'label': locale.value.all},
    {'key': 'available', 'label': locale.value.nurseAvailable},
    {'key': 'busy', 'label': locale.value.nurseBusy},
    {'key': 'off_duty', 'label': locale.value.nurseOffDuty},
  ];

  List<Map<String, String>> get genderFilters => [
    {'key': '', 'label': locale.value.all},
    {'key': 'male', 'label': locale.value.male},
    {'key': 'female', 'label': locale.value.female},
  ];

  @override
  void onInit() {
    super.onInit();
    debounce(searchQuery, (_) { page(1); getNurses(); }, time: const Duration(milliseconds: 500));
    getNurses();
  }

  Future<void> getNurses({bool showLoader = true}) async {
    if (showLoader) isLoading(true);
    await nursesFuture(CoreServiceApis.searchNurses(
      page: page.value, perPage: 15, nurseList: nurses,
      search: searchCont.text.trim(),
      governorateId: selectedGovernorateId.value,
      cityId: selectedCityId.value,
      gender: selectedGender.value,
      availability: selectedAvailability.value,
      lastPageCallBack: (isLast) => isLastPage(isLast),
    )).then((v) {}).catchError((e) { toast(e.toString()); }).whenComplete(() => isLoading(false));
  }

  void onGovernorateChanged(int? id) { selectedGovernorateId.value = id; selectedCityId.value = null; page(1); getNurses(); }
  void onCityChanged(int? id) { selectedCityId.value = id; page(1); getNurses(); }
  void onSearchChanged(String val) { searchQuery.value = val; }
  void onAvailabilityChanged(String val) { selectedAvailability.value = val; page(1); getNurses(); }
  void onGenderChanged(String val) { selectedGender.value = val; page(1); getNurses(); }

  @override void onClose() { searchCont.dispose(); super.onClose(); }
}
