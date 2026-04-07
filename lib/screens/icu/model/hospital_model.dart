class HospitalListResponse {
  bool status;
  List<Hospital> data;
  int currentPage;
  int lastPage;
  int perPage;
  int total;

  HospitalListResponse({
    this.status = false, this.data = const [],
    this.currentPage = 1, this.lastPage = 1, this.perPage = 20, this.total = 0,
  });

  factory HospitalListResponse.fromJson(Map<String, dynamic> json) {
    return HospitalListResponse(
      status: json["status"] is bool ? json["status"] : false,
      data: json["data"] is List ? List<Hospital>.from(json["data"].map((x) => Hospital.fromJson(x))) : [],
      currentPage: json["meta"] is Map ? (json["meta"]["current_page"] ?? 1) : 1,
      lastPage: json["meta"] is Map ? (json["meta"]["last_page"] ?? 1) : 1,
      perPage: json["meta"] is Map ? (json["meta"]["per_page"] ?? 20) : 20,
      total: json["meta"] is Map ? (json["meta"]["total"] ?? 0) : 0,
    );
  }
}

class Hospital {
  int id;
  String name;
  String slug;
  String description;
  String hospitalType;
  String address;
  String city;
  String state;
  String country;
  double latitude;
  double longitude;
  String phone;
  String email;
  String website;
  String licenseNumber;
  List<String> acceptedInsurance;
  double rating;
  String logo;
  bool status;
  List<IcuDepartment> departments;
  int departmentsCount;

  Hospital({
    this.id = -1, this.name = "", this.slug = "", this.description = "",
    this.hospitalType = "", this.address = "", this.city = "", this.state = "",
    this.country = "", this.latitude = 0.0, this.longitude = 0.0,
    this.phone = "", this.email = "", this.website = "", this.licenseNumber = "",
    this.acceptedInsurance = const [], this.rating = 0.0, this.logo = "",
    this.status = true, this.departments = const [], this.departmentsCount = 0,
  });

  factory Hospital.fromJson(Map<String, dynamic> json) {
    return Hospital(
      id: json["id"] is int ? json["id"] : -1,
      name: json["name"] is String ? json["name"] : "",
      slug: json["slug"] is String ? json["slug"] : "",
      description: json["description"] is String ? json["description"] : "",
      hospitalType: json["hospital_type"] is String ? json["hospital_type"] : "",
      address: json["address"] is String ? json["address"] : "",
      city: json["city"] is String ? json["city"] : "",
      state: json["state"] is String ? json["state"] : "",
      country: json["country"] is String ? json["country"] : "",
      latitude: json["latitude"] is num ? json["latitude"].toDouble() : 0.0,
      longitude: json["longitude"] is num ? json["longitude"].toDouble() : 0.0,
      phone: json["phone"] is String ? json["phone"] : "",
      email: json["email"] is String ? json["email"] : "",
      website: json["website"] is String ? json["website"] : "",
      licenseNumber: json["license_number"] is String ? json["license_number"] : "",
      acceptedInsurance: json["accepted_insurance"] is List ? List<String>.from(json["accepted_insurance"]) : [],
      rating: json["rating"] is num ? json["rating"].toDouble() : 0.0,
      logo: json["logo"] is String ? json["logo"] : "",
      status: json["status"] is bool ? json["status"] : true,
      departments: json["departments"] is List ? List<IcuDepartment>.from(json["departments"].map((x) => IcuDepartment.fromJson(x))) : [],
      departmentsCount: json["departments_count"] is int ? json["departments_count"] : 0,
    );
  }

  Map<String, dynamic> toJson() => {
    "id": id, "name": name, "slug": slug, "description": description,
    "hospital_type": hospitalType, "address": address, "city": city,
    "state": state, "country": country, "latitude": latitude,
    "longitude": longitude, "phone": phone, "email": email,
    "website": website, "license_number": licenseNumber,
    "accepted_insurance": acceptedInsurance, "rating": rating,
    "logo": logo, "status": status,
    "departments": departments.map((x) => x.toJson()).toList(),
    "departments_count": departmentsCount,
  };
}

class IcuDepartment {
  int id;
  String name;
  int hospitalId;
  String specialtyType;
  int totalBeds;
  int availableBeds;
  bool hasVentilator;
  bool hasOxygen;
  String equipmentLevel;
  String dailyPrice;
  String description;
  bool status;

  IcuDepartment({
    this.id = -1, this.name = "", this.hospitalId = -1,
    this.specialtyType = "", this.totalBeds = 0, this.availableBeds = 0,
    this.hasVentilator = false, this.hasOxygen = false,
    this.equipmentLevel = "", this.dailyPrice = "",
    this.description = "", this.status = true,
  });

  factory IcuDepartment.fromJson(Map<String, dynamic> json) {
    return IcuDepartment(
      id: json["id"] is int ? json["id"] : -1,
      name: json["name"] is String ? json["name"] : "",
      hospitalId: json["hospital_id"] is int ? json["hospital_id"] : -1,
      specialtyType: json["specialty_type"] is String ? json["specialty_type"] : "",
      totalBeds: json["total_beds"] is int ? json["total_beds"] : 0,
      availableBeds: json["available_beds"] is int ? json["available_beds"] : 0,
      hasVentilator: json["has_ventilator"] is bool ? json["has_ventilator"] : false,
      hasOxygen: json["has_oxygen"] is bool ? json["has_oxygen"] : false,
      equipmentLevel: json["equipment_level"] is String ? json["equipment_level"] : "",
      dailyPrice: json["daily_price"] is String ? json["daily_price"] : "",
      description: json["description"] is String ? json["description"] : "",
      status: json["status"] is bool ? json["status"] : true,
    );
  }

  Map<String, dynamic> toJson() => {
    "id": id, "name": name, "hospital_id": hospitalId,
    "specialty_type": specialtyType, "total_beds": totalBeds,
    "available_beds": availableBeds, "has_ventilator": hasVentilator,
    "has_oxygen": hasOxygen, "equipment_level": equipmentLevel,
    "daily_price": dailyPrice, "description": description, "status": status,
  };
}

class IcuDepartmentListResponse {
  bool status;
  List<IcuDepartment> data;
  int currentPage;
  int lastPage;
  int perPage;
  int total;

  IcuDepartmentListResponse({
    this.status = false, this.data = const [],
    this.currentPage = 1, this.lastPage = 1, this.perPage = 20, this.total = 0,
  });

  factory IcuDepartmentListResponse.fromJson(Map<String, dynamic> json) {
    return IcuDepartmentListResponse(
      status: json["status"] is bool ? json["status"] : false,
      data: json["data"] is List ? List<IcuDepartment>.from(json["data"].map((x) => IcuDepartment.fromJson(x))) : [],
      currentPage: json["meta"] is Map ? (json["meta"]["current_page"] ?? 1) : 1,
      lastPage: json["meta"] is Map ? (json["meta"]["last_page"] ?? 1) : 1,
      perPage: json["meta"] is Map ? (json["meta"]["per_page"] ?? 20) : 20,
      total: json["meta"] is Map ? (json["meta"]["total"] ?? 0) : 0,
    );
  }
}
