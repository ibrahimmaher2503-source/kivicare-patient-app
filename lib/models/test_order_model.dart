import 'package:kivicare_patient/models/test_order_item_model.dart';

class TestOrder {
  final int id;
  final String orderNumber; // LAB-YYYY-NNNN format
  final int patientId;
  final int? doctorId;
  final List<TestOrderItem> items; // Individual test items in order
  final String? clinicalNotes; // Clinical instructions/notes
  final String priority; // routine, urgent, stat
  final String status; // pending, confirmed, sample_collected, processing, completed, delivered, cancelled
  final String paymentStatus; // unpaid, partial, paid
  final double totalAmount;
  final double discountAmount;
  final double finalAmount;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  TestOrder({
    required this.id,
    required this.orderNumber,
    required this.patientId,
    this.doctorId,
    required this.items,
    this.clinicalNotes,
    required this.priority,
    required this.status,
    required this.paymentStatus,
    required this.totalAmount,
    required this.discountAmount,
    required this.finalAmount,
    this.createdAt,
    this.updatedAt,
  });

  factory TestOrder.fromJson(Map<String, dynamic> json) {
    return TestOrder(
      id: json['id'] ?? 0,
      orderNumber: json['order_number'] ?? '',
      patientId: json['patient_id'] ?? 0,
      doctorId: json['doctor_id'],
      items: json['items'] != null
          ? (json['items'] as List).map((item) => TestOrderItem.fromJson(item)).toList()
          : [],
      clinicalNotes: json['clinical_notes'],
      priority: json['priority'] ?? 'routine',
      status: json['status'] ?? 'pending',
      paymentStatus: json['payment_status'] ?? 'unpaid',
      totalAmount: (json['total_amount'] as num?)?.toDouble() ?? 0.0,
      discountAmount: (json['discount_amount'] as num?)?.toDouble() ?? 0.0,
      finalAmount: (json['final_amount'] as num?)?.toDouble() ?? 0.0,
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at']) : null,
      updatedAt: json['updated_at'] != null ? DateTime.tryParse(json['updated_at']) : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'order_number': orderNumber,
    'patient_id': patientId,
    'doctor_id': doctorId,
    'items': items.map((item) => item.toJson()).toList(),
    'clinical_notes': clinicalNotes,
    'priority': priority,
    'status': status,
    'payment_status': paymentStatus,
    'total_amount': totalAmount,
    'discount_amount': discountAmount,
    'final_amount': finalAmount,
    'created_at': createdAt?.toIso8601String(),
    'updated_at': updatedAt?.toIso8601String(),
  };
}
