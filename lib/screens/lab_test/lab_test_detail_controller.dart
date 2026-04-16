import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';
import '../../api/core_apis.dart';
import 'package:kivicare_patient/screens/lab_test/model/lab_test_model.dart';

/// Controller for Lab Test Detail Screen
/// Manages loading and displaying individual test information
class LabTestDetailController extends GetxController {
  final int testId;

  // Reactive variables
  final Rx<LabTest?> selectedTest = Rx<LabTest?>(null);
  final RxBool isLoading = false.obs;
  final Rx<String?> errorMessage = Rx<String?>(null);

  LabTestDetailController({required this.testId});

  @override
  void onInit() {
    super.onInit();
    loadTestDetail();
  }

  /// Load test detail from API
  Future<void> loadTestDetail() async {
    try {
      isLoading(true);
      errorMessage(null);

      final test = await CoreServiceApis.getLabTestDetail(testId: testId);
      selectedTest.value = test;
    } catch (e) {
      errorMessage.value = e.toString();
      debugPrint('Error loading test detail: $e');
    } finally {
      isLoading(false);
    }
  }

  /// Add test to cart (for future order flow)
  void addToCart() {
    if (selectedTest.value == null) {
      toast('Test not loaded');
      return;
    }

    // TODO: Implement cart functionality
    toast('Added to cart');
  }

  /// Navigate to order creation with this test
  void navigateToOrder() {
    if (selectedTest.value == null) {
      toast('Test not loaded');
      return;
    }

    // TODO: Navigate to create test order screen with pre-selected test
  }

  /// Retry loading if error occurred
  Future<void> retry() async {
    await loadTestDetail();
  }

  /// Check if test is loaded
  bool get hasTestLoaded => selectedTest.value != null;

  /// Check if there's an error
  bool get hasError => errorMessage.value != null;
}
