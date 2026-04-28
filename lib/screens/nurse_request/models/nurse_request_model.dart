import 'assigned_nurse_model.dart';
import 'status_history_entry.dart';

class NurseRequestModel {
  final int id;
  final String referenceNumber;
  final String? serviceDescriptionEn;
  final String? serviceDescriptionAr;
  final DateTime preferredDate;
  final String? preferredTime;
  final int durationHours;
  final String addressLine1;
  final String? addressLine2;
  final int? governorateId;
  final int? cityId;
  final String city;
  final String? state;
  final String? country;
  final String? postalCode;
  final String contactPhone;
  final String? patientNotes;
  final String status;
  final AssignedNurseModel? assignedNurse;
  final double? totalAmount;
  final String? currency;
  final String? paymentStatus;
  final String? cancellationReason;
  final DateTime? completedAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<StatusHistoryEntry> statusHistory;

  const NurseRequestModel({
    required this.id,
    required this.referenceNumber,
    this.serviceDescriptionEn,
    this.serviceDescriptionAr,
    required this.preferredDate,
    this.preferredTime,
    required this.durationHours,
    required this.addressLine1,
    this.addressLine2,
    this.governorateId,
    this.cityId,
    required this.city,
    this.state,
    this.country,
    this.postalCode,
    required this.contactPhone,
    this.patientNotes,
    required this.status,
    this.assignedNurse,
    this.totalAmount,
    this.currency,
    this.paymentStatus,
    this.cancellationReason,
    this.completedAt,
    required this.createdAt,
    required this.updatedAt,
    required this.statusHistory,
  });

  String? serviceDescriptionLocalized(String localeCode) {
    final ar = serviceDescriptionAr?.trim() ?? '';
    final en = serviceDescriptionEn?.trim() ?? '';
    if (localeCode == 'ar') {
      return ar.isNotEmpty ? ar : (en.isNotEmpty ? en : null);
    }
    return en.isNotEmpty ? en : (ar.isNotEmpty ? ar : null);
  }

  factory NurseRequestModel.fromJson(Map<String, dynamic> json) {
    final historyList = json['status_history'] as List<dynamic>? ?? [];
    final assignedNurseJson = json['assigned_nurse'] as Map<String, dynamic>?;
    return NurseRequestModel(
      id: json['id'] ?? 0,
      referenceNumber: json['reference_number'] ?? '',
      serviceDescriptionEn: json['service_description_en'],
      serviceDescriptionAr: json['service_description_ar'],
      preferredDate: DateTime.tryParse(json['preferred_date'] ?? '') ?? DateTime.now(),
      preferredTime: json['preferred_time'],
      durationHours: json['duration_hours'] ?? 1,
      addressLine1: json['address_line_1'] ?? '',
      addressLine2: json['address_line_2'],
      governorateId: json['governorate_id'],
      cityId: json['city_id'],
      city: json['city'] ?? '',
      state: json['state'],
      country: json['country'],
      postalCode: json['postal_code'],
      contactPhone: json['contact_phone'] ?? '',
      patientNotes: json['patient_notes'],
      status: json['status'] ?? 'pending',
      assignedNurse: assignedNurseJson != null ? AssignedNurseModel.fromJson(assignedNurseJson) : null,
      totalAmount: json['total_amount'] != null ? (json['total_amount'] as num).toDouble() : null,
      currency: json['currency'],
      paymentStatus: json['payment_status'],
      cancellationReason: json['cancellation_reason'],
      completedAt: json['completed_at'] != null ? DateTime.tryParse(json['completed_at']) : null,
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updated_at'] ?? '') ?? DateTime.now(),
      statusHistory: historyList.map((e) => StatusHistoryEntry.fromJson(e as Map<String, dynamic>)).toList(),
    );
  }
}
