import 'package:kivicare_patient/network/network_utils.dart';
import 'package:kivicare_patient/utils/api_end_points.dart';

class FacilityBookingAPIs {
  /// Get available appointment slots for a lab on a specific date (public endpoint)
  /// Returns slots with availability status (available: true/false)
  static Future<ResponseModel> getLabSlots({
    required int labId,
    required String date,
  }) async {
    Map<String, dynamic> queryParams = {
      'date': date,
    };

    return await buildHttpResponse(
      APIEndPoints.labSlots(labId),
      method: HttpMethodType.GET,
      queryParameters: queryParams,
    ).then((response) {
      return ResponseModel.fromJson(handleResponse(response));
    }).catchError((e) {
      throw e;
    });
  }

  /// Get available appointment slots for a radiology center on a specific date (public endpoint)
  /// Returns slots with availability status (available: true/false)
  static Future<ResponseModel> getRadiologyCenterSlots({
    required int centerId,
    required String date,
  }) async {
    Map<String, dynamic> queryParams = {
      'date': date,
    };

    return await buildHttpResponse(
      APIEndPoints.radiologyCenterSlots(centerId),
      method: HttpMethodType.GET,
      queryParameters: queryParams,
    ).then((response) {
      return ResponseModel.fromJson(handleResponse(response));
    }).catchError((e) {
      throw e;
    });
  }

  /// Create a new facility booking (authenticated endpoint)
  /// Request body includes: type (lab|radiology), facility_id, date, time, patient details
  static Future<ResponseModel> createFacilityBooking({
    required Map request,
  }) async {
    return await buildHttpResponse(
      APIEndPoints.facilityBookings,
      method: HttpMethodType.POST,
      request: request,
    ).then((response) {
      return ResponseModel.fromJson(handleResponse(response));
    }).catchError((e) {
      throw e;
    });
  }

  /// Get authenticated user's facility bookings with optional filtering
  /// Supports filtering by: type (lab|radiology), status (pending|confirmed|cancelled|completed|no_show)
  static Future<ResponseModel> getFacilityBookings({
    required String? type,
    required String? status,
    required int page,
  }) async {
    Map<String, dynamic> queryParams = {};
    if (type != null) queryParams['type'] = type;
    if (status != null) queryParams['status'] = status;
    queryParams['page'] = page;
    queryParams['per_page'] = 15;

    return await buildHttpResponse(
      APIEndPoints.facilityBookings,
      method: HttpMethodType.GET,
      queryParameters: queryParams,
    ).then((response) {
      return ResponseModel.fromJson(handleResponse(response));
    }).catchError((e) {
      throw e;
    });
  }

  /// Get single facility booking details (authenticated endpoint)
  static Future<ResponseModel> getFacilityBookingDetail({
    required int bookingId,
  }) async {
    return await buildHttpResponse(
      APIEndPoints.facilityBookingDetail(bookingId),
      method: HttpMethodType.GET,
    ).then((response) {
      return ResponseModel.fromJson(handleResponse(response));
    }).catchError((e) {
      throw e;
    });
  }

  /// Cancel a facility booking (authenticated endpoint)
  static Future<ResponseModel> cancelFacilityBooking({
    required int bookingId,
    required String cancellationReason,
  }) async {
    Map<String, dynamic> request = {
      'cancellation_reason': cancellationReason,
    };

    return await buildHttpResponse(
      APIEndPoints.facilityBookingCancel(bookingId),
      method: HttpMethodType.POST,
      request: request,
    ).then((response) {
      return ResponseModel.fromJson(handleResponse(response));
    }).catchError((e) {
      throw e;
    });
  }
}
