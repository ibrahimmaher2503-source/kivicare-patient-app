import 'package:intl/intl.dart';
import 'package:nb_utils/nb_utils.dart';

import '../network/critical_operation.dart';
import '../network/network_utils.dart';
import '../screens/doctor_visit/models/visit_request_list_response.dart';
import '../screens/doctor_visit/models/visit_request_model.dart';
import '../screens/doctor_visit/models/visit_status.dart';
import '../utils/api_end_points.dart';

class DoctorVisitApis {
  static Future<VisitRequestModel> submitRequest({
    required String visitReason,
    required DateTime preferredDate,
    required String contactPhone,
    required String idempotencyKey,
    int? preferredDoctorId,
    String? additionalNotes,
  }) async {
    final body = <String, dynamic>{
      'visit_reason': visitReason,
      'preferred_date': DateFormat('yyyy-MM-dd').format(preferredDate),
      'contact_phone': contactPhone,
      if (preferredDoctorId != null) 'preferred_doctor_id': preferredDoctorId,
      if (additionalNotes != null && additionalNotes.isNotEmpty)
        'additional_notes': additionalNotes,
    };

    final response = await buildHttpResponse(
      APIEndPoints.doctorVisitRequests,
      method: HttpMethodType.POST,
      request: body,
      header: {
        ...buildHeaderTokens(),
        ...criticalOperationHeaders(idempotencyKey),
      },
    );
    final json =
        (await handleResponse(response) as Map).cast<String, dynamic>();
    final data = json['data'] is Map
        ? (json['data'] as Map).cast<String, dynamic>()
        : json;
    final model = VisitRequestModel.fromJson(data);
    if (model.id <= 0 || model.referenceNumber.trim().isEmpty) {
      throw const AmbiguousRequestOutcomeException(
        'The visit request may have been accepted, but its confirmation was invalid. Verify its status before retrying.',
      );
    }
    return model;
  }

  static Future<VisitRequestListResponse> getRequests({
    int page = 1,
    VisitStatus? status,
  }) async {
    final response = await buildHttpResponse(
      endpointWithQuery(
        APIEndPoints.doctorVisitRequests,
        {
          'page': page,
          'per_page': 15,
          if (status != null) 'status': status.apiValue,
        },
      ),
      method: HttpMethodType.GET,
    );
    final json =
        (await handleResponse(response) as Map).cast<String, dynamic>();
    return VisitRequestListResponse.fromJson(json);
  }

  static Future<VisitRequestModel> getRequestByReference(
      String referenceNumber) async {
    final response = await buildHttpResponse(
      '${APIEndPoints.doctorVisitRequests}/$referenceNumber',
      method: HttpMethodType.GET,
    );
    final json =
        (await handleResponse(response) as Map).cast<String, dynamic>();
    final data = json['data'] is Map
        ? (json['data'] as Map).cast<String, dynamic>()
        : json;
    return VisitRequestModel.fromJson(data);
  }

  static Future<VisitRequestModel> cancelRequest({
    required String referenceNumber,
    required String reason,
    required String idempotencyKey,
    required DateTime expectedUpdatedAt,
  }) async {
    final response = await buildHttpResponse(
      APIEndPoints.cancelDoctorVisitRequest(referenceNumber),
      method: HttpMethodType.POST,
      request: {
        'cancellation_reason': reason,
        'expected_updated_at': expectedUpdatedAt.toUtc().toIso8601String(),
      },
      header: {
        ...buildHeaderTokens(),
        ...criticalOperationHeaders(idempotencyKey),
      },
    );
    final json =
        (await handleResponse(response) as Map).cast<String, dynamic>();
    final data = json['data'] is Map
        ? (json['data'] as Map).cast<String, dynamic>()
        : json;
    final model = VisitRequestModel.fromJson(data);
    if (model.id <= 0 || model.status != VisitStatus.cancelled) {
      throw const AmbiguousRequestOutcomeException(
        'The cancellation may have been accepted, but its confirmation was invalid. Verify the request status.',
      );
    }
    return model;
  }
}
