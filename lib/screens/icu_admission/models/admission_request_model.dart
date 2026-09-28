import 'hospital_model.dart';
import 'icu_department_model.dart';
import 'status_history_model.dart';

enum UrgencyLevel { routine, urgent, critical }

extension UrgencyLevelExt on UrgencyLevel {
  // Backend expects: standard | urgent | critical
  String get toWire {
    if (this == UrgencyLevel.routine) return 'standard';
    return name;
  }

  static UrgencyLevel fromWire(String? wire) {
    if (wire == 'standard') return UrgencyLevel.routine;
    return UrgencyLevel.values.firstWhere(
      (e) => e.name == wire,
      orElse: () => UrgencyLevel.routine,
    );
  }
}

enum AdmissionStatus {
  pending,
  accepted, // backend: accepted
  infoRequested, // backend: info_requested
  rejected,
  cancelled,
}

extension AdmissionStatusExt on AdmissionStatus {
  String get toWire {
    if (this == AdmissionStatus.infoRequested) return 'info_requested';
    return name;
  }

  static AdmissionStatus fromWire(String? wire) {
    switch (wire) {
      case 'info_requested':
        return AdmissionStatus.infoRequested;
      case 'accepted':
        return AdmissionStatus.accepted;
      default:
        return AdmissionStatus.values.firstWhere(
          (e) => e.name == wire,
          orElse: () => AdmissionStatus.pending,
        );
    }
  }
}

class AdmissionRequest {
  final int id;
  final String referenceNumber;
  final AdmissionStatus status;
  final UrgencyLevel urgency;
  final Hospital hospital;
  final IcuDepartment department;
  final String patientName;
  final int patientAge;
  final String patientGender;
  final String? nationalId;
  final String diagnosis;
  final String? currentCondition;
  final String? attendingDoctor;
  final String? medicalHistory;
  final String? currentMedications;
  final String? allergies;
  final String? additionalNotes;
  final DateTime? preferredAdmissionAt;
  final String accompanyingName;
  final String? accompanyingRelation;
  final String accompanyingPhone;
  final String? assignedRoom;
  final String? assignedBed;
  final DateTime? admittedAt;
  final DateTime? dischargedAt;
  final String? dischargeSummary;
  final DateTime? cancelledAt;
  final String? cancelReason;
  final DateTime? rejectedAt;
  final String? rejectionReason;
  final List<StatusHistoryEntry> statusHistory;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  AdmissionRequest({
    required this.id,
    required this.referenceNumber,
    required this.status,
    required this.urgency,
    required this.hospital,
    required this.department,
    required this.patientName,
    required this.patientAge,
    required this.patientGender,
    this.nationalId,
    required this.diagnosis,
    this.currentCondition,
    this.attendingDoctor,
    this.medicalHistory,
    this.currentMedications,
    this.allergies,
    this.additionalNotes,
    this.preferredAdmissionAt,
    required this.accompanyingName,
    this.accompanyingRelation,
    required this.accompanyingPhone,
    this.assignedRoom,
    this.assignedBed,
    this.admittedAt,
    this.dischargedAt,
    this.dischargeSummary,
    this.cancelledAt,
    this.cancelReason,
    this.rejectedAt,
    this.rejectionReason,
    this.statusHistory = const [],
    this.createdAt,
    this.updatedAt,
  });

  bool get canCancel =>
      status == AdmissionStatus.pending ||
      status == AdmissionStatus.infoRequested;
  bool get showAdmissionCard => status == AdmissionStatus.accepted;
  bool get showDischargeInfo =>
      dischargedAt != null || dischargeSummary?.trim().isNotEmpty == true;
  bool get showCancelOrRejectionBanner =>
      status == AdmissionStatus.cancelled || status == AdmissionStatus.rejected;

