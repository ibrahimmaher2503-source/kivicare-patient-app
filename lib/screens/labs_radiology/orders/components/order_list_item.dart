import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:kivicare_patient/screens/labs_radiology/labs_radiology_common.dart';
import '../../models/test_order_model.dart';
import 'order_status_badge.dart';

class OrderListItem extends StatelessWidget {
  final TestOrderModel order;
  final VoidCallback onTap;

  const OrderListItem({super.key, required this.order, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: boxDecorationDefault(
          color: context.cardColor, borderRadius: radius(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${locale.value.orderRef}: ${order.referenceNumber}',
                style: boldTextStyle(size: 14, color: context.primaryColor),
              ),
              OrderStatusBadge(status: order.status),
            ],
          ),
          Divider(height: 24, color: context.dividerColor),
          Text(order.labTest?.name ?? order.facility.name,
              style: boldTextStyle()),
          8.height,
          Row(
            children: [
              const Icon(Icons.calendar_today_outlined,
                  size: 14, color: secondaryTextColor),
              8.width,
              Text(
                '${locale.value.bookedOn}: ${DateFormat('d MMM yyyy').format(order.createdAt)}',
                style: secondaryTextStyle(size: 12),
              ),
            ],
          ),
          12.height,
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${order.totalAmount?.toStringAsFixed(0)} ${order.currency}',
                style: primaryTextStyle(
                    color: context.primaryColor, weight: FontWeight.bold),
              ),
              Text(
                locale.value.viewDetails,
                style: secondaryTextStyle(
                    color: context.primaryColor,
                    decoration: TextDecoration.underline),
              ),
            ],
          ),
        ],
      ),
    ).onTap(onTap, borderRadius: radius(12));
  }
}
