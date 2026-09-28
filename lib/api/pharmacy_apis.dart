import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:nb_utils/nb_utils.dart';
import '../models/base_response_model.dart';
import '../network/network_utils.dart';
import '../network/critical_operation.dart';
import '../screens/pharmacy/model/pharmacy_prescription_model.dart';
import '../screens/pharmacy/utils/pharmacy_constants.dart';
import '../utils/api_end_points.dart';
import '../utils/constants.dart';

class PharmacyApis {
  // Categories
  static Future<dynamic> getPharmacyCategories({int? parentId}) async {
    String url = parentId != null
        ? '${APIEndPoints.pharmacyCategories}/$parentId/children'
        : APIEndPoints.pharmacyCategories;
    return await handleResponse(
        await buildHttpResponse(url, method: HttpMethodType.GET));
  }

  // Products
  static Future<dynamic> getPharmacyProducts({
    int page = 1,
    int perPage = 10,
    String search = '',
    int? categoryId,
    int? brandId,
    int? productTypeId,
    String? priceMin,
    String? priceMax,
    bool? prescriptionRequired,
    String? sort,
  }) async {
    Map<String, String> params = {
      'page': page.toString(),
      'per_page': perPage.toString(),
    };
    if (search.isNotEmpty) params['search'] = search;
    if (categoryId != null) params['category_id'] = categoryId.toString();
    if (brandId != null) params['brand_id'] = brandId.toString();
    if (productTypeId != null) {
      params['product_type_id'] = productTypeId.toString();
    }
    if (priceMin != null) params['price_min'] = priceMin;
    if (priceMax != null) params['price_max'] = priceMax;
    if (prescriptionRequired != null) {
      params['prescription_required'] = prescriptionRequired ? '1' : '0';
    }
    if (sort != null) params['sort'] = sort;

    String queryString = Uri(queryParameters: params).query;
    return await handleResponse(await buildHttpResponse(
        '${APIEndPoints.pharmacyProducts}?$queryString',
        method: HttpMethodType.GET));
  }

  static Future<dynamic> getProductDetails(int productId) async {
    return await handleResponse(await buildHttpResponse(
        '${APIEndPoints.pharmacyProducts}/$productId',
        method: HttpMethodType.GET));
  }

  // Filters
  static Future<dynamic> getBrands() async {
    return await handleResponse(await buildHttpResponse(
        APIEndPoints.pharmacyBrands,
        method: HttpMethodType.GET));
  }

  static Future<dynamic> getProductTypes() async {
    return await handleResponse(await buildHttpResponse(
        APIEndPoints.pharmacyProductTypes,
        method: HttpMethodType.GET));
  }

  // Cart
  static Future<dynamic> getCart() async {
    return await handleResponse(await buildHttpResponse(
        APIEndPoints.pharmacyCart,
        method: HttpMethodType.GET));
  }

  static Future<dynamic> addToCart(
      {required int productId, required int quantity, int? pharmacyId}) async {
    Map request = {
      'product_id': productId,
      'quantity': quantity,
    };
    if (pharmacyId != null) request['pharmacy_id'] = pharmacyId;
    return await handleResponse(await buildHttpResponse(
        APIEndPoints.pharmacyCartItems,
        request: request,
        method: HttpMethodType.POST));
  }

  static Future<dynamic> updateCartItem(int itemId,
      {required int quantity}) async {
    return await handleResponse(await buildHttpResponse(
        '${APIEndPoints.pharmacyCartItems}/$itemId',
        request: {'quantity': quantity},
        method: HttpMethodType.PUT));
  }

  static Future<dynamic> removeCartItem(int itemId) async {
    return await handleResponse(await buildHttpResponse(
        '${APIEndPoints.pharmacyCartItems}/$itemId',
        method: HttpMethodType.DELETE));
  }

  static Future<dynamic> getAvailablePharmacies() async {
    return await handleResponse(await buildHttpResponse(
        APIEndPoints.pharmacyAvailablePharmacies,
        method: HttpMethodType.GET));
  }

