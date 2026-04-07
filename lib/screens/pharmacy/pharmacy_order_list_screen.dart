import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../components/app_scaffold.dart';
import '../../main.dart';
import '../../utils/empty_error_state_widget.dart';
import 'components/pharmacy_order_card.dart';
import 'pharmacy_categories_screen.dart';
import 'pharmacy_order_detail_screen.dart';
import 'pharmacy_order_list_controller.dart';

class PharmacyOrderListScreen extends StatelessWidget {
  const PharmacyOrderListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<PharmacyOrderListController>(
      init: PharmacyOrderListController(),
      builder: (controller) {
        return AppScaffold(
          appBarTitle: Text(locale.value.orderHistory),
          body: Obx(() {
            if (controller.isLoading.value && controller.orders.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }
            if (controller.orders.isEmpty) {
              return Center(
                child: EmptyErrorStateWidget(
                  title: locale.value.orderHistory,
                  subTitle: locale.value.noData,
                  onRetry: () =>
                      Get.to(() => const PharmacyCategoriesScreen()),
                ),
              );
            }
            return RefreshIndicator(
              onRefresh: () => controller.loadOrders(isRefresh: true),
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
                itemCount: controller.orders.length +
                    (controller.isLastPage ? 0 : 1),
                itemBuilder: (context, index) {
                  if (index >= controller.orders.length) {
                    if (!controller.isLoadingMore.value) {
                      controller.loadMore();
                    }
                    return const Center(
                        child: Padding(
                            padding: EdgeInsets.all(16),
                            child: CircularProgressIndicator()));
                  }
                  return PharmacyOrderCard(
                    order: controller.orders[index],
                    onTap: () {
                      Get.to(() => PharmacyOrderDetailScreen(),
                          arguments: controller.orders[index].id);
                    },
                  );
                },
              ),
            );
          }),
        );
      },
    );
  }
}
