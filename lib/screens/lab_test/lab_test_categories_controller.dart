import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import '../../api/core_apis.dart';
import 'package:kivicare_patient/screens/lab_test/model/lab_test_category_model.dart';

/// Controller for Lab Test Categories Browsing
/// Manages loading and displaying available test categories
class LabTestCategoriesController extends GetxController {
  // Reactive variables
  final RxBool isLoading = false.obs;
  final RxList<LabTestCategory> categories = RxList<LabTestCategory>([]);
  final Rx<String?> errorMessage = Rx<String?>(null);

  @override
  void onInit() {
    super.onInit();
    loadCategories();
  }

  /// Load all lab test categories from API
  Future<void> loadCategories() async {
    try {
      isLoading(true);
      errorMessage(null);

      final loadedCategories = await CoreServiceApis.getLabTestCategories();
      categories.value = loadedCategories;
    } catch (e) {
      errorMessage.value = e.toString();
      debugPrint('Error loading categories: $e');
    } finally {
      isLoading(false);
    }
  }

  /// Refresh categories (pull to refresh)
  Future<void> refreshCategories() async {
    await loadCategories();
  }

  /// Get category by ID
  LabTestCategory? getCategoryById(int categoryId) {
    try {
      return categories.firstWhere((cat) => cat.id == categoryId);
    } catch (e) {
      return null;
    }
  }

  /// Retry loading if error occurred
  Future<void> retry() async {
    await loadCategories();
  }

  /// Check if categories are loaded
  bool get hasCategoriesLoaded => categories.isNotEmpty;

  /// Check if there's an error
  bool get hasError => errorMessage.value != null;
}
