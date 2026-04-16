import 'package:nb_utils/nb_utils.dart';

import '../network/network_utils.dart';
import '../screens/offers/model/active_offer_model.dart';
import '../screens/offers/model/offer_model.dart';
import '../screens/offers/model/discount_calculation_model.dart';
import '../screens/offers/model/coupon_validation_model.dart';
import '../utils/api_end_points.dart';

class OffersApis {
  /// Get public offers with pagination
  static Future<Map<String, dynamic>> getPublicOffers({
    int page = 1,
    int perPage = 15,
  }) async {
    final response = await handleResponse(
      await buildHttpResponse(
        '${APIEndPoints.offersPublic}?page=$page&per_page=$perPage',
        method: HttpMethodType.GET,
      ),
    );

    return {
      'offers': response['data'] is List
          ? List<Offer>.from(response['data'].map((x) => Offer.fromJson(x)))
          : <Offer>[],
      'meta': response['meta'] ?? {},
    };
  }

  /// Get single offer by slug
  static Future<Offer?> getOfferBySlug(String slug) async {
    final response = await handleResponse(
      await buildHttpResponse(
        APIEndPoints.offersPublicBySlug(slug),
        method: HttpMethodType.GET,
      ),
    );

    if (response['data'] is Map<String, dynamic>) {
      return Offer.fromJson(response['data']);
    }
    return null;
  }

  /// Get eligible offers for a specific service
  static Future<List<ActiveOffer>> getServiceOffers({
    required int serviceId,
    int? branchId,
    int? clinicId,
    num? serviceCharge,
    String? channel,
  }) async {
    String queryParams = '';
    if (branchId != null) queryParams += '&branch_id=$branchId';
    if (clinicId != null) queryParams += '&clinic_id=$clinicId';
    if (serviceCharge != null) queryParams += '&service_charge=$serviceCharge';
    if (channel != null) queryParams += '&channel=$channel';

    final response = await handleResponse(
      await buildHttpResponse(
        '${APIEndPoints.serviceOffers(serviceId)}?${queryParams.substring(1)}',
        method: HttpMethodType.GET,
      ),
    );

    if (response['data'] is List) {
      return List<ActiveOffer>.from(
        response['data'].map((x) => ActiveOffer.fromJson(x)),
      );
    }
    return [];
  }

  /// Validate a coupon code
  static Future<CouponValidation> validateCoupon({
    required String code,
    required int serviceId,
    required num serviceCharge,
    int? branchId,
    int? clinicId,
    String? channel,
    String? paymentMethod,
  }) async {
    final Map<String, dynamic> request = {
      'code': code,
      'service_id': serviceId,
      'service_charge': serviceCharge,
    };

    if (branchId != null) request['branch_id'] = branchId;
    if (clinicId != null) request['clinic_id'] = clinicId;
    if (channel != null) request['channel'] = channel;
    if (paymentMethod != null) request['payment_method'] = paymentMethod;

    final response = await handleResponse(
      await buildHttpResponse(
        APIEndPoints.validateCoupon,
        method: HttpMethodType.POST,
        request: request,
      ),
    );

    return CouponValidation.fromJson(response);
  }

  /// Calculate discount preview
  static Future<DiscountCalculation> calculateDiscount({
    required int serviceId,
    required num serviceCharge,
    String? couponCode,
    int? offerId,
    int? branchId,
    int? clinicId,
    String? channel,
    String? paymentMethod,
  }) async {
    final Map<String, dynamic> request = {
      'service_id': serviceId,
      'service_charge': serviceCharge,
    };

    if (couponCode != null) request['coupon_code'] = couponCode;
    if (offerId != null) request['offer_id'] = offerId;
    if (branchId != null) request['branch_id'] = branchId;
    if (clinicId != null) request['clinic_id'] = clinicId;
    if (channel != null) request['channel'] = channel;
    if (paymentMethod != null) request['payment_method'] = paymentMethod;

    final response = await handleResponse(
      await buildHttpResponse(
        APIEndPoints.calculateDiscount,
        method: HttpMethodType.POST,
        request: request,
      ),
    );

    return DiscountCalculation.fromJson(response);
  }

  /// Apply offer to current booking session
  static Future<DiscountCalculation> applyOffer({
    required int offerId,
    required int serviceId,
    required num serviceCharge,
    int? branchId,
    String? channel,
  }) async {
    final Map<String, dynamic> request = {
      'offer_id': offerId,
      'service_id': serviceId,
      'service_charge': serviceCharge,
    };

    if (branchId != null) request['branch_id'] = branchId;
    if (channel != null) request['channel'] = channel;

    final response = await handleResponse(
      await buildHttpResponse(
        APIEndPoints.applyOffer,
        method: HttpMethodType.POST,
        request: request,
      ),
    );

    return DiscountCalculation.fromJson(response);
  }

  /// Remove currently applied offer
  static Future<DiscountCalculation> removeOffer({
    required num serviceCharge,
  }) async {
    final request = {
      'service_charge': serviceCharge,
    };

    final response = await handleResponse(
      await buildHttpResponse(
        APIEndPoints.removeOffer,
        method: HttpMethodType.POST,
        request: request,
      ),
    );

    return DiscountCalculation.fromJson(response);
  }
}
