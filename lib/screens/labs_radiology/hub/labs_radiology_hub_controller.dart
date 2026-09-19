import 'dart:async';

import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';
import '../../../main.dart';
import '../../../network/network_utils.dart';
import '../../../api/labs_radiology_apis.dart';
import '../models/facility_model.dart';
import '../models/facility_type.dart';

class LabsRadiologyHubController extends GetxController {
  final int? initialLabTestId;

  LabsRadiologyHubController({this.initialLabTestId});

  var isLoading = false.obs;
  var isLoadingMore = false.obs;
  var facilityType = FacilityType.lab.obs;

  var labs = <FacilityModel>[].obs;
  var radiologyCenters = <FacilityModel>[].obs;

  var searchQuery = ''.obs;
  var selectedGovernorateId = RxnInt();
  var selectedCityId = RxnInt();
  var selectedGovernorateName = RxnString();
  var selectedCityName = RxnString();
  var errorMessage = ''.obs;

  Timer? _searchDebounce;
  int _page = 1;
  bool _hasMore = true;
  int _requestGeneration = 0;

  @override
  void onInit() {
    super.onInit();
    if (initialLabTestId == null) {
      // Load last used facility type from GetStorage if available (R-9).
      final lastType = getStringAsync('labs_radiology.last_facility_type');
      if (lastType.isNotEmpty) {
        facilityType.value = FacilityType.fromString(lastType);
      }
    } else {
      facilityType.value = FacilityType.lab;
    }

    fetchData();
  }

  Future<void> fetchData({bool showLoader = true, bool reset = true}) async {
    if (!reset && (isLoading.value || isLoadingMore.value || !_hasMore)) return;

    final requestedType = facilityType.value;
    final requestedPage = reset ? 1 : _page + 1;
    final generation = reset ? ++_requestGeneration : _requestGeneration;

    if (reset) {
      _page = 1;
      _hasMore = true;
      errorMessage.value = '';
      if (showLoader) isLoading.value = true;
    } else {
      isLoadingMore.value = true;
    }

    try {
      if (requestedType == FacilityType.lab) {
        final res = await LabsRadiologyApis.searchLabs(
          page: requestedPage,
          search: searchQuery.value,
          governorateId: selectedGovernorateId.value,
          cityId: selectedCityId.value,
          labTestId: initialLabTestId,
        );
        if (generation != _requestGeneration ||
            facilityType.value != requestedType) {
          return;
        }
        if (reset) {
          labs.assignAll(res.data);
        } else {
          labs.addAll(res.data);
        }
        _page = res.currentPage;
        _hasMore = res.hasMore;
      } else {
        final res = await LabsRadiologyApis.searchRadiology(
          page: requestedPage,
          search: searchQuery.value,
          governorateId: selectedGovernorateId.value,
          cityId: selectedCityId.value,
        );
        if (generation != _requestGeneration ||
            facilityType.value != requestedType) {
          return;
        }
        if (reset) {
          radiologyCenters.assignAll(res.data);
        } else {
          radiologyCenters.addAll(res.data);
        }
        _page = res.currentPage;
        _hasMore = res.hasMore;
      }
    } catch (e) {
      if (generation == _requestGeneration) {
        final message =
            sanitizeBackendMessage(e, locale.value.somethingWentWrong);
        errorMessage.value = message;
        toast(message);
      }
    } finally {
      if (generation == _requestGeneration) {
        isLoading.value = false;
        isLoadingMore.value = false;
      }
    }
  }

  Future<void> loadMore() => fetchData(showLoader: false, reset: false);

  void switchType(FacilityType type) {
    if (initialLabTestId != null) return;
    if (facilityType.value == type) return;
    facilityType.value = type;
    setValue('labs_radiology.last_facility_type', type.apiValue);
    fetchData();
  }

  void updateSearch(String query) {
    searchQuery.value = query;
    _searchDebounce?.cancel();
    _searchDebounce = Timer(
      const Duration(milliseconds: 350),
      () => fetchData(),
    );
  }

  void updateLocation(
      {int? governorateId,
      int? cityId,
      String? governorateName,
      String? cityName}) {
    selectedGovernorateId.value = governorateId;
    selectedCityId.value = cityId;
    selectedGovernorateName.value = governorateName;
    selectedCityName.value = cityName;
    fetchData();
  }

  @override
  void onClose() {
    _searchDebounce?.cancel();
    super.onClose();
  }
}
