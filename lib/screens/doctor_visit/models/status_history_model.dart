import 'visit_patient_model.dart';
import 'visit_status.dart';

class StatusHistoryModel {
  final VisitStatus? oldStatus;
  final VisitStatus newStatus;
  final VisitPatientModel? changedBy;
  final String? note;
  final DateTime changedAt;

  StatusHistoryModel({
    this.oldStatus,
    required this.newStatus,
    this.changedBy,
    this.note,
    required this.changedAt,
  });

  factory StatusHistoryModel.fromJson(Map<String, dynamic> json) {
    return StatusHistoryModel(
      oldStatus: json['old_status'] is String
          ? VisitStatus.fromString(json['old_status'])
          : null,
      newStatus: VisitStatus.fromString(json['new_status'] is String ? json['new_status'] : null),
      changedBy: json['changed_by'] is Map<String, dynamic>
          ? VisitPatientModel.fromJson(json['changed_by'])
          : null,
      note: json['note'] is String ? json['note'] : null,
      changedAt: json['changed_at'] is String
          ? DateTime.tryParse(json['changed_at']) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'old_status': oldStatus?.apiValue,
      'new_status': newStatus.apiValue,
      'changed_by': changedBy?.toJson(),
      'note': note,
      'changed_at': changedAt.toIso8601String(),
    };
  }
}