  // Orders
  static Future<dynamic> getOrders({int page = 1, int perPage = 15}) async {
    return await handleResponse(await buildHttpResponse(
        '${APIEndPoints.pharmacyOrders}?page=$page&per_page=$perPage',
        method: HttpMethodType.GET));
  }

  static Future<dynamic> getOrderDetails(int orderId) async {
    return await handleResponse(await buildHttpResponse(
        '${APIEndPoints.pharmacyOrders}/$orderId',
        method: HttpMethodType.GET));
  }

  static Future<dynamic> placeOrder({
    required int pharmacyId,
    required String deliveryAddress,
    required String paymentMethod,
    String? couponCode,
    int? prescriptionId,
    required String idempotencyKey,
  }) async {
    Map request = {
      'pharmacy_id': pharmacyId,
      'delivery_address': deliveryAddress,
      'payment_method': paymentMethod == PaymentMethods.PAYMENT_METHOD_CASH
          ? 'cash_on_delivery'
          : paymentMethod,
    };
    if (couponCode != null) request['coupon_code'] = couponCode;
    if (prescriptionId != null) request['prescription_id'] = prescriptionId;
    return await handleResponse(
        await buildHttpResponse(APIEndPoints.pharmacyOrders,
            request: request,
            header: {
              ...buildHeaderTokens(),
              ...criticalOperationHeaders(idempotencyKey),
            },
            method: HttpMethodType.POST));
  }

  static Future<BaseResponseModel> cancelOrder(int orderId,
      {required String idempotencyKey}) async {
    return BaseResponseModel.fromJson(await handleResponse(
        await buildHttpResponse(
            '${APIEndPoints.pharmacyOrders}/$orderId/cancel',
            method: HttpMethodType.POST,
            header: {
          ...buildHeaderTokens(),
          ...criticalOperationHeaders(idempotencyKey),
        })));
  }

  // Prescriptions
  static Future<dynamic> getPrescriptions({int page = 1}) async {
    return await handleResponse(await buildHttpResponse(
        '${APIEndPoints.pharmacyPrescriptions}?page=$page',
        method: HttpMethodType.GET));
  }

  static Future<dynamic> getPrescriptionDetails(int prescriptionId) async {
    return await handleResponse(await buildHttpResponse(
        '${APIEndPoints.pharmacyPrescriptions}/$prescriptionId',
        method: HttpMethodType.GET));
  }

  /// Deprecated callback-based upload. Use [uploadPrescriptionAsync] instead.
  /// Callers should migrate to the async version which is consistent with the
  /// rest of the API layer and supports try/await/catch error handling.
  @Deprecated('Use uploadPrescriptionAsync which returns a prescription.')
  static Future<void> uploadPrescription({
    required List<String> imagePaths,
    String? notes,
    required String idempotencyKey,
    required VoidCallback onSuccess,
    required Function(dynamic) onError,
  }) async {
    var multiPartRequest =
        await getMultiPartRequest(APIEndPoints.pharmacyPrescriptions);
    if (notes != null) multiPartRequest.fields['notes'] = notes;

    for (String path in imagePaths) {
      multiPartRequest.files
          .add(await MultipartFile.fromPath('prescriptions[]', path));
    }

    multiPartRequest.headers.addAll({
      ...buildHeaderTokens(),
      ...criticalOperationHeaders(idempotencyKey),
    });

    await sendMultiPartRequest(multiPartRequest, onSuccess: (data) async {
      onSuccess.call();
    }, onError: (error) {
      onError.call(error);
    });
  }

