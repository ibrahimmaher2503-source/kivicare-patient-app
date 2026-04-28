import 'status_history_model.dart';
import 'visit_doctor_model.dart';
import 'visit_patient_model.dart';
import 'visit_status.dart';

class VisitRequestModel {
  final int id;
  final String referenceNumber;
  final String visitType;
  final String visitReason;
  final DateTime preferredDate;
  final String contactPhone;
  final VisitStatus status;
  final String? cancellationReason;
  final DateTime? completedAt;
  final String? additionalNotes;
  final VisitPatientModel? patient;
  final VisitDoctorModel? preferredDoctor;
  final VisitDoctorModel? assignedDoctor;
  final List<StatusHistoryModel> statusHistories;
  final int? offerId;
  final double? offerDiscount;
  final String? offerCode;
  final DateTime createdAt;
  final DateTime updatedAt;

  VisitRequestModel({
    this.id = -1,
    this.referenceNumber = '',
    this.visitType = 'home_visit',
    this.visitReason = '',
    required this.preferredDate,
    this.contactPhone = '',
    this.status = VisitStatus.pending,
    this.cancellationReason,
    this.completedAt,
    this.additionalNotes,
    this.patient,
    this.preferredDoctor,
    this.assignedDoctor,
    this.statusHistories = const [],
    this.offerId,
    this.offerDiscount,
    this.offerCode,
    required this.createdAt,
    required this.updatedAt,
  });

  factory VisitRequestModel.fromJson(Map<String, dynamic> json) {
    return VisitRequestModel(
      id: json['id'] is int ? json['id'] : -1,
      referenceNumber: json['reference_number'] is String ? json['reference_number'] : '',
      visitType: json['visit_type'] is String ? json['visit_type'] : 'home_visit',
      visitReason: json['visit_reason'] is String ? json['visit_reason'] : '',
      preferredDate: json['preferred_date'] is String
          ? DateTime.tryParse(json['preferred_date']) ?? DateTime.now()
          : DateTime.now(),
      contactPhone: json['contact_phone'] is String ? json['contact_phone'] : '',
      status: VisitStatus.fromString(json['status'] is String ? json['status'] : null),
      cancellationReason: json['cancellation_reason'] is String ? json['cancellation_reason'] : null,
      completedAt: json['completed_at'] is String
          ? DateTime.tryParse(json['completed_at'])
          : null,
      additionalNotes: json['additional_notes'] is String ? json['additional_notes'] : null,
      patient: json['patient'] is Map<String, dynamic>
          ? VisitPatientModel.fromJson(json['patient'])
          : null,
      preferredDoctor: json['preferred_doctor'] is Map<String, dynamic>
          ? VisitDoctorModel.fromJson(json['preferred_doctor'])
          : null,
      assignedDoctor: json['assigned_doctor'] is Map<String, dynamic>
          ? VisitDoctorModel.fromJson(json['assigned_doctor'])
          : null,
      statusHistories: json['status_histories'] is List
          ? List<StatusHistoryModel>.from(
              (json['status_histories'] as List).map(
                (e) => StatusHistoryModel.fromJson(e as Map<String, dynamic>),
              ),
            )
          : [],
      offerId: json['offer_id'] is int ? json['offer_id'] : null,
      offerDiscount: json['offer_discount'] != null ? (json['offer_discount'] as num).toDouble() : null,
      offerCode: json['offer_code'] is String ? json['offer_code'] : null,
      createdAt: json['created_at'] is String
          ? DateTime.tryParse(json['created_at']) ?? DateTime.now()
          : DateTime.now(),
      updatedAt: json['updated_at'] is String
          ? DateTime.tryParse(json['updated_at']) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'reference_number': referenceNumber,
      'visit_type': visitType,
      'visit_reason': visitReason,
      'preferred_date': preferredDate.toIso8601String(),
      'contact_phone': contactPhone,
      'status': status.apiValue,
      'cancellation_reason': cancellationReason,
      'completed_at': completedAt?.toIso8601String(),
      'additional_notes': additionalNotes,
      'patient': patient?.toJson(),
      'preferred_doctor': preferredDoctor?.toJson(),
      'assigned_doctor': assignedDoctor?.toJson(),
      'status_histories': statusHistories.map((e) => e.toJson()).toList(),
      'offer_id': offerId,
      'offer_discount': offerDiscount,
      'offer_code': offerCode,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
