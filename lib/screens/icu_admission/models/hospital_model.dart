import 'icu_department_model.dart';

class Hospital {
  final int id;
  final String name;
  final String? description;
  final String? phone;
  final String? emergencyPhone;
  final String? email;
  final String? addressLine;
  final int? governorateId;
  final String? governorateName;
  final int? cityId;
  final String? cityName;
  final double? latitude;
  final double? longitude;
  final String? imageUrl;
  final List<String> amenities;
  final List<IcuDepartment> icuDepartments;
  final bool hasAvailableBeds;

  Hospital({
    required this.id,
    required this.name,
    this.description,
    this.phone,
    this.emergencyPhone,
    this.email,
    this.addressLine,
    this.governorateId,
    this.governorateName,
    this.cityId,
    this.cityName,
    this.latitude,
    this.longitude,
    this.imageUrl,
    this.amenities = const [],
    this.icuDepartments = const [],
    this.hasAvailableBeds = false,
  });

  factory Hospital.fromJson(Map<String, dynamic> json) {
    return Hospital(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      description: json['description'],
      phone: json['phone'],
      emergencyPhone: json['emergency_phone'],
      email: json['email'],
      addressLine: json['address_line'],
      governorateId: json['governorate_id'],
      governorateName: json['governorate_name'],
      cityId: json['city_id'],
      cityName: json['city_name'],
      latitude: json['latitude'] != null ? double.tryParse(json['latitude'].toString()) : null,
      longitude: json['longitude'] != null ? double.tryParse(json['longitude'].toString()) : null,
      imageUrl: json['image_url'],
      amenities: json['amenities'] != null ? List<String>.from(json['amenities']) : [],
      icuDepartments: json['icu_departments'] != null
          ? (json['icu_departments'] as List).map((i) => IcuDepartment.fromJson(i)).toList()
          : [],
      hasAvailableBeds: json['has_available_beds'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'phone': phone,
      'emergency_phone': emergencyPhone,
      'email': email,
      'address_line': addressLine,
      'governorate_id': governorateId,
      'governorate_name': governorateName,
      'city_id': cityId,
      'city_name': cityName,
      'latitude': latitude,
      'longitude': longitude,
      'image_url': imageUrl,
      'amenities': amenities,
      'icu_departments': icuDepartments.map((i) => i.toJson()).toList(),
      'has_available_beds': hasAvailableBeds,
    };
  }
}
