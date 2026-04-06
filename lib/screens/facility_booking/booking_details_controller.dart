import 'package:get/get.dart';
import '../../api/core_apis.dart';
import 'package:kivicare_patient/models/facility_booking_model.dart';
import 'package:kivicare_patient/screens/facility_booking/booking_confirmation_screen.dart';
import 'package:kivicare_patient/utils/app_common.dart';
import 'package:kivicare_patient/utils/common_base.dart';
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

      final response = await CoreServiceApis.createFacilityBooking(request: request);

      if (response.status ?? false) {
        final bookingData = response.data as Map<String, dynamic>?;
        if (bookingData != null) {
          createdBooking.value = FacilityBooking.fromJson(bookingData);
          toast('Booking confirmed: ${createdBooking.value?.bookingNumber ?? "N/A"}');
          _navigateToConfirmation();
        } else {
          errorMessage.value = 'Failed to parse booking response';
        }
      } else {
        errorMessage.value = response.message ?? 'Failed to create booking';
        
        if (response.statusCode == 422) {
          _handleValidationErrors(response);
        }
        
        toast(errorMessage.value);
      }
    } catch (e) {
      errorMessage.value = e.toString();
      appPrint('Error creating booking: $e');
      toast('Error: ${e.toString()}');
    } finally {
      isLoading(false);
    }
  }

  void _handleValidationErrors(dynamic response) {
    final errors = response.errors as Map<String, dynamic>?;
    if (errors != null) {
      final errorMessages = errors.entries.map((e) => '${e.key}: ${e.value.join(', ')}').toList();
      errorMessage.value = errorMessages.join('\n');
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
