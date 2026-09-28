import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';
import '../../../api/icu_apis.dart';
import '../../../main.dart';
import '../../../network/network_utils.dart';
import '../filter/hospital_filter_controller.dart';
import '../models/hospital_model.dart';

class HospitalListController extends GetxController {
  final hospitals = <Hospital>[].obs;
  final isLoading = false.obs;
  final isLoadingMore = false.obs;

  int currentPage = 1;
  int lastPage = 1;

  final searchCont = TextEditingController();
  final searchStream = "".obs;

  late HospitalFilterController filter;

  @override
  void onInit() {
    super.onInit();
    filter = Get.isRegistered<HospitalFilterController>()
        ? Get.find<HospitalFilterController>()
        : Get.put(HospitalFilterController());

    debounce(searchStream, (_) => loadFirstPage(),
        time: const Duration(milliseconds: 400));
    loadFirstPage();
  }

  Future<void> loadFirstPage() async {
    isLoading(true);
    currentPage = 1;
    try {
      final res = await IcuApis.getHospitals(
        page: currentPage,
        search: searchCont.text.trim(),
        governorateId: filter.selectedGovernorateId.value,
        cityId: filter.selectedCityId.value,
        departmentId: filter.selectedDepartmentTypeId.value,
        hasAvailableBeds: filter.hasAvailableBedsOnly.value ? true : null,
      );
      hospitals.assignAll(res.data);
      lastPage = res.lastPage;
    } catch (e) {
      toast(sanitizeBackendMessage(
          e, locale.value.somethingWentWrongPleaseTryAgainLater));
    } finally {
      isLoading(false);
    }
  }

  Future<void> loadNextPage() async {
    if (currentPage >= lastPage || isLoadingMore.value) return;

    isLoadingMore(true);
    currentPage++;
    try {
      final res = await IcuApis.getHospitals(
        page: currentPage,
        search: searchCont.text.trim(),
        governorateId: filter.selectedGovernorateId.value,
        cityId: filter.selectedCityId.value,
        departmentId: filter.selectedDepartmentTypeId.value,
        hasAvailableBeds: filter.hasAvailableBedsOnly.value ? true : null,
      );
      hospitals.addAll(res.data);
      lastPage = res.lastPage;
    } catch (e) {
      toast(sanitizeBackendMessage(
          e, locale.value.somethingWentWrongPleaseTryAgainLater));
      currentPage--;
    } finally {
      isLoadingMore(false);
    }
  }

  Future<void> refreshData() async {
    await loadFirstPage();
  }

  @override
  void onClose() {
    searchCont.dispose();
    super.onClose();
  }
}
