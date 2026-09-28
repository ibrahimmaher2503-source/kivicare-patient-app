import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../main.dart';
import '../../../utils/colors.dart';

class OfferDiscountCard extends StatelessWidget {
  final String offerCode;
  final double discount;

  const OfferDiscountCard({
    super.key,
    required this.offerCode,
    required this.discount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [gradientSecondaryStart, gradientSecondaryEnd],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Icon(Icons.local_offer_outlined, color: Colors.white, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  locale.value.discountApplied,
                  style: boldTextStyle(size: 14, color: white),
                ),
                const SizedBox(height: 2),
                Text(
                  '${locale.value.visitOfferCode}: $offerCode',
                  style: secondaryTextStyle(size: 12, color: white),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                locale.value.youSaved,
                style: secondaryTextStyle(size: 12, color: white),
              ),
              Text(
                '${discount.toStringAsFixed(0)}%',
                style: boldTextStyle(size: 20, color: white),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
