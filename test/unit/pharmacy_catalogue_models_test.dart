import 'package:flutter_test/flutter_test.dart';
import 'package:kivicare_patient/screens/pharmacy/model/pharmacy_category_model.dart';
import 'package:kivicare_patient/screens/pharmacy/model/pharmacy_product_model.dart';

void main() {
  test('catalogue models discard blank image values', () {
    expect(PharmacyCategory.fromJson({'id': 1, 'image': '  '}).image, isNull);
    expect(
      PharmacyProduct.fromJson({
        'id': 1,
        'images': ['', '  ']
      }).images,
      isEmpty,
    );
  });

  test('catalogue models preserve a usable image URL', () {
    expect(
      PharmacyCategory.fromJson(
          {'id': 1, 'image': 'https://example.test/a.png'}).image,
      'https://example.test/a.png',
    );
  });
}
