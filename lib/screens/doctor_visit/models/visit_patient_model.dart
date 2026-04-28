class VisitPatientModel {
  final int id;
  final String name;
  final String? email;
  final String? avatar;

  VisitPatientModel({
    this.id = -1,
    this.name = '',
    this.email,
    this.avatar,
  });

  factory VisitPatientModel.fromJson(Map<String, dynamic> json) {
    return VisitPatientModel(
      id: json['id'] is int ? json['id'] : -1,
      name: json['name'] is String ? json['name'] : '',
      email: json['email'] is String ? json['email'] : null,
      avatar: json['avatar'] is String ? json['avatar'] : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'avatar': avatar,
    };
  }
}