  /// Async version of prescription upload consistent with the rest of the
  /// API layer. Returns the parsed response or throws on error.
  /// Callers should use try/await/catch:
  ///   try {
  ///     final res = await PharmacyApis.uploadPrescriptionAsync(imagePaths: [...]);
  ///   } catch (e) { toast(e.toString()); }
  static Future<PharmacyPrescription> uploadPrescriptionAsync({
    required List<String> imagePaths,
    String? notes,
    required String idempotencyKey,
  }) async {
    var multiPartRequest =
        await getMultiPartRequest(APIEndPoints.pharmacyPrescriptions);
    if (notes != null) multiPartRequest.fields['notes'] = notes;

    for (String path in imagePaths) {
      multiPartRequest.files
          .add(await MultipartFile.fromPath('prescriptions[]', path));
    }

    multiPartRequest.headers.addAll({
      ...buildHeaderTokens(),
      ...criticalOperationHeaders(idempotencyKey),
    });

    dynamic result;
    dynamic uploadError;

    await sendMultiPartRequest(multiPartRequest, onSuccess: (data) async {
      result = data;
    }, onError: (error) {
      uploadError = error;
    });

    if (uploadError != null) throw uploadError;
    return parsePrescriptionUploadResponse(result);
  }

  // Coupons
  static Future<dynamic> validateCoupon(String code, int pharmacyId) async {
    return await handleResponse(await buildHttpResponse(
        APIEndPoints.pharmacyValidateCoupon,
        request: {'code': code, 'pharmacy_id': pharmacyId},
        method: HttpMethodType.POST));
  }

  // Refunds
  static Future<dynamic> getRefunds({int page = 1}) async {
    return await handleResponse(await buildHttpResponse(
        '${APIEndPoints.pharmacyRefunds}?page=$page',
        method: HttpMethodType.GET));
  }

  static Future<dynamic> requestRefund(
      {required int orderId, required String reason, String? notes}) async {
    Map request = {
      'order_id': orderId,
      'reason': reason,
    };
    if (notes != null) request['notes'] = notes;
    return await handleResponse(await buildHttpResponse(
        '${APIEndPoints.pharmacyOrders}/$orderId/refund',
        request: request,
        method: HttpMethodType.POST));
  }

  // Notifications
  static Future<dynamic> getNotifications({int page = 1}) async {
    return await handleResponse(await buildHttpResponse(
        '${APIEndPoints.pharmacyNotifications}?page=$page',
        method: HttpMethodType.GET));
  }

  static Future<dynamic> getUnreadNotificationsCount() async {
    return await handleResponse(await buildHttpResponse(
        APIEndPoints.pharmacyUnreadNotificationsCount,
        method: HttpMethodType.GET));
  }

  static Future<BaseResponseModel> markNotificationAsRead(
      int notificationId) async {
    return BaseResponseModel.fromJson(await handleResponse(
        await buildHttpResponse(
            '${APIEndPoints.pharmacyNotifications}/$notificationId/read',
            method: HttpMethodType.POST)));
  }

  static Future<BaseResponseModel> markAllNotificationsAsRead() async {
    return BaseResponseModel.fromJson(await handleResponse(
        await buildHttpResponse(APIEndPoints.pharmacyReadAllNotifications,
            method: HttpMethodType.POST)));
  }
}

PharmacyPrescription parsePrescriptionUploadResponse(dynamic raw) {
  final decoded = raw is String ? jsonDecode(raw) : raw;
  if (decoded is! Map) {
    throw const FormatException('Invalid prescription upload response');
  }
  final response = Map<String, dynamic>.from(decoded);
  if (response['status'] != true) {
    throw FormatException(
      response['message']?.toString() ?? 'Prescription upload failed',
    );
  }
  final rawData = response['data'];
  if (rawData is! Map) {
    throw const FormatException('Prescription data is missing');
  }
  final data = Map<String, dynamic>.from(rawData);
  final nested = data['prescription'];
  final prescription = PharmacyPrescription.fromJson(
    nested is Map ? Map<String, dynamic>.from(nested) : data,
  );
  if ((prescription.id ?? 0) <= 0 ||
      prescription.status == PharmacyConstants.prescriptionRejected) {
    throw const FormatException('Prescription upload was not accepted');
  }
  return prescription;
}
