class ReportDownloadPolicy {
  const ReportDownloadPolicy._();

  static Uri? validatedHttpsUri(dynamic value) {
    if (value is! String || value.trim().isEmpty) return null;
    final uri = Uri.tryParse(value.trim());
    if (uri == null || uri.scheme != 'https' || uri.host.isEmpty) return null;
    return uri;
  }

  static bool shouldAttachAuthorization(Uri uri, Uri firstPartyBase) {
    return uri.scheme == 'https' &&
        uri.host.toLowerCase() == firstPartyBase.host.toLowerCase();
  }

  static String safeReference(String value, {required String fallback}) {
    final safe = value
        .trim()
        .replaceAll(RegExp(r'[^A-Za-z0-9_-]+'), '_')
        .replaceAll(RegExp(r'_+'), '_')
        .replaceAll(RegExp(r'^_+|_+$'), '');
    final result = safe.isEmpty ? fallback : safe;
    return result.length <= 60 ? result : result.substring(0, 60);
  }
}
