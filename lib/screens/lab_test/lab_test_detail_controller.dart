import 'package:get/get.dart';
import '../../api/core_apis.dart';
import 'package:kivicare_patient/models/lab_test_model.dart';
import 'package:kivicare_patient/utils/app_common.dart';
import 'package:kivicare_patient/utils/common_base.dart';

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

      final response = await CoreServiceApis.getLabTestDetail(testId: testId);

      if (response.status ?? false) {
        final testData = response.data as Map<String, dynamic>?;
        if (testData != null) {
          selectedTest.value = LabTest.fromJson(testData);
        } else {
          errorMessage.value = 'Invalid test data';
        }
      } else {
        errorMessage.value = response.message ?? 'Failed to load test details';
      }
    } catch (e) {
      errorMessage.value = e.toString();
      appPrint('Error loading test detail: $e');
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
    // For now, just show a message
    toast('Added to cart', length: Toast.LENGTH_SHORT);
  }

  /// Navigate to order creation with this test
  void navigateToOrder() {
    if (selectedTest.value == null) {
      toast('Test not loaded');
      return;
    }

    // TODO: Navigate to create test order screen with pre-selected test
    // Get.to(() => CreateTestOrderScreen(
    //   preSelectedTests: [selectedTest.value!],
    // ));
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
