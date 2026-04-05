import 'package:get/get.dart';
import 'package:kivicare_patient/api/lab_test_apis.dart';
import 'package:kivicare_patient/models/lab_test_model.dart';
import 'package:kivicare_patient/screens/lab_test/lab_test_categories_controller.dart';
import 'package:kivicare_patient/screens/lab_test/model/lab_test_filter.dart';
import 'package:kivicare_patient/utils/app_common.dart';

/// Controller for Lab Test List Browsing with Filtering
/// Extends LabTestCategoriesController to add filtering and pagination
class LabTestListController extends LabTestCategoriesController {
  // Reactive variables for filtering
  final Rx<LabTestFilter> filter = LabTestFilter.empty.obs;
  final RxList<LabTest> tests = RxList<LabTest>([]);
  final RxBool isLoadingTests = false.obs;
  final Rx<String?> testErrorMessage = Rx<String?>(null);
  
  // Pagination state
  final RxInt totalTests = 0.obs;
  final RxInt totalPages = 0.obs;
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

      final response = await LabTestAPIs.getLabTests(
        categoryId: filter.value.categoryId?.toString(),
        department: filter.value.department,
        search: filter.value.searchQuery,
        page: filter.value.currentPage,
      );

      if (response.status ?? false) {
        // Parse tests from response
        final List<dynamic> data = response.data ?? [];
        final loadedTests = data
            .map((json) => LabTest.fromJson(json as Map<String, dynamic>))
            .toList();

        // Handle pagination
        final meta = response.meta as Map<String, dynamic>?;
        if (meta != null) {
          totalTests.value = meta['total'] ?? 0;
          totalPages.value = meta['last_page'] ?? 1;
          hasMorePages.value = filter.value.currentPage < (meta['last_page'] ?? 1);
        }

        // Append or replace tests based on pagination
        if (filter.value.currentPage == 1) {
          tests.value = loadedTests;
        } else {
          tests.addAll(loadedTests);
        }
      } else {
        testErrorMessage.value = response.message ?? 'Failed to load tests';
      }
    } catch (e) {
      testErrorMessage.value = e.toString();
      appPrint('Error loading tests: $e');
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
  Future<void> loadNextPage() async {
    if (!hasMorePages.value || isLoadingTests.value) return;
    
    filter.value = filter.value.nextPage();
    await loadTests();
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
