import '../../../models/governorate_model.dart';
import '../../../models/city_model.dart';

class LabListResponse {
  bool status;
  List<Lab> data;
  int currentPage;
  int lastPage;
  int perPage;
  int total;

  LabListResponse({
    this.status = false,
    this.data = const [],
    this.currentPage = 1,
    this.lastPage = 1,
    this.perPage = 15,
    this.total = 0,
  });

  factory LabListResponse.fromJson(Map<String, dynamic> json) {
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

    return LabListResponse(
      status: json['status'] is bool ? json['status'] : false,
      data: items.map((e) => Lab.fromJson(Map<String, dynamic>.from(e))).toList(),
      currentPage: currPage,
      lastPage: lastPg,
      perPage: perPg,
      total: tot,
    );
  }
}

class Lab {
  int id;
  String name;
  Governorate? governorate;
  City? city;

  Lab({
    this.id = -1,
    this.name = '',
    this.governorate,
    this.city,
  });

  factory Lab.fromJson(Map<String, dynamic> json) {
    return Lab(
      id: json['id'] is int ? json['id'] : -1,
      name: json['name'] is String ? json['name'] : '',
      governorate: json['governorate'] is Map
          ? Governorate.fromJson(Map<String, dynamic>.from(json['governorate']))
          : null,
      city: json['city'] is Map
          ? City.fromJson(Map<String, dynamic>.from(json['city']))
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
  };
}
