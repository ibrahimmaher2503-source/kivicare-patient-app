import 'package:get/get.dart';
import 'package:kivicare_patient/models/facility_booking_model.dart';
import 'package:kivicare_patient/models/lab_model.dart';
import 'package:kivicare_patient/models/radiology_center_model.dart';
import 'package:kivicare_patient/utils/app_common.dart';
import 'package:kivicare_patient/utils/lab_test_constants.dart';
import 'package:kivicare_patient/utils/rbac_utils.dart';

class FacilityBookingController extends GetxController {
  final RxString facilityType = RxString(FacilityType.lab);
  final Rx<int?> selectedFacilityId = Rx<int?>(null);
  final Rx<String?> selectedDate = Rx<String?>(null);
  final Rx<String?> selectedTime = Rx<String?>(null);
  
  final RxList<Lab> labs = RxList<Lab>([]);
  final RxList<RadiologyCenter> radiologyCenters = RxList<RadiologyCenter>([]);
  
  final RxBool isLoadingFacilities = false.obs;
  final Rx<String?> errorMessage = Rx<String?>(null);

  void setFacilityType(String type) {
    facilityType.value = type;
    selectedFacilityId.value = null;
  }

  void selectFacility(int facilityId) {
    selectedFacilityId.value = facilityId;
  }

  void selectDate(String date) {
    selectedDate.value = date;
  }

  void selectTime(String time) {
    selectedTime.value = time;
  }

  bool get isFacilitySelected => selectedFacilityId.value != null;
  bool get isDateSelected => selectedDate.value != null;
  bool get isTimeSelected => selectedTime.value != null;
  bool get isAllSelected => isFacilitySelected && isDateSelected && isTimeSelected;

  void reset() {
    facilityType.value = FacilityType.lab;
    selectedFacilityId.value = null;
    selectedDate.value = null;
    selectedTime.value = null;
  }

  /// Check if current user has role
  bool hasRole(String role) {
    return loginUserData.value.userRole.contains(role);
  }

  /// Get user's role for filtering
  String? getUserRole() {
    if (hasRole('admin')) return 'admin';
    if (hasRole('user')) return 'user';
    return null;
  }

  /// Check if user can view booking (RBAC check)
  bool canViewBooking(FacilityBooking booking) {
    final userRole = getUserRole();
    if (userRole == 'admin') {
      RBACUtils.logAccessAttempt('Booking#${booking.id}', true, null);
      return true;
    }

    // Patients can only view their own bookings
    if (userRole == 'user') {
      final canAccess = booking.patientPhone == loginUserData.value.mobile;
      RBACUtils.logAccessAttempt(
        'Booking#${booking.id}',
        canAccess,
        canAccess ? null : 'Patient#${loginUserData.value.mobile} cannot access Booking for ${booking.patientPhone}',
      );
      return canAccess;
    }

    RBACUtils.logAccessAttempt('Booking#${booking.id}', false, 'Invalid role: $userRole');
    return false;
  }

  /// Check if user can cancel booking
  bool canCancelBooking(FacilityBooking booking) {
    if (!hasRole('user') && !hasRole('admin')) {
      RBACUtils.logAccessAttempt(
        'Booking#${booking.id}:cancel',
        false,
        'User does not have required role',
      );
      return false;
    }

    // Only pending and confirmed bookings can be cancelled
    if (booking.status != 'pending' && booking.status != 'confirmed') {
      RBACUtils.logAccessAttempt(
        'Booking#${booking.id}:cancel',
        false,
        'Booking status is ${booking.status}, cannot cancel',
      );
      return false;
    }

    // Patient can cancel own bookings, admin can cancel any
    if (hasRole('admin')) {
      RBACUtils.logAccessAttempt('Booking#${booking.id}:cancel', true, null);
      return true;
    }
    if (hasRole('user')) {
      final canAccess = booking.patientPhone == loginUserData.value.mobile;
      RBACUtils.logAccessAttempt(
        'Booking#${booking.id}:cancel',
        canAccess,
        canAccess ? null : 'Patient#${loginUserData.value.mobile} cannot cancel Booking for ${booking.patientPhone}',
      );
      return canAccess;
    }

    return false;
  }
}
