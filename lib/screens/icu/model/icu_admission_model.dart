import 'hospital_model.dart';

class IcuAdmissionListResponse {
  bool status;
  List<IcuAdmissionRequest> data;
  int currentPage;
  int lastPage;
  int perPage;
  int total;

  IcuAdmissionListResponse({
    this.status = false, this.data = const [],
    this.currentPage = 1, this.lastPage = 1, this.perPage = 20, this.total = 0,
  });

  factory IcuAdmissionListResponse.fromJson(Map<String, dynamic> json) {
    return IcuAdmissionListResponse(
      status: json["status"] is bool ? json["status"] : false,
      data: json["data"] is List ? List<IcuAdmissionRequest>.from(json["data"].map((x) => IcuAdmissionRequest.fromJson(x))) : [],
      currentPage: json["meta"] is Map ? (json["meta"]["current_page"] ?? 1) : 1,
      lastPage: json["meta"] is Map ? (json["meta"]["last_page"] ?? 1) : 1,
      perPage: json["meta"] is Map ? (json["meta"]["per_page"] ?? 20) : 20,
      total: json["meta"] is Map ? (json["meta"]["total"] ?? 0) : 0,
    );
  }
}

class IcuAdmissionRequest {
  int id;
  String requestNumber;
  AdmissionPatient? patient;
  PatientInfo? patientInfo;
  CaseDetails? caseDetails;
  ContactInfo? contact;
  Hospital? hospital;
  IcuDepartment? icuDepartment;
  String status;
  String urgency;
  String paymentMethod;
  String insuranceProvider;
  String adminNotes;
  String rejectionReason;
  String responseDate;
  List<MedicalReport> medicalReports;
  String createdAt;

  IcuAdmissionRequest({
    this.id = -1, this.requestNumber = "", this.patient, this.patientInfo,
    this.caseDetails, this.contact, this.hospital, this.icuDepartment,
    this.status = "", this.urgency = "", this.paymentMethod = "",
    this.insuranceProvider = "", this.adminNotes = "", this.rejectionReason = "",
    this.responseDate = "", this.medicalReports = const [], this.createdAt = "",
  });

  factory IcuAdmissionRequest.fromJson(Map<String, dynamic> json) {
    return IcuAdmissionRequest(
      id: json["id"] is int ? json["id"] : -1,
      requestNumber: json["request_number"] is String ? json["request_number"] : "",
      patient: json["patient"] is Map<String, dynamic> ? AdmissionPatient.fromJson(json["patient"]) : null,
      patientInfo: json["patient_info"] is Map<String, dynamic> ? PatientInfo.fromJson(json["patient_info"]) : null,
      caseDetails: json["case_details"] is Map<String, dynamic> ? CaseDetails.fromJson(json["case_details"]) : null,
      contact: json["contact"] is Map<String, dynamic> ? ContactInfo.fromJson(json["contact"]) : null,
      hospital: json["hospital"] is Map<String, dynamic> ? Hospital.fromJson(json["hospital"]) : null,
      icuDepartment: json["icu_department"] is Map<String, dynamic> ? IcuDepartment.fromJson(json["icu_department"]) : null,
      status: json["status"] is String ? json["status"] : "",
      urgency: json["urgency"] is String ? json["urgency"] : "",
      paymentMethod: json["payment_method"] is String ? json["payment_method"] : "",
      insuranceProvider: json["insurance_provider"] is String ? json["insurance_provider"] : "",
      adminNotes: json["admin_notes"] is String ? json["admin_notes"] : "",
      rejectionReason: json["rejection_reason"] is String ? json["rejection_reason"] : "",
      responseDate: json["response_date"] is String ? json["response_date"] : "",
      medicalReports: json["medical_reports"] is List ? List<MedicalReport>.from(json["medical_reports"].map((x) => MedicalReport.fromJson(x))) : [],
      createdAt: json["created_at"] is String ? json["created_at"] : "",
    );
  }

  Map<String, dynamic> toJson() => {
    "id": id, "request_number": requestNumber,
    "patient": patient?.toJson(), "patient_info": patientInfo?.toJson(),
    "case_details": caseDetails?.toJson(), "contact": contact?.toJson(),
    "hospital": hospital?.toJson(), "icu_department": icuDepartment?.toJson(),
    "status": status, "urgency": urgency, "payment_method": paymentMethod,
    "insurance_provider": insuranceProvider, "admin_notes": adminNotes,
    "rejection_reason": rejectionReason, "response_date": responseDate,
    "medical_reports": medicalReports.map((x) => x.toJson()).toList(),
    "created_at": createdAt,
  };
}

