import 'package:flutter/material.dart';

import '../../../main.dart';
import '../models/visit_status.dart';

class VisitStatusChip extends StatelessWidget {
  final VisitStatus status;

  const VisitStatusChip({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final cfg = _configFor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: cfg.bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: cfg.border, width: 0.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(cfg.icon, size: 14, color: cfg.fg),
          const SizedBox(width: 6),
          Text(
            cfg.label,
            style: TextStyle(
              color: cfg.fg,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  _ChipConfig _configFor(VisitStatus s) {
    switch (s) {
      case VisitStatus.pending:
        return _ChipConfig(
          label: locale.value.pending,
          icon: Icons.hourglass_empty,
          bg: Colors.amber.shade50,
          fg: Colors.amber.shade700,
          border: Colors.amber.shade200,
        );
      case VisitStatus.confirmed:
        return _ChipConfig(
          label: locale.value.confirmed,
          icon: Icons.check_circle_outline,
          bg: Colors.blue.shade50,
          fg: Colors.blue.shade700,
          border: Colors.blue.shade200,
        );
      case VisitStatus.completed:
        return _ChipConfig(
          label: locale.value.completed,
          icon: Icons.task_alt,
          bg: Colors.green.shade50,
          fg: Colors.green.shade700,
          border: Colors.green.shade200,
        );
      case VisitStatus.cancelled:
        return _ChipConfig(
          label: locale.value.cancelled,
          icon: Icons.cancel_outlined,
          bg: Colors.red.shade50,
          fg: Colors.red.shade700,
          border: Colors.red.shade200,
        );
    }
  }
}

class _ChipConfig {
  final String label;
  final IconData icon;
  final Color bg, fg, border;

  _ChipConfig({
    required this.label,
    required this.icon,
    required this.bg,
    required this.fg,
    required this.border,
  });
}
