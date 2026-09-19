import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';
import '../../../api/labs_radiology_apis.dart';
import '../../../main.dart';
import '../../../network/network_utils.dart';
import '../models/facility_model.dart';
import '../models/lab_test_model.dart';

class FacilityDetailController extends GetxController {
  final FacilityModel initialFacility;

  var isLoading = false.obs;
  var facility = Rxn<FacilityModel>();
  var availableTests = <LabTestModel>[].obs;
  var selectedTest = Rxn<LabTestModel>();

  FacilityDetailController({required this.initialFacility});

  @override
  void onInit() {
    super.onInit();
    facility.value = initialFacility;
    fetchFacilityDetails();
  }

  Future<void> fetchFacilityDetails() async {
    isLoading.value = true;
    try {
      // In a real app, there might be a dedicated detail endpoint.
      // For now, we reuse the list search with ID if needed,
      // or assume initialFacility has enough data.
      // We also fetch available tests for this facility.
      final testsRes =
          await LabsRadiologyApis.getLabTests(facilityId: initialFacility.id);
      availableTests.assignAll(testsRes.data);
    } catch (e) {
      toast(sanitizeBackendMessage(e, locale.value.somethingWentWrong));
    } finally {
      isLoading.value = false;
    }
  }

  void selectTest(LabTestModel test) {
    selectedTest.value = test;
  }
}
