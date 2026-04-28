import 'package:intl/intl.dart';
import 'package:nb_utils/nb_utils.dart';

import '../network/network_utils.dart';
import '../screens/doctor_visit/models/visit_request_list_response.dart';
import '../screens/doctor_visit/models/visit_request_model.dart';
import '../utils/api_end_points.dart';

class DoctorVisitApis {
  static Future<VisitRequestModel> submitRequest({
    required String visitReason,
    required DateTime preferredDate,
    required String contactPhone,
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

    return await buildHttpResponse(
      APIEndPoints.doctorVisitRequests,
      method: HttpMethodType.POST,
      request: body,
    ).then((response) {
      final json = handleResponse(response) as Map<String, dynamic>;
      final data = json['data'] is Map<String, dynamic>
          ? json['data'] as Map<String, dynamic>
          : json;
      return VisitRequestModel.fromJson(data);
    }).catchError((e) {
      throw e;
    });
  }

  static Future<VisitRequestListResponse> getRequests({int page = 1}) async {
    return await buildHttpResponse(
      '${APIEndPoints.doctorVisitRequests}?page=$page&per_page=15',
      method: HttpMethodType.GET,
    ).then((response) {
      final json = handleResponse(response) as Map<String, dynamic>;
      return VisitRequestListResponse.fromJson(json);
    }).catchError((e) {
      throw e;
    });
  }

  static Future<VisitRequestModel> getRequestByReference(
      String referenceNumber) async {
    return await buildHttpResponse(
      '${APIEndPoints.doctorVisitRequests}/$referenceNumber',
      method: HttpMethodType.GET,
    ).then((response) {
      final json = handleResponse(response) as Map<String, dynamic>;
      final data = json['data'] is Map<String, dynamic>
          ? json['data'] as Map<String, dynamic>
          : json;
      return VisitRequestModel.fromJson(data);
    }).catchError((e) {
      throw e;
    });
  }
}
