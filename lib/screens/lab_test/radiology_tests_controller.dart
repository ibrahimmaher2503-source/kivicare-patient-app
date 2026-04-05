import 'package:get/get.dart';
import 'package:kivicare_patient/screens/lab_test/lab_test_list_controller.dart';
import 'package:kivicare_patient/utils/lab_test_constants.dart';

/// Controller for browsing radiology services (imaging tests)
/// Extends LabTestListController with pre-filtered department="radiology"
class RadiologyTestsController extends LabTestListController {
  @override
  void onInit() {
    // Set department filter to radiology from the start
    filter.value = filter.value.copyWith(department: Department.radiology);
    super.onInit();
  }

  @override
  Future<void> loadTests({bool showLoader = true}) async {
    // Ensure department is always set to radiology
    filter.value = filter.value.copyWith(department: Department.radiology);
    await super.loadTests(showLoader: showLoader);
  }

  @override
  void filterByDepartment(String? department) {
    // Override to always use radiology
    filter.value = filter.value.copyWith(department: Department.radiology);
    resetPagination();
    loadTests();
  }

  @override
  void searchTests(String query) {
    // Search with radiology department filter
    filter.value = filter.value.copyWith(
      searchQuery: query,
      department: Department.radiology,
    );
    resetPagination();
    loadTests();
  }

  @override
  void resetFilters() {
    // Reset filters but keep radiology department
    filter.value = filter.value.copyWith(
      searchQuery: null,
      categoryId: null,
      department: Department.radiology,
      currentPage: 1,
    );
    loadTests();
  }
}
