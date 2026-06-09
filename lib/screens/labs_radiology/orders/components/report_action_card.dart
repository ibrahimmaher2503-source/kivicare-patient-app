import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:kivicare_patient/screens/labs_radiology/labs_radiology_common.dart';
import 'package:kivicare_patient/components/loader_widget.dart';

class ReportActionCard extends StatelessWidget {
  final bool hasReport;
  final bool isDownloading;
  final VoidCallback onDownload;

  const ReportActionCard({
    super.key,
    required this.hasReport,
    required this.isDownloading,
    required this.onDownload,
  });

  @override
  Widget build(BuildContext context) {
    if (!hasReport) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: boxDecorationDefault(
            color: context.cardColor, borderRadius: radius(12)),
        child: Row(
          children: [
            const Icon(Icons.info_outline, color: Colors.orange),
            16.width,
            Text(locale.value.reportNotReady, style: secondaryTextStyle())
                .expand(),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: boxDecorationDefault(
        color: context.primaryColor.withValues(alpha: 0.1),
        borderRadius: radius(12),
        border: Border.all(color: context.primaryColor.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: boxDecorationDefault(
                shape: BoxShape.circle, color: context.primaryColor),
            child:
                const Icon(Icons.picture_as_pdf, color: Colors.white, size: 20),
          ),
          16.width,
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(locale.value.medicalReport, style: boldTextStyle()),
              4.height,
              Text(locale.value.downloadingReport,
                  style: secondaryTextStyle(size: 12)),
            ],
          ).expand(),
          16.width,
          isDownloading
              ? const LoaderWidget().withHeight(24).withWidth(24)
              : IconButton(
                  icon:
                      Icon(Icons.download_rounded, color: context.primaryColor),
                  onPressed: onDownload,
                ),
        ],
      ),
    ).onTap(isDownloading ? null : onDownload);
  }
}
