import 'package:flutter_test/flutter_test.dart';
import 'package:kivicare_patient/network/network_utils.dart';

void main() {
  const fallback = 'Something Went Wrong';

  test('keeps short plain validation messages', () {
    expect(sanitizeBackendMessage('Email is already registered', fallback),
        'Email is already registered');
    expect(sanitizeBackendMessage('Please update your profile and set a password', fallback),
        'Please update your profile and set a password');
  });

  test('hides markup, diagnostics, long, and empty messages', () {
    for (final value in [
      '<html>SQLSTATE[42S02]</html>',
      'Exception: #0 /var/www/app.php',
      'Call to undefined method App\\Models\\User::foo()',
      'Warning: require(/var/www/html/vendor/autoload.php): failed to open stream',
      List.filled(241, 'x').join(),
      '',
      null,
    ]) {
      expect(sanitizeBackendMessage(value, fallback), fallback);
    }
  });
}
