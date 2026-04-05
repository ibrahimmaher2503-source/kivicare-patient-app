import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../api/core_apis.dart';
import '../../main.dart';
import '../../utils/constants.dart';
import '../call_booking/model/time_slot_model.dart';
import 'model/independent_doctor_model.dart';
import 'model/independent_booking_model.dart';

class BookIndependentController extends GetxController {
  // Selected doctor & service
  Rx<IndependentDoctor?> selectedDoctor = Rx<IndependentDoctor?>(null);
  Rx<IndependentService?> selectedService = Rx<IndependentService?>(null);

  // Date & slot selection
  Rx<DateTime?> selectedDate = Rx<DateTime?>(null);
  Rx<TimeSlot?> selectedSlot = Rx<TimeSlot?>(null);
  RxList<TimeSlot> availableSlots = RxList<TimeSlot>();

  // Loading states
  RxBool isLoadingSlots = false.obs;
  RxBool isBooking = false.obs;

  // Payment method
  RxString paymentMethod = 'cash'.obs;

  /// Pre-set doctor and service when navigating to the booking screen.
  void initWith(IndependentDoctor doctor, IndependentService service) {
    selectedDoctor(doctor);
    selectedService(service);
  }

  /// Fetches available time slots for the given date.
  /// Clears any previously selected slot.
  Future<void> fetchSlots(DateTime date) async {
    selectedDate(date);
    selectedSlot(null);
    availableSlots.clear();

    final doctor = selectedDoctor.value;
    final service = selectedService.value;
    if (doctor == null || service == null) return;

    isLoadingSlots(true);

    final request = <String, dynamic>{
      'date': DateFormat(DateFormatConst.yyyy_MM_dd).format(date),
      'independent_service_id': service.id,
    };

    await CoreServiceApis.getIndependentSlots(
      doctorId: doctor.doctorId,
      request: request,
    ).then((slots) {
      availableSlots.addAll(slots);
    }).catchError((e) {
      toast(e.toString());
      log("fetchSlots error: $e");
    }).whenComplete(() => isLoadingSlots(false));
  }

  /// Selects a time slot.
  void selectSlot(TimeSlot slot) {
    selectedSlot(slot);
  }

  /// Validates inputs and creates the independent booking.
  /// On success, returns the [IndependentBooking] for confirmation display.
  Future<IndependentBooking?> confirmBooking() async {
    if (isBooking.value) return null;

    if (selectedDate.value == null || selectedSlot.value == null) {
      toast(locale.value.thisFieldIsRequired);
      return null;
    }

    isBooking(true);
    FocusManager.instance.primaryFocus?.unfocus();

    final request = <String, dynamic>{
      'doctor_id': selectedDoctor.value!.doctorId,
      'independent_service_id': selectedService.value!.id,
      'appointment_date': DateFormat(DateFormatConst.yyyy_MM_dd).format(selectedDate.value!),
      'appointment_time': selectedSlot.value!.value,
      'transaction_type': paymentMethod.value,
    };

    try {
      final booking = await CoreServiceApis.createIndependentBooking(request: request);
      isBooking(false);
      return booking;
    } catch (e) {
      isBooking(false);
      toast(e.toString());
      log("confirmBooking error: $e");
      return null;
    }
  }
}
