import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';
import '../../api/core_apis.dart';
import 'package:kivicare_patient/models/booking_slot_model.dart';

class FacilitySlotsController extends GetxController {
  final int facilityId;
  final String facilityType;

  final RxList<BookingSlot> slots = RxList<BookingSlot>([]);
  final RxBool isLoading = false.obs;
  final Rx<String?> errorMessage = Rx<String?>(null);
  final Rx<DateTime?> selectedDate = Rx<DateTime?>(null);

  FacilitySlotsController({
    required this.facilityId,
    required this.facilityType,
  });

  void setSelectedDate(DateTime date) {
    selectedDate.value = date;
  }

  Future<void> loadSlots(DateTime date) async {
    try {
      isLoading(true);
      errorMessage(null);
      selectedDate.value = date;

      final dateStr = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

      final result = facilityType == 'lab'
          ? await CoreServiceApis.getLabSlots(labId: facilityId, date: dateStr)
          : await CoreServiceApis.getRadiologyCenterSlots(centerId: facilityId, date: dateStr);

      slots.value = result;
    } catch (e) {
      errorMessage.value = e.toString();
      debugPrint('Error loading slots: $e');
    } finally {
      isLoading(false);
    }
  }

  List<BookingSlot> getAvailableSlots() {
    return slots.where((slot) => slot.available).toList();
  }

  List<BookingSlot> getBookedSlots() {
    return slots.where((slot) => !slot.available).toList();
  }

  bool isSlotAvailable(String time) {
    return slots.any((slot) => slot.time == time && slot.available);
  }

  Future<void> retry(DateTime date) async {
    await loadSlots(date);
  }

  bool get hasSlots => slots.isNotEmpty;
  bool get hasAvailableSlots => getAvailableSlots().isNotEmpty;
}
