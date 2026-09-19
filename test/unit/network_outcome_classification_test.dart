import 'package:flutter_test/flutter_test.dart';
import 'package:kivicare_patient/network/network_utils.dart';
import 'package:nb_utils/nb_utils.dart';

void main() {
  test('only mutating HTTP methods can have an ambiguous committed outcome',
      () {
    expect(isMutatingHttpMethod(HttpMethodType.GET), isFalse);
    expect(isMutatingHttpMethod(HttpMethodType.POST), isTrue);
    expect(isMutatingHttpMethod(HttpMethodType.PUT), isTrue);
    expect(isMutatingHttpMethod(HttpMethodType.DELETE), isTrue);
  });

  test('ambiguous outcomes have a dedicated exception type', () {
    const error = AmbiguousRequestOutcomeException('verify status');
    expect(error, isA<NetworkRequestException>());
    expect(error.toString(), 'verify status');
  });
}
