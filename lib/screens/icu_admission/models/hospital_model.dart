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

  String get formattedLocation => [cityName, governorateName]
      .whereType<String>()
      .map((part) => part.trim())
      .where((part) => part.isNotEmpty)
      .join(', ');

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
    // Backend returns governorate/city as nested objects: {id, name}
    final governorate = json['governorate'] as Map<String, dynamic>?;
    final city = json['city'] as Map<String, dynamic>?;

    // Backend returns available_beds_total (int), not has_available_beds (bool)
    final availableBedsTotal = json['available_beds_total'];
    final hasAvailableBeds = availableBedsTotal != null
        ? (availableBedsTotal is int ? availableBedsTotal > 0 : false)
        : (json['has_available_beds'] ?? false);

    return Hospital(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      description: json['description'],
      phone: json['phone'],
      emergencyPhone: json['emergency_phone'],
      email: json['email'],
      // backend returns 'address' not 'address_line'
      addressLine: json['address'] ?? json['address_line'],
      // backend returns nested governorate object
      governorateId: governorate?['id'] ?? json['governorate_id'],
      governorateName: governorate?['name'] ?? json['governorate_name'],
      cityId: city?['id'] ?? json['city_id'],
      cityName: city?['name'] ?? json['city_name'],
      latitude: json['latitude'] != null
          ? double.tryParse(json['latitude'].toString())
          : null,
      longitude: json['longitude'] != null
          ? double.tryParse(json['longitude'].toString())
          : null,
      // backend returns 'logo_url' not 'image_url'
      imageUrl: json['logo_url'] ?? json['image_url'],
      amenities:
          json['amenities'] != null ? List<String>.from(json['amenities']) : [],
      icuDepartments: json['departments'] != null
          ? (json['departments'] as List)
              .map((i) => IcuDepartment.fromJson(i))
              .toList()
          : json['icu_departments'] != null
              ? (json['icu_departments'] as List)
                  .map((i) => IcuDepartment.fromJson(i))
                  .toList()
              : [],
      hasAvailableBeds: hasAvailableBeds,
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
      'address': addressLine,
      'governorate_id': governorateId,
      'governorate_name': governorateName,
      'city_id': cityId,
      'city_name': cityName,
      'latitude': latitude,
      'longitude': longitude,
      'logo_url': imageUrl,
      'amenities': amenities,
      'departments': icuDepartments.map((i) => i.toJson()).toList(),
      'available_beds_total': hasAvailableBeds ? 1 : 0,
    };
  }
}
