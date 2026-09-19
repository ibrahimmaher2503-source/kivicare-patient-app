import 'pharmacy_parsers.dart';

class Pharmacy {
  int? id;
  String? name;
  String? address;
  String? image;
  double? distance;
  double? deliveryFee;
  String? estimatedDeliveryTime;
  double? rating;
  bool? canFulfillFullCart;

  Pharmacy({
    this.id,
    this.name,
    this.address,
    this.image,
    this.distance,
    this.deliveryFee,
    this.estimatedDeliveryTime,
    this.rating,
    this.canFulfillFullCart,
  });

  factory Pharmacy.fromJson(Map<String, dynamic> json) {
    return Pharmacy(
      id: pharmacyInt(json['id']),
      name: json['name'],
      address: json['address'],
      image: json['image'],
      distance: pharmacyDouble(json['distance']),
      deliveryFee: pharmacyDouble(json['delivery_fee']),
      estimatedDeliveryTime: json['estimated_delivery_time'],
      rating: pharmacyDouble(json['rating']),
      canFulfillFullCart: pharmacyBool(json['can_fulfill_full_cart']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'image': image,
      'distance': distance,
      'delivery_fee': deliveryFee,
      'estimated_delivery_time': estimatedDeliveryTime,
      'rating': rating,
      'can_fulfill_full_cart': canFulfillFullCart,
    };
  }
}

class AvailablePharmaciesRes {
  List<Pharmacy>? data;

  AvailablePharmaciesRes({this.data});

  factory AvailablePharmaciesRes.fromJson(Map<String, dynamic> json) {
    return AvailablePharmaciesRes(
      data: json['data'] != null
          ? (json['data'] as List).map((i) => Pharmacy.fromJson(i)).toList()
          : null,
    );
  }
}
