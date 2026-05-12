import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';
import '../../../api/pharmacy_apis.dart';
import '../../../components/app_scaffold.dart';
import '../../../components/loader_widget.dart';
import '../../../main.dart';
import '../../../utils/colors.dart';
import '../model/pharmacy_order_model.dart';
import '../utils/pharmacy_constants.dart';
import 'refund_request_screen.dart';

class PharmacyOrderDetailController extends GetxController {
  final int orderId;
  RxBool isLoading = false.obs;
  Rx<PharmacyOrder?> order = Rx<PharmacyOrder?>(null);

  PharmacyOrderDetailController({required this.orderId});

  @override
  void onInit() {
    super.onInit();
    fetchOrderDetails();
  }

  Future<void> fetchOrderDetails() async {
    isLoading(true);
    try {
      final res = await PharmacyApis.getOrderDetails(orderId);
      if (res != null && res['data'] != null) {
        order(PharmacyOrder.fromJson(res['data']));
      }
    } catch (e) {
      log('Error fetching order details: $e');
    } finally {
      isLoading(false);
    }
  }

  Future<void> cancelOrder() async {
    bool? confirm = await showConfirmDialog(
        Get.context!, locale.value.pharmacyCancelOrderConfirm,
        positiveText: locale.value.pharmacyYesCancel, negativeText: locale.value.no);
    if (confirm != true) return;

    isLoading(true);
    try {
      final res = await PharmacyApis.cancelOrder(orderId);
      if (res.status) {
        toast(res.message);
        fetchOrderDetails();
      }
    } catch (e) {
      toast(e.toString());
    } finally {
      isLoading(false);
    }
  }
}

class PharmacyOrderDetailScreen extends StatelessWidget {
  final PharmacyOrder? order;
  final int? orderId;

  const PharmacyOrderDetailScreen({super.key, this.order, this.orderId});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(
        PharmacyOrderDetailController(orderId: order?.id ?? orderId ?? 0),
        tag: (order?.id ?? orderId ?? 0).toString());

