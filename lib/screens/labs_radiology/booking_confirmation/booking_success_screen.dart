import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:kivicare_patient/screens/labs_radiology/labs_radiology_common.dart';
import '../models/test_order_model.dart';
import '../hub/labs_radiology_hub_screen.dart';
import '../orders/test_order_detail_screen.dart';

class BookingSuccessScreen extends StatelessWidget {
  final TestOrderModel order;

  const BookingSuccessScreen({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) => SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: ConstrainedBox(
              constraints:
                  BoxConstraints(minHeight: constraints.maxHeight - 48),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: boxDecorationDefault(
                        shape: BoxShape.circle,
                        color: context.primaryColor.withValues(alpha: 0.1)),
                    child: Icon(Icons.check_circle_outline,
                        size: 100, color: context.primaryColor),
                  ),
                  32.height,
                  Text(locale.value.bookingSubmitted,
                      style: boldTextStyle(size: 22)),
                  16.height,
                  Text(
                    locale.value.yourTestIsBooked,
                    style: secondaryTextStyle(),
                    textAlign: TextAlign.center,
                  ).paddingSymmetric(horizontal: 32),
                  40.height,
                  Container(
                    padding: const EdgeInsets.all(16),
                    margin: const EdgeInsets.symmetric(horizontal: 32),
                    decoration: boxDecorationDefault(
                        color: context.cardColor, borderRadius: radius(12)),
                    child: Column(
                      children: [
                        Text(locale.value.orderRef,
                            style: secondaryTextStyle(size: 12)),
                        4.height,
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Flexible(
                              child: Text(
                                order.referenceNumber,
                                style: boldTextStyle(
                                    size: 18, color: context.primaryColor),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            8.width,
                            const Icon(Icons.copy,
                                    size: 18, color: secondaryTextColor)
                                .onTap(() {
                              order.referenceNumber.copyToClipboard();
                              toast(locale.value.copied);
                            }),
                          ],
                        ),
                      ],
                    ),
                  ),
                  60.height,
                  AppButton(
                    text: locale.value.viewDetails,
                    color: context.primaryColor,
                    textStyle: boldTextStyle(color: Colors.white),
                    width: 250,
                    onTap: () {
                      Get.off(() => TestOrderDetailScreen(orderId: order.id));
                    },
                  ),
                  12.height,
                  AppButton(
                    text: locale.value.backToLabs,
                    color: context.cardColor,
                    textStyle: boldTextStyle(color: context.primaryColor),
                    width: 250,
                    onTap: () {
                      Get.offAll(() => LabsRadiologyHubScreen());
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
