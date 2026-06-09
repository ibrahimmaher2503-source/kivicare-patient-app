import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:kivicare_patient/screens/labs_radiology/labs_radiology_common.dart';
import '../../models/test_order_status.dart';

class OrderStatusBadge extends StatelessWidget {
  final TestOrderStatus status;

  const OrderStatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    switch (status) {
      case TestOrderStatus.pending:
        color = Colors.orange;
        break;
      case TestOrderStatus.confirmed:
        color = context.primaryColor;
        break;
      case TestOrderStatus.sampleCollected:
      case TestOrderStatus.inProgress:
        color = Colors.blue;
        break;
      case TestOrderStatus.completed:
        color = Colors.green;
        break;
      case TestOrderStatus.cancelled:
      case TestOrderStatus.rejected:
        color = Colors.red;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: boxDecorationWithRoundedCorners(
        borderRadius: radius(4),
        backgroundColor: color.withValues(alpha: 0.1),
      ),
      child: Text(
        status.displayLabel(locale.value).toUpperCase(),
        style:
            secondaryTextStyle(size: 10, color: color, weight: FontWeight.bold),
      ),
    );
  }
}
