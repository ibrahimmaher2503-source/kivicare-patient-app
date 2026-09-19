import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nb_utils/nb_utils.dart';
import '../../../main.dart';
import '../../../utils/constants.dart';
import '../../../utils/locale_formatters.dart';
import '../models/admission_request_model.dart';
import '../models/status_history_model.dart';

class StatusTimeline extends StatelessWidget {
  final List<StatusHistoryEntry> history;

  const StatusTimeline({super.key, required this.history});

  String _getStatusLabel(AdmissionStatus status) {
    switch (status) {
      case AdmissionStatus.pending:
        return locale.value.pending;
      case AdmissionStatus.infoRequested:
        return locale.value.underReview;
      case AdmissionStatus.accepted:
        return locale.value.approved;
      case AdmissionStatus.rejected:
        return locale.value.rejected;
      case AdmissionStatus.cancelled:
        return locale.value.cancelled;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (history.isEmpty) return const SizedBox.shrink();

    // Sort history by date descending (newest at top) or ascending?
    // FR-026 says "vertical timeline", usually newest at top or bottom.
    // I'll follow newest at bottom (chronological) for a "timeline" feel.
    final sortedHistory = List<StatusHistoryEntry>.from(history)
      ..sort((a, b) => a.changedAt.compareTo(b.changedAt));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(locale.value.statusTimeline, style: boldTextStyle()),
        24.height,
        ...List.generate(sortedHistory.length, (index) {
          final e = sortedHistory[index];
          final isLast = index == sortedHistory.length - 1;

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 4),
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color:
                          isLast ? context.primaryColor : context.dividerColor,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                      boxShadow: isLast
                          ? [
                              BoxShadow(
                                  color: context.primaryColor
                                      .withValues(alpha: 0.3),
                                  blurRadius: 4)
                            ]
                          : null,
                    ),
                  ),
                  if (!isLast)
                    Container(
                        width: 2,
                        height: 50,
                        color: context.dividerColor.withValues(alpha: 0.5)),
                ],
              ),
              16.width,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_getStatusLabel(e.status).toUpperCase(),
                        style: boldTextStyle(
                            size: 14,
                            color: isLast ? context.primaryColor : null)),
                    4.height,
                    Text(
                      DateFormat(DateFormatConst.EEEE_D_MMMM_At_HH_mm_a,
                              activeIntlLocale)
                          .format(e.changedAt),
                      style: secondaryTextStyle(size: 12),
                    ),
                    if (e.note.validate().isNotEmpty)
                      Container(
                        margin: const EdgeInsets.only(top: 8),
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: context.dividerColor.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(e.note!, style: primaryTextStyle(size: 13)),
                      ),
                    24.height,
                  ],
                ),
              ),
            ],
          );
        }),
      ],
    );
  }
}
