import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';
import '../../../api/labs_radiology_apis.dart';
import '../../../main.dart';
import '../../../utils/common_base.dart';
import '../../../components/operation_verification_screen.dart';
import '../../../network/critical_operation.dart';
import '../../../network/network_utils.dart';
import '../models/booking_payload.dart';
import '../models/facility_model.dart';
import '../models/lab_test_model.dart';
import '../models/slot_model.dart';
import '../slot_selection/components/slot_conflict_dialog.dart';
import 'booking_success_screen.dart'; // Will be created next
import '../orders/test_orders_list_screen.dart';

class BookingConfirmationController extends GetxController {
  final FacilityModel facility;
  final LabTestModel test;
  final DateTime selectedDate;
  final SlotModel selectedSlot;

  var isLoading = false.obs;
  var notesController = TextEditingController();

  BookingConfirmationController({
    required this.facility,
    required this.test,
    required this.selectedDate,
    required this.selectedSlot,
  });

  Future<void> confirmBooking() async {
    if (isLoading.value) return;
    if (!await requireAuthenticated()) return;

    final payload = BookingPayload(
      facilityType: facility.type,
      facilityId: facility.id,
      labTestId: test.id,
      slotId: selectedSlot.id,
      preferredDate: selectedDate,
      preferredTime: selectedSlot.startTime,
      patientNotes: notesController.text.trim(),
    );
    final validationError = payload.validate();
    if (validationError != null) {
      toast(_validationMessage(validationError));
      return;
    }

    isLoading.value = true;
    String? operationKey;

    try {
      operationKey = await CriticalOperationStore.begin(
        CriticalOperationType.testOrder,
        requestFingerprint: criticalOperationFingerprint(payload.toJson()),
      );
      final order = await LabsRadiologyApis.createTestOrder(
        payload,
        idempotencyKey: operationKey,
      );
      await CriticalOperationStore.complete(CriticalOperationType.testOrder);
      Get.off(() => BookingSuccessScreen(order: order));
    } on AmbiguousRequestOutcomeException {
      Get.off(
        () => OperationVerificationScreen(
          recordsScreen: _testOrdersScreen,
          operationType: CriticalOperationType.testOrder,
          operationKey: operationKey,
        ),
      );
    } on PendingCriticalOperationException {
      Get.off(
        () => OperationVerificationScreen(
          recordsScreen: _testOrdersScreen,
          operationType: CriticalOperationType.testOrder,
          operationKey: operationKey ??
              CriticalOperationStore.pendingKey(
                  CriticalOperationType.testOrder),
        ),
      );
    } catch (e) {
      await CriticalOperationStore.complete(CriticalOperationType.testOrder);
      if (e.toString().contains('409') ||
          e.toString().contains('slot_conflict')) {
        _handleSlotConflict();
      } else {
        toast(sanitizeBackendMessage(
            e, locale.value.somethingWentWrongPleaseTryAgainLater));
      }
    } finally {
      isLoading.value = false;
    }
  }

  static Widget _testOrdersScreen() => const TestOrdersListScreen();

  String _validationMessage(String error) {
    switch (error) {
      case 'lab_test_required':
        return locale.value.labTestRequired;
      case 'preferred_date_past':
        return locale.value.preferredDatePast;
      case 'preferred_time_invalid':
        return locale.value.preferredTimeInvalid;
      case 'patient_notes_too_long':
        return locale.value.patientNotesTooLong;
      default:
        return locale.value.somethingWentWrongPleaseTryAgainLater;
    }
  }

  void _handleSlotConflict() async {
    final retry = await Get.dialog<bool>(const SlotConflictDialog());
    if (retry == true) {
      Get.back(); // Back to slot selection
    }
  }

  @override
  void onClose() {
    notesController.dispose();
    super.onClose();
  }
}
