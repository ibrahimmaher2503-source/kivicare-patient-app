import 'package:flutter/material.dart';
import 'package:kivicare_patient/main.dart';
import 'package:kivicare_patient/utils/app_common.dart';
import 'package:kivicare_patient/utils/colors.dart';
import '../models/nurse_status.dart';

class NurseStatusChip extends StatelessWidget {
  final NurseStatus status;

  const NurseStatusChip({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final (bg, textColor, borderColor) = _colors(status);
    return Container(
      constraints: const BoxConstraints(minHeight: 28),
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor),
      ),
      child: Text(
        status.displayLabel(locale.value),
        style: TextStyle(
          color: textColor,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  (Color, Color, Color) _colors(NurseStatus s) {
    final dark = isDarkMode.value;
    final color = _statusColor(s);
    final bg = color.withValues(alpha: dark ? 0.18 : 0.11);
    final border = color.withValues(alpha: dark ? 0.42 : 0.22);
    final text = dark ? color : _lightTextColor(s);
    return (bg, text, border);
  }

  Color _statusColor(NurseStatus s) {
    switch (s) {
      case NurseStatus.pending:
        return nurseStatusPendingColor;
      case NurseStatus.assigned:
        return checkInStatusColor;
      case NurseStatus.confirmed:
        return nurseStatusConfirmedColor;
      case NurseStatus.inProgress:
        return nurseStatusInProgressColor;
      case NurseStatus.completed:
        return nurseStatusCompletedColor;
      case NurseStatus.cancelled:
        return nurseStatusCancelledColor;
    }
  }

  Color _lightTextColor(NurseStatus s) {
    switch (s) {
      case NurseStatus.pending:
        return pendingStatusColor;
      case NurseStatus.assigned:
        return checkInStatusColor;
      case NurseStatus.confirmed:
        return nurseStatusConfirmedColor;
      case NurseStatus.inProgress:
        return nurseStatusInProgressColor;
      case NurseStatus.completed:
        return appColorSecondary;
      case NurseStatus.cancelled:
        return nurseStatusCancelledColor;
    }
  }
}
