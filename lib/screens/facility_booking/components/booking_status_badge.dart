import 'package:flutter/material.dart';
import 'package:kivicare_patient/utils/colors.dart';
import 'package:nb_utils/nb_utils.dart';

class BookingStatusBadge extends StatelessWidget {
  final String status;
  final bool showIcon;

  const BookingStatusBadge({
    required this.status,
    this.showIcon = true,
  });

  Color get _backgroundColor {
    switch (status.toLowerCase()) {
      case 'pending':
        return orange.withOpacity(0.2);
      case 'confirmed':
        return blue.withOpacity(0.2);
      case 'completed':
        return green.withOpacity(0.2);
      case 'cancelled':
        return red.withOpacity(0.2);
      case 'no_show':
        return gray300.withOpacity(0.5);
      default:
        return gray200.withOpacity(0.3);
    }
  }

  Color get _textColor {
    switch (status.toLowerCase()) {
      case 'pending':
        return orange;
      case 'confirmed':
        return blue;
      case 'completed':
        return green;
      case 'cancelled':
        return red;
      case 'no_show':
        return gray600;
      default:
        return gray700;
    }
  }

  IconData? get _icon {
    switch (status.toLowerCase()) {
      case 'pending':
        return Icons.schedule;
      case 'confirmed':
        return Icons.check_circle;
      case 'completed':
        return Icons.check_circle;
      case 'cancelled':
        return Icons.cancel;
      case 'no_show':
        return Icons.person_off;
      default:
        return null;
    }
  }

  String get _displayText {
    final text = status.replaceAll('_', ' ').toLowerCase();
    return text.replaceFirst(text[0], text[0].toUpperCase());
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.w),
      decoration: BoxDecoration(
        color: _backgroundColor,
        borderRadius: BorderRadius.circular(8.w),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showIcon && _icon != null) ...[
            Icon(_icon, size: 12.w, color: _textColor),
            SizedBox(width: 6.w),
          ],
          Text(
            _displayText,
            style: boldTextStyle(size: 12, color: _textColor),
          ),
        ],
      ),
    );
  }
}
