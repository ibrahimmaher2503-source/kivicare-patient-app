class StatusHistoryEntry {
  final String? previousStatus;
  final String newStatus;
  final String? note;
  final DateTime changedAt;

  const StatusHistoryEntry({
    this.previousStatus,
    required this.newStatus,
    this.note,
    required this.changedAt,
  });

  factory StatusHistoryEntry.fromJson(Map<String, dynamic> json) {
    return StatusHistoryEntry(
      previousStatus: json['previous_status'],
      newStatus: json['new_status'] ?? 'pending',
      note: json['note'],
      changedAt: DateTime.tryParse(json['changed_at'] ?? '') ?? DateTime.now(),
    );
  }
}
