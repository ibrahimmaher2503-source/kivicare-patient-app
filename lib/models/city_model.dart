class CityListResponse {
  bool status;
  List<City> data;

  CityListResponse({this.status = false, this.data = const []});

  factory CityListResponse.fromJson(Map<String, dynamic> json) {
    List<dynamic> items = [];
    if (json['data'] is Map && json['data']['items'] is List) {
      items = json['data']['items'];
    } else if (json['data'] is List) {
      items = json['data'];
    }
    return CityListResponse(
      status: json['status'] is bool ? json['status'] : false,
      data: items.map((e) => City.fromJson(e)).toList(),
    );
  }
}

class City {
  int id;
  String name;
  int governorateId;

  City({this.id = -1, this.name = '', this.governorateId = -1});

  factory City.fromJson(Map<String, dynamic> json) {
    return City(
      id: json['id'] is int ? json['id'] : -1,
      name: json['name'] is String ? json['name'] : '',
      governorateId: json['governorate_id'] is int ? json['governorate_id'] : -1,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'governorate_id': governorateId,
  };
}
