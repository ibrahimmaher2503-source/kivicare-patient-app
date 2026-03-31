import '../../../models/governorate_model.dart';
import '../../../models/city_model.dart';

class RadiologyCenterListResponse {
  bool status;
  List<RadiologyCenter> data;
  int currentPage;
  int lastPage;
  int perPage;
  int total;

  RadiologyCenterListResponse({
    this.status = false,
    this.data = const [],
    this.currentPage = 1,
    this.lastPage = 1,
    this.perPage = 15,
    this.total = 0,
  });

  factory RadiologyCenterListResponse.fromJson(Map<String, dynamic> json) {
    List<dynamic> items = [];
    if (json['data'] is List) {
      items = json['data'];
    } else if (json['data'] is Map && json['data']['items'] is List) {
      items = json['data']['items'];
    }
    int currPage = 1;
    int lastPg = 1;
    int perPg = 15;
    int tot = 0;
    if (json['meta'] is Map) {
      currPage = json['meta']['current_page'] ?? 1;
      lastPg = json['meta']['last_page'] ?? 1;
      perPg = json['meta']['per_page'] ?? 15;
      tot = json['meta']['total'] ?? 0;
    } else if (json['data'] is Map && json['data']['pagination'] is Map) {
      final p = json['data']['pagination'];
      currPage = p['current_page'] ?? 1;
      lastPg = p['last_page'] ?? 1;
      perPg = p['per_page'] ?? 15;
      tot = p['total'] ?? 0;
    }
    return RadiologyCenterListResponse(
      status: json['status'] is bool ? json['status'] : false,
      data: items.map((e) => RadiologyCenter.fromJson(Map<String, dynamic>.from(e))).toList(),
      currentPage: currPage,
      lastPage: lastPg,
      perPage: perPg,
      total: tot,
    );
  }
}

class RadiologyCenter {
  int id;
  String name;
  String description;
  String address;
  String contactNumber;
  String email;
  String profileImage;
  String status;
  double rating;
  List<String> scanTypes;
  String operatingHours;
  String pricing;
  Governorate? governorate;
  City? city;
  String createdAt;
  String updatedAt;

  RadiologyCenter({
    this.id = -1,
    this.name = '',
    this.description = '',
    this.address = '',
    this.contactNumber = '',
    this.email = '',
    this.profileImage = '',
    this.status = '',
    this.rating = 0.0,
    this.scanTypes = const [],
    this.operatingHours = '',
    this.pricing = '',
    this.governorate,
    this.city,
    this.createdAt = '',
    this.updatedAt = '',
  });

  factory RadiologyCenter.fromJson(Map<String, dynamic> json) {
    return RadiologyCenter(
      id: json['id'] is int ? json['id'] : -1,
      name: json['name'] is String ? json['name'] : '',
      description: json['description'] is String ? json['description'] : '',
      address: json['address'] is String ? json['address'] : '',
      contactNumber: json['contact_number'] is String ? json['contact_number'] : '',
      email: json['email'] is String ? json['email'] : '',
      profileImage: json['profile_image'] is String ? json['profile_image'] : '',
      status: json['status'] is String ? json['status'] : '',
      rating: json['rating'] is num ? json['rating'].toDouble() : 0.0,
      scanTypes: json['scan_types'] is List
          ? (json['scan_types'] as List).map((e) => e.toString()).toList()
          : [],
      operatingHours: json['operating_hours'] is String ? json['operating_hours'] : '',
      pricing: json['pricing'] is String ? json['pricing'] : '',
      governorate: json['governorate'] is Map
          ? Governorate.fromJson(Map<String, dynamic>.from(json['governorate']))
          : null,
      city: json['city'] is Map ? City.fromJson(Map<String, dynamic>.from(json['city'])) : null,
      createdAt: json['created_at'] is String ? json['created_at'] : '',
      updatedAt: json['updated_at'] is String ? json['updated_at'] : '',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'address': address,
    'contact_number': contactNumber,
    'email': email,
    'profile_image': profileImage,
    'status': status,
    'rating': rating,
    'scan_types': scanTypes,
    'operating_hours': operatingHours,
    'pricing': pricing,
  };
}
