import '../../../models/governorate_model.dart';
import '../../../models/city_model.dart';

class NurseListResponse {
  bool status;
  List<Nurse> data;
  int currentPage;
  int lastPage;
  int perPage;
  int total;

  NurseListResponse({
    this.status = false,
    this.data = const [],
    this.currentPage = 1,
    this.lastPage = 1,
    this.perPage = 20,
    this.total = 0,
  });

  factory NurseListResponse.fromJson(Map<String, dynamic> json) {
    List<dynamic> items = [];
    if (json["data"] is List) {
      items = json["data"];
    } else if (json["data"] is Map && json["data"]["items"] is List) {
      items = json["data"]["items"];
    }
    int currPage = 1;
    int lastPg = 1;
    int perPg = 20;
    int tot = 0;
    if (json["meta"] is Map) {
      currPage = json["meta"]["current_page"] ?? 1;
      lastPg = json["meta"]["last_page"] ?? 1;
      perPg = json["meta"]["per_page"] ?? 20;
      tot = json["meta"]["total"] ?? 0;
    } else if (json["data"] is Map && json["data"]["pagination"] is Map) {
      final p = json["data"]["pagination"];
      currPage = p["current_page"] ?? 1;
      lastPg = p["last_page"] ?? 1;
      perPg = p["per_page"] ?? 20;
      tot = p["total"] ?? 0;
    }
    return NurseListResponse(
      status: json["status"] is bool ? json["status"] : false,
      data: items.map((x) => Nurse.fromJson(Map<String, dynamic>.from(x))).toList(),
      currentPage: currPage,
      lastPage: lastPg,
      perPage: perPg,
      total: tot,
    );
  }
}

class Nurse {
  int id;
  int nurseId;
  String name;
  String firstName;
  String lastName;
  String email;
  String mobile;
  String specialization;
  String experience;
  String about;
  double hourlyRate;
  String availabilityStatus;
  String serviceArea;
  String profileImage;
  bool status;
  String createdAt;
  String updatedAt;
  Governorate? governorate;
  City? city;

  Nurse({
    this.id = -1,
    this.nurseId = -1,
    this.name = "",
    this.firstName = "",
    this.lastName = "",
    this.email = "",
    this.mobile = "",
    this.specialization = "",
    this.experience = "",
    this.about = "",
    this.hourlyRate = 0.0,
    this.availabilityStatus = "",
    this.serviceArea = "",
    this.profileImage = "",
    this.status = true,
    this.createdAt = "",
    this.updatedAt = "",
    this.governorate,
    this.city,
  });

  factory Nurse.fromJson(Map<String, dynamic> json) {
    return Nurse(
      id: json["id"] is int ? json["id"] : -1,
      nurseId: json["nurse_id"] is int ? json["nurse_id"] : -1,
      name: json["name"] is String ? json["name"] : "",
      firstName: json["first_name"] is String ? json["first_name"] : "",
      lastName: json["last_name"] is String ? json["last_name"] : "",
      email: json["email"] is String ? json["email"] : "",
      mobile: json["mobile"] is String ? json["mobile"] : "",
      specialization: json["specialization"] is String ? json["specialization"] : "",
      experience: json["experience"] is String ? json["experience"] : "",
      about: json["about"] is String ? json["about"] : "",
      hourlyRate: json["hourly_rate"] is num ? json["hourly_rate"].toDouble() : 0.0,
      availabilityStatus: json["availability_status"] is String ? json["availability_status"] : "",
      serviceArea: json["service_area"] is String ? json["service_area"] : "",
      profileImage: json["profile_image"] is String ? json["profile_image"] : "",
      status: json["status"] is bool ? json["status"] : true,
      createdAt: json["created_at"] is String ? json["created_at"] : "",
      updatedAt: json["updated_at"] is String ? json["updated_at"] : "",
      governorate: json['governorate'] is Map
          ? Governorate.fromJson(Map<String, dynamic>.from(json['governorate']))
          : null,
      city: json['city'] is Map ? City.fromJson(Map<String, dynamic>.from(json['city'])) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "nurse_id": nurseId,
      "name": name,
      "first_name": firstName,
      "last_name": lastName,
      "email": email,
      "mobile": mobile,
      "specialization": specialization,
      "experience": experience,
      "about": about,
      "hourly_rate": hourlyRate,
      "availability_status": availabilityStatus,
      "service_area": serviceArea,
      "profile_image": profileImage,
      "status": status,
      "created_at": createdAt,
      "updated_at": updatedAt,
    };
  }
}
