import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';
import '../../../main.dart';
import '../../dashboard/dashboard_screen.dart';
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
                height: 160,
                width: 160,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      height: 160,
                      width: 160,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: completedStatusColor.withValues(alpha: 0.06),
                      ),
                    ),
                    Container(
                      height: 120,
                      width: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: completedStatusColor.withValues(alpha: 0.10),
                        border: Border.all(
                          color: completedStatusColor.withValues(alpha: 0.18),
                          width: 1,
                        ),
                      ),
                    ),
                    Container(
                      height: 84,
                      width: 84,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [
                            completedStatusColor,
                            completedStatusColor.withValues(alpha: 0.78),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: completedStatusColor.withValues(alpha: 0.32),
                            blurRadius: 22,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: const Icon(Icons.check_rounded,
                          color: Colors.white, size: 44),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Text(locale.value.orderSuccess,
                  style: boldTextStyle(size: 24, color: appColorPrimary),
                  textAlign: TextAlign.center),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style:
                        primaryTextStyle(size: 14, color: secondaryTextColor),
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
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: appColorSecondary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.receipt_long_rounded,
                          color: appColorSecondary, size: 18),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(locale.value.orderNumber,
                          style: secondaryTextStyle(size: 13)),
                    ),
                    Text(orderNumber,
                        style: boldTextStyle(size: 14, color: appColorPrimary)),
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
                    colors: [gradientSecondaryStart, gradientSecondaryEnd],
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
                      Get.off(
                          () => PharmacyOrderDetailScreen(orderId: orderId));
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.local_shipping_rounded,
                            color: Colors.white, size: 18),
                        const SizedBox(width: 8),
                        Text(
                          locale.value.trackOrder,
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 15),
                        ),
                      ],
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
                    side:
                        const BorderSide(color: appColorSecondary, width: 1.2),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                  onPressed: () => Get.offAll(() => DashboardScreen()),
                  child: Text(locale.value.backToHome,
                      style: boldTextStyle(color: appColorSecondary, size: 14)),
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
