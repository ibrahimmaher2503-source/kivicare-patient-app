import 'governorate_model.dart';
import 'city_model.dart';

class HomeHealthcareListResponse {
  bool status;
  List<HomeHealthcareProvider> data;
  int currentPage;
  int lastPage;
  int perPage;
  int total;

  HomeHealthcareListResponse({
    this.status = false,
    this.data = const [],
    this.currentPage = 1,
    this.lastPage = 1,
    this.perPage = 15,
    this.total = 0,
  });

  factory HomeHealthcareListResponse.fromJson(Map<String, dynamic> json) {
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
    return HomeHealthcareListResponse(
      status: json['status'] is bool ? json['status'] : false,
      data: items.map((e) => HomeHealthcareProvider.fromJson(Map<String, dynamic>.from(e))).toList(),
      currentPage: currPage,
      lastPage: lastPg,
      perPage: perPg,
      total: tot,
    );
  }
}

class HomeHealthcareProvider {
  int id;
  String name;
  String serviceType;
  String profileImage;
  Governorate? governorate;
  City? city;
  String createdAt;
  String updatedAt;

  HomeHealthcareProvider({
    this.id = -1,
    this.name = '',
    this.serviceType = '',
    this.profileImage = '',
    this.governorate,
    this.city,
    this.createdAt = '',
    this.updatedAt = '',
  });

  factory HomeHealthcareProvider.fromJson(Map<String, dynamic> json) {
    return HomeHealthcareProvider(
      id: json['id'] is int ? json['id'] : -1,
      name: json['name'] is String ? json['name'] : '',
      serviceType: json['service_type'] is String ? json['service_type'] : '',
      profileImage: json['profile_image'] is String ? json['profile_image'] : '',
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
    'service_type': serviceType,
    'profile_image': profileImage,
  };
}
