import 'package:nb_utils/nb_utils.dart';
import 'facility_type.dart';

class FacilityModel {
  int id;
  String name;
  String? logo;
  String? coverImage;
  FacilityType type;
  String? description;
  double? rating;
  int reviewsCount;
  String address;
  String? city;
  String? governorate;
  String? phone;
  String? email;
  double? latitude;
  double? longitude;
  List<String> services;
  int? availableTestsCount;
  double? distanceKm;
  double? priceFrom;

  FacilityModel({
    this.id = 0,
    this.name = '',
    this.logo,
    this.coverImage,
    this.type = FacilityType.lab,
    this.description,
    this.rating,
    this.reviewsCount = 0,
    this.address = '',
    this.city,
    this.governorate,
    this.phone,
    this.email,
    this.latitude,
    this.longitude,
    this.services = const [],
    this.availableTestsCount,
    this.distanceKm,
    this.priceFrom,
  });

  factory FacilityModel.fromJson(
    Map<String, dynamic> json, {
    FacilityType? fallbackType,
  }) {
    final facilityType = json['facility_type'];

    return FacilityModel(
      id: json['id'] is int ? json['id'] : json['id'].toString().toInt(),
      name: json['name'] ?? '',
      logo: json['logo'],
      coverImage: json['cover_image'],
      type: facilityType == null
          ? fallbackType ?? FacilityType.lab
          : FacilityType.fromString(facilityType.toString()),
      description: json['description'],
      rating: json['rating']?.toDouble(),
      reviewsCount: json['reviews_count'] ?? 0,
      address: json['address'] ?? '',
      city: json['city'] is Map ? json['city']['name'] : json['city'],
      governorate: json['governorate'] is Map
          ? json['governorate']['name']
          : json['governorate'],
      phone: json['phone'],
      email: json['email'],
      latitude: json['latitude']?.toDouble(),
      longitude: json['longitude']?.toDouble(),
      services:
          json['services'] is List ? List<String>.from(json['services']) : [],
      availableTestsCount: json['available_tests_count']?.toInt(),
      distanceKm: json['distance_km']?.toDouble(),
      priceFrom: json['price_from']?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'logo': logo,
      'cover_image': coverImage,
      'facility_type': type.apiValue,
      'description': description,
      'rating': rating,
      'reviews_count': reviewsCount,
      'address': address,
      'city': city,
      'governorate': governorate,
      'phone': phone,
      'email': email,
      'latitude': latitude,
      'longitude': longitude,
      'services': services,
      'available_tests_count': availableTestsCount,
      'distance_km': distanceKm,
      'price_from': priceFrom,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FacilityModel &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          type == other.type;

  @override
  int get hashCode => id.hashCode ^ type.hashCode;
}
