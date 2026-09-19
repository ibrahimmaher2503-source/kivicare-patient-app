import 'package:flutter/material.dart';
import 'package:kivicare_patient/main.dart';
import 'package:kivicare_patient/utils/colors.dart';
import 'package:kivicare_patient/utils/locale_formatters.dart';
import 'package:nb_utils/nb_utils.dart';

import '../models/nurse_status.dart';
import '../models/status_history_entry.dart';
import 'nurse_request_design.dart';

class NurseStatusHistoryTile extends StatelessWidget {
  final StatusHistoryEntry entry;

  const NurseStatusHistoryTile({super.key, required this.entry});

  @override
  Widget build(BuildContext context) {
    final prev = entry.previousStatus != null
        ? NurseStatusExtension.fromString(
            entry.previousStatus,
          ).displayLabel(locale.value)
        : null;
    final next = NurseStatusExtension.fromString(
      entry.newStatus,
    ).displayLabel(locale.value);
    final timestamp = formatLocalizedDate(entry.changedAt, 'dd MMM yyyy HH:mm');

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: nurseRequestSubtleSurface(context),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: nurseRequestBorderColor(context)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 8,
            height: 8,
            margin: const EdgeInsets.only(top: 5),
            decoration: const BoxDecoration(
              color: gradientSecondaryStart,
              shape: BoxShape.circle,
            ),
          ),
          12.width,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  prev != null ? '$prev -> $next' : next,
                  style: boldTextStyle(size: 13),
                ),
                if (entry.note != null && entry.note!.isNotEmpty)
                  Text(
                    entry.note!,
                    style: secondaryTextStyle(
                      size: 12,
                      color: nurseRequestMutedColor(context),
                    ),
                  ),
                Text(
                  timestamp,
                  style: secondaryTextStyle(
                    size: 12,
                    color: nurseRequestMutedColor(context),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
