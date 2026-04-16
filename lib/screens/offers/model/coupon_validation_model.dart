class CouponValidation {
  bool success;
  int? offerId;
  String code;
  String title;
  String discountType;
  num discountValue;
  num originalPrice;
  num discountAmount;
  num finalPrice;
  String terms;
  String failureReason;
  String message;

  CouponValidation({
    this.success = false,
    this.offerId,
    this.code = "",
    this.title = "",
    this.discountType = "",
    this.discountValue = 0,
    this.originalPrice = 0,
    this.discountAmount = 0,
    this.finalPrice = 0,
    this.terms = "",
    this.failureReason = "",
    this.message = "",
  });

  factory CouponValidation.fromJson(Map<String, dynamic> json) {
    // Handle nested data structure
    final data = json['data'] is Map<String, dynamic> ? json['data'] : json;

    return CouponValidation(
      success: json['status'] is bool ? json['status'] : false,
      offerId: data['offer_id'] is int ? data['offer_id'] : null,
      code: data['code'] is String ? data['code'] : "",
      title: data['title'] is String ? data['title'] : "",
      discountType: data['discount_type'] is String ? data['discount_type'] : "",
      discountValue: data['discount_value'] is num ? data['discount_value'] : 0,
      originalPrice: data['original_price'] is num ? data['original_price'] : 0,
      discountAmount: data['discount_amount'] is num ? data['discount_amount'] : 0,
      finalPrice: data['final_price'] is num ? data['final_price'] : 0,
      terms: data['terms'] is String ? data['terms'] : "",
      failureReason: data['reason'] is String ? data['reason'] : "",
      message: json['message'] is String ? json['message'] : "",
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = {};
    json['status'] = success;
    final Map<String, dynamic> data = {};
    if (offerId != null) {
      data['offer_id'] = offerId;
    }
    data['code'] = code;
    data['title'] = title;
    data['discount_type'] = discountType;
    data['discount_value'] = discountValue;
    data['original_price'] = originalPrice;
    data['discount_amount'] = discountAmount;
    data['final_price'] = finalPrice;
    data['terms'] = terms;
    if (failureReason.isNotEmpty) {
      data['reason'] = failureReason;
    }
    json['data'] = data;
    json['message'] = message;
    return json;
  }

  // Computed getter
  bool get isValid => success;
}
