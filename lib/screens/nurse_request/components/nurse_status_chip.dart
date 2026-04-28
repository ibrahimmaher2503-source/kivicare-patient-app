import 'package:flutter/material.dart';
import 'package:kivicare_patient/main.dart';
import 'package:kivicare_patient/utils/app_common.dart';
import '../models/nurse_status.dart';

class NurseStatusChip extends StatelessWidget {
  final NurseStatus status;

  const NurseStatusChip({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final (bg, textColor) = _colors(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status.displayLabel(locale.value),
        style: TextStyle(color: textColor, fontSize: 12, fontWeight: FontWeight.w600),
      ),
    );
  }

  (Color, Color) _colors(NurseStatus s) {
    final dark = isDarkMode.value;
    switch (s) {
      case NurseStatus.pending:
        return (dark ? const Color(0xFF4A3800) : const Color(0xFFFFF3CD), const Color(0xFFB8860B));
      case NurseStatus.assigned:
        return (dark ? const Color(0xFF003450) : const Color(0xFFCCE5FF), const Color(0xFF004085));
      case NurseStatus.confirmed:
        return (dark ? const Color(0xFF1A3A00) : const Color(0xFFD4EDDA), const Color(0xFF155724));
      case NurseStatus.inProgress:
        return (dark ? const Color(0xFF003450) : const Color(0xFFCCE5FF), const Color(0xFF0056B3));
      case NurseStatus.completed:
        return (dark ? const Color(0xFF1A3A00) : const Color(0xFFD4EDDA), const Color(0xFF28A745));
      case NurseStatus.cancelled:
        return (dark ? const Color(0xFF3A0000) : const Color(0xFFF8D7DA), const Color(0xFF721C24));
    }
  }
}
