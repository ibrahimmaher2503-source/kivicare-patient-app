import 'package:flutter_test/flutter_test.dart';
import 'package:kivicare_patient/screens/pharmacy/model/pharmacy_cart_model.dart';

/// Unit tests for cart API response parsing.
///
/// Note: Full integration tests that exercise the HTTP layer require a running
/// backend. These tests focus on the response model contracts — verifying that
/// the `fromJson` methods correctly map API responses to cart state.
void main() {
  group('addToPharmacyCart — response contract', () {
    test('success response maps to PharmacyCart with updated items', () {
      // Simulates the response body returned by POST /v1/pharmacy/cart/items
      final successBody = {
        'status': true,
        'data': {
          'items': [
            {
              'id': 1,
              'quantity': 2,
              'product': {
                'id': 10,
                'name': 'Panadol Extra',
                'image': null,
                'price_from': 5.50,
                'is_in_stock': true,
              },
            }
          ],
          'item_count': 1,
        },
      };
      final res = PharmacyCartResponse.fromJson(successBody);
      expect(res.status, isTrue);
      expect(res.data, isNotNull);
      expect(res.data!.itemCount, 1);
      expect(res.data!.items.first.product?.name, 'Panadol Extra');
      expect(res.data!.items.first.quantity, 2);
    });

    test('cart item product price_from accepts integer values', () {
      final body = {
        'status': true,
        'data': {
          'items': [
            {'id': 1, 'quantity': 1, 'product': {'id': 5, 'name': 'Aspirin', 'price_from': 3}},
          ],
          'item_count': 1,
        },
      };
      final res = PharmacyCartResponse.fromJson(body);
      expect(res.data!.items.first.product!.priceFrom, 3.0);
    });

    test('out-of-stock product correctly parsed', () {
      final body = {
        'status': true,
        'data': {
          'items': [
            {'id': 1, 'quantity': 1, 'product': {'id': 5, 'name': 'OOS Product', 'price_from': 10.0, 'is_in_stock': false}},
          ],
          'item_count': 1,
        },
      };
      final res = PharmacyCartResponse.fromJson(body);
      expect(res.data!.items.first.product!.isInStock, isFalse);
    });
  });

  group('updatePharmacyCartItem — response contract', () {
    test('PATCH response returns updated cart with new quantity', () {
      // Simulates PATCH /v1/pharmacy/cart/items/{id} returning updated cart
      final body = {
        'status': true,
        'data': {
          'items': [
            {'id': 1, 'quantity': 5, 'product': {'id': 10, 'name': 'Panadol', 'price_from': 5.50}},
          ],
          'item_count': 1,
        },
      };
      final res = PharmacyCartResponse.fromJson(body);
      expect(res.data!.items.first.quantity, 5);
    });
  });

  group('removePharmacyCartItem — response contract', () {
    test('DELETE response returns cart with item removed', () {
      // After removal, cart is empty
      final body = {
        'status': true,
        'data': {
          'items': [],
          'item_count': 0,
        },
      };
      final res = PharmacyCartResponse.fromJson(body);
      expect(res.status, isTrue);
      expect(res.data!.items, isEmpty);
      expect(res.data!.itemCount, 0);
    });
  });

  group('getAvailablePharmacies — response contract', () {
    test('parses list of available pharmacies with pricing', () {
      final body = {
        'status': true,
        'data': [
          {
            'id': 1,
            'name': 'Al-Dawa Pharmacy',
            'subtotal': 55.0,
            'delivery_fee': 5.0,
            'total': 60.0,
          },
          {
            'id': 2,
            'name': 'City Health',
            'subtotal': 55.0,
            'delivery_fee': 10.0,
            'total': 65.0,
          },
        ],
      };
      final res = PharmacyAvailablePharmacyListResponse.fromJson(body);
      expect(res.status, isTrue);
      expect(res.data.length, 2);
      expect(res.data.first.total, 60.0);
      expect(res.data.last.deliveryFee, 10.0);
    });

    test('no matching pharmacies returns empty list with message', () {
      final body = {
        'status': false,
        'data': [],
        'message': 'No pharmacies serve your area',
      };
      final res = PharmacyAvailablePharmacyListResponse.fromJson(body);
      expect(res.status, isFalse);
      expect(res.data, isEmpty);
      expect(res.message, 'No pharmacies serve your area');
    });
  });
}
