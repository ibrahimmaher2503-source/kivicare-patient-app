import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../api/core_apis.dart';
import '../../../utils/app_common.dart';
import '../../../utils/common_base.dart';
import '../../../utils/constants.dart';
import '../../call_booking/book_call_screen.dart';
import '../../call_booking/model/call_doctor_model.dart';
import '../../call_booking/model/time_slot_model.dart';
import '../../doctor/model/doctor_list_res.dart';
import '../../doctor/model/unified_doctor_model.dart';
import '../../independent_booking/book_independent_screen.dart';
import '../../independent_booking/model/independent_doctor_model.dart';
import '../../slots/booking_form_screen.dart';

/// Controller for the doctor-first QuickBook widget on the home screen.
/// Five-step flow: search doctor → select booking type → select date →
/// select slot → book.
class DoctorQuickBookController extends GetxController {
  final TextEditingController searchCont = TextEditingController();

  // Step 1 — doctor search results
  final RxList<UnifiedDoctor> doctorResults = <UnifiedDoctor>[].obs;
  final RxBool isSearching = false.obs;

  // Selected state (each step depends on the previous)
  final Rx<UnifiedDoctor?> selectedDoctor = Rx<UnifiedDoctor?>(null);
  final Rx<BookingCapability?> selectedCapability = Rx<BookingCapability?>(null);
  final Rx<DateTime?> selectedDate = Rx<DateTime?>(null);
  final Rx<TimeSlot?> selectedSlot = Rx<TimeSlot?>(null);
  final RxList<TimeSlot> slots = <TimeSlot>[].obs;
  final RxBool isLoadingSlots = false.obs;

  final RxString _searchQuery = ''.obs;
  final List<Doctor> _rawDoctorList = [];

  @override
  void onInit() {
    super.onInit();
    // Debounce triggers search 500 ms after typing stops
    debounce(_searchQuery, (_) => _performSearch(),
        time: const Duration(milliseconds: 500));
  }

  @override
  void onClose() {
    searchCont.dispose();
    super.onClose();
  }

  // ── Step 1: search ──────────────────────────────────────────────────────────

  void onSearchChanged(String query) {
    _searchQuery(query);
    if (query.isEmpty) doctorResults.clear();
  }

  Future<void> _performSearch() async {
    final query = _searchQuery.value.trim();
    if (query.isEmpty) {
      doctorResults.clear();
      return;
    }
    isSearching(true);
    _rawDoctorList.clear();
    try {
      await CoreServiceApis.searchDoctors(
        name: query,
        doctorList: _rawDoctorList,
        perPage: 10,
      );
      doctorResults.assignAll(_rawDoctorList.map(UnifiedDoctor.fromDoctor));
    } catch (e) {
      log('DoctorQuickBookController search error: $e');
    }
    isSearching(false);
  }

  void onDoctorSelected(UnifiedDoctor doctor) {
    selectedDoctor.value = doctor;
    // Reset downstream state
    selectedCapability.value = null;
    selectedDate.value = null;
    selectedSlot.value = null;
    slots.clear();
  }

  // ── Step 2: booking type ────────────────────────────────────────────────────

  void onCapabilitySelected(BookingCapability cap) {
    selectedCapability.value = cap;
    selectedDate.value = null;
    selectedSlot.value = null;
    slots.clear();
  }

  // ── Step 3: date selection ─────────────────────────────────────────────────

  void onDateSelected(DateTime date) {
    selectedDate.value = date;
    selectedSlot.value = null;
    _loadSlots(date);
  }

  Future<void> _loadSlots(DateTime date) async {
    final cap = selectedCapability.value;
    final doctor = selectedDoctor.value;
    if (cap == null || doctor == null) return;
    if (cap.type == BookingType.clinic) return; // BookingFormScreen handles slots

    isLoadingSlots(true);
    slots.clear();

    final dateStr = DateFormat(DateFormatConst.yyyy_MM_dd).format(date);

    try {
      if (cap.type == BookingType.videoCall || cap.type == BookingType.phoneCall) {
        final service = cap.services.isNotEmpty ? cap.services.first : null;
        if (service != null) {
          final result = await CoreServiceApis.getCallSlots(
            doctorId: doctor.doctorId,
            request: {'date': dateStr, 'call_service_id': service.id},
          );
          slots.addAll(result);
        }
      } else if (cap.type == BookingType.inPerson) {
        final service = cap.services.isNotEmpty ? cap.services.first : null;
        if (service != null) {
          final result = await CoreServiceApis.getIndependentSlots(
            doctorId: doctor.doctorId,
            request: {'date': dateStr, 'independent_service_id': service.id},
          );
          slots.addAll(result);
        }
      }
    } catch (e) {
      log('DoctorQuickBookController loadSlots error: $e');
    }

    isLoadingSlots(false);
  }

  // ── Step 4: slot selection ─────────────────────────────────────────────────

  void onSlotSelected(TimeSlot slot) {
    selectedSlot.value = slot;
  }

  // ── Step 5: book ───────────────────────────────────────────────────────────

  bool get canBook {
    final cap = selectedCapability.value;
    if (cap == null || selectedDoctor.value == null) return false;
    if (cap.type == BookingType.clinic) return true;
    return selectedDate.value != null && selectedSlot.value != null;
  }

  void navigateToBooking() {
    doIfLoggedIn(() {
      final doctor = selectedDoctor.value;
      final cap = selectedCapability.value;
      if (doctor == null || cap == null) return;

      switch (cap.type) {
        case BookingType.clinic:
          currentSelectedDoctor.value = doctor.toDoctor();
          Get.to(() => BookingFormScreen());
          break;
        case BookingType.videoCall:
        case BookingType.phoneCall:
          final raw = cap.services.isNotEmpty ? cap.services.first.rawService : null;
          if (raw is CallService) {
            Get.to(() => BookCallScreen(
                  doctor: doctor.toCallDoctor(),
                  service: raw,
                ));
          }
          break;
        case BookingType.inPerson:
          final raw = cap.services.isNotEmpty ? cap.services.first.rawService : null;
          if (raw is IndependentService) {
            Get.to(() => BookIndependentScreen(
                  doctor: doctor.toIndependentDoctor(),
                  service: raw,
                ));
          }
          break;
      }
    });
  }

  /// Resets all state back to step 1.
  void reset() {
    searchCont.clear();
    _searchQuery('');
    doctorResults.clear();
    selectedDoctor.value = null;
    selectedCapability.value = null;
    selectedDate.value = null;
    selectedSlot.value = null;
    slots.clear();
  }
}
