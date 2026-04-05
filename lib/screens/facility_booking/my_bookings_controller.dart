import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kivicare_patient/models/facility_booking_model.dart';
import 'package:kivicare_patient/api/facility_booking_apis.dart';
import 'package:kivicare_patient/utils/app_common.dart';
import 'package:kivicare_patient/utils/common_base.dart';
import 'package:kivicare_patient/utils/constants.dart';
import 'package:kivicare_patient/utils/rbac_utils.dart';
import 'package:kivicare_patient/screens/lab_test/components/cancellation_reason_dialog.dart';
import 'package:nb_utils/nb_utils.dart';

/// Controller for managing user's bookings with filtering and RBAC
class MyBookingsController extends GetxController {
  final RxList<FacilityBooking> bookings = RxList<FacilityBooking>();
  final RxBool isLoading = false.obs;
  final RxBool isLastPage = false.obs;
  final RxInt page = 1.obs;

  // Filters
  final Rx<String?> selectedType = Rx<String?>(null);
  final Rx<String?> selectedStatus = Rx<String?>(null);

  @override
  void onInit() {
    loadBookings();
    super.onInit();
  }

  /// Load bookings with current filters
  Future<void> loadBookings({bool showLoader = true}) async {
    if (showLoader) {
      isLoading(true);
    }

    try {
      page(1);
      final response = await FacilityBookingAPIs.getFacilityBookings(
        type: selectedType.value,
        status: selectedStatus.value,
        page: 1,
      );

      if (response.status ?? false) {
        final bookingList = response.data as List?;
        if (bookingList != null) {
          // Filter by RBAC
          final filtered = bookingList
              .map((e) => FacilityBooking.fromJson(e as Map<String, dynamic>))
              .where((booking) => canViewBooking(booking))
              .toList();

          bookings.value = filtered;
          isLastPage.value = false;
          appPrint('Bookings loaded: ${filtered.length}');
        }
      } else {
        toast(response.message ?? locale.value.somethingWentWrong);
      }
    } catch (e) {
      appPrint('Error loading bookings: $e');
      toast(locale.value.somethingWentWrong);
    } finally {
      isLoading(false);
    }
  }

  /// Load more bookings (pagination)
  Future<void> loadMoreBookings() async {
    if (isLastPage.value) return;

    try {
      page(page.value + 1);
      final response = await FacilityBookingAPIs.getFacilityBookings(
        type: selectedType.value,
        status: selectedStatus.value,
        page: page.value,
      );

      if (response.status ?? false) {
        final bookingList = response.data as List?;
        if (bookingList != null) {
          if (bookingList.isEmpty) {
            isLastPage(true);
          } else {
            final filtered = bookingList
                .map((e) => FacilityBooking.fromJson(e as Map<String, dynamic>))
                .where((booking) => canViewBooking(booking))
                .toList();

            bookings.addAll(filtered);
          }
        }
      }
    } catch (e) {
      appPrint('Error loading more bookings: $e');
      toast(locale.value.somethingWentWrong);
    }
  }

  /// Filter by facility type (lab/radiology)
  void filterByType(String? type) {
    selectedType.value = type;
    loadBookings();
  }

  /// Filter by booking status
  void filterByStatus(String? status) {
    selectedStatus.value = status;
    loadBookings();
  }

  /// Check if user can view booking (RBAC)
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
        canAccess ? null : 'Patient cannot access others\' bookings',
      );
      return canAccess;
    }

    return false;
  }

  /// Check if user can cancel booking
  bool canCancelBooking(FacilityBooking booking) {
    if (!hasRole('user') && !hasRole('admin')) {
      return false;
    }

    // Only pending and confirmed bookings can be cancelled
    if (booking.status != 'pending' && booking.status != 'confirmed') {
      return false;
    }

    // Patient can cancel own bookings, admin can cancel any
    if (hasRole('admin')) {
      return true;
    }
    if (hasRole('user')) {
      return booking.patientPhone == loginUserData.value.mobile;
    }

    return false;
  }

  /// Cancel booking with reason dialog
  Future<void> cancelBookingWithReason(int bookingId, BuildContext context) async {
    await showCancellationReasonDialog(context, (reason) {
      cancelBooking(bookingId, reason: reason);
    });
  }

  /// Cancel a booking with reason
  Future<void> cancelBooking(int bookingId, {String? reason}) async {
    try {
      isLoading(true);

      final request = {
        if (reason != null) 'reason': reason,
      };

      final response = await FacilityBookingAPIs.cancelFacilityBooking(
        bookingId: bookingId,
        request: request,
      );

      if (response.status ?? false) {
        toast(response.message ?? locale.value.bookingCancelledSuccessfully);
        // Remove from list
        bookings.removeWhere((b) => b.id == bookingId);
        RBACUtils.logAccessAttempt('Booking#$bookingId:cancel', true, null);
      } else {
        toast(response.message ?? locale.value.failedToCancelBooking);
        if (response.statusCode == 403) {
          RBACUtils.handle403Error(response.message);
        }
      }
    } catch (e) {
      appPrint('Error cancelling booking: $e');
      toast(locale.value.somethingWentWrong);
    } finally {
      isLoading(false);
    }
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
}
