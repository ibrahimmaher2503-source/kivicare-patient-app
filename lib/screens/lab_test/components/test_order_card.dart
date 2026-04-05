import 'package:flutter/material.dart';
import 'package:kivicare_patient/models/test_order_model.dart';
import 'package:kivicare_patient/utils/colors.dart';
import 'package:kivicare_patient/utils/price_widget.dart';
import 'package:nb_utils/nb_utils.dart';

class TestOrderCard extends StatelessWidget {
  final TestOrder order;
  final VoidCallback onTap;
  final VoidCallback? onCancel;

  const TestOrderCard({
    Key? key,
    required this.order,
    required this.onTap,
    this.onCancel,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: appStore.isDarkMode ? cardDarkColor : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: appStore.isDarkMode ? Colors.grey.shade800 : Colors.grey.shade200,
          ),
          boxShadow: [
            BoxShadow(
              color: softShadowColor.withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with order number and status
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        order.orderNumber,
                        style: boldTextStyle(size: 14),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${order.items.length} test${order.items.length > 1 ? 's' : ''}',
                        style: secondaryTextStyle(size: 12),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                _OrderStatusBadge(status: order.status),
              ],
            ),
            const SizedBox(height: 12),

            // Tests list preview
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              decoration: BoxDecoration(
                color: appColorPrimary.withOpacity(0.05),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                order.items.take(2).map((item) => item.labTest?.name ?? 'Unknown').join(', ') +
                    (order.items.length > 2 ? '...' : ''),
                style: secondaryTextStyle(size: 11),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 12),

            // Footer with amount and date
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total Amount',
                      style: secondaryTextStyle(size: 11),
                    ),
                    const SizedBox(height: 4),
                    PriceWidget(
                      price: order.finalAmount,
                      textStyle: boldTextStyle(size: 13, color: appColorPrimary),
                    ),
                  ],
                ),
                Text(
                  order.createdAt?.toString().split(' ')[0] ?? 'N/A',
                  style: secondaryTextStyle(size: 11),
                ),
                if (onCancel != null && (order.status == 'pending' || order.status == 'confirmed'))
                  GestureDetector(
                    onTap: onCancel,
                    child: Icon(Icons.more_vert, size: 20, color: Colors.grey.shade500),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _OrderStatusBadge extends StatelessWidget {
  final String status;

  const _OrderStatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final colorMap = {
      'pending': Colors.orange,
      'confirmed': Colors.blue,
      'sample_collected': Colors.purple,
      'processing': Colors.purple,
      'completed': Colors.green,
      'delivered': Colors.green,
      'cancelled': Colors.grey,
    };

    final color = colorMap[status] ?? Colors.grey;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        status.replaceAll('_', ' ').toUpperCase(),
        style: primaryTextStyle(size: 10, color: color),
      ),
    );
  }
}
