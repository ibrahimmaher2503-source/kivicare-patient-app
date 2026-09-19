import 'pharmacy_parsers.dart';

class PharmacyCategory {
  int? id;
  String? name;
  String? image;
  int? parentId;
  bool? hasSubcategories;

  PharmacyCategory({
    this.id,
    this.name,
    this.image,
    this.parentId,
    this.hasSubcategories,
  });

  factory PharmacyCategory.fromJson(Map<String, dynamic> json) {
    return PharmacyCategory(
      id: pharmacyInt(json['id']),
      name: json['name'],
      image:
          json['image'] is String && (json['image'] as String).trim().isNotEmpty
              ? (json['image'] as String).trim()
              : null,
      parentId: pharmacyInt(json['parent_id']),
      hasSubcategories: pharmacyBool(json['has_subcategories']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'image': image,
      'parent_id': parentId,
      'has_subcategories': hasSubcategories,
    };
  }
}

class PharmacyCategoryListRes {
  List<PharmacyCategory>? data;

  PharmacyCategoryListRes({this.data});

  factory PharmacyCategoryListRes.fromJson(Map<String, dynamic> json) {
    return PharmacyCategoryListRes(
      data: json['data'] != null
          ? (json['data'] as List)
              .map((i) => PharmacyCategory.fromJson(i))
              .toList()
          : null,
    );
  }
}
