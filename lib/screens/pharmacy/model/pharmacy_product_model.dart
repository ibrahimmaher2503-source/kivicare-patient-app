import '../../../utils/localized_field.dart';
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
    final brand = json['brand'] is Map ? json['brand'] as Map : null;
    final category = json['category'] is Map ? json['category'] as Map : null;
    final productTypeObj =
        json['product_type'] is Map ? json['product_type'] as Map : null;

    final image = json['image'];
    final List<String> imageList;
    if (json['images'] != null) {
      imageList = pharmacyStringList(json['images']);
    } else if (image is String && image.trim().isNotEmpty) {
      imageList = [image];
    } else {
      imageList = const [];
    }

    final bool? inStock = json.containsKey('is_in_stock')
        ? pharmacyBool(json['is_in_stock'])
        : null;
    int? stockQty;
    if (json['stock_quantity'] != null) {
      stockQty = pharmacyInt(json['stock_quantity']);
    } else if (inStock == false) {
      stockQty = 0;
    }

    return PharmacyProduct(
      id: pharmacyInt(json['id']),
      name: pickLocalized(json, 'name', fallback: json['name']?.toString() ?? ''),
      brandName: brand != null ? brand['name']?.toString() : json['brand_name'],
      brandId: pharmacyInt(brand?['id'] ?? json['brand_id']),
      categoryName:
          category != null ? category['name']?.toString() : json['category_name'],
      categoryId: pharmacyInt(category?['id'] ?? json['category_id']),
      productType: productTypeObj != null
          ? productTypeObj['name']?.toString()
          : (json['product_type'] is String ? json['product_type'] : null),
      price: pharmacyDouble(json['price'] ?? json['price_from']),
      referencePrice:
          pharmacyDouble(json['reference_price'] ?? json['price_to']),
      stockQuantity: stockQty,
      maxOrderQuantity: pharmacyInt(json['max_order_quantity']),
      images: imageList,
      isPrescriptionRequired: pharmacyBool(
          json['requires_prescription'] ?? json['prescription_required']),
      description: pickLocalized(json, 'description',
          fallback: json['description']?.toString() ?? ''),
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
