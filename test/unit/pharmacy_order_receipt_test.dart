import 'package:flutter_test/flutter_test.dart';
import 'package:kivicare_patient/screens/pharmacy/model/pharmacy_order_receipt.dart';

void main() {
  group('parsePharmacyOrderReceipt', () {
    test('accepts a validated direct receipt', () {
      final receipt = parsePharmacyOrderReceipt({
        'status': true,
        'data': {'id': 17, 'order_number': 'PH-17'},
      });

      expect(receipt.orderId, 17);
      expect(receipt.orderNumber, 'PH-17');
    });

    test('accepts a nested order receipt', () {
      final receipt = parsePharmacyOrderReceipt({
        'status': true,
        'data': {
          'order': {'id': '18', 'order_number': 'PH-18'},
        },
      });

      expect(receipt.orderId, 18);
      expect(receipt.orderNumber, 'PH-18');
    });

    test('rejects a receipt without a usable id and reference', () {
      expect(
        () => parsePharmacyOrderReceipt({
          'status': true,
          'data': {'id': 0, 'order_number': ''},
        }),
        throwsA(isA<FormatException>()),
      );
    });

    test('rejects a logical order failure', () {
      expect(
        () => parsePharmacyOrderReceipt({
          'status': false,
          'message': 'Order rejected',
        }),
        throwsA(isA<FormatException>()),
      );
    });
  });
}
