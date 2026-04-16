class DoctorSummary {
  int id;
  String name;

  DoctorSummary({
    this.id = 0,
    this.name = '',
  });

  factory DoctorSummary.fromJson(Map<String, dynamic> json) {
    return DoctorSummary(
      id: json['id'] is int ? json['id'] : 0,
      name: json['name'] is String ? json['name'] : '',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
      };
}

class PatientSummary {
  int id;
  String name;
  String email;

  PatientSummary({
    this.id = 0,
    this.name = '',
    this.email = '',
  });

  factory PatientSummary.fromJson(Map<String, dynamic> json) {
    return PatientSummary(
      id: json['id'] is int ? json['id'] : 0,
      name: json['name'] is String ? json['name'] : '',
      email: json['email'] is String ? json['email'] : '',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
      };
}

class DoctorVisitRequest {
  int id;
  String referenceNumber;
  String visitType;
  String visitReason;
  String preferredDate;
  String contactPhone;
  String additionalNotes;
  String status;
  String adminNotes;
  String cancellationReason;
  String completedAt;
  String createdAt;
  DoctorSummary? preferredDoctor;
  DoctorSummary? assignedDoctor;
  PatientSummary? patient;

  DoctorVisitRequest({
    this.id = 0,
    this.referenceNumber = '',
    this.visitType = 'home_visit',
    this.visitReason = '',
    this.preferredDate = '',
    this.contactPhone = '',
    this.additionalNotes = '',
    this.status = 'pending',
    this.adminNotes = '',
    this.cancellationReason = '',
    this.completedAt = '',
    this.createdAt = '',
    this.preferredDoctor,
    this.assignedDoctor,
    this.patient,
  });

  factory DoctorVisitRequest.fromJson(Map<String, dynamic> json) {
    return DoctorVisitRequest(
      id: json['id'] is int ? json['id'] : 0,
      referenceNumber: json['reference_number'] is String ? json['reference_number'] : '',
      visitType: json['visit_type'] is String ? json['visit_type'] : 'home_visit',
      visitReason: json['visit_reason'] is String ? json['visit_reason'] : '',
      preferredDate: json['preferred_date'] is String ? json['preferred_date'] : '',
      contactPhone: json['contact_phone'] is String ? json['contact_phone'] : '',
      additionalNotes: json['additional_notes'] is String ? json['additional_notes'] : '',
      status: json['status'] is String ? json['status'] : 'pending',
      adminNotes: json['admin_notes'] is String ? json['admin_notes'] : '',
      cancellationReason: json['cancellation_reason'] is String ? json['cancellation_reason'] : '',
      completedAt: json['completed_at'] is String ? json['completed_at'] : '',
      createdAt: json['created_at'] is String ? json['created_at'] : '',
      preferredDoctor: json['preferred_doctor'] is Map ? DoctorSummary.fromJson(json['preferred_doctor']) : null,
      assignedDoctor: json['assigned_doctor'] is Map ? DoctorSummary.fromJson(json['assigned_doctor']) : null,
      patient: json['patient'] is Map ? PatientSummary.fromJson(json['patient']) : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'reference_number': referenceNumber,
        'visit_type': visitType,
        'visit_reason': visitReason,
        'preferred_date': preferredDate,
        'contact_phone': contactPhone,
        'additional_notes': additionalNotes,
        'status': status,
        'admin_notes': adminNotes,
        'cancellation_reason': cancellationReason,
        'completed_at': completedAt,
        'created_at': createdAt,
        if (preferredDoctor != null) 'preferred_doctor': preferredDoctor!.toJson(),
        if (assignedDoctor != null) 'assigned_doctor': assignedDoctor!.toJson(),
        if (patient != null) 'patient': patient!.toJson(),
      };
}

class DoctorVisitRequestListResponse {
  bool status;
  List<DoctorVisitRequest> data;
  String message;
  int currentPage;
  int lastPage;
  int perPage;
  int total;

  DoctorVisitRequestListResponse({
    this.status = false,
    this.data = const [],
    this.message = '',
    this.currentPage = 1,
    this.lastPage = 1,
    this.perPage = 15,
    this.total = 0,
  });

  factory DoctorVisitRequestListResponse.fromJson(Map<String, dynamic> json) {
    return DoctorVisitRequestListResponse(
      status: json['status'] is bool ? json['status'] : false,
      data: json['data'] is List
          ? List<DoctorVisitRequest>.from(
              (json['data'] as List).map((x) => DoctorVisitRequest.fromJson(x)),
            )
          : [],
      message: json['message'] is String ? json['message'] : '',
      currentPage: json['meta'] is Map ? (json['meta']['current_page'] ?? 1) : 1,
      lastPage: json['meta'] is Map ? (json['meta']['last_page'] ?? 1) : 1,
      perPage: json['meta'] is Map ? (json['meta']['per_page'] ?? 15) : 15,
      total: json['meta'] is Map ? (json['meta']['total'] ?? 0) : 0,
    );
  }
}
