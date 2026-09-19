import 'pharmacy_parsers.dart';

class PharmacyRefund {
  int? id;
  int? orderId;
  String? orderNumber;
  String? reason;
  String? notes;
  double? refundAmount;
  String? status; // pending, approved, rejected, processed
  String? rejectionReason;
  String? createdAt;
  String? updatedAt;

  PharmacyRefund({
    this.id,
    this.orderId,
    this.orderNumber,
    this.reason,
    this.notes,
    this.refundAmount,
    this.status,
    this.rejectionReason,
    this.createdAt,
    this.updatedAt,
  });

  factory PharmacyRefund.fromJson(Map<String, dynamic> json) {
    return PharmacyRefund(
      id: pharmacyInt(json['id']),
      orderId: pharmacyInt(json['order_id']),
      orderNumber: json['order_number'],
      reason: json['reason'],
      notes: json['notes'],
      refundAmount: pharmacyDouble(json['refund_amount']),
      status: json['status'],
      rejectionReason: json['rejection_reason'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }
}

class PharmacyRefundListRes {
  List<PharmacyRefund>? data;

  PharmacyRefundListRes({this.data});

  factory PharmacyRefundListRes.fromJson(Map<String, dynamic> json) {
    return PharmacyRefundListRes(
      data: json['data'] != null
          ? (json['data'] as List)
              .map((i) => PharmacyRefund.fromJson(i))
              .toList()
          : null,
    );
  }
}
