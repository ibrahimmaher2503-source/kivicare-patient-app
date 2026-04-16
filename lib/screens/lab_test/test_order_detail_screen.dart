import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kivicare_patient/components/app_scaffold.dart';
import 'package:kivicare_patient/utils/empty_error_state_widget.dart';
import 'package:kivicare_patient/components/loader_widget.dart';
import 'package:kivicare_patient/screens/lab_test/test_order_detail_controller.dart';
import 'package:kivicare_patient/utils/colors.dart';
import 'package:kivicare_patient/utils/common_base.dart';
import 'package:kivicare_patient/utils/app_common.dart';
import 'package:kivicare_patient/utils/price_widget.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../main.dart';

class TestOrderDetailScreen extends StatelessWidget {
  final int orderId;
  const TestOrderDetailScreen({Key? key, required this.orderId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<TestOrderDetailController>(
      init: TestOrderDetailController(orderId: orderId),
      builder: (controller) {
        return AppScaffold(
          appBarTitle: Text(locale.value.testOrderDetails),
          body: Obx(
            () => controller.isLoading.value
                ? const LoaderWidget()
                : controller.hasError
                    ? EmptyErrorStateWidget(
                        title: locale.value.error,
                        subTitle: controller.errorMessage.value ?? locale.value.somethingWentWrong,
                        onRetry: controller.retry,
                      )
                    : controller.hasOrderLoaded
                        ? SingleChildScrollView(
                            padding: const EdgeInsets.all(16),
                            child: _OrderContent(controller: controller),
                          )
                        : EmptyErrorStateWidget(
                            title: locale.value.noData,
                            subTitle: locale.value.noDataFound,
                            onRetry: controller.retry,
                          ),
          ),
        );
      },
    );
  }
}

class _OrderContent extends StatelessWidget {
  final TestOrderDetailController controller;
  const _OrderContent({required this.controller});

  @override
  Widget build(BuildContext context) {
    final order = controller.order.value;
    if (order == null) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: appColorPrimary.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(order.orderNumber, style: boldTextStyle(size: 18)),
                  Text(order.status, style: boldTextStyle(size: 12, color: Colors.orange)),
                ],
              ),
              const SizedBox(height: 12),
              PriceWidget(price: order.finalAmount, size: 16, color: appColorPrimary, isBoldText: true),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Text(locale.value.testCount, style: boldTextStyle(size: 14)),
        const SizedBox(height: 12),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: order.items.length,
          itemBuilder: (c, i) {
            final it = order.items[i];
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDarkMode.value ? cardDarkColor : Colors.grey.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Expanded(child: Text(it.labTest?.name ?? locale.value.labTests, style: boldTextStyle(size: 12))),
                  PriceWidget(price: it.price, size: 12, isBoldText: true),
                ],
              ),
            );
          },
        ),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          child: AppButton(
            text: locale.value.goBack,
            onTap: () => Get.back(),
            color: appColorPrimary.withValues(alpha: 0.1),
            textColor: appColorPrimary,
          ),
        ),
      ],
    );
  }
}
