import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:kivicare_patient/screens/labs_radiology/labs_radiology_common.dart';
import 'package:kivicare_patient/components/loader_widget.dart';
import 'package:kivicare_patient/components/no_data_found_widget.dart';
import 'test_orders_list_controller.dart';
import 'components/order_list_item.dart';
import 'test_order_detail_screen.dart'; // Will be created in T057

class TestOrdersListScreen extends StatelessWidget {
  const TestOrdersListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(TestOrdersListController());

    return Scaffold(
      appBar: appBarWidget(
        locale.value.myTestOrders,
        textColor: Colors.white,
        systemUiOverlayStyle: defaultSystemUiOverlayStyle(context),
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.orders.isEmpty) {
          return const LoaderWidget().center();
        }

        if (controller.orders.isEmpty) {
          return NoDataFoundWidget(text: locale.value.noDataFound).center();
        }

        return RefreshIndicator(
          onRefresh: () async {
            controller.page.value = 1;
            await controller.fetchOrders(showLoader: false);
          },
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: controller.orders.length,
            itemBuilder: (context, index) {
              final order = controller.orders[index];

              if (index == controller.orders.length - 1 &&
                  !controller.isLastPage.value) {
                controller.loadMore();
              }

              return OrderListItem(
                order: order,
                onTap: () {
                  Get.to(() => TestOrderDetailScreen(orderId: order.id));
                },
              );
            },
          ),
        );
      }),
    );
  }
}
