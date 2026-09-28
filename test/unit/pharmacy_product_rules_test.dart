import 'package:flutter_test/flutter_test.dart';
import 'package:kivicare_patient/screens/pharmacy/utils/pharmacy_product_rules.dart';

void main() {
  test('discount is absent for zero or non-discounted reference prices', () {
    expect(
      pharmacyDiscountPercentage(price: 10, referencePrice: 0),
      isNull,
    );
    expect(
      pharmacyDiscountPercentage(price: 10, referencePrice: 10),
      isNull,
    );
  });

  test('discount is calculated only for a valid higher reference price', () {
    expect(
      pharmacyDiscountPercentage(price: 75, referencePrice: 100),
      25,
    );
  });

  test('zero stock is unavailable while unspecified stock remains valid', () {
    expect(pharmacyProductIsOutOfStock(0), isTrue);
    expect(pharmacyProductIsOutOfStock(-1), isTrue);
    expect(pharmacyProductIsOutOfStock(null), isFalse);
  });
}
