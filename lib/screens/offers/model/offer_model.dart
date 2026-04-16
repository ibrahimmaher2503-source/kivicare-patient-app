import '../../../utils/app_common.dart';

class Offer {
  int id;
  String slug;
  String titleEn;
  String titleAr;
  String shortLabelEn;
  String shortLabelAr;
  String descriptionEn;
  String descriptionAr;
  String termsEn;
  String termsAr;
  String discountType;
  num discountValue;
  String code;
  bool autoApply;
  DateTime? startsAt;
  DateTime? endsAt;
  bool isFlash;
  String bannerText;
  String bannerImage;
  int servicesCount;
  int branchesCount;
  num maxDiscountAmount;
  num minimumOrderAmount;

  Offer({
    this.id = -1,
    this.slug = "",
    this.titleEn = "",
    this.titleAr = "",
    this.shortLabelEn = "",
    this.shortLabelAr = "",
    this.descriptionEn = "",
    this.descriptionAr = "",
    this.termsEn = "",
    this.termsAr = "",
    this.discountType = "",
    this.discountValue = 0,
    this.code = "",
    this.autoApply = false,
    this.startsAt,
    this.endsAt,
    this.isFlash = false,
    this.bannerText = "",
    this.bannerImage = "",
    this.servicesCount = 0,
    this.branchesCount = 0,
    this.maxDiscountAmount = 0,
    this.minimumOrderAmount = 0,
  });

  factory Offer.fromJson(Map<String, dynamic> json) {
    return Offer(
      id: json['id'] is int ? json['id'] : -1,
      slug: json['slug'] is String ? json['slug'] : "",
      titleEn: json['title_en'] is String ? json['title_en'] : "",
      titleAr: json['title_ar'] is String ? json['title_ar'] : "",
      shortLabelEn: json['short_label_en'] is String ? json['short_label_en'] : "",
      shortLabelAr: json['short_label_ar'] is String ? json['short_label_ar'] : "",
      descriptionEn: json['description_en'] is String ? json['description_en'] : "",
      descriptionAr: json['description_ar'] is String ? json['description_ar'] : "",
      termsEn: json['terms_en'] is String ? json['terms_en'] : "",
      termsAr: json['terms_ar'] is String ? json['terms_ar'] : "",
      discountType: json['discount_type'] is String ? json['discount_type'] : "",
      discountValue: json['discount_value'] is num ? json['discount_value'] : 0,
      code: json['code'] is String ? json['code'] : "",
      autoApply: json['auto_apply'] is bool ? json['auto_apply'] : false,
      startsAt: json['starts_at'] is String ? DateTime.tryParse(json['starts_at']) : null,
      endsAt: json['ends_at'] is String ? DateTime.tryParse(json['ends_at']) : null,
      isFlash: json['is_flash'] is bool ? json['is_flash'] : false,
      bannerText: json['banner_text'] is String ? json['banner_text'] : "",
      bannerImage: json['banner_image'] is String ? json['banner_image'] : "",
      servicesCount: json['services_count'] is int ? json['services_count'] : 0,
      branchesCount: json['branches_count'] is int ? json['branches_count'] : 0,
      maxDiscountAmount: json['max_discount_amount'] is num ? json['max_discount_amount'] : 0,
      minimumOrderAmount: json['minimum_order_amount'] is num ? json['minimum_order_amount'] : 0,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['id'] = id;
    data['slug'] = slug;
    data['title_en'] = titleEn;
    data['title_ar'] = titleAr;
    data['short_label_en'] = shortLabelEn;
    data['short_label_ar'] = shortLabelAr;
    data['description_en'] = descriptionEn;
    data['description_ar'] = descriptionAr;
    data['terms_en'] = termsEn;
    data['terms_ar'] = termsAr;
    data['discount_type'] = discountType;
    data['discount_value'] = discountValue;
    data['code'] = code;
    data['auto_apply'] = autoApply;
    if (startsAt != null) {
      data['starts_at'] = startsAt!.toIso8601String();
    }
    if (endsAt != null) {
      data['ends_at'] = endsAt!.toIso8601String();
    }
    data['is_flash'] = isFlash;
    data['banner_text'] = bannerText;
    data['banner_image'] = bannerImage;
    data['services_count'] = servicesCount;
    data['branches_count'] = branchesCount;
    data['max_discount_amount'] = maxDiscountAmount;
    data['minimum_order_amount'] = minimumOrderAmount;
    return data;
  }

  // Localized display getters
  String get displayTitle => selectedLanguageCode.value == 'ar' ? titleAr : titleEn;
  String get displayLabel => selectedLanguageCode.value == 'ar' ? shortLabelAr : shortLabelEn;
  String get displayDescription => selectedLanguageCode.value == 'ar' ? descriptionAr : descriptionEn;
  String get displayTerms => selectedLanguageCode.value == 'ar' ? termsAr : termsEn;

  // Status getters
  bool get isExpired => endsAt != null && endsAt!.isBefore(DateTime.now());
  Duration? get timeRemaining => endsAt?.difference(DateTime.now());
  bool get isActive => !isExpired && (startsAt == null || startsAt!.isBefore(DateTime.now()));
}
