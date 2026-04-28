import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kivicare_patient/main.dart';
import 'package:kivicare_patient/utils/colors.dart';
import 'package:nb_utils/nb_utils.dart';

import '../models/nurse_status.dart';
import '../models/status_history_entry.dart';

class NurseStatusHistoryTile extends StatelessWidget {
  final StatusHistoryEntry entry;

  const NurseStatusHistoryTile({super.key, required this.entry});

  @override
  Widget build(BuildContext context) {
    final prev = entry.previousStatus != null
        ? NurseStatusExtension.fromString(entry.previousStatus).displayLabel(locale.value)
        : null;
    final next = NurseStatusExtension.fromString(entry.newStatus).displayLabel(locale.value);
    final timestamp = DateFormat('dd MMM yyyy HH:mm').format(entry.changedAt);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 8,
            height: 8,
            margin: const EdgeInsets.only(top: 5),
            decoration: BoxDecoration(color: gradientStart, shape: BoxShape.circle),
          ),
          12.width,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  prev != null ? '$prev → $next' : next,
                  style: boldTextStyle(size: 13),
                ),
                if (entry.note != null && entry.note!.isNotEmpty)
                  Text(entry.note!, style: secondaryTextStyle(size: 12)),
                Text(
                  timestamp,
                  style: secondaryTextStyle(size: 11, color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
