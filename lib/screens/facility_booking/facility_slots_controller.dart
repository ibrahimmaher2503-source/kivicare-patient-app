import 'package:get/get.dart';
import '../../api/core_apis.dart';
import 'package:kivicare_patient/models/booking_slot_model.dart';
import 'package:kivicare_patient/utils/app_common.dart';

class FacilitySlotCalendarController extends GetxController {
  final int facilityId;
  final String facilityType;

  final RxList<BookingSlot> slots = RxList<BookingSlot>([]);
  final RxBool isLoadingSlots = false.obs;
  final Rx<String?> errorMessage = Rx<String?>(null);
  final Rx<String?> selectedDate = Rx<String?>(null);

  FacilitySlotCalendarController({
    required this.facilityId,
    required this.facilityType,
  });

  Future<void> loadSlots(String date) async {
    try {
      isLoadingSlots(true);
      errorMessage(null);
      selectedDate.value = date;

      final response = facilityType == 'lab'
          ? await CoreServiceApis.getLabSlots(labId: facilityId, date: date)
          : await CoreServiceApis.getRadiologyCenterSlots(centerId: facilityId, date: date);

      if (response.status ?? false) {
        final slotsData = response.data?['slots'] as List?;
        if (slotsData != null) {
          slots.value = slotsData.map((slot) => BookingSlot.fromJson(slot as Map<String, dynamic>)).toList();
        } else {
          slots.value = [];
        }
      } else {
        errorMessage.value = response.message ?? 'Failed to load slots';
      }
    } catch (e) {
      errorMessage.value = e.toString();
      appPrint('Error loading slots: $e');
    } finally {
      isLoadingSlots(false);
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

  Future<void> retry(String date) async {
    await loadSlots(date);
  }

  bool get hasSlots => slots.isNotEmpty;
  bool get hasAvailableSlots => getAvailableSlots().isNotEmpty;
}
