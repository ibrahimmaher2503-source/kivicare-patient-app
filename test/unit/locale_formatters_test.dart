import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:kivicare_patient/locale/language_ar.dart';
import 'package:kivicare_patient/screens/pharmacy/utils/pharmacy_constants.dart';
import 'package:kivicare_patient/utils/app_common.dart';
import 'package:kivicare_patient/utils/common_base.dart';
import 'package:kivicare_patient/utils/locale_formatters.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting('ar_EG');
    await initializeDateFormatting('en_EG');
  });

  tearDown(() => selectedLanguageCode('ar'));

  test('Arabic dates and EGP amounts use Egyptian locale output', () {
    selectedLanguageCode('ar');
    expect(activeIntlLocale, 'ar_EG');
    expect(
      formatLocalizedDate(DateTime(2026, 3, 10), 'd MMMM yyyy'),
      contains('مارس'),
    );
    expect(formatLocalizedCurrency(125, 'EGP'), contains('ج.م'));
  });

  test('Arabic language metadata uses the Egypt region', () {
    final arabic =
        languageList().firstWhere((language) => language.languageCode == 'ar');
    expect(arabic.fullLanguageCode, 'ar-EG');
  });

  test('English dates use the Egypt locale when selected', () {
    selectedLanguageCode('en');
    expect(activeIntlLocale, 'en_EG');
    expect(
      formatLocalizedDate(DateTime(2026, 3, 10), 'd MMMM yyyy'),
      contains('March'),
    );
  });

  test('pharmacy wire statuses are mapped to localized labels', () {
    final language = LanguageAr();
    expect(
      PharmacyConstants.orderStatusLabel(language, 'out_for_delivery'),
      language.outForDelivery,
    );
    expect(
      PharmacyConstants.prescriptionStatusLabel(language, 'reviewed'),
      language.reviewed,
    );
    expect(
      PharmacyConstants.refundStatusLabel(language, 'processed'),
      language.processed,
    );
  });
}
