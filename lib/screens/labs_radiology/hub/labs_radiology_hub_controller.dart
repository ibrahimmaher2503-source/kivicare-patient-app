import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';
import '../../../api/labs_radiology_apis.dart';
import '../models/facility_model.dart';
import '../models/facility_type.dart';

class LabsRadiologyHubController extends GetxController {
  var isLoading = false.obs;
  var facilityType = FacilityType.lab.obs;

  var labs = <FacilityModel>[].obs;
  var radiologyCenters = <FacilityModel>[].obs;

  var searchQuery = ''.obs;
  var selectedGovernorateId = RxnInt();
  var selectedCityId = RxnInt();
  var selectedGovernorateName = RxnString();
  var selectedCityName = RxnString();

  @override
  void onInit() {
    super.onInit();
    // Load last used facility type from GetStorage if available (R-9)
    String? lastType = getStringAsync('labs_radiology.last_facility_type');
    if (lastType.isNotEmpty) {
      facilityType.value = FacilityType.fromString(lastType);
    }

    fetchData();
  }

  Future<void> fetchData({bool showLoader = true}) async {
    if (showLoader) isLoading.value = true;

    try {
      if (facilityType.value == FacilityType.lab) {
        final res = await LabsRadiologyApis.searchLabs(
          search: searchQuery.value,
          governorateId: selectedGovernorateId.value,
          cityId: selectedCityId.value,
        );
        labs.assignAll(res.data);
      } else {
        final res = await LabsRadiologyApis.searchRadiology(
          search: searchQuery.value,
          governorateId: selectedGovernorateId.value,
          cityId: selectedCityId.value,
        );
        radiologyCenters.assignAll(res.data);
      }
    } catch (e, st) {
      // ignore: avoid_print
      print('[HubController] fetchData ERROR: $e\n$st');
      toast(e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  void switchType(FacilityType type) {
    if (facilityType.value == type) return;
    facilityType.value = type;
    setValue('labs_radiology.last_facility_type', type.apiValue);
    fetchData();
  }

  void updateSearch(String query) {
    searchQuery.value = query;
    fetchData();
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
}
