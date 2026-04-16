import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';
import '../../api/core_apis.dart';
import 'package:kivicare_patient/screens/lab_test/model/lab_test_model.dart';
import 'package:kivicare_patient/screens/lab_test/lab_test_categories_controller.dart';
import 'package:kivicare_patient/screens/lab_test/model/lab_test_filter.dart';

/// Controller for Lab Test List Browsing with Filtering
/// Extends LabTestCategoriesController to add filtering and pagination
class LabTestListController extends LabTestCategoriesController {
  // Reactive variables for filtering
  final Rx<LabTestFilter> filter = LabTestFilter.empty.obs;
  final RxList<LabTest> tests = RxList<LabTest>([]);
  final RxBool isLoadingTests = false.obs;
  final Rx<String?> testErrorMessage = Rx<String?>(null);

  // Pagination state
  final RxBool isLastPage = false.obs;
  final RxBool hasMorePages = true.obs;

  @override
  void onInit() {
    super.onInit();
    // Don't auto-load tests, wait for user to select category or search
  }

  /// Load tests with current filters
  Future<void> loadTests() async {
    try {
      isLoadingTests(true);
      testErrorMessage(null);

      final bool isFirstPage = filter.value.currentPage == 1;
      if (isFirstPage) tests.clear();

      bool reachedLastPage = false;
      await CoreServiceApis.getLabTestList(
        page: filter.value.currentPage,
        perPage: filter.value.perPage,
        labTestList: tests,
        categoryId: filter.value.categoryId,
        department: filter.value.department ?? '',
        search: filter.value.searchQuery ?? '',
        lastPageCallBack: (lastPage) {
          reachedLastPage = lastPage;
        },
      );

      isLastPage.value = reachedLastPage;
      hasMorePages.value = !reachedLastPage;
    } catch (e) {
      testErrorMessage.value = e.toString();
      debugPrint('Error loading tests: $e');
    } finally {
      isLoadingTests(false);
    }
  }

  /// Set category filter and reload tests
  Future<void> filterByCategory(int? categoryId) async {
    filter.value = filter.value.copyWith(categoryId: categoryId).resetPagination();
    await loadTests();
  }

  /// Set department filter and reload tests
  Future<void> filterByDepartment(String? department) async {
    filter.value = filter.value.copyWith(department: department).resetPagination();
    await loadTests();
  }

  /// Search tests by query and reload
  Future<void> searchTests(String query) async {
    filter.value = filter.value.copyWith(searchQuery: query.isEmpty ? null : query).resetPagination();
    await loadTests();
  }

  /// Clear all filters and reload
  Future<void> clearFilters() async {
    filter.value = LabTestFilter.empty;
    tests.clear();
  }

  /// Load next page of tests
  Future<void> loadMoreTests() async {
    if (isLastPage.value || isLoadingTests.value) return;
    filter.value = filter.value.nextPage();
    await loadTests();
  }

  /// Reset pagination
  void resetPagination() {
    filter.value = filter.value.resetPagination();
  }

  /// Reset filters but keep department
  void resetFilters() {
    filter.value = LabTestFilter(
      department: filter.value.department,
      currentPage: 1,
    );
    loadTests();
  }

  /// Get test by ID
  LabTest? getTestById(int testId) {
    try {
      return tests.firstWhere((test) => test.id == testId);
    } catch (e) {
      return null;
    }
  }

  /// Check if tests are loaded
  bool get hasTestsLoaded => tests.isNotEmpty;

  /// Check if there's a test error
  bool get hasTestError => testErrorMessage.value != null;

  /// Get active filter count
  int get activeFilterCount {
    int count = 0;
    if (filter.value.categoryId != null) count++;
    if (filter.value.department != null) count++;
    if (filter.value.searchQuery != null) count++;
    return count;
  }

  /// Retry loading tests if error occurred
  Future<void> retryLoadTests() async {
    await loadTests();
  }
}
