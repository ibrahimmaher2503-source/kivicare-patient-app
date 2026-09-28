class AdmissionRequestFormValidators {
  const AdmissionRequestFormValidators._();

  static String? requiredText(
    String? value, {
    required String requiredMessage,
    int? maxLength,
    String? maxLengthMessage,
  }) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return requiredMessage;
    if (maxLength != null && text.length > maxLength) {
      return maxLengthMessage ?? requiredMessage;
    }
    return null;
  }

  static String? optionalText(
    String? value, {
    required int maxLength,
    required String maxLengthMessage,
  }) {
    final text = value?.trim() ?? '';
    if (text.length > maxLength) return maxLengthMessage;
    return null;
  }

  static String? age(
    String? value, {
    required String requiredMessage,
    required String invalidMessage,
  }) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return requiredMessage;
    final parsed = int.tryParse(text);
    if (parsed == null || parsed < 0 || parsed > 150) return invalidMessage;
    return null;
  }

  static String normalizePhone(String value) {
    return value.replaceAll(RegExp(r'[\s-]'), '');
  }

  static String? phone(
    String? value, {
    required String requiredMessage,
    required String invalidMessage,
  }) {
    final normalized = normalizePhone(value ?? '');
    if (normalized.isEmpty) return requiredMessage;
    if (!RegExp(r'^\+?\d{7,20}$').hasMatch(normalized)) {
      return invalidMessage;
    }
    return null;
  }
}
