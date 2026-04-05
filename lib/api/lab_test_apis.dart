import 'package:kivicare_patient/network/network_utils.dart';
import 'package:kivicare_patient/utils/api_end_points.dart';

class LabTestAPIs {
  /// Get all available lab test categories (public endpoint)
  static Future<ResponseModel> getLabTestCategories() async {
    return await buildHttpResponse(
      APIEndPoints.labTestCategories,
      method: HttpMethodType.GET,
    ).then((response) {
      return ResponseModel.fromJson(handleResponse(response));
    }).catchError((e) {
      throw e;
    });
  }

  /// Get paginated list of lab tests with optional filters (public endpoint)
  /// Supports filtering by: category_id, department (laboratory|radiology), search text
  static Future<ResponseModel> getLabTests({
    required String? categoryId,
    required String? department,
    required String? search,
    required int page,
  }) async {
    Map<String, dynamic> queryParams = {};
    if (categoryId != null) queryParams['category_id'] = categoryId;
    if (department != null) queryParams['department'] = department;
    if (search != null) queryParams['search'] = search;
    queryParams['page'] = page;
    queryParams['per_page'] = 15;

    return await buildHttpResponse(
      APIEndPoints.labTests,
      method: HttpMethodType.GET,
      queryParameters: queryParams,
    ).then((response) {
      return ResponseModel.fromJson(handleResponse(response));
    }).catchError((e) {
      throw e;
    });
  }

  /// Get single lab test details (public endpoint)
  static Future<ResponseModel> getLabTestDetail({required int testId}) async {
    return await buildHttpResponse(
      APIEndPoints.labTestDetail(testId),
      method: HttpMethodType.GET,
    ).then((response) {
      return ResponseModel.fromJson(handleResponse(response));
    }).catchError((e) {
      throw e;
    });
  }

  /// Create a new test order (authenticated endpoint)
  static Future<ResponseModel> createTestOrder({
    required Map request,
  }) async {
    return await buildHttpResponse(
      APIEndPoints.testOrders,
      method: HttpMethodType.POST,
      request: request,
    ).then((response) {
      return ResponseModel.fromJson(handleResponse(response));
    }).catchError((e) {
      throw e;
    });
  }

  /// Get authenticated user's test orders with optional filtering
  static Future<ResponseModel> getTestOrders({
    required String? status,
    required int page,
  }) async {
    Map<String, dynamic> queryParams = {};
    if (status != null) queryParams['status'] = status;
    queryParams['page'] = page;
    queryParams['per_page'] = 15;

    return await buildHttpResponse(
      APIEndPoints.testOrders,
      method: HttpMethodType.GET,
      queryParameters: queryParams,
    ).then((response) {
      return ResponseModel.fromJson(handleResponse(response));
    }).catchError((e) {
      throw e;
    });
  }

  /// Get single test order details (authenticated endpoint)
  static Future<ResponseModel> getTestOrderDetail({required int orderId}) async {
    return await buildHttpResponse(
      APIEndPoints.testOrderDetail(orderId),
      method: HttpMethodType.GET,
    ).then((response) {
      return ResponseModel.fromJson(handleResponse(response));
    }).catchError((e) {
      throw e;
    });
  }

  /// Cancel a test order (authenticated endpoint)
  static Future<ResponseModel> cancelTestOrder({
    required int orderId,
    required String cancellationReason,
  }) async {
    Map<String, dynamic> request = {
      'cancellation_reason': cancellationReason,
    };

    return await buildHttpResponse(
      APIEndPoints.testOrderCancel(orderId),
      method: HttpMethodType.POST,
      request: request,
    ).then((response) {
      return ResponseModel.fromJson(handleResponse(response));
    }).catchError((e) {
      throw e;
    });
  }

  /// Download test report as PDF (authenticated endpoint)
  static Future<ResponseModel> downloadTestReport({required int orderId}) async {
    return await buildHttpResponse(
      APIEndPoints.testOrderReportDownload(orderId),
      method: HttpMethodType.GET,
    ).then((response) {
      return ResponseModel.fromJson(handleResponse(response));
    }).catchError((e) {
      throw e;
    });
  }
}
