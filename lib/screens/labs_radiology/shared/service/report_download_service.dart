import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:kivicare_patient/api/labs_radiology_apis.dart';
import 'package:kivicare_patient/network/network_utils.dart';
import 'package:kivicare_patient/utils/common_base.dart';
import 'package:url_launcher/url_launcher.dart';

class ReportDownloadService {
  Future<File?> download(int orderId, String referenceNumber) async {
    try {
      final info = await LabsRadiologyApis.getReportDownloadInfo(orderId);

      String? downloadUrl;
      if (info is Map && info.containsKey('download_url')) {
        downloadUrl = info['download_url'];
      }

      if (kIsWeb) {
        if (downloadUrl != null) {
          commonLaunchUrl(downloadUrl,
              launchMode: LaunchMode.externalApplication);
        } else {
          toast('Direct binary download not supported on Web in this version');
        }
        return null;
      }

      // Native implementation
      if (downloadUrl == null) {
        // Assume direct binary response if no URL provided
        // We'd need to handle the binary response from getReportDownloadInfo
        // For now, assume it's always a URL or we'll handle binary in a follow-up.
        toast('Direct binary download not yet implemented for Native');
        return null;
      }

      final directory = await getApplicationDocumentsDirectory();
      final filePath = '${directory.path}/report_$referenceNumber.pdf';
      final file = File(filePath);

      if (await file.exists()) {
        await OpenFilex.open(filePath);
        return file;
      }

      final response =
          await http.get(Uri.parse(downloadUrl), headers: buildHeaderTokens());
      if (response.statusCode == 200) {
        await file.writeAsBytes(response.bodyBytes);
        await OpenFilex.open(filePath);
        return file;
      } else {
        throw 'Failed to download file: ${response.statusCode}';
      }
    } catch (e) {
      log('ReportDownloadService E: $e');
      rethrow;
    }
  }
}
