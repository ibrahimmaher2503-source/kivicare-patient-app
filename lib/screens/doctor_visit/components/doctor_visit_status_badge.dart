import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../main.dart';

class DoctorVisitStatusBadge extends StatelessWidget {
  final String status;

  const DoctorVisitStatusBadge({super.key, required this.status});

  Color _getStatusColor() {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'confirmed':
        return Colors.blue;
      case 'completed':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getStatusLabel() {
    switch (status) {
      case 'pending':
        return locale.value.statusPendingLabel;
      case 'confirmed':
        return locale.value.statusConfirmedLabel;
      case 'completed':
        return locale.value.statusCompletedLabel;
      case 'cancelled':
        return locale.value.statusCancelledLabel;
      default:
        return status.capitalizeFirstLetter();
    }
  }

  IconData _getStatusIcon() {
    switch (status) {
      case 'pending':
        return Icons.schedule;
      case 'confirmed':
        return Icons.check_circle;
      case 'completed':
        return Icons.task_alt;
      case 'cancelled':
        return Icons.cancel;
      default:
        return Icons.info;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _getStatusColor();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_getStatusIcon(), size: 14, color: color),
          const SizedBox(width: 6),
          Text(
            _getStatusLabel(),
            style: boldTextStyle(size: 11, color: color),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
