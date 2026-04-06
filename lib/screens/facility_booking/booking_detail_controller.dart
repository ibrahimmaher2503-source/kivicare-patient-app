import 'package:get/get.dart';
import '../../api/core_apis.dart';
import 'package:kivicare_patient/models/facility_booking_model.dart';
import 'package:kivicare_patient/utils/app_common.dart';
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

      final response = await CoreServiceApis.getFacilityBookingDetail(
        bookingId: bookingId,
      );

      if (response.status ?? false) {
        final bookingData = response.data as Map<String, dynamic>?;
        if (bookingData != null) {
          booking.value = FacilityBooking.fromJson(bookingData);
          appPrint('Booking detail loaded: ${booking.value?.bookingNumber}');
        } else {
          errorMessage.value = 'Invalid booking data';
        }
      } else {
        errorMessage.value = response.message ?? 'Failed to load booking';
        if (response.statusCode == 403) {
          RBACUtils.handle403Error(response.message);
        }
      }
    } catch (e) {
      errorMessage.value = e.toString();
      appPrint('Error loading booking detail: $e');
    } finally {
      isLoading(false);
    }
  }

  /// Cancel the booking with reason
  Future<void> cancelBooking(int id, {String? reason}) async {
    try {
      isLoading(true);
      errorMessage(null);

      final request = {
        if (reason != null) 'reason': reason,
      };

      final response = await CoreServiceApis.cancelFacilityBooking(
        bookingId: id,
        request: request,
      );

      if (response.status ?? false) {
        toast('Booking cancelled successfully');
        RBACUtils.logAccessAttempt('Booking#$id:cancel', true, null);
        // Navigate back and refresh
        Get.back();
      } else {
        errorMessage.value = response.message ?? 'Failed to cancel booking';
        toast(errorMessage.value);
        if (response.statusCode == 403) {
          RBACUtils.handle403Error(response.message);
        }
      }
    } catch (e) {
      errorMessage.value = e.toString();
      appPrint('Error cancelling booking: $e');
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
