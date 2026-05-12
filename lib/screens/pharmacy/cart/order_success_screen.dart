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
      backgroundColor: appLayoutBackground,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const Spacer(),
              SizedBox(
                height: 96,
                width: 96,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      height: 96,
                      width: 96,
                      decoration: const BoxDecoration(
                          color: lightSecondaryColor,
                          shape: BoxShape.circle),
                    ),
                    const Icon(Icons.check_circle,
                        color: completedStatusColor, size: 64),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Text(locale.value.orderSuccess,
                  style:
                      boldTextStyle(size: 24, color: appColorPrimary),
                  textAlign: TextAlign.center),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: primaryTextStyle(
                        size: 14, color: secondaryTextColor),
                    children: [
                      TextSpan(
                          text: locale.value.pharmacyOrderSuccess
                              .replaceAll('{orderNumber}', '')
                              .trim()),
                      const TextSpan(text: '  '),
                      TextSpan(
                          text: orderNumber,
                          style: boldTextStyle(
                              size: 14, color: appColorSecondary)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: surfaceElevated,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                        color: softShadowColor,
                        blurRadius: 16,
                        offset: const Offset(0, 6))
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(locale.value.orderNumber,
                        style: secondaryTextStyle(size: 13)),
                    Text(orderNumber,
                        style: boldTextStyle(
                            size: 14, color: appColorPrimary)),
                  ],
                ),
              ),
              const Spacer(),
              Container(
                width: double.infinity,
                height: 52,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  gradient: const LinearGradient(
                    colors: [
                      gradientSecondaryStart,
                      gradientSecondaryEnd
                    ],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                        color: softShadowColorMedium,
                        blurRadius: 16,
                        offset: const Offset(0, 6)),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(14),
                    onTap: () {
                      Get.off(() =>
                          PharmacyOrderDetailScreen(orderId: orderId));
                    },
                    child: Center(
                      child: Text(
                        locale.value.trackOrder,
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 15),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: appColorSecondary,
                    side: const BorderSide(
                        color: appColorSecondary, width: 1.2),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                  onPressed: () => Get.until((route) => route.isFirst),
                  child: Text(locale.value.pharmacyBackToHome,
                      style: boldTextStyle(
                          color: appColorSecondary, size: 14)),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
