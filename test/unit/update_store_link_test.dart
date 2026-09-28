import 'package:flutter_test/flutter_test.dart';
import 'package:kivicare_patient/utils/update_store_link.dart';

void main() {
  test('store links require an absolute HTTPS URL', () {
    expect(validatedStoreUri('https://apps.apple.com/app/id123'), isNotNull);
    expect(validatedStoreUri('http://apps.apple.com/app/id123'), isNull);
    expect(validatedStoreUri(''), isNull);
    expect(validatedStoreUri('/app/id123'), isNull);
  });
}