  factory AdmissionRequest.fromJson(Map<String, dynamic> json) {
    return AdmissionRequest(
      id: json['id'] ?? 0,
      // backend returns request_number not reference_number
      referenceNumber: json['request_number'] ?? json['reference_number'] ?? '',
      status: AdmissionStatusExt.fromWire(json['status']),
      urgency: UrgencyLevelExt.fromWire(json['urgency']),
      hospital: json['hospital'] != null
          ? Hospital.fromJson(json['hospital'])
          : Hospital(id: 0, name: ''),
      department: json['department'] != null
          ? IcuDepartment.fromJson(json['department'])
          : IcuDepartment(id: 0, name: ''),
      patientName: json['patient_name'] ?? '',
      patientAge: json['patient_age'] ?? 0,
      patientGender: json['patient_gender'] ?? 'male',
      nationalId: json['national_id'],
      diagnosis: json['diagnosis'] ?? '',
      // backend returns medical_condition (localized) not current_condition
      currentCondition: json['medical_condition'] ?? json['current_condition'],
      attendingDoctor: json['attending_doctor'],
      medicalHistory: json['medical_history'],
      currentMedications: json['current_medications'],
      allergies: json['allergies'],
      additionalNotes: json['additional_notes'],
      preferredAdmissionAt: json['preferred_admission_at'] != null
          ? DateTime.tryParse(json['preferred_admission_at'])
          : null,
      // backend uses contact_name not accompanying_name
      accompanyingName: json['contact_name'] ?? json['accompanying_name'] ?? '',
      accompanyingRelation:
          json['relationship_to_patient'] ?? json['accompanying_relation'],
      accompanyingPhone:
          json['contact_phone'] ?? json['accompanying_phone'] ?? '',
      assignedRoom: json['assigned_room'],
      assignedBed: json['assigned_bed'],
      admittedAt: json['admitted_at'] != null
          ? DateTime.tryParse(json['admitted_at'])
          : null,
      dischargedAt: json['discharged_at'] != null
          ? DateTime.tryParse(json['discharged_at'])
          : null,
      dischargeSummary: json['discharge_summary'],
      cancelledAt: json['cancelled_at'] != null
          ? DateTime.tryParse(json['cancelled_at'])
          : null,
      cancelReason: json['cancellation_reason'] ?? json['cancel_reason'],
      rejectedAt: json['rejected_at'] != null
          ? DateTime.tryParse(json['rejected_at'])
          : null,
      rejectionReason: json['rejection_reason'] ?? json['rejection_reason_ar'],
      statusHistory: json['status_history'] != null
          ? (json['status_history'] as List)
              .map((i) => StatusHistoryEntry.fromJson(i))
              .toList()
          : [],
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'request_number': referenceNumber,
      'status': status.toWire,
      'urgency': urgency.toWire,
      'hospital': hospital.toJson(),
      'department': department.toJson(),
      'patient_name': patientName,
      'patient_age': patientAge,
      'patient_gender': patientGender,
      'national_id': nationalId,
      'diagnosis': diagnosis,
      'medical_condition': currentCondition,
      'attending_doctor': attendingDoctor,
      'medical_history': medicalHistory,
      'current_medications': currentMedications,
      'allergies': allergies,
      'additional_notes': additionalNotes,
      'preferred_admission_at': preferredAdmissionAt?.toIso8601String(),
      'contact_name': accompanyingName,
      'relationship_to_patient': accompanyingRelation,
      'contact_phone': accompanyingPhone,
      'assigned_room': assignedRoom,
      'assigned_bed': assignedBed,
      'admitted_at': admittedAt?.toIso8601String(),
      'discharged_at': dischargedAt?.toIso8601String(),
      'discharge_summary': dischargeSummary,
      'cancelled_at': cancelledAt?.toIso8601String(),
      'cancellation_reason': cancelReason,
      'rejected_at': rejectedAt?.toIso8601String(),
      'rejection_reason': rejectionReason,
      'status_history': statusHistory.map((i) => i.toJson()).toList(),
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}
