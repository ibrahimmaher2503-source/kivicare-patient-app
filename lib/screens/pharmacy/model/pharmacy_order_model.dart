import 'pharmacy_model.dart';
import 'pharmacy_parsers.dart';
import 'pharmacy_prescription_model.dart';

class PharmacyOrder {
  int? id;
  String? orderNumber;
  int? pharmacyId;
  Pharmacy? pharmacy;
  double? subtotal;
  double? discount;
  double? deliveryFee;
  double? totalAmount;
  String?
      status; // pending, confirmed, preparing, out_for_delivery, delivered, cancelled, refunded
  String? paymentMethod;
  String? deliveryAddress;
  String? createdAt;
  List<PharmacyOrderItem>? items;
  PharmacyPrescription? prescription;
  bool? canCancel;
  bool? canRefund;

  PharmacyOrder({
    this.id,
    this.orderNumber,
    this.pharmacyId,
    this.pharmacy,
    this.subtotal,
    this.discount,
    this.deliveryFee,
    this.totalAmount,
    this.status,
    this.paymentMethod,
    this.deliveryAddress,
    this.createdAt,
    this.items,
    this.prescription,
    this.canCancel,
    this.canRefund,
  });

  factory PharmacyOrder.fromJson(Map<String, dynamic> json) {
    return PharmacyOrder(
      id: pharmacyInt(json['id']),
      orderNumber: json['order_number'],
      pharmacyId: pharmacyInt(json['pharmacy_id']),
      pharmacy:
          json['pharmacy'] != null ? Pharmacy.fromJson(json['pharmacy']) : null,
      subtotal: pharmacyDouble(json['subtotal']),
      discount: pharmacyDouble(json['discount']),
      deliveryFee: pharmacyDouble(json['delivery_fee']),
      totalAmount: pharmacyDouble(json['total_amount']),
      status: json['status'],
      paymentMethod: json['payment_method'],
      deliveryAddress: json['delivery_address'],
      createdAt: json['created_at'],
      items: json['items'] != null
          ? (json['items'] as List)
              .map((i) => PharmacyOrderItem.fromJson(i))
              .toList()
          : [],
      prescription: json['prescription'] != null
          ? PharmacyPrescription.fromJson(json['prescription'])
          : null,
      canCancel: pharmacyBool(json['can_cancel']),
      canRefund: pharmacyBool(json['can_refund']),
    );
  }
}

class PharmacyOrderItem {
  int? id;
  int? productId;
  String? productName;
  String? productImage;
  double? unitPrice;
  int? quantity;
  double? lineTotal;

  PharmacyOrderItem({
    this.id,
    this.productId,
    this.productName,
    this.productImage,
    this.unitPrice,
    this.quantity,
    this.lineTotal,
  });

  factory PharmacyOrderItem.fromJson(Map<String, dynamic> json) {
    return PharmacyOrderItem(
      id: pharmacyInt(json['id']),
      productId: pharmacyInt(json['product_id']),
      productName: json['product_name'],
      productImage: json['product_image'],
      unitPrice: pharmacyDouble(json['unit_price']),
      quantity: pharmacyInt(json['quantity']),
      lineTotal: pharmacyDouble(json['line_total']),
    );
  }
}

class PharmacyOrderListRes {
  List<PharmacyOrder>? data;

  PharmacyOrderListRes({this.data});

  factory PharmacyOrderListRes.fromJson(Map<String, dynamic> json) {
    return PharmacyOrderListRes(
      data: json['data'] != null
          ? (json['data'] as List)
              .map((i) => PharmacyOrder.fromJson(i))
              .toList()
          : null,
    );
  }
}
