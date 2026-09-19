import 'pharmacy_product_model.dart';
import 'pharmacy_parsers.dart';

class PharmacyCart {
  List<PharmacyCartItem>? items;
  double? subtotal;
  double? discount;
  String? couponCode;

  PharmacyCart({
    this.items,
    this.subtotal,
    this.discount,
    this.couponCode,
  });

  factory PharmacyCart.fromJson(Map<String, dynamic> json) {
    return PharmacyCart(
      items: json['items'] != null
          ? (json['items'] as List)
              .map((i) => PharmacyCartItem.fromJson(i))
              .toList()
          : [],
      subtotal: pharmacyDouble(json['subtotal']) ?? 0.0,
      discount: pharmacyDouble(json['discount']) ?? 0.0,
      couponCode: json['coupon_code'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'items': items?.map((e) => e.toJson()).toList(),
      'subtotal': subtotal,
      'discount': discount,
      'coupon_code': couponCode,
    };
  }
}

class PharmacyCartItem {
  int? id;
  int? productId;
  String? name;
  String? brandName;
  String? image;
  double? unitPrice;
  int? quantity;
  double? lineTotal;
  PharmacyProduct? product;

  PharmacyCartItem({
    this.id,
    this.productId,
    this.name,
    this.brandName,
    this.image,
    this.unitPrice,
    this.quantity,
    this.lineTotal,
    this.product,
  });

  factory PharmacyCartItem.fromJson(Map<String, dynamic> json) {
    return PharmacyCartItem(
      id: pharmacyInt(json['id']),
      productId: pharmacyInt(json['product_id']),
      name: json['name'],
      brandName: json['brand_name'],
      image: json['image'],
      unitPrice: pharmacyDouble(json['unit_price']),
      quantity: pharmacyInt(json['quantity']),
      lineTotal: pharmacyDouble(json['line_total']),
      product: json['product'] != null
          ? PharmacyProduct.fromJson(json['product'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'product_id': productId,
      'name': name,
      'brand_name': brandName,
      'image': image,
      'unit_price': unitPrice,
      'quantity': quantity,
      'line_total': lineTotal,
      'product': product?.toJson(),
    };
  }
}
