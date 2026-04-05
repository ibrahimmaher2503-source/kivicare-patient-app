class NurseRequestListResponse {
  bool status;
  List<NurseRequest> data;
  int currentPage;
  int lastPage;
  int perPage;
  int total;

  NurseRequestListResponse({
    this.status = false,
    this.data = const [],
    this.currentPage = 1,
    this.lastPage = 1,
    this.perPage = 20,
    this.total = 0,
  });

  factory NurseRequestListResponse.fromJson(Map<String, dynamic> json) {
    return NurseRequestListResponse(
      status: json["status"] is bool ? json["status"] : false,
      data: json["data"] is List ? List<NurseRequest>.from(json["data"].map((x) => NurseRequest.fromJson(x))) : [],
      currentPage: json["meta"] is Map ? (json["meta"]["current_page"] ?? 1) : 1,
      lastPage: json["meta"] is Map ? (json["meta"]["last_page"] ?? 1) : 1,
      perPage: json["meta"] is Map ? (json["meta"]["per_page"] ?? 20) : 20,
      total: json["meta"] is Map ? (json["meta"]["total"] ?? 0) : 0,
    );
  }
}

class NurseRequestPatient {
  int id;
  String name;
  String email;
  String mobile;

  NurseRequestPatient({this.id = -1, this.name = "", this.email = "", this.mobile = ""});

  factory NurseRequestPatient.fromJson(Map<String, dynamic> json) {
    return NurseRequestPatient(
      id: json["id"] is int ? json["id"] : -1,
      name: json["name"] is String ? json["name"] : "",
      email: json["email"] is String ? json["email"] : "",
      mobile: json["mobile"] is String ? json["mobile"] : "",
    );
  }

  Map<String, dynamic> toJson() => {"id": id, "name": name, "email": email, "mobile": mobile};
}

class NurseRequestNurse {
  int id;
  String name;
  String specialization;

  NurseRequestNurse({this.id = -1, this.name = "", this.specialization = ""});

  factory NurseRequestNurse.fromJson(Map<String, dynamic> json) {
    return NurseRequestNurse(
      id: json["id"] is int ? json["id"] : -1,
      name: json["name"] is String ? json["name"] : "",
      specialization: json["specialization"] is String ? json["specialization"] : "",
    );
  }

  Map<String, dynamic> toJson() => {"id": id, "name": name, "specialization": specialization};
}

class NurseRequestAddress {
  String addressLine1;
  String addressLine2;
  String city;
  String state;
  String country;
  String postalCode;
  double latitude;
  double longitude;
  String fullAddress;

  NurseRequestAddress({
    this.addressLine1 = "",
    this.addressLine2 = "",
    this.city = "",
    this.state = "",
    this.country = "",
    this.postalCode = "",
    this.latitude = 0.0,
    this.longitude = 0.0,
    this.fullAddress = "",
  });

  factory NurseRequestAddress.fromJson(Map<String, dynamic> json) {
    return NurseRequestAddress(
      addressLine1: json["address_line_1"] is String ? json["address_line_1"] : "",
      addressLine2: json["address_line_2"] is String ? json["address_line_2"] : "",
      city: json["city"] is String ? json["city"] : "",
      state: json["state"] is String ? json["state"] : "",
      country: json["country"] is String ? json["country"] : "",
      postalCode: json["postal_code"] is String ? json["postal_code"] : "",
      latitude: json["latitude"] is num ? json["latitude"].toDouble() : 0.0,
      longitude: json["longitude"] is num ? json["longitude"].toDouble() : 0.0,
      fullAddress: json["full_address"] is String ? json["full_address"] : "",
    );
  }

  Map<String, dynamic> toJson() => {
    "address_line_1": addressLine1,
    "address_line_2": addressLine2,
    "city": city,
    "state": state,
    "country": country,
    "postal_code": postalCode,
    "latitude": latitude,
    "longitude": longitude,
    "full_address": fullAddress,
  };
}

class NurseRequest {
  int id;
  NurseRequestPatient? patient;
  NurseRequestNurse? nurse;
  String serviceDescription;
  String requestDate;
  String preferredDate;
  String preferredTime;
  int durationHours;
  NurseRequestAddress? address;
  String contactNumber;
  String status;
  bool paymentStatus;
  double totalAmount;
  String patientNotes;
  String? adminNotes;
  String? cancelledBy;
  String? cancellationReason;
  String createdAt;
  String updatedAt;

  NurseRequest({
    this.id = -1,
    this.patient,
    this.nurse,
    this.serviceDescription = "",
    this.requestDate = "",
    this.preferredDate = "",
    this.preferredTime = "",
    this.durationHours = 0,
    this.address,
    this.contactNumber = "",
    this.status = "",
    this.paymentStatus = false,
    this.totalAmount = 0.0,
    this.patientNotes = "",
    this.adminNotes,
    this.cancelledBy,
    this.cancellationReason,
    this.createdAt = "",
    this.updatedAt = "",
  });

  factory NurseRequest.fromJson(Map<String, dynamic> json) {
    return NurseRequest(
      id: json["id"] is int ? json["id"] : -1,
      patient: json["patient"] is Map<String, dynamic> ? NurseRequestPatient.fromJson(json["patient"]) : null,
      nurse: json["nurse"] is Map<String, dynamic> ? NurseRequestNurse.fromJson(json["nurse"]) : null,
      serviceDescription: json["service_description"] is String ? json["service_description"] : "",
      requestDate: json["request_date"] is String ? json["request_date"] : "",
      preferredDate: json["preferred_date"] is String ? json["preferred_date"] : "",
      preferredTime: json["preferred_time"] is String ? json["preferred_time"] : "",
      durationHours: json["duration_hours"] is int ? json["duration_hours"] : 0,
      address: json["address"] is Map<String, dynamic> ? NurseRequestAddress.fromJson(json["address"]) : null,
      contactNumber: json["contact_number"] is String ? json["contact_number"] : "",
      status: json["status"] is String ? json["status"] : "",
      paymentStatus: json["payment_status"] is bool ? json["payment_status"] : false,
      totalAmount: json["total_amount"] is num ? json["total_amount"].toDouble() : 0.0,
      patientNotes: json["patient_notes"] is String ? json["patient_notes"] : "",
      adminNotes: json["admin_notes"] is String ? json["admin_notes"] : null,
      cancelledBy: json["cancelled_by"] is String ? json["cancelled_by"] : null,
      cancellationReason: json["cancellation_reason"] is String ? json["cancellation_reason"] : null,
      createdAt: json["created_at"] is String ? json["created_at"] : "",
      updatedAt: json["updated_at"] is String ? json["updated_at"] : "",
    );
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "patient": patient?.toJson(),
    "nurse": nurse?.toJson(),
    "service_description": serviceDescription,
    "request_date": requestDate,
    "preferred_date": preferredDate,
    "preferred_time": preferredTime,
    "duration_hours": durationHours,
    "address": address?.toJson(),
    "contact_number": contactNumber,
    "status": status,
    "payment_status": paymentStatus,
    "total_amount": totalAmount,
    "patient_notes": patientNotes,
    "admin_notes": adminNotes,
    "cancelled_by": cancelledBy,
    "cancellation_reason": cancellationReason,
    "created_at": createdAt,
    "updated_at": updatedAt,
  };
}
