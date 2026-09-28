import 'package:flutter/foundation.dart';
import 'package:nb_utils/nb_utils.dart';
import '../network/network_utils.dart';
import '../network/critical_operation.dart';
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
    if (kDebugMode) {
      debugPrint(
        '[LabsRadiologyApis] $method failed (${e.runtimeType})',
      );
    }
  }

  static void _logStatus(String method, int statusCode) {
    if (kDebugMode) {
      debugPrint('[LabsRadiologyApis] $method status=$statusCode');
    }
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
      _logStatus('searchLabs', raw.statusCode);
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
      _logStatus('searchRadiology', raw.statusCode);
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
      _logStatus('getTestCategories', raw.statusCode);
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
      _logStatus('getLabTests', raw.statusCode);
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
      _logStatus('getLabTestById', raw.statusCode);
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
      _logStatus('getLabSlots', raw.statusCode);
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
      _logStatus('getRadiologySlots', raw.statusCode);
      final response = await handleResponse(raw);
      return SlotsResponse.fromJson(response);
    } catch (e, st) {
      _logError('getRadiologySlots($centerId)', e, st);
      rethrow;
    }
  }

  static Future<TestOrderModel> createTestOrder(
    BookingPayload payload, {
    required String idempotencyKey,
  }) async {
    try {
      final raw = await buildHttpResponse(
        APIEndPoints.testOrders,
        method: HttpMethodType.POST,
        request: payload.toJson(),
        header: {
          ...buildHeaderTokens(),
          ...criticalOperationHeaders(idempotencyKey),
        },
      );
      _logStatus('createTestOrder', raw.statusCode);
      final response = await handleResponse(raw);
      return parseCreatedTestOrderResponse(response);
    } catch (e, st) {
      _logError('createTestOrder', e, st);
      rethrow;
    }
  }

  /// A 2xx response without a usable order receipt is still ambiguous: the
  /// backend may have committed the order before losing its response body.
  static TestOrderModel parseCreatedTestOrderResponse(dynamic response) {
    if (response is! Map || response['data'] is! Map) {
      throw const AmbiguousRequestOutcomeException(
        'The server accepted the order but returned an invalid confirmation. Verify its status before retrying.',
      );
    }
    try {
      final order = TestOrderModel.fromJson(
        (response['data'] as Map).cast<String, dynamic>(),
      );
      if (order.id <= 0 || order.referenceNumber.trim().isEmpty) {
        throw const AmbiguousRequestOutcomeException(
          'The server accepted the order but returned an invalid confirmation. Verify its status before retrying.',
        );
      }
      return order;
    } on AmbiguousRequestOutcomeException {
      rethrow;
    } on Object {
      throw const AmbiguousRequestOutcomeException(
        'The server accepted the order but returned an invalid confirmation. Verify its status before retrying.',
      );
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
      _logStatus('getTestOrders', raw.statusCode);
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
      _logStatus('getTestOrderById', raw.statusCode);
      final response = await handleResponse(raw);
      return TestOrderModel.fromJson(response['data']);
    } catch (e, st) {
      _logError('getTestOrderById($id)', e, st);
      rethrow;
    }
  }

  static Future<TestOrderModel> cancelTestOrder(int id,
      {String? reason, required String idempotencyKey}) async {
    Map request = {};
    if (reason.validate().isNotEmpty) request['cancellation_reason'] = reason;

    try {
      final raw = await buildHttpResponse(
        '${APIEndPoints.testOrders}/$id/cancel',
        method: HttpMethodType.POST,
        request: request,
        header: {
          ...buildHeaderTokens(),
          ...criticalOperationHeaders(idempotencyKey),
        },
      );
      _logStatus('cancelTestOrder', raw.statusCode);
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
      _logStatus('getReportDownloadInfo', raw.statusCode);
      return await handleResponse(raw);
    } catch (e, st) {
      _logError('getReportDownloadInfo($orderId)', e, st);
      rethrow;
    }
  }
}
