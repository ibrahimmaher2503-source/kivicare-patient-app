class CallDoctorListResponse {
  bool status;
  List<CallDoctor> data;
  int currentPage;
  int lastPage;
  int perPage;
  int total;

  CallDoctorListResponse({
    this.status = false, this.data = const [],
    this.currentPage = 1, this.lastPage = 1, this.perPage = 20, this.total = 0,
  });

  factory CallDoctorListResponse.fromJson(Map<String, dynamic> json) {
    return CallDoctorListResponse(
      status: json["status"] is bool ? json["status"] : false,
      data: json["data"] is List ? List<CallDoctor>.from(json["data"].map((x) => CallDoctor.fromJson(x))) : [],
      currentPage: json["meta"] is Map ? (json["meta"]["current_page"] ?? 1) : 1,
      lastPage: json["meta"] is Map ? (json["meta"]["last_page"] ?? 1) : 1,
      perPage: json["meta"] is Map ? (json["meta"]["per_page"] ?? 20) : 20,
      total: json["meta"] is Map ? (json["meta"]["total"] ?? 0) : 0,
    );
  }
}

class CallDoctor {
  int id;
  int doctorId;
  String firstName;
  String lastName;
  String fullName;
  String email;
  String mobile;
  String gender;
  String expert;
  String aboutSelf;
  String experience;
  String profileImage;
  double averageRating;
  int totalReviews;
  bool hasVideoCall;
  bool hasPhoneCall;
  double callStartingPrice;
  List<CallService> callServices;

  CallDoctor({
    this.id = -1, this.doctorId = -1, this.firstName = "", this.lastName = "",
    this.fullName = "", this.email = "", this.mobile = "", this.gender = "",
    this.expert = "", this.aboutSelf = "", this.experience = "",
    this.profileImage = "", this.averageRating = 0.0, this.totalReviews = 0,
    this.hasVideoCall = false, this.hasPhoneCall = false,
    this.callStartingPrice = 0.0, this.callServices = const [],
  });

  factory CallDoctor.fromJson(Map<String, dynamic> json) {
    return CallDoctor(
      id: json["id"] is int ? json["id"] : -1,
      doctorId: json["doctor_id"] is int ? json["doctor_id"] : -1,
      firstName: json["first_name"] is String ? json["first_name"] : "",
      lastName: json["last_name"] is String ? json["last_name"] : "",
      fullName: json["full_name"] is String ? json["full_name"] : "",
      email: json["email"] is String ? json["email"] : "",
      mobile: json["mobile"] is String ? json["mobile"] : "",
      gender: json["gender"] is String ? json["gender"] : "",
      expert: json["expert"] is String ? json["expert"] : "",
      aboutSelf: json["about_self"] is String ? json["about_self"] : "",
      experience: json["experience"] is String ? json["experience"] : "",
      profileImage: json["profile_image"] is String ? json["profile_image"] : "",
      averageRating: json["average_rating"] is num ? json["average_rating"].toDouble() : 0.0,
      totalReviews: json["total_reviews"] is int ? json["total_reviews"] : 0,
      hasVideoCall: json["has_video_call"] is bool ? json["has_video_call"] : false,
      hasPhoneCall: json["has_phone_call"] is bool ? json["has_phone_call"] : false,
      callStartingPrice: json["call_starting_price"] is num ? json["call_starting_price"].toDouble() : 0.0,
      callServices: json["call_services"] is List ? List<CallService>.from(json["call_services"].map((x) => CallService.fromJson(x))) : [],
    );
  }

  Map<String, dynamic> toJson() => {
    "id": id, "doctor_id": doctorId, "first_name": firstName,
    "last_name": lastName, "full_name": fullName, "email": email,
    "mobile": mobile, "gender": gender, "expert": expert,
    "about_self": aboutSelf, "experience": experience,
    "profile_image": profileImage, "average_rating": averageRating,
    "total_reviews": totalReviews, "has_video_call": hasVideoCall,
    "has_phone_call": hasPhoneCall, "call_starting_price": callStartingPrice,
    "call_services": callServices.map((x) => x.toJson()).toList(),
  };
}

class CallService {
  int id;
  int doctorId;
  String name;
  String description;
  String callType;
  int durationMin;
  int timeSlot;
  double charges;
  int discount;
  String discountType;
  double discountValue;
  double finalPrice;
  int isInclusiveTax;
  double inclusiveTaxPrice;
  int status;

  CallService({
    this.id = -1, this.doctorId = -1, this.name = "", this.description = "",
    this.callType = "", this.durationMin = 0, this.timeSlot = 0,
    this.charges = 0.0, this.discount = 0, this.discountType = "",
    this.discountValue = 0.0, this.finalPrice = 0.0,
    this.isInclusiveTax = 0, this.inclusiveTaxPrice = 0.0, this.status = 1,
  });

  factory CallService.fromJson(Map<String, dynamic> json) {
    return CallService(
      id: json["id"] is int ? json["id"] : -1,
      doctorId: json["doctor_id"] is int ? json["doctor_id"] : -1,
      name: json["name"] is String ? json["name"] : "",
      description: json["description"] is String ? json["description"] : "",
      callType: json["call_type"] is String ? json["call_type"] : "",
      durationMin: json["duration_min"] is int ? json["duration_min"] : 0,
      timeSlot: json["time_slot"] is int ? json["time_slot"] : 0,
      charges: json["charges"] is num ? json["charges"].toDouble() : 0.0,
      discount: json["discount"] is int ? json["discount"] : 0,
      discountType: json["discount_type"] is String ? json["discount_type"] : "",
      discountValue: json["discount_value"] is num ? json["discount_value"].toDouble() : 0.0,
      finalPrice: json["final_price"] is num ? json["final_price"].toDouble() : 0.0,
      isInclusiveTax: json["is_inclusive_tax"] is int ? json["is_inclusive_tax"] : 0,
      inclusiveTaxPrice: json["inclusive_tax_price"] is num ? json["inclusive_tax_price"].toDouble() : 0.0,
      status: json["status"] is int ? json["status"] : 1,
    );
  }

  Map<String, dynamic> toJson() => {
    "id": id, "doctor_id": doctorId, "name": name, "description": description,
    "call_type": callType, "duration_min": durationMin, "time_slot": timeSlot,
    "charges": charges, "discount": discount, "discount_type": discountType,
    "discount_value": discountValue, "final_price": finalPrice,
    "is_inclusive_tax": isInclusiveTax, "inclusive_tax_price": inclusiveTaxPrice,
    "status": status,
  };
}
