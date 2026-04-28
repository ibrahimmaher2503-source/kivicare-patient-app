import 'package:nb_utils/nb_utils.dart';
import 'package:kivicare_patient/network/network_utils.dart';
import 'package:kivicare_patient/screens/nurse_request/models/nurse_request_form_payload.dart';
import 'package:kivicare_patient/screens/nurse_request/models/nurse_request_list_response.dart';
import 'package:kivicare_patient/screens/nurse_request/models/nurse_request_model.dart';
import 'package:kivicare_patient/utils/api_end_points.dart';

class NurseRequestApis {
  static Future<NurseRequestModel> create({required NurseRequestFormPayload payload}) async {
    final data = await handleResponse(
      await buildHttpResponse(
        APIEndPoints.createNurseRequest,
        method: HttpMethodType.POST,
        request: payload.toJson(),
      ),
    );
    return NurseRequestModel.fromJson(data['data'] ?? data);
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
}
