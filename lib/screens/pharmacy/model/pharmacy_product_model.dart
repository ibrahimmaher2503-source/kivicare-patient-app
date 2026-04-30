import 'pharmacy_parsers.dart';

class PharmacyProduct {
  int? id;
  String? name;
  String? brandName;
  int? brandId;
  String? categoryName;
  int? categoryId;
  String? productType;
  double? price;
  double? referencePrice;
  int? stockQuantity;
  int? maxOrderQuantity;
  List<String>? images;
  bool? isPrescriptionRequired;
  String? description;
  String? unit;
  String? dosage;
  String? manufacturer;
  double? rating;
  int? reviewCount;

  PharmacyProduct({
    this.id,
    this.name,
    this.brandName,
    this.brandId,
    this.categoryName,
    this.categoryId,
    this.productType,
    this.price,
    this.referencePrice,
    this.stockQuantity,
    this.maxOrderQuantity,
    this.images,
    this.isPrescriptionRequired,
    this.description,
    this.unit,
    this.dosage,
    this.manufacturer,
    this.rating,
    this.reviewCount,
  });

  factory PharmacyProduct.fromJson(Map<String, dynamic> json) {
    return PharmacyProduct(
      id: pharmacyInt(json['id']),
      name: json['name'],
      brandName: json['brand_name'],
      brandId: pharmacyInt(json['brand_id']),
      categoryName: json['category_name'],
      categoryId: pharmacyInt(json['category_id']),
      productType: json['product_type'],
      price: pharmacyDouble(json['price']),
      referencePrice: pharmacyDouble(json['reference_price']),
      stockQuantity: pharmacyInt(json['stock_quantity']),
      maxOrderQuantity: pharmacyInt(json['max_order_quantity']),
      images: pharmacyStringList(json['images']),
      isPrescriptionRequired: pharmacyBool(json['prescription_required']),
      description: json['description'],
      unit: json['unit'],
      dosage: json['dosage'],
      manufacturer: json['manufacturer'],
      rating: pharmacyDouble(json['rating']),
      reviewCount: pharmacyInt(json['review_count']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'brand_name': brandName,
      'brand_id': brandId,
      'category_name': categoryName,
      'category_id': categoryId,
      'product_type': productType,
      'price': price,
      'reference_price': referencePrice,
      'stock_quantity': stockQuantity,
      'max_order_quantity': maxOrderQuantity,
      'images': images,
      'prescription_required': isPrescriptionRequired,
      'description': description,
      'unit': unit,
      'dosage': dosage,
      'manufacturer': manufacturer,
      'rating': rating,
      'review_count': reviewCount,
    };
  }
}

class PharmacyProductListRes {
  List<PharmacyProduct>? data;
  int? total;

  PharmacyProductListRes({this.data, this.total});

  factory PharmacyProductListRes.fromJson(Map<String, dynamic> json) {
    return PharmacyProductListRes(
      data: json['data'] != null
          ? (json['data'] as List)
              .map((i) => PharmacyProduct.fromJson(i))
              .toList()
          : null,
      total: json['total'],
    );
  }
}
