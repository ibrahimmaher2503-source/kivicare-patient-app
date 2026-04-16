class GovernorateListResponse {
  bool status;
  List<Governorate> data;

  GovernorateListResponse({this.status = false, this.data = const []});

  factory GovernorateListResponse.fromJson(Map<String, dynamic> json) {
    List<dynamic> items = [];
    if (json['data'] is Map && json['data']['items'] is List) {
      items = json['data']['items'];
    } else if (json['data'] is List) {
      items = json['data'];
    }
    return GovernorateListResponse(
      status: json['status'] is bool ? json['status'] : false,
      data: items.map((e) => Governorate.fromJson(e)).toList(),
    );
  }
}

class Governorate {
  int id;
  String name;

  Governorate({this.id = -1, this.name = ''});

  factory Governorate.fromJson(Map<String, dynamic> json) {
    return Governorate(
      id: json['id'] is int ? json['id'] : -1,
      name: json['name'] is String ? json['name'] : '',
    );
  }

  Map<String, dynamic> toJson() => {'id': id, 'name': name};
}
