import 'test_order_status.dart';

class TestOrderStatusHistoryModel {
  TestOrderStatus? oldStatus;
  TestOrderStatus newStatus;
  String? note;
  DateTime changedAt;

  TestOrderStatusHistoryModel({
    this.oldStatus,
    this.newStatus = TestOrderStatus.pending,
    this.note,
    required this.changedAt,
  });

  factory TestOrderStatusHistoryModel.fromJson(Map<String, dynamic> json) {
    return TestOrderStatusHistoryModel(
      oldStatus: json['old_status'] != null
          ? TestOrderStatus.fromString(json['old_status'])
          : null,
      newStatus: TestOrderStatus.fromString(json['new_status']),
      note: json['note'],
      changedAt: json['changed_at'] != null
          ? DateTime.parse(json['changed_at'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'old_status': oldStatus?.apiValue,
      'new_status': newStatus.apiValue,
      'note': note,
      'changed_at': changedAt.toIso8601String(),
    };
  }
}
