import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../main.dart';
import '../../../utils/colors.dart';
import '../models/status_history_model.dart';

class StatusHistoryTile extends StatelessWidget {
  final StatusHistoryModel history;

  const StatusHistoryTile({super.key, required this.history});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.dividerColor.withValues(alpha: 0.3)),
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
                  child: Icon(Icons.arrow_forward, size: 14, color: appColorSecondary),
                ),
              ],
              _StatusBadge(label: history.newStatus.name, isNew: true),
            ],
          ),
          if (history.changedBy != null) ...[
            const SizedBox(height: 6),
            Text(
              '${locale.value.visitChangedBy}: ${history.changedBy!.name}',
              style: secondaryTextStyle(size: 11),
            ),
          ],
          if (history.note != null && history.note!.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              history.note!,
              style: primaryTextStyle(size: 12),
            ),
          ],
          const SizedBox(height: 4),
          Text(
            DateFormat('d MMM yyyy, hh:mm a').format(history.changedAt.toLocal()),
            style: secondaryTextStyle(size: 11),
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isNew
            ? gradientSecondaryStart.withValues(alpha: 0.1)
            : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: isNew ? gradientSecondaryStart : Colors.grey.shade600,
        ),
      ),
    );
  }
}
