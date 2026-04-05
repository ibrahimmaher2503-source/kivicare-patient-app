import 'package:kivicare_patient/network/network_utils.dart';
import 'package:kivicare_patient/utils/api_end_points.dart';

class FacilityBookingAPIs {
  /// Get available appointment slots for a lab on a specific date (public endpoint)
  /// Returns slots with availability status (available: true/false)
  /// Throws: Exception if API call fails or date is invalid
  static Future<ResponseModel> getLabSlots({
    required int labId,
    required String date,
  }) async {
    try {
      final queryParams = <String, dynamic>{'date': date};

      final response = await buildHttpResponse(
        APIEndPoints.labSlots(labId),
        method: HttpMethodType.GET,
        queryParameters: queryParams,
      );
      return ResponseModel.fromJson(handleResponse(response));
    } catch (e) {
      rethrow;
    }
  }

  /// Get available appointment slots for a radiology center on a specific date (public endpoint)
  /// Returns slots with availability status (available: true/false)
  /// Throws: Exception if API call fails or date is invalid
  static Future<ResponseModel> getRadiologyCenterSlots({
    required int centerId,
    required String date,
  }) async {
    try {
      final queryParams = <String, dynamic>{'date': date};

      final response = await buildHttpResponse(
        APIEndPoints.radiologyCenterSlots(centerId),
        method: HttpMethodType.GET,
        queryParameters: queryParams,
      );
      return ResponseModel.fromJson(handleResponse(response));
    } catch (e) {
      rethrow;
    }
  }

  /// Create a new facility booking (authenticated endpoint)
  /// Request body includes: type (lab|radiology), facility_id, date, time, patient details
  /// Throws: Exception if API call fails or slot unavailable (422)
  static Future<ResponseModel> createFacilityBooking({
    required Map<String, dynamic> request,
  }) async {
    try {
      final response = await buildHttpResponse(
        APIEndPoints.facilityBookings,
        method: HttpMethodType.POST,
        request: request,
      );
      return ResponseModel.fromJson(handleResponse(response));
    } catch (e) {
      rethrow;
    }
  }

  /// Get authenticated user's facility bookings with optional filtering
  /// Supports filtering by: type (lab|radiology), status (pending|confirmed|cancelled|completed|no_show)
  /// Throws: Exception if API call fails
  static Future<ResponseModel> getFacilityBookings({
    String? type,
    String? status,
    required int page,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (type != null) queryParams['type'] = type;
      if (status != null) queryParams['status'] = status;
      queryParams['page'] = page;
      queryParams['per_page'] = 15;

      final response = await buildHttpResponse(
        APIEndPoints.facilityBookings,
        method: HttpMethodType.GET,
        queryParameters: queryParams,
      );
      return ResponseModel.fromJson(handleResponse(response));
    } catch (e) {
      rethrow;
    }
  }

  /// Get single facility booking details (authenticated endpoint)
  /// Throws: Exception if API call fails or booking not found (404)
  static Future<ResponseModel> getFacilityBookingDetail({
    required int bookingId,
  }) async {
    try {
      final response = await buildHttpResponse(
        APIEndPoints.facilityBookingDetail(bookingId),
        method: HttpMethodType.GET,
      );
      return ResponseModel.fromJson(handleResponse(response));
    } catch (e) {
      rethrow;
    }
  }

  /// Cancel a facility booking (authenticated endpoint)
  /// Throws: Exception if API call fails, booking not found (404), or invalid state (422)
  static Future<ResponseModel> cancelFacilityBooking({
    required int bookingId,
    required Map<String, dynamic> request,
  }) async {
    try {
      final response = await buildHttpResponse(
        APIEndPoints.facilityBookingCancel(bookingId),
        method: HttpMethodType.POST,
        request: request,
      );
      return ResponseModel.fromJson(handleResponse(response));
    } catch (e) {
      rethrow;
    }
  }
}
