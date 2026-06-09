import 'package:nb_utils/nb_utils.dart';
import '../network/network_utils.dart';
import '../screens/labs_radiology/models/booking_payload.dart';
import '../screens/labs_radiology/models/facility_list_response.dart';
import '../screens/labs_radiology/models/facility_type.dart';
import '../screens/labs_radiology/models/lab_test_category_model.dart';
import '../screens/labs_radiology/models/lab_test_list_response.dart';
import '../screens/labs_radiology/models/lab_test_model.dart';
import '../screens/labs_radiology/models/slots_response.dart';
import '../screens/labs_radiology/models/test_order_list_response.dart';
import '../screens/labs_radiology/models/test_order_model.dart';
import '../screens/labs_radiology/models/test_order_status.dart';
import '../utils/api_end_points.dart';

class LabsRadiologyApis {
  static void _logError(String method, dynamic e, StackTrace? st) {
    // ignore: avoid_print
    print('[LabsRadiologyApis] $method ERROR: $e');
    // ignore: avoid_print
    if (st != null) print(st);
  }

  static Future<FacilityListResponse> searchLabs({
    int page = 1,
    String? search,
    int? governorateId,
    int? cityId,
    int? labTestId,
  }) async {
    String params = '?page=$page';
    if (search.validate().isNotEmpty) params += '&search=$search';
    if (governorateId != null) params += '&governorate_id=$governorateId';
    if (cityId != null) params += '&city_id=$cityId';
    if (labTestId != null) params += '&lab_test_id=$labTestId';

    try {
      final raw = await buildHttpResponse('${APIEndPoints.labsSearch}$params');
      // ignore: avoid_print
      print(
          '[LabsRadiologyApis] searchLabs status=${raw.statusCode} body=${raw.body}');
      final handled = await handleResponse(raw);
      return FacilityListResponse.fromJson(
        handled,
        fallbackType: FacilityType.lab,
      );
    } catch (e, st) {
      _logError('searchLabs', e, st);
      rethrow;
    }
  }

  static Future<FacilityListResponse> searchRadiology({
    int page = 1,
    String? search,
    int? governorateId,
    int? cityId,
    int? serviceId,
  }) async {
    String params = '?page=$page';
    if (search.validate().isNotEmpty) params += '&search=$search';
    if (governorateId != null) params += '&governorate_id=$governorateId';
    if (cityId != null) params += '&city_id=$cityId';
    if (serviceId != null) params += '&service_id=$serviceId';

    try {
      final raw =
          await buildHttpResponse('${APIEndPoints.radiologySearch}$params');
      // ignore: avoid_print
      print(
          '[LabsRadiologyApis] searchRadiology status=${raw.statusCode} body=${raw.body}');
      final handled = await handleResponse(raw);
      return FacilityListResponse.fromJson(
        handled,
        fallbackType: FacilityType.radiology,
      );
    } catch (e, st) {
      _logError('searchRadiology', e, st);
      rethrow;
    }
  }

  static Future<List<LabTestCategoryModel>> getTestCategories() async {
    try {
      final raw = await buildHttpResponse(APIEndPoints.labTestCategories);
      // ignore: avoid_print
      print(
          '[LabsRadiologyApis] getTestCategories status=${raw.statusCode} body=${raw.body}');
      final response = await handleResponse(raw);
      return (response['data'] as List)
          .map((i) => LabTestCategoryModel.fromJson(i))
          .toList();
    } catch (e, st) {
      _logError('getTestCategories', e, st);
      rethrow;
    }
  }

  static Future<LabTestListResponse> getLabTests({
    int page = 1,
    String? search,
    int? categoryId,
    int? facilityId,
  }) async {
    String params = '?page=$page';
    if (search.validate().isNotEmpty) params += '&search=$search';
    if (categoryId != null) params += '&category_id=$categoryId';
    if (facilityId != null) params += '&facility_id=$facilityId';

    try {
      final raw = await buildHttpResponse('${APIEndPoints.labTests}$params');
      // ignore: avoid_print
      print(
          '[LabsRadiologyApis] getLabTests status=${raw.statusCode} body=${raw.body}');
      final handled = await handleResponse(raw);
      return LabTestListResponse.fromJson(handled);
    } catch (e, st) {
      _logError('getLabTests', e, st);
      rethrow;
    }
  }

