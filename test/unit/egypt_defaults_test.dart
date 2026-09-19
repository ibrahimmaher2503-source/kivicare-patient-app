import 'package:flutter_test/flutter_test.dart';
import 'package:kivicare_patient/configs.dart';
import 'package:kivicare_patient/screens/auth/model/app_configuration_res.dart';
import 'package:kivicare_patient/utils/constants.dart';

void main() {
  test('new installs default to Arabic and Egypt', () {
    expect(DEFAULT_LANGUAGE, 'ar');
    expect(defaultCountry.countryCode, 'EG');
    expect(defaultCountry.phoneCode, '20');
  });

  test('missing backend currency data safely falls back to EGP', () {
    final currency = Currency.fromJson(const <String, dynamic>{});
    expect(currency.currencyCode, 'EGP');
    expect(currency.currencySymbol, 'ج.م');
  });
}
