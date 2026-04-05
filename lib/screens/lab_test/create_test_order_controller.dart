import 'package:get/get.dart';
import 'package:kivicare_patient/api/lab_test_apis.dart';
import 'package:kivicare_patient/models/lab_test_model.dart';
import 'package:kivicare_patient/models/test_order_model.dart';
import 'package:kivicare_patient/utils/app_common.dart';
import 'package:kivicare_patient/utils/common_base.dart';
import 'package:kivicare_patient/utils/form_validators.dart';

class CreateTestOrderController extends GetxController {
  // Reactive variables
  final RxList<LabTest> selectedTests = RxList<LabTest>([]);
  final RxString clinicalNotes = RxString('');
  final RxString priority = RxString('routine');
  final RxBool isLoading = false.obs;
  final RxDouble discountAmount = RxDouble(0.0);
  final RxDouble totalAmount = RxDouble(0.0);
  final RxDouble finalAmount = RxDouble(0.0);
  final Rx<String?> errorMessage = Rx<String?>(null);
  final Rx<TestOrder?> createdOrder = Rx<TestOrder?>(null);

  /// Add test to selection
  void addTest(LabTest test) {
    if (!selectedTests.any((t) => t.id == test.id)) {
      selectedTests.add(test);
      calculateOrderTotal();
    }
  }

  /// Remove test from selection
  void removeTest(int testId) {
    selectedTests.removeWhere((t) => t.id == testId);
    calculateOrderTotal();
  }

  /// Check if test is selected
  bool isTestSelected(int testId) {
    return selectedTests.any((t) => t.id == testId);
  }

  /// Set clinical notes
  void setClinicalNotes(String notes) {
    clinicalNotes.value = notes;
  }

  /// Set priority level
  void setPriority(String newPriority) {
    priority.value = newPriority;
  }

  /// Calculate order total, discount, and final amount
  Future<void> calculateOrderTotal() async {
    double total = 0.0;
    
    for (final test in selectedTests) {
      total += test.defaultPrice;
    }
    
    totalAmount.value = total;
    
    // Apply discount logic (if any)
    // For now, no automatic discount
    discountAmount.value = 0.0;
    
    finalAmount.value = totalAmount.value - discountAmount.value;
  }

  /// Validate order form before submission
  String? validateOrderForm() {
    // Validate test selection
    final testValidation = FormValidators.validateTestSelection(
      selectedTests.isNotEmpty ? selectedTests : null,
    );
    if (testValidation != null) return testValidation;

    // Validate clinical notes
    final notesValidation = FormValidators.validateClinicalNotes(
      clinicalNotes.value.isEmpty ? null : clinicalNotes.value,
    );
    if (notesValidation != null) return notesValidation;

    // Validate priority
    final priorityValidation = FormValidators.validatePriority(priority.value);
    if (priorityValidation != null) return priorityValidation;

    return null; // All validations passed
  }

  /// Create test order via API
  Future<void> createOrder() async {
    // Validate form first
    final validationError = validateOrderForm();
    if (validationError != null) {
      errorMessage.value = validationError;
      toast(validationError);
      return;
    }

    try {
      isLoading(true);
      errorMessage(null);

      // Build request body
      final Map<String, dynamic> request = {
        'items': selectedTests.map((test) => {'lab_test_id': test.id}).toList(),
        'clinical_notes': clinicalNotes.value.isEmpty ? null : clinicalNotes.value,
        'priority': priority.value,
        'patient_id': loginUserData.value.id,
        // 'doctor_id': null, // Optional
      };

      final response = await LabTestAPIs.createTestOrder(request: request);

      if (response.status ?? false) {
        // Parse created order from response
        final orderData = response.data as Map<String, dynamic>?;
        if (orderData != null) {
          createdOrder.value = TestOrder.fromJson(orderData);
          
          // Show success message
          final orderNumber = createdOrder.value?.orderNumber ?? 'N/A';
          toast('Order created: $orderNumber');
          
          // Navigate to confirmation screen
          _navigateToConfirmation();
        } else {
          errorMessage.value = 'Failed to parse order response';
        }
      } else {
        // Handle API error
        errorMessage.value = response.message ?? 'Failed to create order';
        
        // Check for validation errors (422)
        if (response.statusCode == 422) {
          _handleValidationErrors(response);
        } else {
          toast(errorMessage.value ?? 'Error creating order');
        }
      }
    } catch (e) {
      errorMessage.value = e.toString();
      appPrint('Error creating order: $e');
      toast('Error: ${e.toString()}');
    } finally {
      isLoading(false);
    }
  }

  /// Handle 422 validation errors from API
  void _handleValidationErrors(dynamic response) {
    // Extract field-specific errors if available
    final errors = response.errors as Map<String, dynamic>?;
    if (errors != null) {
      final errorMessages = errors.entries.map((e) => '${e.key}: ${e.value.join(', ')}').toList();
      errorMessage.value = errorMessages.join('\n');
    }
  }

  /// Navigate to confirmation screen
  void _navigateToConfirmation() {
    // TODO: Navigate to CreateTestOrderConfirmationScreen with createdOrder
    // Get.to(() => CreateTestOrderConfirmationScreen(
    //   testOrder: createdOrder.value,
    // ));
  }

  /// Reset form for new order
  void resetForm() {
    selectedTests.clear();
    clinicalNotes.value = '';
    priority.value = 'routine';
    discountAmount.value = 0.0;
    totalAmount.value = 0.0;
    finalAmount.value = 0.0;
    errorMessage.value = null;
    createdOrder.value = null;
  }

  /// Get selected test count
  int get selectedTestCount => selectedTests.length;

  /// Check if order is ready
  bool get isOrderReady => selectedTests.isNotEmpty;

  /// Check if there's an error
  bool get hasError => errorMessage.value != null;
}
