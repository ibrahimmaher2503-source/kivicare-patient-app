import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';
import '../../../api/pharmacy_apis.dart';
import '../../../components/app_scaffold.dart';
import '../../../main.dart';
import '../../../utils/colors.dart';
import '../model/pharmacy_order_model.dart';
import '../utils/pharmacy_constants.dart';
import '../utils/pharmacy_empty_state.dart';
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
          ? PharmacyEmptyState(
              icon: Icons.receipt_long_outlined,
              title: locale.value.pharmacyNoOrders,
              hint: locale.value.cartEmptyHint,
              primaryLabel: locale.value.browsePharmacy,
              onPrimary: () => Get.back(),
            )
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
    final Color statusColor =
        PharmacyConstants.getStatusColor(order.status ?? '');
    return GestureDetector(
      onTap: () => Get.to(() => PharmacyOrderDetailScreen(order: order)),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: boxDecorationDefault(
          color: surfaceElevated,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
                color: softShadowColor,
                blurRadius: 16,
                offset: const Offset(0, 6))
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Text(
                    '${locale.value.orderNumber} #${order.orderNumber}',
                    style: boldTextStyle(size: 14, color: appColorPrimary),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                _StatusPill(
                  color: statusColor,
                  label: order.status
                      .validate()
                      .replaceAll('_', ' ')
                      .capitalizeFirstLetter(),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(order.pharmacy?.name ?? 'Pharmacy',
                style: primaryTextStyle(size: 13)),
            const SizedBox(height: 14),
            Container(
              height: 1,
              color: whiteBorderColor,
            ),
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(locale.value.placedOn,
                          style: secondaryTextStyle(size: 12)),
                      const SizedBox(height: 2),
                      Text(order.createdAt ?? '',
                          style: primaryTextStyle(size: 12)),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(locale.value.total,
                        style: secondaryTextStyle(size: 12)),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Text('${order.totalAmount} LE',
                            style: boldTextStyle(
                                size: 15, color: appColorPrimary)),
                        const SizedBox(width: 6),
                        const Icon(Icons.chevron_right_rounded,
                            color: appColorSecondary, size: 20),
                      ],
                    ),
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

class _StatusPill extends StatelessWidget {
  final Color color;
  final String label;

  const _StatusPill({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(label, style: boldTextStyle(color: color, size: 11)),
        ],
      ),
    );
  }
}