  static Future<LabTestModel> getLabTestById(int id) async {
    try {
      final raw = await buildHttpResponse('${APIEndPoints.labTests}/$id');
      // ignore: avoid_print
      print(
          '[LabsRadiologyApis] getLabTestById status=${raw.statusCode} body=${raw.body}');
      final response = await handleResponse(raw);
      return LabTestModel.fromJson(response['data']);
    } catch (e, st) {
      _logError('getLabTestById($id)', e, st);
      rethrow;
    }
  }

  static Future<SlotsResponse> getLabSlots(int labId) async {
    try {
      final raw = await buildHttpResponse(
          '${APIEndPoints.facilityBookings}/labs/$labId/slots');
      // ignore: avoid_print
      print(
          '[LabsRadiologyApis] getLabSlots status=${raw.statusCode} body=${raw.body}');
      final response = await handleResponse(raw);
      return SlotsResponse.fromJson(response);
    } catch (e, st) {
      _logError('getLabSlots($labId)', e, st);
      rethrow;
    }
  }

  static Future<SlotsResponse> getRadiologySlots(int centerId) async {
    try {
      final raw = await buildHttpResponse(
          '${APIEndPoints.facilityBookings}/radiology-centers/$centerId/slots');
      // ignore: avoid_print
      print(
          '[LabsRadiologyApis] getRadiologySlots status=${raw.statusCode} body=${raw.body}');
      final response = await handleResponse(raw);
      return SlotsResponse.fromJson(response);
    } catch (e, st) {
      _logError('getRadiologySlots($centerId)', e, st);
      rethrow;
    }
  }

  static Future<TestOrderModel> createTestOrder(BookingPayload payload) async {
    try {
      final raw = await buildHttpResponse(
        APIEndPoints.testOrders,
        method: HttpMethodType.POST,
        request: payload.toJson(),
      );
      // ignore: avoid_print
      print(
          '[LabsRadiologyApis] createTestOrder status=${raw.statusCode} body=${raw.body}');
      final response = await handleResponse(raw);
      return TestOrderModel.fromJson(response['data']);
    } catch (e, st) {
      _logError('createTestOrder', e, st);
      rethrow;
    }
  }

  static Future<TestOrderListResponse> getTestOrders({
    int page = 1,
    TestOrderStatus? statusFilter,
  }) async {
    String params = '?page=$page';
    if (statusFilter != null) params += '&status=${statusFilter.apiValue}';

    try {
      final raw = await buildHttpResponse('${APIEndPoints.testOrders}$params');
      // ignore: avoid_print
      print(
          '[LabsRadiologyApis] getTestOrders status=${raw.statusCode} body=${raw.body}');
      final handled = await handleResponse(raw);
      return TestOrderListResponse.fromJson(handled);
    } catch (e, st) {
      _logError('getTestOrders', e, st);
      rethrow;
    }
  }

  static Future<TestOrderModel> getTestOrderById(int id) async {
    try {
      final raw = await buildHttpResponse('${APIEndPoints.testOrders}/$id');
      // ignore: avoid_print
      print(
          '[LabsRadiologyApis] getTestOrderById status=${raw.statusCode} body=${raw.body}');
      final response = await handleResponse(raw);
      return TestOrderModel.fromJson(response['data']);
    } catch (e, st) {
      _logError('getTestOrderById($id)', e, st);
      rethrow;
    }
  }

  static Future<TestOrderModel> cancelTestOrder(int id,
      {String? reason}) async {
    Map request = {};
    if (reason.validate().isNotEmpty) request['cancellation_reason'] = reason;

    try {
      final raw = await buildHttpResponse(
        '${APIEndPoints.testOrders}/$id/cancel',
        method: HttpMethodType.POST,
        request: request,
      );
      // ignore: avoid_print
      print(
          '[LabsRadiologyApis] cancelTestOrder status=${raw.statusCode} body=${raw.body}');
      final response = await handleResponse(raw);
      return TestOrderModel.fromJson(response['data']);
    } catch (e, st) {
      _logError('cancelTestOrder($id)', e, st);
      rethrow;
    }
  }

  static Future<dynamic> getReportDownloadInfo(int orderId) async {
    try {
      final raw = await buildHttpResponse(
          '${APIEndPoints.testOrders}/$orderId/report/download');
      // ignore: avoid_print
      print(
          '[LabsRadiologyApis] getReportDownloadInfo status=${raw.statusCode} body=${raw.body}');
      return await handleResponse(raw);
    } catch (e, st) {
      _logError('getReportDownloadInfo($orderId)', e, st);
      rethrow;
    }
  }
}
