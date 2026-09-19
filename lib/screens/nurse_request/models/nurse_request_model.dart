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
    final address = json['address'] is Map
        ? Map<String, dynamic>.from(json['address'] as Map)
        : const <String, dynamic>{};
    final assignedNurseJson = json['assigned_nurse'] is Map
        ? Map<String, dynamic>.from(json['assigned_nurse'] as Map)
        : json['nurse'] is Map
            ? Map<String, dynamic>.from(json['nurse'] as Map)
            : null;
    final id = _asInt(json['id']);
    final paymentStatus = json['payment_status'];
    return NurseRequestModel(
      id: id,
      referenceNumber: _asString(json['reference_number']).isNotEmpty
          ? _asString(json['reference_number'])
          : 'NR-${id.toString().padLeft(6, '0')}',
      serviceDescriptionEn: _nullableString(json['service_description_en']),
      serviceDescriptionAr: _nullableString(json['service_description_ar']),
      preferredDate: DateTime.tryParse(_asString(json['preferred_date'])) ??
          DateTime.now(),
      preferredTime: _nullableString(json['preferred_time']),
      durationHours: _asInt(json['duration_hours'], fallback: 1),
      addressLine1:
          _asString(json['address_line_1'] ?? address['address_line_1']),
      addressLine2:
          _nullableString(json['address_line_2'] ?? address['address_line_2']),
      governorateId: _nullableInt(json['governorate_id']),
      cityId: _nullableInt(json['city_id']),
      city: _asString(json['city'] ?? address['city']),
      state: _nullableString(json['state'] ?? address['state']),
      country: _nullableString(json['country'] ?? address['country']),
      postalCode:
          _nullableString(json['postal_code'] ?? address['postal_code']),
      contactPhone: _asString(json['contact_phone'] ?? json['contact_number']),
      patientNotes: _nullableString(json['patient_notes']),
      status: _asString(json['status'], fallback: 'pending'),
      assignedNurse: assignedNurseJson != null
          ? AssignedNurseModel.fromJson(assignedNurseJson)
          : null,
      totalAmount: _nullableDouble(json['total_amount']),
      currency: _nullableString(json['currency']),
      paymentStatus: paymentStatus is bool
          ? (paymentStatus ? 'paid' : 'unpaid')
          : _nullableString(paymentStatus),
      cancellationReason: _nullableString(json['cancellation_reason']),
      completedAt: DateTime.tryParse(_asString(json['completed_at'])),
      createdAt:
          DateTime.tryParse(_asString(json['created_at'])) ?? DateTime.now(),
      updatedAt:
          DateTime.tryParse(_asString(json['updated_at'])) ?? DateTime.now(),
      statusHistory: historyList
          .map((e) => StatusHistoryEntry.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  static String _asString(dynamic value, {String fallback = ''}) =>
      value?.toString() ?? fallback;
  static String? _nullableString(dynamic value) {
    final string = _asString(value).trim();
    return string.isEmpty ? null : string;
  }

  static int _asInt(dynamic value, {int fallback = 0}) => value is num
      ? value.toInt()
      : double.tryParse(value?.toString() ?? '')?.toInt() ?? fallback;
  static int? _nullableInt(dynamic value) =>
      value == null ? null : _asInt(value);
  static double? _nullableDouble(dynamic value) => value is num
      ? value.toDouble()
      : double.tryParse(value?.toString() ?? '');
}
