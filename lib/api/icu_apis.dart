import 'package:nb_utils/nb_utils.dart';
import '../network/network_utils.dart';
import '../network/critical_operation.dart';
import '../screens/icu_admission/models/admission_request_form_payload.dart';
import '../screens/icu_admission/models/admission_request_model.dart';
import '../screens/icu_admission/models/hospital_model.dart';
import '../screens/icu_admission/models/icu_department_model.dart';
import '../screens/icu_admission/models/icu_paginated_response.dart';
import '../utils/api_end_points.dart';

class IcuApis {
  static Future<IcuPaginatedResponse<Hospital>> getHospitals({
    int page = 1,
    String? search,
    int? governorateId,
    int? cityId,
    int? departmentId,
    bool? hasAvailableBeds,
  }) async {
    final endpoint = endpointWithQuery(APIEndPoints.icuHospitals, {
      'page': page,
      'search': search.validate().isEmpty ? null : search,
      'governorate_id': governorateId,
      'city_id': cityId,
      'icu_department_id': departmentId,
      'has_available_beds': hasAvailableBeds == true ? true : null,
    });
    final raw = await handleResponse(await buildHttpResponse(endpoint));
    return _parsePaginated(raw, (json) => Hospital.fromJson(json));
  }

  static Future<Hospital> getHospitalDetail(int id) async {
    final response = await handleResponse(
        await buildHttpResponse(APIEndPoints.icuHospitalDetail(id)));
    return Hospital.fromJson(response['data']);
  }

  static Future<List<IcuDepartment>> getDepartments() async {
    final response = await handleResponse(
        await buildHttpResponse(APIEndPoints.icuDepartments));
    return (response['data'] as List)
        .map((i) => IcuDepartment.fromJson(i))
        .toList();
  }

  // Backend has no /hospitals/{id}/departments endpoint — filter via icu-departments?hospital_id=
  static Future<List<IcuDepartment>> getHospitalDepartments(
      int hospitalId) async {
    final response = await handleResponse(
      await buildHttpResponse(APIEndPoints.icuHospitalDepartments(hospitalId)),
    );
    return (response['data'] as List)
        .map((i) => IcuDepartment.fromJson(i))
        .toList();
  }

  /// Returns {id, referenceNumber} from the backend's minimal create response.
  static Future<({int id, String referenceNumber})> submitAdmissionRequest(
      AdmissionRequestFormPayload payload,
      {required String idempotencyKey}) async {
    final response = await handleResponse(await buildHttpResponse(
      APIEndPoints.icuAdmissionRequests,
      method: HttpMethodType.POST,
      request: payload.toJson(),
      header: {
        ...buildHeaderTokens(),
        ...criticalOperationHeaders(idempotencyKey),
      },
    ));
    return parseIcuAdmissionResponse(response);
  }

  static Future<IcuPaginatedResponse<AdmissionRequest>> getAdmissionRequests({
    int page = 1,
    AdmissionStatus? status,
  }) async {
    final endpoint = endpointWithQuery(APIEndPoints.icuAdmissionRequests, {
      'page': page,
      'status': status?.toWire,
    });
    final raw = await handleResponse(
      await buildHttpResponse(endpoint),
    );
    return _parsePaginated(raw, (json) => AdmissionRequest.fromJson(json));
  }

  static Future<AdmissionRequest> getAdmissionRequestDetail(int id) async {
    final response = await handleResponse(
      await buildHttpResponse(APIEndPoints.icuAdmissionRequestDetail(id)),
    );
    return AdmissionRequest.fromJson(response['data']);
  }

  static Future<void> cancelAdmissionRequest(int id, String? reason,
      {required String idempotencyKey}) async {
    // Backend requires field name 'cancellation_reason' (not 'reason')
    final Map<String, dynamic> request = {};
    if (reason.validate().isNotEmpty) request['cancellation_reason'] = reason;

    await handleResponse(await buildHttpResponse(
      APIEndPoints.cancelIcuAdmissionRequest(id),
      method: HttpMethodType.POST,
      request: request,
      header: {
        ...buildHeaderTokens(),
        ...criticalOperationHeaders(idempotencyKey),
      },
    ));
  }

  // Handles both standard Laravel pagination (current_page at top level)
  // and wrapped pagination ({pagination: {current_page, ...}})
  static IcuPaginatedResponse<T> _parsePaginated<T>(
    Map raw,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    final data = raw['data'];
    final List<T> items = data != null
        ? (data as List)
            .map((i) => fromJson(i as Map<String, dynamic>))
            .toList()
        : [];

    final pagination = raw['pagination'] as Map?;
    return IcuPaginatedResponse<T>(
      data: items,
      currentPage: pagination?['current_page'] ?? raw['current_page'] ?? 1,
      lastPage: pagination?['last_page'] ?? raw['last_page'] ?? 1,
      total: pagination?['total'] ?? raw['total'] ?? 0,
    );
  }
}

/// Parses only a confirmed ICU receipt. Missing/invalid receipt data remains
/// pending because a successful mutation may have committed before the body
/// was lost or malformed.
({int id, String referenceNumber}) parseIcuAdmissionResponse(dynamic response) {
  try {
    final data = (response as Map)['data'];
    if (data is! Map) throw const FormatException();
    final id = int.tryParse(data['id']?.toString() ?? '');
    final referenceNumber = (data['request_number'] as String?)?.trim();
    if (id == null ||
        id <= 0 ||
        referenceNumber == null ||
        referenceNumber.isEmpty) {
      throw const FormatException();
    }
    return (id: id, referenceNumber: referenceNumber);
  } on Object {
    throw const AmbiguousRequestOutcomeException(
      'The server accepted the ICU request but returned an invalid confirmation. Verify its status before retrying.',
    );
  }
}
