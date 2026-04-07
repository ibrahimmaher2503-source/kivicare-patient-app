import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import '../../api/core_apis.dart';
import 'package:kivicare_patient/models/facility_booking_model.dart';
import 'package:kivicare_patient/utils/rbac_utils.dart';
import 'package:nb_utils/nb_utils.dart';

/// Controller for viewing a single facility booking detail
class BookingDetailController extends GetxController {
  final int bookingId;

  final Rx<FacilityBooking?> booking = Rx<FacilityBooking?>(null);
  final RxBool isLoading = false.obs;
  final Rx<String?> errorMessage = Rx<String?>(null);

  BookingDetailController({required this.bookingId});

  @override
  void onInit() {
    super.onInit();
    loadBookingDetail();
  }

  /// Load booking detail from API
  Future<void> loadBookingDetail() async {
    try {
      isLoading(true);
      errorMessage(null);

      final result = await CoreServiceApis.getFacilityBookingDetail(
        bookingId: bookingId,
      );
      booking.value = result;
      debugPrint('Booking detail loaded: ${booking.value?.bookingNumber}');
    } catch (e) {
      errorMessage.value = e.toString();
      debugPrint('Error loading booking detail: $e');
    } finally {
      isLoading(false);
    }
  }

  /// Cancel the booking with reason
  Future<void> cancelBooking(int id, {String? reason}) async {
    try {
      isLoading(true);
      errorMessage(null);

      final request = <String, dynamic>{
        if (reason != null) 'reason': reason,
      };

      final response = await CoreServiceApis.cancelFacilityBooking(
        bookingId: id,
        request: request,
      );

      if (response.status) {
        toast('Booking cancelled successfully');
        RBACUtils.logAccessAttempt('Booking#$id:cancel', true, null);
        Get.back();
      } else {
        errorMessage.value = response.message.isNotEmpty ? response.message : 'Failed to cancel booking';
        toast(errorMessage.value ?? '');
      }
    } catch (e) {
      errorMessage.value = e.toString();
      debugPrint('Error cancelling booking: $e');
      toast('Error: ${e.toString()}');
    } finally {
      isLoading(false);
    }
  }

  /// Retry loading booking detail
  Future<void> retry() async {
    await loadBookingDetail();
  }

  bool get hasBookingLoaded => booking.value != null;
  bool get hasError => errorMessage.value != null;
}
