import 'package:kivicare_patient/models/lab_test_model.dart';

class TestOrderItem {
  final int id;
  final int testId;
  final int orderId;
  final LabTest? labTest; // Relationship to the test
  final double price;
  final String status; // pending, sample_collected, processing, completed
  final String? resultValue;
  final String? resultUnit;
  final String? referenceRange;
  final String? resultStatus; // normal, abnormal, pending
  final String? resultNotes;
  final DateTime? resultDate;

  TestOrderItem({
    required this.id,
    required this.testId,
    required this.orderId,
    this.labTest,
    required this.price,
    required this.status,
    this.resultValue,
    this.resultUnit,
    this.referenceRange,
    this.resultStatus,
    this.resultNotes,
    this.resultDate,
  });

  factory TestOrderItem.fromJson(Map<String, dynamic> json) {
    return TestOrderItem(
      id: json['id'] ?? 0,
      testId: json['test_id'] ?? 0,
      orderId: json['order_id'] ?? 0,
      labTest: json['lab_test'] != null ? LabTest.fromJson(json['lab_test']) : null,
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      status: json['status'] ?? 'pending',
      resultValue: json['result_value'],
      resultUnit: json['result_unit'],
      referenceRange: json['reference_range'],
      resultStatus: json['result_status'],
      resultNotes: json['result_notes'],
      resultDate: json['result_date'] != null ? DateTime.tryParse(json['result_date']) : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'test_id': testId,
    'order_id': orderId,
    'lab_test': labTest?.toJson(),
    'price': price,
    'status': status,
    'result_value': resultValue,
    'result_unit': resultUnit,
    'reference_range': referenceRange,
    'result_status': resultStatus,
    'result_notes': resultNotes,
    'result_date': resultDate?.toIso8601String(),
  };
}
