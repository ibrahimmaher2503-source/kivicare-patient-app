class PharmacyFilterListResponse {
  bool status;
  List<PharmacyFilterOption> data;

  PharmacyFilterListResponse({this.status = false, this.data = const []});

  factory PharmacyFilterListResponse.fromJson(Map<String, dynamic> json) {
    List<dynamic> items = [];
    if (json['data'] is List) {
      items = json['data'];
    }
    return PharmacyFilterListResponse(
      status: json['status'] is bool ? json['status'] : false,
      data: items.map((x) => PharmacyFilterOption.fromJson(Map<String, dynamic>.from(x))).toList(),
    );
  }
}

class PharmacyFilterOption {
  int id;
  String name;
  String? nameAr;
  String? nameEn;

  PharmacyFilterOption({this.id = -1, this.name = '', this.nameAr, this.nameEn});

  factory PharmacyFilterOption.fromJson(Map<String, dynamic> json) {
    return PharmacyFilterOption(
      id: json['id'] is int ? json['id'] : -1,
      name: json['name'] is String ? json['name'] : '',
      nameAr: json['name_ar'] is String ? json['name_ar'] : null,
      nameEn: json['name_en'] is String ? json['name_en'] : null,
    );
  }
}
