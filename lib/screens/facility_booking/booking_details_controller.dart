import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';
import '../../api/core_apis.dart';
import 'package:kivicare_patient/models/facility_booking_model.dart';
import 'package:kivicare_patient/screens/facility_booking/booking_confirmation_screen.dart';
import 'package:kivicare_patient/utils/form_validators.dart';

class BookingDetailsController extends GetxController {
  final String facilityType;
  final int facilityId;
  final String selectedDate;
  final String selectedTime;

  final RxString patientName = RxString('');
  final RxString patientPhone = RxString('');
  final RxString notes = RxString('');
  final RxBool isLoading = false.obs;
  final Rx<String?> errorMessage = Rx<String?>(null);
  final Rx<FacilityBooking?> createdBooking = Rx<FacilityBooking?>(null);

  BookingDetailsController({
    required this.facilityType,
    required this.facilityId,
    required this.selectedDate,
    required this.selectedTime,
  });

  void setPatientName(String name) {
    patientName.value = name;
  }

  void setPatientPhone(String phone) {
    patientPhone.value = phone;
  }

  void setNotes(String value) {
    notes.value = value;
  }

  String? validateBookingForm() {
    final nameValidation = FormValidators.validatePatientName(patientName.value);
    if (nameValidation != null) return nameValidation;

    final phoneValidation = FormValidators.validatePhoneNumber(patientPhone.value);
    if (phoneValidation != null) return phoneValidation;

    if (!_hasSlotSelected()) {
      return 'Please select a time slot';
    }

    return null;
  }

  bool _hasSlotSelected() {
    return selectedTime.isNotEmpty;
  }

  Future<void> createBooking() async {
    final validationError = validateBookingForm();
    if (validationError != null) {
      errorMessage.value = validationError;
      toast(validationError);
      return;
    }

    try {
      isLoading(true);
      errorMessage(null);

      final Map<String, dynamic> request = {
        'type': facilityType,
        if (facilityType == 'lab') 'lab_id': facilityId,
        if (facilityType == 'radiology') 'radiology_center_id': facilityId,
        'booking_date': selectedDate,
        'booking_time': selectedTime,
        'patient_name': patientName.value,
        'patient_phone': patientPhone.value,
        if (notes.value.isNotEmpty) 'notes': notes.value,
      };

      createdBooking.value = await CoreServiceApis.createFacilityBooking(request: request);
      toast('Booking confirmed: ${createdBooking.value?.bookingNumber ?? "N/A"}');
      _navigateToConfirmation();
    } catch (e) {
      errorMessage.value = e.toString();
      debugPrint('Error creating booking: $e');
      toast('Error: ${e.toString()}');
    } finally {
      isLoading(false);
    }
  }

  void _navigateToConfirmation() {
    if (createdBooking.value != null) {
      Get.to(() => BookingConfirmationScreen(booking: createdBooking.value!));
    }
  }

  void reset() {
    patientName.value = '';
    patientPhone.value = '';
    notes.value = '';
    errorMessage.value = null;
    createdBooking.value = null;
  }

  bool get hasError => errorMessage.value != null;
  bool get isBookingCreated => createdBooking.value != null;
}
