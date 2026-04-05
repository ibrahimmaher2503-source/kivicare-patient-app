import 'package:kivicare_patient/network/network_utils.dart';
import 'package:kivicare_patient/utils/api_end_points.dart';

class LabTestAPIs {
  /// Get all available lab test categories (public endpoint)
  /// Throws: Exception if API call fails
  static Future<ResponseModel> getLabTestCategories() async {
    try {
      final response = await buildHttpResponse(
        APIEndPoints.labTestCategories,
        method: HttpMethodType.GET,
      );
      return ResponseModel.fromJson(handleResponse(response));
    } catch (e) {
      rethrow;
    }
  }

  /// Get paginated list of lab tests with optional filters (public endpoint)
  /// Supports filtering by: category_id, department (laboratory|radiology), search text
  /// Throws: Exception if API call fails
  static Future<ResponseModel> getLabTests({
    int? categoryId,
    String? department,
    String? search,
    required int page,
  }) async {
    Map<String, dynamic> queryParams = {};
    if (categoryId != null) queryParams['category_id'] = categoryId;
    if (department != null) queryParams['department'] = department;
    if (search != null) queryParams['search'] = search;
    queryParams['page'] = page;
    queryParams['per_page'] = 15;

    try {
      final response = await buildHttpResponse(
        APIEndPoints.labTests,
        method: HttpMethodType.GET,
        queryParameters: queryParams,
      );
      return ResponseModel.fromJson(handleResponse(response));
    } catch (e) {
      rethrow;
    }
  }

  /// Get single lab test details (public endpoint)
  /// Throws: Exception if API call fails
  static Future<ResponseModel> getLabTestDetail({required int testId}) async {
    try {
      final response = await buildHttpResponse(
        APIEndPoints.labTestDetail(testId),
        method: HttpMethodType.GET,
      );
      return ResponseModel.fromJson(handleResponse(response));
    } catch (e) {
      rethrow;
    }
  }

  /// Create a new test order (authenticated endpoint)
  /// Throws: Exception if API call fails or validation error (422)
  static Future<ResponseModel> createTestOrder({
    required Map<String, dynamic> request,
  }) async {
    try {
      final response = await buildHttpResponse(
        APIEndPoints.testOrders,
        method: HttpMethodType.POST,
        request: request,
      );
      return ResponseModel.fromJson(handleResponse(response));
    } catch (e) {
      rethrow;
    }
  }

  /// Get authenticated user's test orders with optional filtering
  /// Throws: Exception if API call fails
  static Future<ResponseModel> getTestOrders({
    String? status,
    required int page,
  }) async {
    final queryParams = <String, dynamic>{};
    if (status != null) queryParams['status'] = status;
    queryParams['page'] = page;
    queryParams['per_page'] = 15;

    try {
      final response = await buildHttpResponse(
        APIEndPoints.testOrders,
        method: HttpMethodType.GET,
        queryParameters: queryParams,
      );
      return ResponseModel.fromJson(handleResponse(response));
    } catch (e) {
      rethrow;
    }
  }

  /// Get single test order details (authenticated endpoint)
  /// Throws: Exception if API call fails or order not found (404)
  static Future<ResponseModel> getTestOrderDetail({required int orderId}) async {
    try {
      final response = await buildHttpResponse(
        APIEndPoints.testOrderDetail(orderId),
        method: HttpMethodType.GET,
      );
      return ResponseModel.fromJson(handleResponse(response));
    } catch (e) {
      rethrow;
    }
  }

  /// Cancel a test order (authenticated endpoint)
  /// Throws: Exception if API call fails, order not found (404), or invalid state (422)
  static Future<ResponseModel> cancelTestOrder({
    required int orderId,
    required String cancellationReason,
  }) async {
    try {
      final request = <String, dynamic>{
        'cancellation_reason': cancellationReason,
      };

      final response = await buildHttpResponse(
        APIEndPoints.testOrderCancel(orderId),
        method: HttpMethodType.POST,
        request: request,
      );
      return ResponseModel.fromJson(handleResponse(response));
    } catch (e) {
      rethrow;
    }
  }

  /// Download test report as PDF (authenticated endpoint)
  /// Throws: Exception if API call fails or order not found (404)
  static Future<ResponseModel> downloadTestReport({required int orderId}) async {
    try {
      final response = await buildHttpResponse(
        APIEndPoints.testOrderReportDownload(orderId),
        method: HttpMethodType.GET,
      );
      return ResponseModel.fromJson(handleResponse(response));
    } catch (e) {
      rethrow;
    }
  }
}
