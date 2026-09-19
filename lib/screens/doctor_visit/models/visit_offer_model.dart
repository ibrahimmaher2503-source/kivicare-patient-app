class VisitOfferModel {
  final int id;
  final String code;
  final double discount;

  VisitOfferModel({
    this.id = -1,
    this.code = '',
    this.discount = 0.0,
  });

  factory VisitOfferModel.fromJson(Map<String, dynamic> json) {
    return VisitOfferModel(
      id: json['id'] is int ? json['id'] : -1,
      code: json['code'] is String ? json['code'] : '',
      discount: json['discount'] != null ? (json['discount'] as num).toDouble() : 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'code': code,
      'discount': discount,
    };
  }
}
