import 'package:flutter_test/flutter_test.dart';
import 'package:kivicare_patient/screens/pharmacy/model/pharmacy_category_model.dart';
import 'package:kivicare_patient/screens/pharmacy/model/pharmacy_product_model.dart';
import 'package:kivicare_patient/screens/pharmacy/model/pharmacy_filter_model.dart';
import 'package:kivicare_patient/screens/pharmacy/model/pharmacy_cart_model.dart';
import 'package:kivicare_patient/screens/pharmacy/model/pharmacy_order_model.dart';

void main() {
  group('PharmacyCategory fromJson', () {
    test('parses all fields correctly', () {
      final json = {
        'id': 1,
        'name': 'Vitamins',
        'name_ar': 'فيتامينات',
        'name_en': 'Vitamins',
        'image': 'https://example.com/img.png',
        'sort_order': 2,
      };
      final cat = PharmacyCategory.fromJson(json);
      expect(cat.id, 1);
      expect(cat.name, 'Vitamins');
      expect(cat.nameAr, 'فيتامينات');
      expect(cat.image, 'https://example.com/img.png');
      expect(cat.sortOrder, 2);
    });

    test('uses safe defaults for missing fields', () {
      final cat = PharmacyCategory.fromJson({});
      expect(cat.id, -1);
      expect(cat.name, '');
      expect(cat.image, isNull);
      expect(cat.sortOrder, 0);
    });
  });

  group('PharmacyCategoryListResponse fromJson', () {
    test('parses data array', () {
      final json = {
        'status': true,
        'data': [
          {'id': 1, 'name': 'Cat A'},
          {'id': 2, 'name': 'Cat B'},
        ],
      };
      final res = PharmacyCategoryListResponse.fromJson(json);
      expect(res.status, isTrue);
      expect(res.data.length, 2);
      expect(res.data.first.name, 'Cat A');
    });

    test('handles empty data gracefully', () {
      final res = PharmacyCategoryListResponse.fromJson({'status': false, 'data': []});
      expect(res.data, isEmpty);
    });
  });

  group('PharmacyProduct fromJson', () {
    test('parses numeric priceFrom correctly', () {
      final json = {
        'id': 10,
        'name': 'Panadol',
        'price_from': 5,
        'is_in_stock': true,
        'requires_prescription': false,
      };
      final p = PharmacyProduct.fromJson(json);
      expect(p.id, 10);
      expect(p.priceFrom, 5.0);
      expect(p.isInStock, isTrue);
      expect(p.requiresPrescription, isFalse);
    });

    test('parses decimal price', () {
      final p = PharmacyProduct.fromJson({'price_from': 12.99});
      expect(p.priceFrom, closeTo(12.99, 0.001));
    });

    test('defaults isInStock to true when missing', () {
      final p = PharmacyProduct.fromJson({});
      expect(p.isInStock, isTrue);
    });
  });

  group('PharmacyFilterOption fromJson', () {
    test('parses id and name', () {
      final f = PharmacyFilterOption.fromJson({'id': 5, 'name': 'Pfizer'});
      expect(f.id, 5);
      expect(f.name, 'Pfizer');
    });
  });

  group('PharmacyCart fromJson', () {
    test('parses items and item_count', () {
      final json = {
        'items': [
          {'id': 1, 'quantity': 2, 'product': {'id': 7, 'name': 'Aspirin', 'price_from': 3.0}},
        ],
        'item_count': 1,
      };
      final cart = PharmacyCart.fromJson(json);
      expect(cart.itemCount, 1);
      expect(cart.items.length, 1);
      expect(cart.items.first.product?.name, 'Aspirin');
      expect(cart.items.first.quantity, 2);
    });

    test('falls back to items length when item_count missing', () {
      final json = {
        'items': [
          {'id': 1, 'quantity': 1},
          {'id': 2, 'quantity': 3},
        ],
      };
      final cart = PharmacyCart.fromJson(json);
      expect(cart.itemCount, 2);
    });

    test('handles empty cart', () {
      final cart = PharmacyCart.fromJson({'items': [], 'item_count': 0});
      expect(cart.items, isEmpty);
      expect(cart.itemCount, 0);
    });
  });

  group('PharmacyCartResponse fromJson', () {
    test('parses nested cart', () {
      final json = {
        'status': true,
        'data': {'items': [], 'item_count': 0},
      };
      final res = PharmacyCartResponse.fromJson(json);
      expect(res.status, isTrue);
      expect(res.data, isNotNull);
    });
  });

  group('PharmacyAvailablePharmacy fromJson', () {
    test('parses pricing fields', () {
      final json = {
        'id': 3,
        'name': 'Al-Shifaa Pharmacy',
        'subtotal': 45.0,
        'delivery_fee': 5.0,
        'total': 50.0,
      };
      final p = PharmacyAvailablePharmacy.fromJson(json);
      expect(p.id, 3);
      expect(p.name, 'Al-Shifaa Pharmacy');
      expect(p.subtotal, 45.0);
      expect(p.deliveryFee, 5.0);
      expect(p.total, 50.0);
    });

    test('handles integer pricing values', () {
      final p = PharmacyAvailablePharmacy.fromJson({'subtotal': 10, 'delivery_fee': 2, 'total': 12});
      expect(p.subtotal, 10.0);
      expect(p.deliveryFee, 2.0);
      expect(p.total, 12.0);
    });
  });

  group('PharmacyOrderSummary fromJson', () {
    test('parses with nested pharmacy ref', () {
      final json = {
        'id': 99,
        'status': 'pending',
        'total': 75.5,
        'item_count': 3,
        'created_at': '2024-01-15T10:00:00Z',
        'pharmacy': {'id': 1, 'name': 'City Pharmacy'},
      };
      final order = PharmacyOrderSummary.fromJson(json);
      expect(order.id, 99);
      expect(order.status, 'pending');
      expect(order.total, 75.5);
      expect(order.itemCount, 3);
      expect(order.pharmacy?.name, 'City Pharmacy');
    });
  });

  group('PharmacyOrderDetail fromJson', () {
    test('parses full order with items', () {
      final json = {
        'id': 42,
        'status': 'confirmed',
        'subtotal': 90.0,
        'delivery_fee': 10.0,
        'total': 100.0,
        'payment_method': 'cash_on_delivery',
        'created_at': '2024-01-16T12:00:00Z',
        'updated_at': '2024-01-16T12:01:00Z',
        'items': [
          {
            'id': 1,
            'product_id': 5,
            'product_name': 'Panadol',
            'quantity': 2,
            'price': 5.0,
            'line_total': 10.0,
          }
        ],
      };
      final detail = PharmacyOrderDetail.fromJson(json);
      expect(detail.id, 42);
      expect(detail.status, 'confirmed');
      expect(detail.items.length, 1);
      expect(detail.items.first.productName, 'Panadol');
      expect(detail.items.first.lineTotal, 10.0);
      expect(detail.total, 100.0);
    });
  });

  group('PharmacyOrderListResponse fromJson', () {
    test('parses meta pagination', () {
      final json = {
        'status': true,
        'data': [
          {'id': 1, 'status': 'pending', 'total': 50.0, 'item_count': 1, 'created_at': ''},
        ],
        'meta': {
          'current_page': 2,
          'last_page': 5,
          'per_page': 10,
          'total': 48,
        },
      };
      final res = PharmacyOrderListResponse.fromJson(json);
      expect(res.status, isTrue);
      expect(res.data.length, 1);
      expect(res.currentPage, 2);
      expect(res.lastPage, 5);
      expect(res.total, 48);
    });

    test('uses defaults when meta is absent', () {
      final res = PharmacyOrderListResponse.fromJson({'status': true, 'data': []});
      expect(res.currentPage, 1);
      expect(res.lastPage, 1);
    });
  });

  group('PharmacyOrderPlacedResponse fromJson', () {
    test('parses order summary and message', () {
      final json = {
        'status': true,
        'message': 'Order placed successfully',
        'data': {'id': 77, 'status': 'pending', 'total': 60.0, 'item_count': 2, 'created_at': ''},
      };
      final res = PharmacyOrderPlacedResponse.fromJson(json);
      expect(res.status, isTrue);
      expect(res.message, 'Order placed successfully');
      expect(res.data?.id, 77);
    });
  });
}
