import 'package:nb_utils/nb_utils.dart';
import '../network/network_utils.dart';
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
    String params = '?page=$page';
    if (search.validate().isNotEmpty) params += '&search=$search';
    if (governorateId != null) params += '&governorate_id=$governorateId';
    if (cityId != null) params += '&city_id=$cityId';
    if (departmentId != null) params += '&icu_department_id=$departmentId';
    if (hasAvailableBeds != null) params += '&has_available_beds=$hasAvailableBeds';

    return IcuPaginatedResponse<Hospital>.fromJson(
      await handleResponse(await buildHttpResponse('${APIEndPoints.icuHospitals}$params')),
      (json) => Hospital.fromJson(json),
    );
  }

  static Future<Hospital> getHospitalDetail(int id) async {
    final response = await handleResponse(await buildHttpResponse(APIEndPoints.icuHospitalDetail(id)));
    return Hospital.fromJson(response['data']);
  }

  static Future<List<IcuDepartment>> getDepartments() async {
    final response = await handleResponse(await buildHttpResponse(APIEndPoints.icuDepartments));
    return (response['data'] as List).map((i) => IcuDepartment.fromJson(i)).toList();
  }

  static Future<List<IcuDepartment>> getHospitalDepartments(int hospitalId) async {
    final response = await handleResponse(await buildHttpResponse(APIEndPoints.icuHospitalDepartments(hospitalId)));
    return (response['data'] as List).map((i) => IcuDepartment.fromJson(i)).toList();
  }

  static Future<AdmissionRequest> submitAdmissionRequest(AdmissionRequestFormPayload payload) async {
    final response = await handleResponse(await buildHttpResponse(
      APIEndPoints.icuAdmissionRequests,
      method: HttpMethodType.POST,
      request: payload.toJson(),
    ));
    return AdmissionRequest.fromJson(response['data']);
  }

  static Future<IcuPaginatedResponse<AdmissionRequest>> getAdmissionRequests({
    int page = 1,
    AdmissionStatus? status,
  }) async {
    String params = '?page=$page';
    if (status != null) params += '&status=${status.toWire}';

    return IcuPaginatedResponse<AdmissionRequest>.fromJson(
      await handleResponse(await buildHttpResponse('${APIEndPoints.icuAdmissionRequests}$params')),
      (json) => AdmissionRequest.fromJson(json),
    );
  }

  static Future<AdmissionRequest> getAdmissionRequestDetail(int id) async {
    final response = await handleResponse(await buildHttpResponse(APIEndPoints.icuAdmissionRequestDetail(id)));
    return AdmissionRequest.fromJson(response['data']);
  }

  static Future<AdmissionRequest> cancelAdmissionRequest(int id, String? reason) async {
    Map request = {};
    if (reason.validate().isNotEmpty) request['reason'] = reason;

    final response = await handleResponse(await buildHttpResponse(
      APIEndPoints.cancelIcuAdmissionRequest(id),
      method: HttpMethodType.POST,
      request: request,
    ));
    return AdmissionRequest.fromJson(response['data']);
  }
}
