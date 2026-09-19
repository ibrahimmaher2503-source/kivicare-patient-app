import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('sign-in has no reusable demo credentials or fixed OTP', () {
    final source = File(
      'lib/screens/auth/sign_in_sign_up/sign_in_controller.dart',
    ).readAsStringSync();

    expect(source, isNot(contains('Constants.DEFAULT_EMAIL')));
    expect(source, isNot(contains('Constants.DEFAULT_PASS')));
    expect(source, isNot(contains('isDummyCredential')));
    expect(source, isNot(matches(RegExp(r'otp\w*\.text\s*=\s*\d{4,6}'))));
    expect(source, contains("emailCont.text = ''"));
    expect(source, contains("passwordCont.text = ''"));
  });
}
