import 'package:get/get_rx/src/rx_types/rx_types.dart';

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
    this.perPage = 15,
    this.total = 0,
  });

  factory NurseListResponse.fromJson(Map<String, dynamic> json) {
    return NurseListResponse(
      status: json["status"] is bool ? json["status"] : false,
      data: json["data"] is List ? List<Nurse>.from(json["data"].map((x) => Nurse.fromJson(x))) : [],
      currentPage: json["meta"] is Map ? (json["meta"]["current_page"] ?? 1) : 1,
      lastPage: json["meta"] is Map ? (json["meta"]["last_page"] ?? 1) : 1,
      perPage: json["meta"] is Map ? (json["meta"]["per_page"] ?? 15) : 15,
      total: json["meta"] is Map ? (json["meta"]["total"] ?? 0) : 0,
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

class NurseListResult {
  final RxList<Nurse> nurses;

  NurseListResult({required this.nurses});
}
