import 'package:flutter_test/flutter_test.dart';
import 'package:kivicare_patient/screens/labs_radiology/shared/service/report_download_policy.dart';

void main() {
  test('accepts only absolute HTTPS report URLs', () {
    expect(
      ReportDownloadPolicy.validatedHttpsUri(
        'https://espitalia.net/reports/1.pdf',
      ),
      isNotNull,
    );
    expect(
      ReportDownloadPolicy.validatedHttpsUri('http://espitalia.net/1.pdf'),
      isNull,
    );
    expect(ReportDownloadPolicy.validatedHttpsUri('/reports/1.pdf'), isNull);
  });

  test('attaches bearer authorization only to the exact first-party host', () {
    final base = Uri.parse('https://espitalia.net');
    expect(
      ReportDownloadPolicy.shouldAttachAuthorization(
        Uri.parse('https://espitalia.net/reports/1.pdf'),
        base,
      ),
      isTrue,
    );
    expect(
      ReportDownloadPolicy.shouldAttachAuthorization(
        Uri.parse('https://storage.example.com/report.pdf'),
        base,
      ),
      isFalse,
    );
    expect(
      ReportDownloadPolicy.shouldAttachAuthorization(
        Uri.parse('https://evil.espitalia.net/report.pdf'),
        base,
      ),
      isFalse,
    );
  });

  test('sanitizes and bounds patient report references used as filenames', () {
    expect(
      ReportDownloadPolicy.safeReference('../ICU/REF 12', fallback: '9'),
      'ICU_REF_12',
    );
    expect(
      ReportDownloadPolicy.safeReference('***', fallback: '9'),
      '9',
    );
    expect(
      ReportDownloadPolicy.safeReference(
        List.filled(100, 'a').join(),
        fallback: '9',
      ).length,
      60,
    );
  });
}
