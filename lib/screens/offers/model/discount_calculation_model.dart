class DiscountBreakdownItem {
  int offerId;
  String title;
  String code;
  String discountType;
  num discountAmount;

  DiscountBreakdownItem({
    this.offerId = -1,
    this.title = "",
    this.code = "",
    this.discountType = "",
    this.discountAmount = 0,
  });

  factory DiscountBreakdownItem.fromJson(Map<String, dynamic> json) {
    return DiscountBreakdownItem(
      offerId: json['offer_id'] is int ? json['offer_id'] : -1,
      title: json['title'] is String ? json['title'] : "",
      code: json['code'] is String ? json['code'] : "",
      discountType: json['discount_type'] is String ? json['discount_type'] : "",
      discountAmount: json['discount_amount'] is num ? json['discount_amount'] : 0,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['offer_id'] = offerId;
    data['title'] = title;
    data['code'] = code;
    data['discount_type'] = discountType;
    data['discount_amount'] = discountAmount;
    return data;
  }
}

class DiscountCalculation {
  num originalPrice;
  num discountAmount;
  num discountedPrice;
  int? appliedOfferId;
  String appliedOfferCode;
  String appliedOfferTitle;
  List<DiscountBreakdownItem> discountBreakdown;

  DiscountCalculation({
    this.originalPrice = 0,
    this.discountAmount = 0,
    this.discountedPrice = 0,
    this.appliedOfferId,
    this.appliedOfferCode = "",
    this.appliedOfferTitle = "",
    this.discountBreakdown = const [],
  });

  factory DiscountCalculation.fromJson(Map<String, dynamic> json) {
    // Handle nested data structure
    final data = json['data'] is Map<String, dynamic> ? json['data'] : json;

    return DiscountCalculation(
      originalPrice: data['original_price'] is num ? data['original_price'] : 0,
      discountAmount: data['discount_amount'] is num ? data['discount_amount'] : 0,
      discountedPrice: data['discounted_price'] is num ? data['discounted_price'] : 0,
      appliedOfferId: data['applied_offer_id'] is int ? data['applied_offer_id'] : null,
      appliedOfferCode: data['applied_offer_code'] is String ? data['applied_offer_code'] : "",
      appliedOfferTitle: data['applied_offer_title'] is String ? data['applied_offer_title'] : "",
      discountBreakdown: data['discount_breakdown'] is List
          ? List<DiscountBreakdownItem>.from(
              data['discount_breakdown'].map((x) => DiscountBreakdownItem.fromJson(x)))
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['original_price'] = originalPrice;
    data['discount_amount'] = discountAmount;
    data['discounted_price'] = discountedPrice;
    if (appliedOfferId != null) {
      data['applied_offer_id'] = appliedOfferId;
    }
    data['applied_offer_code'] = appliedOfferCode;
    data['applied_offer_title'] = appliedOfferTitle;
    data['discount_breakdown'] = discountBreakdown.map((x) => x.toJson()).toList();
    return data;
  }
}
