import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../main.dart';
import '../../../utils/app_common.dart';
import '../../../utils/colors.dart';
import '../../../utils/locale_formatters.dart';
import '../models/status_history_model.dart';

class StatusHistoryTile extends StatelessWidget {
  final StatusHistoryModel history;

  const StatusHistoryTile({super.key, required this.history});

  @override
  Widget build(BuildContext context) {
    final dark = isDarkMode.value;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: dark ? surfaceElevatedDark : surfaceElevated,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: (dark ? borderColorDark : whiteBorderColor),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (history.oldStatus != null) ...[
                _StatusBadge(label: history.oldStatus!.name),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  child: Icon(
                    Icons.arrow_forward,
                    size: 14,
                    color: appColorSecondary,
                  ),
                ),
              ],
              _StatusBadge(label: history.newStatus.name, isNew: true),
            ],
          ),
          if (history.changedBy != null) ...[
            6.height,
            Text(
              '${locale.value.visitChangedBy}: ${history.changedBy!.name}',
              style: secondaryTextStyle(size: 12),
            ),
          ],
          if (history.note != null && history.note!.isNotEmpty) ...[
            4.height,
            Text(history.note!, style: primaryTextStyle(size: 12)),
          ],
          4.height,
          Text(
            DateFormat('d MMM yyyy, hh:mm a', activeIntlLocale)
                .format(history.changedAt.toLocal()),
            style: secondaryTextStyle(size: 12),
          ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String label;
  final bool isNew;

  const _StatusBadge({required this.label, this.isNew = false});

  @override
  Widget build(BuildContext context) {
    final dark = isDarkMode.value;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isNew
            ? gradientSecondaryStart.withValues(alpha: dark ? 0.2 : 0.1)
            : (dark ? borderColorDark : inputFillColor),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: isNew
              ? gradientSecondaryStart
              : (dark ? textSecondaryDark : secondaryTextColor),
        ),
      ),
    );
  }
}
