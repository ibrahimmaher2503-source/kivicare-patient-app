import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';
import '../../../api/labs_radiology_apis.dart';
import '../models/booking_payload.dart';
import '../models/facility_model.dart';
import '../models/lab_test_model.dart';
import '../models/slot_model.dart';
import '../slot_selection/components/slot_conflict_dialog.dart';
import 'booking_success_screen.dart'; // Will be created next

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
    isLoading.value = true;

    final payload = BookingPayload(
      facilityType: facility.type,
      facilityId: facility.id,
      labTestId: test.id,
      slotId: selectedSlot.id,
      preferredDate: selectedDate,
      preferredTime: selectedSlot.startTime,
      patientNotes: notesController.text.trim(),
    );

    try {
      final order = await LabsRadiologyApis.createTestOrder(payload);
      Get.off(() => BookingSuccessScreen(order: order));
    } catch (e) {
      if (e.toString().contains('409') ||
          e.toString().contains('slot_conflict')) {
        _handleSlotConflict();
      } else {
        toast(e.toString());
      }
    } finally {
      isLoading.value = false;
    }
  }

  void _handleSlotConflict() async {
    final retry = await Get.dialog<bool>(const SlotConflictDialog());
    if (retry == true) {
      Get.back(); // Back to slot selection
    }
  }
}
