import 'package:nb_utils/nb_utils.dart';
import 'package:kivicare_patient/network/network_utils.dart';
import 'package:kivicare_patient/network/critical_operation.dart';
import 'package:kivicare_patient/screens/nurse_request/models/nurse_request_form_payload.dart';
import 'package:kivicare_patient/screens/nurse_request/models/nurse_request_list_response.dart';
import 'package:kivicare_patient/screens/nurse_request/models/nurse_request_model.dart';
import 'package:kivicare_patient/utils/api_end_points.dart';

class NurseRequestApis {
  static Future<NurseRequestModel> create({
    required NurseRequestFormPayload payload,
    required String idempotencyKey,
  }) async {
    final data = await handleResponse(
      await buildHttpResponse(
        APIEndPoints.createNurseRequest,
        method: HttpMethodType.POST,
        request: payload.toJson(),
        header: {
          ...buildHeaderTokens(),
          ...criticalOperationHeaders(idempotencyKey),
        },
      ),
    );
    final model = NurseRequestModel.fromJson(data['data'] ?? data);
    if (model.id <= 0 || model.referenceNumber.trim().isEmpty) {
      throw const AmbiguousRequestOutcomeException(
        'The request may have been accepted, but its confirmation was invalid. Verify its status before retrying.',
      );
    }
    return model;
  }

  static Future<NurseRequestListResponse> list({
    required int page,
    int perPage = 15,
    String? status,
  }) async {
    String query = '?page=$page&per_page=$perPage';
    if (status != null && status.isNotEmpty) query += '&status=$status';
    final data = await handleResponse(
      await buildHttpResponse(
        '${APIEndPoints.getNurseRequests}$query',
        method: HttpMethodType.GET,
      ),
    );
    return NurseRequestListResponse.fromJson(data);
  }

  static Future<NurseRequestModel> detail({required int id}) async {
    final data = await handleResponse(
      await buildHttpResponse(
        '${APIEndPoints.getNurseRequestDetail}/$id',
        method: HttpMethodType.GET,
      ),
    );
    return NurseRequestModel.fromJson(data['data'] ?? data);
  }

  /// Cancels a patient-owned request through the documented endpoint. The
  /// server must enforce ownership, current-state/version rules, audit the
  /// transition, and make this key idempotent.
  static Future<NurseRequestModel> cancel({
    required int id,
    required String reason,
    required String idempotencyKey,
    DateTime? expectedUpdatedAt,
  }) async {
    final data = await handleResponse(
      await buildHttpResponse(
        '${APIEndPoints.getNurseRequestDetail}/$id/cancel',
        method: HttpMethodType.POST,
        request: {
          'cancellation_reason': reason,
          if (expectedUpdatedAt != null)
            'expected_updated_at': expectedUpdatedAt.toUtc().toIso8601String(),
        },
        header: {
          ...buildHeaderTokens(),
          ...criticalOperationHeaders(idempotencyKey),
        },
      ),
    );
    try {
      return NurseRequestModel.fromJson(data['data'] ?? data);
    } on Object {
      throw const AmbiguousRequestOutcomeException(
        'The cancellation may have been accepted, but its confirmation was invalid. Verify the request status.',
      );
    }
  }
}