class AdmissionPatient {
  int id;
  String name;
  String email;

  AdmissionPatient({this.id = -1, this.name = "", this.email = ""});

  factory AdmissionPatient.fromJson(Map<String, dynamic> json) {
    return AdmissionPatient(
      id: json["id"] is int ? json["id"] : -1,
      name: json["name"] is String ? json["name"] : "",
      email: json["email"] is String ? json["email"] : "",
    );
  }

  Map<String, dynamic> toJson() => {"id": id, "name": name, "email": email};
}

class PatientInfo {
  String patientName;
  int patientAge;
  String patientGender;
  String nationalId;
  String insuranceNumber;

  PatientInfo({
    this.patientName = "", this.patientAge = 0, this.patientGender = "",
    this.nationalId = "", this.insuranceNumber = "",
  });

  factory PatientInfo.fromJson(Map<String, dynamic> json) {
    return PatientInfo(
      patientName: json["patient_name"] is String ? json["patient_name"] : "",
      patientAge: json["patient_age"] is int ? json["patient_age"] : 0,
      patientGender: json["patient_gender"] is String ? json["patient_gender"] : "",
      nationalId: json["national_id"] is String ? json["national_id"] : "",
      insuranceNumber: json["insurance_number"] is String ? json["insurance_number"] : "",
    );
  }

  Map<String, dynamic> toJson() => {
    "patient_name": patientName, "patient_age": patientAge,
    "patient_gender": patientGender, "national_id": nationalId,
    "insurance_number": insuranceNumber,
  };
}

class CaseDetails {
  String medicalCondition;
  String diagnosis;
  String caseType;
  bool needsVentilator;
  bool needsOxygen;
  String currentLocation;
  bool needsAmbulance;

  CaseDetails({
    this.medicalCondition = "", this.diagnosis = "", this.caseType = "",
    this.needsVentilator = false, this.needsOxygen = false,
    this.currentLocation = "", this.needsAmbulance = false,
  });

  factory CaseDetails.fromJson(Map<String, dynamic> json) {
    return CaseDetails(
      medicalCondition: json["medical_condition"] is String ? json["medical_condition"] : "",
      diagnosis: json["diagnosis"] is String ? json["diagnosis"] : "",
      caseType: json["case_type"] is String ? json["case_type"] : "",
      needsVentilator: json["needs_ventilator"] is bool ? json["needs_ventilator"] : false,
      needsOxygen: json["needs_oxygen"] is bool ? json["needs_oxygen"] : false,
      currentLocation: json["current_location"] is String ? json["current_location"] : "",
      needsAmbulance: json["needs_ambulance"] is bool ? json["needs_ambulance"] : false,
    );
  }

  Map<String, dynamic> toJson() => {
    "medical_condition": medicalCondition, "diagnosis": diagnosis,
    "case_type": caseType, "needs_ventilator": needsVentilator,
    "needs_oxygen": needsOxygen, "current_location": currentLocation,
    "needs_ambulance": needsAmbulance,
  };
}

class ContactInfo {
  String contactName;
  String contactPhone;
  String relationshipToPatient;

  ContactInfo({
    this.contactName = "", this.contactPhone = "", this.relationshipToPatient = "",
  });

  factory ContactInfo.fromJson(Map<String, dynamic> json) {
    return ContactInfo(
      contactName: json["contact_name"] is String ? json["contact_name"] : "",
      contactPhone: json["contact_phone"] is String ? json["contact_phone"] : "",
      relationshipToPatient: json["relationship_to_patient"] is String ? json["relationship_to_patient"] : "",
    );
  }

  Map<String, dynamic> toJson() => {
    "contact_name": contactName, "contact_phone": contactPhone,
    "relationship_to_patient": relationshipToPatient,
  };
}

class MedicalReport {
  int id;
  String name;
  String url;
  int size;
  String mimeType;

  MedicalReport({
    this.id = -1, this.name = "", this.url = "", this.size = 0, this.mimeType = "",
  });

  factory MedicalReport.fromJson(Map<String, dynamic> json) {
    return MedicalReport(
      id: json["id"] is int ? json["id"] : -1,
      name: json["name"] is String ? json["name"] : "",
      url: json["url"] is String ? json["url"] : "",
      size: json["size"] is int ? json["size"] : 0,
      mimeType: json["mime_type"] is String ? json["mime_type"] : "",
    );
  }

  Map<String, dynamic> toJson() => {
    "id": id, "name": name, "url": url, "size": size, "mime_type": mimeType,
  };
}