    return AppScaffoldNew(
      appBartitleText: locale.value.orderDetail,
      isLoading: controller.isLoading,
      body: Obx(() {
        if (controller.order.value == null) {
          return const LoaderWidget().center();
        }
        final o = controller.order.value!;
        final bool showCancel = o.canCancel ?? false;
        final bool showRefund = o.canRefund ?? false;
        final bool hasBottomActions = showCancel || showRefund;
        return Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildStatusHero(context, o),
                    const SizedBox(height: 20),
                    _buildStatusTimeline(context, o),
                    const SizedBox(height: 20),
                    _buildOrderItemsCard(context, o),
                    const SizedBox(height: 20),
                    _buildPaymentInfo(context, o),
                    const SizedBox(height: 20),
                    _buildDeliveryInfo(context, o),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
            if (hasBottomActions)
              _buildBottomBar(context,
                  showCancel: showCancel,
                  showRefund: showRefund,
                  onCancel: controller.cancelOrder,
                  onRefund: () => Get.to(() => RefundRequestScreen(order: o))),
          ],
        );
      }),
    );
  }

  Widget _buildStatusHero(BuildContext context, PharmacyOrder o) {
    final Color statusColor =
        PharmacyConstants.getStatusColor(o.status ?? '');
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: surfaceElevated,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: softShadowColor,
              blurRadius: 16,
              offset: const Offset(0, 6)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                      color: statusColor, shape: BoxShape.circle),
                ),
                const SizedBox(width: 8),
                Text(
                  o.status
                      .validate()
                      .replaceAll('_', ' ')
                      .capitalizeFirstLetter(),
                  style: boldTextStyle(color: statusColor, size: 13),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Text('${locale.value.orderNumber} #${o.orderNumber}',
              style: boldTextStyle(size: 18, color: appColorPrimary)),
          const SizedBox(height: 4),
          Text('${locale.value.placedOn} ${o.createdAt ?? ''}',
              style: secondaryTextStyle(size: 12)),
        ],
      ),
    );
  }

  Widget _buildStatusTimeline(BuildContext context, PharmacyOrder o) {
    List<String> statuses = [
      PharmacyConstants.statusPending,
      PharmacyConstants.statusConfirmed,
      PharmacyConstants.statusPreparing,
      PharmacyConstants.statusOutForDelivery,
      PharmacyConstants.statusDelivered,
    ];

    if (o.status == PharmacyConstants.statusCancelled) {
      statuses = [
        PharmacyConstants.statusPending,
        PharmacyConstants.statusCancelled
      ];
    } else if (o.status == PharmacyConstants.statusRefunded) {
      statuses.add(PharmacyConstants.statusRefunded);
    }

    int currentIndex = statuses.indexOf(o.status ?? '');

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: surfaceElevated,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: softShadowColor,
              blurRadius: 16,
              offset: const Offset(0, 6)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(locale.value.orderStatus,
              style: boldTextStyle(size: 16, color: appColorPrimary)),
          const SizedBox(height: 16),
          ...statuses.asMap().entries.map((entry) {
            int idx = entry.key;
            String s = entry.value;
            bool isPastOrCurrent = idx <= currentIndex;
            bool isLast = idx == statuses.length - 1;
            final bool connectorActive = idx < currentIndex;

            return IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    children: [
                      Container(
                        height: 24,
                        width: 24,
                        decoration: BoxDecoration(
                          color: isPastOrCurrent
                              ? appColorSecondary
                              : surfaceSubtle,
                          shape: BoxShape.circle,
                          border: Border.all(
                              color: isPastOrCurrent
                                  ? appColorSecondary
                                  : whiteBorderColor,
                              width: 1),
                        ),
                        child: isPastOrCurrent
                            ? const Icon(Icons.check,
                                color: Colors.white, size: 14)
                            : null,
                      ),
                      if (!isLast)
                        Expanded(
                          child: Container(
                            width: 2,
                            color: connectorActive
                                ? appColorSecondary
                                : whiteBorderColor,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(bottom: isLast ? 0 : 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            s.replaceAll('_', ' ').capitalizeFirstLetter(),
                            style: boldTextStyle(
                                size: 14,
                                color: isPastOrCurrent
                                    ? appColorPrimary
                                    : gray500),
                          ),
                          if (idx == currentIndex && o.createdAt != null) ...[
                            const SizedBox(height: 2),
                            Text(o.createdAt ?? '',
                                style: secondaryTextStyle(size: 12)),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildOrderItemsCard(BuildContext context, PharmacyOrder o) {
    final items = o.items.validate();
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surfaceElevated,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: softShadowColor,
              blurRadius: 16,
              offset: const Offset(0, 6)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(locale.value.items,
              style: boldTextStyle(size: 16, color: appColorPrimary)),
          const SizedBox(height: 12),
          ...items.asMap().entries.map((entry) {
            final idx = entry.key;
            final item = entry.value;
            final bool isLast = idx == items.length - 1;
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      (item.productImage.validate().isNotEmpty
                              ? CachedNetworkImage(
                                  imageUrl: item.productImage!,
                                  height: 56,
                                  width: 56,
                                  fit: BoxFit.cover)
                              : Container(
                                  height: 56,
                                  width: 56,
                                  color: surfaceSubtle,
                                  child: const Icon(Icons.image_outlined,
                                      color: gray400)))
                          .cornerRadiusWithClipRRect(12),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(item.productName ?? '',
                                style: boldTextStyle(
                                    size: 14, color: appColorPrimary),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis),
                            const SizedBox(height: 4),
                            Text(
                                '${locale.value.pharmacyQty}: ${item.quantity}',
                                style: secondaryTextStyle(size: 12)),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text('${item.lineTotal} LE',
                          style: boldTextStyle(size: 14)),
                    ],
                  ),
                ),
                if (!isLast)
                  Container(height: 1, color: whiteBorderColor),
              ],
            );
          }),
          const SizedBox(height: 8),
          Container(height: 1, color: whiteBorderColor),
          const SizedBox(height: 12),
          _buildPriceRow(locale.value.subtotal, '${o.subtotal} LE'),
          if (o.discount.validate() > 0)
            _buildPriceRow(locale.value.discount, '- ${o.discount} LE',
                color: completedStatusColor),
          _buildPriceRow(locale.value.deliveryFee, '${o.deliveryFee} LE'),
          const SizedBox(height: 8),
          Container(height: 1, color: whiteBorderColor),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(locale.value.total,
                  style: boldTextStyle(size: 16, color: appColorPrimary)),
              Text('${o.totalAmount} LE',
                  style: boldTextStyle(size: 20, color: appColorPrimary)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPriceRow(String label, String value,
      {double size = 14, Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: secondaryTextStyle(size: size.toInt())),
          Text(value,
              style: boldTextStyle(size: size.toInt(), color: color)),
        ],
      ),
    );
  }

  Widget _buildPaymentInfo(BuildContext context, PharmacyOrder o) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surfaceElevated,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: softShadowColor,
              blurRadius: 16,
              offset: const Offset(0, 6)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(locale.value.paymentMethod,
              style: boldTextStyle(size: 16, color: appColorPrimary)),
          const SizedBox(height: 12),
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: lightSecondaryColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.payment,
                    color: appColorSecondary, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                    o.paymentMethod
                        .validate()
                        .replaceAll('_', ' ')
                        .capitalizeFirstLetter(),
                    style: primaryTextStyle(size: 14)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDeliveryInfo(BuildContext context, PharmacyOrder o) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surfaceElevated,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: softShadowColor,
              blurRadius: 16,
              offset: const Offset(0, 6)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(locale.value.deliveryAddress,
              style: boldTextStyle(size: 16, color: appColorPrimary)),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: lightSecondaryColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.location_on_outlined,
                    color: appColorSecondary, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(o.deliveryAddress.validate(),
                    style: primaryTextStyle(size: 14)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context,
      {required bool showCancel,
      required bool showRefund,
      required VoidCallback onCancel,
      required VoidCallback onRefund}) {
    return Container(
      padding: EdgeInsets.fromLTRB(
          16, 12, 16, 12 + MediaQuery.of(context).padding.bottom),
      decoration: BoxDecoration(
        color: surfaceElevated,
        boxShadow: [
          BoxShadow(
              color: softShadowColor,
              blurRadius: 16,
              offset: const Offset(0, -6)),
        ],
      ),
      child: Row(
        children: [
          if (showCancel)
            Expanded(
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  foregroundColor: cancelStatusColor,
                  side: const BorderSide(color: cancelStatusColor, width: 1.2),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                onPressed: onCancel,
                child: Text(locale.value.cancelOrder,
                    style: boldTextStyle(color: cancelStatusColor, size: 14)),
              ),
            ),
          if (showCancel && showRefund) const SizedBox(width: 12),
          if (showRefund)
            Expanded(
              child: GestureDetector(
                onTap: onRefund,
                child: Container(
                  height: 52,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [gradientSecondaryStart, gradientSecondaryEnd],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                          color: softShadowColorMedium,
                          blurRadius: 16,
                          offset: const Offset(0, 6)),
                    ],
                  ),
                  child: Text(locale.value.requestRefund,
                      style: boldTextStyle(color: Colors.white, size: 14)),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
