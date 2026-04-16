class ActiveOffer {
  int id;
  String title;
  String label;
  String discountType;
  num discountValue;
  String code;
  bool autoApply;
  DateTime? endsAt;

  ActiveOffer({
    this.id = -1,
    this.title = "",
    this.label = "",
    this.discountType = "",
    this.discountValue = 0,
    this.code = "",
    this.autoApply = false,
    this.endsAt,
  });

  factory ActiveOffer.fromJson(Map<String, dynamic> json) {
    return ActiveOffer(
      id: json['id'] is int ? json['id'] : -1,
      title: json['title'] is String ? json['title'] : "",
      label: json['label'] is String ? json['label'] : "",
      discountType: json['discount_type'] is String ? json['discount_type'] : "",
      discountValue: json['discount_value'] is num ? json['discount_value'] : 0,
      code: json['code'] is String ? json['code'] : "",
      autoApply: json['auto_apply'] is bool ? json['auto_apply'] : false,
      endsAt: json['ends_at'] is String ? DateTime.tryParse(json['ends_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['id'] = id;
    data['title'] = title;
    data['label'] = label;
    data['discount_type'] = discountType;
    data['discount_value'] = discountValue;
    data['code'] = code;
    data['auto_apply'] = autoApply;
    if (endsAt != null) {
      data['ends_at'] = endsAt!.toIso8601String();
    }
    return data;
  }

  // Computed getters
  bool get isExpired => endsAt != null && endsAt!.isBefore(DateTime.now());

  String get formattedDiscount {
    if (discountType == 'percentage') {
      return '${discountValue.toInt()}%';
    } else {
      return 'EGP ${discountValue.toStringAsFixed(0)}';
    }
  }
}
