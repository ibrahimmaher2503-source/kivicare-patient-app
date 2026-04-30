import 'admission_request_model.dart';

class StatusHistoryEntry {
  final AdmissionStatus status;
  final DateTime changedAt;
  final String? note;

  StatusHistoryEntry({
    required this.status,
    required this.changedAt,
    this.note,
  });

  factory StatusHistoryEntry.fromJson(Map<String, dynamic> json) {
    return StatusHistoryEntry(
      status: AdmissionStatus.values.firstWhere(
        (e) => e.name == json['status'] || e.toString().split('.').last == json['status'],
        orElse: () => AdmissionStatus.pending,
      ),
      changedAt: json['changed_at'] != null ? DateTime.parse(json['changed_at']) : DateTime.now(),
      note: json['note'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status.name,
      'changed_at': changedAt.toIso8601String(),
      'note': note,
    };
  }
}
