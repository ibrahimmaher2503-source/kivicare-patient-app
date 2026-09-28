class PharmacyOrderReceipt {
  final int orderId;
  final String orderNumber;

  const PharmacyOrderReceipt({
    required this.orderId,
    required this.orderNumber,
  });
}

PharmacyOrderReceipt parsePharmacyOrderReceipt(dynamic raw) {
  if (raw is! Map) {
    throw const FormatException('Invalid pharmacy order response');
  }
  final response = Map<String, dynamic>.from(raw);
  if (response['status'] != true) {
    throw FormatException(
      response['message']?.toString() ?? 'Pharmacy order was not accepted',
    );
  }

  final rawData = response['data'];
  if (rawData is! Map) {
    throw const FormatException('Pharmacy order receipt is missing');
  }
  final data = Map<String, dynamic>.from(rawData);
  final rawOrder = data['order'];
  final order = rawOrder is Map ? Map<String, dynamic>.from(rawOrder) : data;
  final orderId = int.tryParse(order['id']?.toString() ?? '') ?? 0;
  final orderNumber = order['order_number']?.toString().trim() ?? '';
  if (orderId <= 0 || orderNumber.isEmpty) {
    throw const FormatException('Pharmacy order receipt is incomplete');
  }

  return PharmacyOrderReceipt(
    orderId: orderId,
    orderNumber: orderNumber,
  );
}
