import 'app_common.dart';

/// Resolves a localized string from a JSON map that ships `<base>_ar` /
/// `<base>_en` pairs (and optionally a default `<base>` column), based on the
/// current app locale.
///
/// Fallback order: preferred-locale → other-locale → default → fallback.
String pickLocalized(Map json, String baseKey, {String fallback = ''}) {
  final code = selectedLanguageCode.value;
  final preferred = json['${baseKey}_$code'];
  if (preferred is String && preferred.trim().isNotEmpty) return preferred;

  final otherCode = code == 'ar' ? 'en' : 'ar';
  final other = json['${baseKey}_$otherCode'];
  if (other is String && other.trim().isNotEmpty) return other;

  final base = json[baseKey];
  if (base is String && base.trim().isNotEmpty) return base;
  return fallback;
}

/// Resolves a localized string from already-parsed `_ar` / `_en` values.
String pickLocalizedFrom({
  String? ar,
  String? en,
  String? fallbackValue,
  String fallback = '',
}) {
  final code = selectedLanguageCode.value;
  final preferred = code == 'ar' ? ar : en;
  if (preferred != null && preferred.trim().isNotEmpty) return preferred;

  final other = code == 'ar' ? en : ar;
  if (other != null && other.trim().isNotEmpty) return other;

  if (fallbackValue != null && fallbackValue.trim().isNotEmpty) {
    return fallbackValue;
  }
  return fallback;
}
