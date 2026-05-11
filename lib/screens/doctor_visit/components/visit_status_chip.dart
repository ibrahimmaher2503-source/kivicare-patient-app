import 'package:flutter/material.dart';

import '../../../main.dart';
import '../../../utils/app_common.dart';
import '../../../utils/colors.dart';
import '../models/visit_status.dart';

class VisitStatusChip extends StatelessWidget {
  final VisitStatus status;

  const VisitStatusChip({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final base = _colorFor(status);
    final dark = isDarkMode.value;
    final bg = base.withValues(alpha: dark ? 0.18 : 0.11);
    final border = base.withValues(alpha: dark ? 0.42 : 0.22);

    return Container(
      constraints: const BoxConstraints(minHeight: 28),
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_iconFor(status), size: 13, color: base),
          const SizedBox(width: 5),
          Text(
            _labelFor(status),
            style: TextStyle(
              color: base,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Color _colorFor(VisitStatus s) {
    switch (s) {
      case VisitStatus.pending:
        return pendingStatusColor;
      case VisitStatus.confirmed:
        return confirmedStatusColor;
      case VisitStatus.completed:
        return completedStatusColor;
      case VisitStatus.cancelled:
        return cancelStatusColor;
    }
  }

  IconData _iconFor(VisitStatus s) {
    switch (s) {
      case VisitStatus.pending:
        return Icons.hourglass_empty;
      case VisitStatus.confirmed:
        return Icons.check_circle_outline;
      case VisitStatus.completed:
        return Icons.task_alt;
      case VisitStatus.cancelled:
        return Icons.cancel_outlined;
    }
  }

  String _labelFor(VisitStatus s) {
    switch (s) {
      case VisitStatus.pending:
        return locale.value.pending;
      case VisitStatus.confirmed:
        return locale.value.confirmed;
      case VisitStatus.completed:
        return locale.value.completed;
      case VisitStatus.cancelled:
        return locale.value.cancelled;
    }
  }
}
