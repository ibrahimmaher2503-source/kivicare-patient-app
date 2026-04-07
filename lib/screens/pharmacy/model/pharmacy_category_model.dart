class PharmacyCategoryListResponse {
  bool status;
  List<PharmacyCategory> data;

  PharmacyCategoryListResponse({this.status = false, this.data = const []});

  factory PharmacyCategoryListResponse.fromJson(Map<String, dynamic> json) {
    List<dynamic> items = [];
    if (json['data'] is List) {
      items = json['data'];
    }
    return PharmacyCategoryListResponse(
      status: json['status'] is bool ? json['status'] : false,
      data: items.map((x) => PharmacyCategory.fromJson(Map<String, dynamic>.from(x))).toList(),
    );
  }
}

class PharmacyCategory {
  int id;
  String name;
  String nameAr;
  String nameEn;
  String? image;
  int sortOrder;

  PharmacyCategory({
    this.id = -1,
    this.name = '',
    this.nameAr = '',
    this.nameEn = '',
    this.image,
    this.sortOrder = 0,
  });

  factory PharmacyCategory.fromJson(Map<String, dynamic> json) {
    return PharmacyCategory(
      id: json['id'] is int ? json['id'] : -1,
      name: json['name'] is String ? json['name'] : '',
      nameAr: json['name_ar'] is String ? json['name_ar'] : '',
      nameEn: json['name_en'] is String ? json['name_en'] : '',
      image: json['image'] is String ? json['image'] : null,
      sortOrder: json['sort_order'] is int ? json['sort_order'] : 0,
    );
  }
}
