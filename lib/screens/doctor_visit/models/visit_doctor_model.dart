class VisitDoctorModel {
  final int id;
  final String name;
  final String? specialty;
  final String? avatar;
  final double? rating;

  VisitDoctorModel({
    this.id = -1,
    this.name = '',
    this.specialty,
    this.avatar,
    this.rating,
  });

  factory VisitDoctorModel.fromJson(Map<String, dynamic> json) {
    return VisitDoctorModel(
      id: json['id'] is int ? json['id'] : -1,
      name: json['name'] is String ? json['name'] : '',
      specialty: json['specialty'] is String ? json['specialty'] : null,
      avatar: json['avatar'] is String ? json['avatar'] : null,
      rating: json['rating'] != null ? (json['rating'] as num).toDouble() : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'specialty': specialty,
      'avatar': avatar,
      'rating': rating,
    };
  }
}
