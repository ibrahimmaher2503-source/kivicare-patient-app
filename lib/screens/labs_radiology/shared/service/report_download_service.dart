import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:kivicare_patient/api/labs_radiology_apis.dart';
import 'package:kivicare_patient/configs.dart';
import 'package:kivicare_patient/main.dart';
import 'package:kivicare_patient/network/network_utils.dart';
import 'package:kivicare_patient/utils/common_base.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:url_launcher/url_launcher.dart';
import 'report_download_policy.dart';

class ReportDownloadService {
  Future<File?> download(int orderId, String referenceNumber) async {
    try {
      final info = await LabsRadiologyApis.getReportDownloadInfo(orderId);

      final downloadUrl = info is Map ? info['download_url'] : null;

      if (downloadUrl == null ||
          (downloadUrl is String && downloadUrl.trim().isEmpty)) {
        toast(locale.value.reportDownloadUnavailable);
        return null;
      }

      final downloadUri = ReportDownloadPolicy.validatedHttpsUri(downloadUrl);
      if (downloadUri == null) {
        throw locale.value.invalidReportDownloadUrl;
      }

      if (kIsWeb) {
        commonLaunchUrl(
          downloadUri.toString(),
          launchMode: LaunchMode.externalApplication,
        );
        return null;
      }

      final directory = await getTemporaryDirectory();
      await _purgeExpiredReports(directory);
      final safeReference = ReportDownloadPolicy.safeReference(
        referenceNumber,
        fallback: '$orderId',
      );
      final filePath = path.join(
        directory.path,
        'espitalia_lab_report_${safeReference}_$orderId.pdf',
      );
      final file = File(filePath);

      if (await file.exists()) {
        await OpenFilex.open(filePath);
        return file;
      }

      final response = await http.get(
        downloadUri,
        headers: ReportDownloadPolicy.shouldAttachAuthorization(
          downloadUri,
          Uri.parse(DOMAIN_URL),
        )
            ? buildHeaderTokens()
            : null,
      );
      if (response.statusCode == 200) {
        await file.writeAsBytes(response.bodyBytes, flush: true);
        await OpenFilex.open(filePath);
        return file;
      } else {
        throw locale.value.reportDownloadFailed;
      }
    } catch (_) {
      rethrow;
    }
  }

  static Future<void> clearCachedReports() async {
    if (kIsWeb) return;
    try {
      final directory = await getTemporaryDirectory();
      await _deleteReports(directory);
    } on FileSystemException {
      // Session clearing continues even if the OS already removed the cache.
    }
  }

  Future<void> _purgeExpiredReports(Directory directory) async {
    final cutoff = DateTime.now().subtract(const Duration(hours: 24));
    await _deleteReports(directory, olderThan: cutoff);
  }

  static Future<void> _deleteReports(
    Directory directory, {
    DateTime? olderThan,
  }) async {
    await for (final entity in directory.list()) {
      if (entity is! File ||
          !path.basename(entity.path).startsWith('espitalia_lab_report_')) {
        continue;
      }
      try {
        final stat = await entity.stat();
        if (olderThan == null || stat.modified.isBefore(olderThan)) {
          await entity.delete();
        }
      } on FileSystemException {
        // Cache cleanup is best effort and must not block a fresh report.
      }
    }
  }
}
