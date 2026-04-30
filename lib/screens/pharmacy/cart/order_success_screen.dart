import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';
import '../../../main.dart';
import '../../../utils/colors.dart';
import '../order/pharmacy_order_detail_screen.dart';

class OrderSuccessScreen extends StatelessWidget {
  final int orderId;
  final String orderNumber;

  const OrderSuccessScreen(
      {super.key, required this.orderId, required this.orderNumber});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: boxDecorationDefault(
                color: Colors.green.withValues(alpha: 0.1), shape: BoxShape.circle),
            child:
                const Icon(Icons.check_circle, color: Colors.green, size: 80),
          ),
          const SizedBox(height: 24),
          Text(locale.value.orderSuccess, style: boldTextStyle(size: 22)),
          const SizedBox(height: 8),
          Text(locale.value.pharmacyOrderSuccess.replaceAll('{orderNumber}', orderNumber),
                  style: secondaryTextStyle(), textAlign: TextAlign.center)
              .paddingSymmetric(horizontal: 32),
          const SizedBox(height: 48),
          AppButton(
            text: locale.value.trackOrder,
            color: appColorPrimary,
            textColor: Colors.white,
            onTap: () {
              Get.off(() => PharmacyOrderDetailScreen(orderId: orderId));
            },
          ).paddingSymmetric(horizontal: 16),
          const SizedBox(height: 16),
          TextButton(
            onPressed: () => Get.until((route) => route.isFirst),
            child: Text(locale.value.pharmacyBackToHome,
                style: boldTextStyle(color: appColorSecondary)),
          ),
        ],
      ).center(),
    );
  }
}
