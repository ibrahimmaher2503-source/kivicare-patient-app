import 'package:intl/intl.dart';

import 'app_common.dart';

String get activeIntlLocale =>
    selectedLanguageCode.value == 'ar' ? 'ar_EG' : 'en_EG';

String formatLocalizedDate(DateTime value, String pattern) {
  return DateFormat(pattern, activeIntlLocale).format(value);
}

String formatLocalizedCurrency(num value, String? currencyCode) {
  final code = currencyCode?.trim().toUpperCase();
  if (code == null || code.isEmpty) {
    return NumberFormat.decimalPattern(activeIntlLocale).format(value);
  }
  return NumberFormat.currency(
    locale: activeIntlLocale,
    name: code,
    symbol: code == 'EGP' && selectedLanguageCode.value == 'ar' ? 'ج.م' : code,
    decimalDigits: appCurrency.value.noOfDecimal,
  ).format(value);
}
