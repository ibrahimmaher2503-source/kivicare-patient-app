import 'package:flutter/material.dart';
import 'package:kivicare_patient/utils/lab_test_constants.dart';
import 'package:nb_utils/nb_utils.dart';

class TestOrderStatusBadge extends StatelessWidget {
  final String status;
  final double? width;
  final double? height;
  final TextStyle? textStyle;

  const TestOrderStatusBadge({
    Key? key,
    required this.status,
    this.width,
    this.height,
    this.textStyle,
  }) : super(key: key);

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'confirmed':
        return Colors.blue;
      case 'sample_collected':
        return Colors.purple;
      case 'processing':
        return Colors.purple;
      case 'completed':
        return Colors.green;
      case 'delivered':
        return Colors.green;
      case 'cancelled':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  String _getStatusLabel(String status) {
    return status.replaceAll('_', ' ').toUpperCase();
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'pending':
        return Icons.schedule;
      case 'confirmed':
        return Icons.check_circle;
      case 'sample_collected':
        return Icons.verified_user;
      case 'processing':
        return Icons.hourglass_bottom;
      case 'completed':
        return Icons.task_alt;
      case 'delivered':
        return Icons.local_shipping;
      case 'cancelled':
        return Icons.cancel;
      default:
        return Icons.info;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _getStatusColor(status);

    return Container(
      width: width,
      height: height,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(_getStatusIcon(status), size: 14, color: color),
          const SizedBox(width: 6),
          Text(
            _getStatusLabel(status),
            style: textStyle ?? boldTextStyle(size: 11, color: color),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
