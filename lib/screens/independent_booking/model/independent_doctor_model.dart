class IndependentDoctorListResponse {
  bool status;
  List<IndependentDoctor> data;
  int currentPage;
  int lastPage;
  int perPage;
  int total;

  IndependentDoctorListResponse({
    this.status = false, this.data = const [],
    this.currentPage = 1, this.lastPage = 1, this.perPage = 20, this.total = 0,
  });

  factory IndependentDoctorListResponse.fromJson(Map<String, dynamic> json) {
    return IndependentDoctorListResponse(
      status: json["status"] is bool ? json["status"] : false,
      data: json["data"] is List ? List<IndependentDoctor>.from(json["data"].map((x) => IndependentDoctor.fromJson(x))) : [],
      currentPage: json["meta"] is Map ? (json["meta"]["current_page"] ?? 1) : 1,
      lastPage: json["meta"] is Map ? (json["meta"]["last_page"] ?? 1) : 1,
      perPage: json["meta"] is Map ? (json["meta"]["per_page"] ?? 20) : 20,
      total: json["meta"] is Map ? (json["meta"]["total"] ?? 0) : 0,
    );
  }
}

class IndependentDoctor {
  int id;
  int doctorId;
  String firstName;
  String lastName;
  String fullName;
  String email;
  String mobile;
  String gender;
  String expert;
  String dateOfBirth;
  int status;
  String address;
  String latitude;
  String longitude;
  String description;
  String experience;
  String profileImage;
  double averageRating;
  int totalAppointment;
  int totalPatient;
  int totalReviews;
  List<IndependentService> services;

  IndependentDoctor({
    this.id = -1, this.doctorId = -1, this.firstName = "", this.lastName = "",
    this.fullName = "", this.email = "", this.mobile = "", this.gender = "",
    this.expert = "", this.dateOfBirth = "", this.status = 1,
    this.address = "", this.latitude = "", this.longitude = "",
    this.description = "", this.experience = "", this.profileImage = "",
    this.averageRating = 0.0, this.totalAppointment = 0, this.totalPatient = 0,
    this.totalReviews = 0, this.services = const [],
  });

  factory IndependentDoctor.fromJson(Map<String, dynamic> json) {
    return IndependentDoctor(
      id: json["id"] is int ? json["id"] : -1,
      doctorId: json["doctor_id"] is int ? json["doctor_id"] : -1,
      firstName: json["first_name"] is String ? json["first_name"] : "",
      lastName: json["last_name"] is String ? json["last_name"] : "",
      fullName: json["full_name"] is String ? json["full_name"] : "",
      email: json["email"] is String ? json["email"] : "",
      mobile: json["mobile"] is String ? json["mobile"] : "",
      gender: json["gender"] is String ? json["gender"] : "",
      expert: json["expert"] is String ? json["expert"] : "",
      dateOfBirth: json["date_of_birth"] is String ? json["date_of_birth"] : "",
      status: json["status"] is int ? json["status"] : 1,
      address: json["address"] is String ? json["address"] : "",
      latitude: json["latitude"] is String ? json["latitude"] : "",
      longitude: json["longitude"] is String ? json["longitude"] : "",
      description: json["description"] is String ? json["description"] : "",
      experience: json["experience"] is String ? json["experience"] : "",
      profileImage: json["profile_image"] is String ? json["profile_image"] : "",
      averageRating: json["average_rating"] is num ? json["average_rating"].toDouble() : 0.0,
      totalAppointment: json["total_appointment"] is int ? json["total_appointment"] : 0,
      totalPatient: json["total_patient"] is int ? json["total_patient"] : 0,
      totalReviews: json["total_reviews"] is int ? json["total_reviews"] : 0,
      services: json["services"] is List ? List<IndependentService>.from(json["services"].map((x) => IndependentService.fromJson(x))) : [],
    );
  }

  Map<String, dynamic> toJson() => {
    "id": id, "doctor_id": doctorId, "first_name": firstName,
    "last_name": lastName, "full_name": fullName, "email": email,
    "mobile": mobile, "gender": gender, "expert": expert,
    "date_of_birth": dateOfBirth, "status": status,
    "address": address, "latitude": latitude, "longitude": longitude,
    "description": description, "experience": experience,
    "profile_image": profileImage, "average_rating": averageRating,
    "total_appointment": totalAppointment, "total_patient": totalPatient,
    "total_reviews": totalReviews,
    "services": services.map((x) => x.toJson()).toList(),
  };
}

class IndependentService {
  int id;
  int doctorId;
  String name;
  String description;
  int durationMin;
  int timeSlot;
  double charges;
  int discount;
  String discountType;
  double discountValue;
  int isInclusiveTax;
  String inclusiveTax;
  double inclusiveTaxPrice;
  int status;
  String createdAt;
  String updatedAt;

  IndependentService({
    this.id = -1, this.doctorId = -1, this.name = "", this.description = "",
    this.durationMin = 30, this.timeSlot = 10,
    this.charges = 0.0, this.discount = 0, this.discountType = "",
    this.discountValue = 0.0, this.isInclusiveTax = 0, this.inclusiveTax = "",
    this.inclusiveTaxPrice = 0.0, this.status = 1,
    this.createdAt = "", this.updatedAt = "",
  });

  factory IndependentService.fromJson(Map<String, dynamic> json) {
    return IndependentService(
      id: json["id"] is int ? json["id"] : -1,
      doctorId: json["doctor_id"] is int ? json["doctor_id"] : -1,
      name: json["name"] is String ? json["name"] : "",
      description: json["description"] is String ? json["description"] : "",
      durationMin: json["duration_min"] is int ? json["duration_min"] : 30,
      timeSlot: json["time_slot"] is int ? json["time_slot"] : 10,
      charges: json["charges"] is num ? json["charges"].toDouble() : 0.0,
      discount: json["discount"] is int ? json["discount"] : 0,
      discountType: json["discount_type"] is String ? json["discount_type"] : "",
      discountValue: json["discount_value"] is num ? json["discount_value"].toDouble() : 0.0,
      isInclusiveTax: json["is_inclusive_tax"] is int ? json["is_inclusive_tax"] : 0,
      inclusiveTax: json["inclusive_tax"] is String ? json["inclusive_tax"] : "",
      inclusiveTaxPrice: json["inclusive_tax_price"] is num ? json["inclusive_tax_price"].toDouble() : 0.0,
      status: json["status"] is int ? json["status"] : 1,
      createdAt: json["created_at"] is String ? json["created_at"] : "",
      updatedAt: json["updated_at"] is String ? json["updated_at"] : "",
    );
  }

  Map<String, dynamic> toJson() => {
    "id": id, "doctor_id": doctorId, "name": name, "description": description,
    "duration_min": durationMin, "time_slot": timeSlot,
    "charges": charges, "discount": discount, "discount_type": discountType,
    "discount_value": discountValue, "is_inclusive_tax": isInclusiveTax,
    "inclusive_tax": inclusiveTax, "inclusive_tax_price": inclusiveTaxPrice,
    "status": status, "created_at": createdAt, "updated_at": updatedAt,
  };
}
