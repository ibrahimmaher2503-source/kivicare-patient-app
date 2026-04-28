import 'package:flutter/material.dart';
import 'package:kivicare_patient/main.dart';
import 'package:kivicare_patient/utils/colors.dart';
import 'package:kivicare_patient/utils/price_widget.dart';
import 'package:nb_utils/nb_utils.dart';

class PricingCard extends StatelessWidget {
  final double totalAmount;
  final String? currency;
  final String? paymentStatus;

  const PricingCard({
    super.key,
    required this.totalAmount,
    this.currency,
    this.paymentStatus,
  });

  @override
  Widget build(BuildContext context) {
    final statusLabel = _paymentLabel(paymentStatus);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: softShadowColor, blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(locale.value.estimatedTotal, style: boldTextStyle(size: 14)),
          8.height,
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              PriceWidget(price: totalAmount, size: 20),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _statusColor(paymentStatus).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  statusLabel,
                  style: TextStyle(
                    color: _statusColor(paymentStatus),
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _paymentLabel(String? s) {
    switch (s) {
      case 'paid':
        return locale.value.paymentStatusPaid;
      case 'refunded':
        return locale.value.paymentStatusRefunded;
      default:
        return locale.value.paymentStatusUnpaid;
    }
  }

  Color _statusColor(String? s) {
    switch (s) {
      case 'paid':
        return Colors.green;
      case 'refunded':
        return Colors.blue;
      default:
        return Colors.orange;
    }
  }
}
