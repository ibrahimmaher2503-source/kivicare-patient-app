import 'package:flutter_test/flutter_test.dart';
import 'package:kivicare_patient/screens/pharmacy/model/pharmacy_order_model.dart';

/// Unit tests for order API response parsing.
///
/// Tests verify the `fromJson` contracts for order placement and cancellation
/// responses without requiring a live backend.
void main() {
  group('placePharmacyOrder — success response (201)', () {
    test('PharmacyOrderPlacedResponse.fromJson parses created order', () {
      final successBody = {
        'status': true,
        'message': 'Order placed successfully',
        'data': {
          'id': 101,
          'status': 'pending',
          'total': 75.50,
          'item_count': 3,
          'created_at': '2024-01-20T09:30:00Z',
          'pharmacy': {
            'id': 5,
            'name': 'Hayat Pharmacy',
          },
        },
      };
      final res = PharmacyOrderPlacedResponse.fromJson(successBody);
      expect(res.status, isTrue);
      expect(res.message, 'Order placed successfully');
      expect(res.data?.id, 101);
      expect(res.data?.status, 'pending');
      expect(res.data?.total, 75.50);
      expect(res.data?.itemCount, 3);
      expect(res.data?.pharmacy?.name, 'Hayat Pharmacy');
    });

    test('parses integer total as double', () {
      final body = {
        'status': true,
        'data': {'id': 1, 'status': 'pending', 'total': 100, 'item_count': 1, 'created_at': ''},
      };
      final res = PharmacyOrderPlacedResponse.fromJson(body);
      expect(res.data?.total, 100.0);
    });
  });

  group('placePharmacyOrder — stock conflict response (422)', () {
    test('failed response has status false and message', () {
      final errorBody = {
        'status': false,
        'message': 'One or more products are out of stock',
        'data': null,
      };
      final res = PharmacyOrderPlacedResponse.fromJson(errorBody);
      expect(res.status, isFalse);
      expect(res.data, isNull);
      expect(res.message, 'One or more products are out of stock');
    });
  });

  group('cancelPharmacyOrder — success response', () {
    test('order status transitions to cancelled after successful cancel', () {
      // After cancellation, getPharmacyOrderDetail returns updated order
      final detailBody = {
        'status': true,
        'data': {
          'id': 101,
          'status': 'cancelled',
          'subtotal': 75.0,
          'delivery_fee': 5.0,
          'total': 80.0,
          'payment_method': 'cash_on_delivery',
          'created_at': '2024-01-20T09:30:00Z',
          'updated_at': '2024-01-20T10:00:00Z',
          'items': [],
        },
      };
      final res = PharmacyOrderDetailResponse.fromJson(detailBody);
      expect(res.status, isTrue);
      expect(res.data?.status, 'cancelled');
      expect(res.data?.id, 101);
    });
  });

  group('getPharmacyOrders — paginated list', () {
    test('parses first page with meta', () {
      final body = {
        'status': true,
        'data': [
          {
            'id': 1,
            'status': 'confirmed',
            'total': 50.0,
            'item_count': 2,
            'created_at': '2024-01-18T08:00:00Z',
            'pharmacy': {'id': 3, 'name': 'Al-Noor'},
          },
          {
            'id': 2,
            'status': 'pending',
            'total': 120.0,
            'item_count': 5,
            'created_at': '2024-01-19T14:00:00Z',
          },
        ],
        'meta': {
          'current_page': 1,
          'last_page': 3,
          'per_page': 15,
          'total': 40,
        },
      };
      final res = PharmacyOrderListResponse.fromJson(body);
      expect(res.status, isTrue);
      expect(res.data.length, 2);
      expect(res.currentPage, 1);
      expect(res.lastPage, 3);
      expect(res.total, 40);
      expect(res.data.first.pharmacy?.name, 'Al-Noor');
    });

    test('last page detection: currentPage == lastPage', () {
      final body = {
        'status': true,
        'data': [
          {'id': 9, 'status': 'delivered', 'total': 25.0, 'item_count': 1, 'created_at': ''},
        ],
        'meta': {'current_page': 3, 'last_page': 3, 'per_page': 15, 'total': 9},
      };
      final res = PharmacyOrderListResponse.fromJson(body);
      expect(res.currentPage, res.lastPage);
    });

    test('empty order history', () {
      final body = {
        'status': true,
        'data': [],
        'meta': {'current_page': 1, 'last_page': 1, 'per_page': 15, 'total': 0},
      };
      final res = PharmacyOrderListResponse.fromJson(body);
      expect(res.data, isEmpty);
      expect(res.total, 0);
    });
  });

  group('PharmacyOrderDetail — item line totals', () {
    test('calculates correct line total from quantity × price', () {
      final item = PharmacyOrderItem.fromJson({
        'id': 1,
        'product_id': 5,
        'product_name': 'Vitamin C',
        'quantity': 3,
        'price': 12.0,
        'line_total': 36.0,
      });
      expect(item.quantity * item.price, closeTo(item.lineTotal, 0.001));
    });
  });
}
