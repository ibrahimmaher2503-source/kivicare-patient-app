import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';
import '../../../api/pharmacy_apis.dart';
import '../../../components/app_scaffold.dart';
import '../../../utils/empty_error_state_widget.dart';
import '../../../main.dart';
import '../../../utils/colors.dart';
import '../model/pharmacy_order_model.dart';
import '../utils/pharmacy_constants.dart';
import 'pharmacy_order_detail_screen.dart';

class PharmacyOrderListController extends GetxController {
  RxBool isLoading = false.obs;
  RxList<PharmacyOrder> orders = <PharmacyOrder>[].obs;
  RxInt page = 1.obs;
  RxBool isLastPage = false.obs;

  static const int perPage = 15;

  @override
  void onInit() {
    super.onInit();
    fetchOrders();
  }

  Future<void> fetchOrders() async {
    if (isLoading.value) return;
    isLoading(true);

    try {
      final res = await PharmacyApis.getOrders(page: page.value, perPage: perPage);
      if (res != null && res['data'] != null) {
        final List<PharmacyOrder> newItems = (res['data'] as List)
            .map((e) => PharmacyOrder.fromJson(e))
            .toList();
        if (page.value == 1) {
          orders(newItems);
        } else {
          orders.addAll(newItems);
        }
        isLastPage(newItems.length < perPage);
      }
    } catch (e) {
      log('Error fetching orders: $e');
    } finally {
      isLoading(false);
    }
  }

  Future<void> loadMore() async {
    if (!isLastPage.value && !isLoading.value) {
      page.value++;
      await fetchOrders();
    }
  }

  @override
  Future<void> refresh() async {
    page(1);
    isLastPage(false);
    await fetchOrders();
  }
}

class PharmacyOrderListScreen extends StatelessWidget {
  PharmacyOrderListScreen({super.key});

  final PharmacyOrderListController controller =
      Get.put(PharmacyOrderListController());

  @override
  Widget build(BuildContext context) {
    return AppScaffoldNew(
      appBartitleText: locale.value.orders,
      isLoading: controller.isLoading,
      body: Obx(() => controller.orders.isEmpty && !controller.isLoading.value
          ? NoDataWidget(
              title: locale.value.pharmacyNoOrders,
              imageWidget: const ErrorStateWidget(),
              onRetry: () => controller.refresh(),
            ).center()
          : AnimatedScrollView(
              padding: const EdgeInsets.all(16),
              onSwipeRefresh: () => controller.refresh(),
              onNextPage: () => controller.loadMore(),
              children: [
                ...controller.orders.map((order) => _OrderWidget(order: order)),
              ],
            )),
    );
  }
}

class _OrderWidget extends StatelessWidget {
  final PharmacyOrder order;

  const _OrderWidget({required this.order});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Get.to(() => PharmacyOrderDetailScreen(order: order)),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: boxDecorationDefault(
          color: context.cardColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
                color: softShadowColor,
                blurRadius: 10,
                offset: const Offset(0, 4))
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('${locale.value.orderNumber} #${order.orderNumber}',
                    style: boldTextStyle()),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: boxDecorationDefault(
                    color: PharmacyConstants.getStatusColor(order.status ?? '')
                        .withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    order.status
                        .validate()
                        .replaceAll('_', ' ')
                        .capitalizeFirstLetter(),
                    style: boldTextStyle(
                        color: PharmacyConstants.getStatusColor(
                            order.status ?? ''),
                        size: 12),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(order.pharmacy?.name ?? 'Pharmacy',
                style: primaryTextStyle(size: 14)),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(locale.value.placedOn,
                        style: secondaryTextStyle(size: 12)),
                    Text(order.createdAt ?? '',
                        style: primaryTextStyle(size: 12)),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(locale.value.total,
                        style: secondaryTextStyle(size: 12)),
                    Text('${order.totalAmount} LE',
                        style: boldTextStyle(color: appColorSecondary)),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
