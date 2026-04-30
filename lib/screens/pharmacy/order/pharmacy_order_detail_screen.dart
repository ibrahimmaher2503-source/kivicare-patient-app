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
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context, o),
              const SizedBox(height: 24),
              _buildStatusTimeline(context, o),
              const SizedBox(height: 24),
              _buildOrderItems(context, o),
              const SizedBox(height: 24),
              _buildPaymentInfo(context, o),
              const SizedBox(height: 24),
              _buildDeliveryInfo(context, o),
              const SizedBox(height: 32),
              if (o.canCancel ?? false)
                AppButton(
                  text: locale.value.cancelOrder,
                  color: Colors.red,
                  textColor: Colors.white,
                  width: Get.width,
                  onTap: controller.cancelOrder,
                ),
              if (o.canRefund ?? false)
                AppButton(
                  text: locale.value.requestRefund,
                  color: appColorPrimary,
                  textColor: Colors.white,
                  width: Get.width,
                  onTap: () => Get.to(() => RefundRequestScreen(order: o)),
                ),
              const SizedBox(height: 48),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildHeader(BuildContext context, PharmacyOrder o) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${locale.value.orderNumber} #${o.orderNumber}',
                style: boldTextStyle(size: 18)),
            Text('${locale.value.placedOn} ${o.createdAt}',
                style: secondaryTextStyle()),
          ],
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: boxDecorationDefault(
            color: PharmacyConstants.getStatusColor(o.status ?? '')
                .withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            o.status.validate().replaceAll('_', ' ').capitalizeFirstLetter(),
            style: boldTextStyle(
                color: PharmacyConstants.getStatusColor(o.status ?? ''),
                size: 14),
          ),
        ),
      ],
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(locale.value.orderStatus, style: boldTextStyle()),
        const SizedBox(height: 16),
        ...statuses.asMap().entries.map((entry) {
          int idx = entry.key;
          String s = entry.value;
          bool isCompleted = idx <= currentIndex;
          bool isLast = idx == statuses.length - 1;

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                children: [
                  Container(
                    height: 20,
                    width: 20,
                    decoration: BoxDecoration(
                      color: isCompleted
                          ? PharmacyConstants.getStatusColor(s)
                          : gray200,
                      shape: BoxShape.circle,
                    ),
                    child: isCompleted
                        ? const Icon(Icons.check, color: Colors.white, size: 12)
                        : null,
                  ),
                  if (!isLast)
                    Container(
                      height: 30,
                      width: 2,
                      color: idx < currentIndex
                          ? PharmacyConstants.getStatusColor(s)
                          : gray200,
                    ),
                ],
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(s.replaceAll('_', ' ').capitalizeFirstLetter(),
                        style: primaryTextStyle(
                            color: isCompleted
                                ? blackTextColor
                                : secondaryTextColor,
                            size: 14)),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ],
          );
        }),
      ],
    );
  }

  Widget _buildOrderItems(BuildContext context, PharmacyOrder o) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(locale.value.items, style: boldTextStyle()),
        const SizedBox(height: 12),
        ...o.items.validate().map((item) => Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: Row(
                children: [
                  (item.productImage.validate().isNotEmpty
                          ? CachedNetworkImage(
                              imageUrl: item.productImage!,
                              height: 50,
                              width: 50,
                              fit: BoxFit.cover)
                          : Container(
                              height: 50,
                              width: 50,
                              color: gray100,
                              child: const Icon(Icons.image_outlined,
                                  color: gray400)))
                      .cornerRadiusWithClipRRect(8),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item.productName ?? '',
                            style: primaryTextStyle(size: 14),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis),
                        Text('${locale.value.pharmacyQty}: ${item.quantity}',
                            style: secondaryTextStyle(size: 12)),
                      ],
                    ),
                  ),
                  Text('${item.lineTotal} LE', style: boldTextStyle(size: 14)),
                ],
              ),
            )),
        const Divider(),
        _buildPriceRow(locale.value.subtotal, '${o.subtotal} LE'),
        if (o.discount.validate() > 0)
          _buildPriceRow(locale.value.discount, '- ${o.discount} LE',
              color: Colors.green),
        _buildPriceRow(locale.value.deliveryFee, '${o.deliveryFee} LE'),
        const SizedBox(height: 8),
        _buildPriceRow(locale.value.total, '${o.totalAmount} LE',
            isBold: true, size: 16, color: appColorSecondary),
      ],
    );
  }

  Widget _buildPriceRow(String label, String value,
      {bool isBold = false, double size = 14, Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: isBold
                  ? boldTextStyle(size: size.toInt())
                  : secondaryTextStyle(size: size.toInt())),
          Text(value, style: boldTextStyle(size: size.toInt(), color: color)),
        ],
      ),
    );
  }

  Widget _buildPaymentInfo(BuildContext context, PharmacyOrder o) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(locale.value.paymentMethod, style: boldTextStyle()),
        const SizedBox(height: 8),
        Container(
          width: Get.width,
          padding: const EdgeInsets.all(16),
          decoration: boxDecorationDefault(
              color: context.cardColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: context.dividerColor)),
          child: Row(
            children: [
              const Icon(Icons.payment, color: appColorSecondary, size: 20),
              const SizedBox(width: 12),
              Text(
                  o.paymentMethod
                      .validate()
                      .replaceAll('_', ' ')
                      .capitalizeFirstLetter(),
                  style: primaryTextStyle(size: 14)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDeliveryInfo(BuildContext context, PharmacyOrder o) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(locale.value.deliveryAddress, style: boldTextStyle()),
        const SizedBox(height: 8),
        Container(
          width: Get.width,
          padding: const EdgeInsets.all(16),
          decoration: boxDecorationDefault(
              color: context.cardColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: context.dividerColor)),
          child: Row(
            children: [
              const Icon(Icons.location_on_outlined,
                  color: appColorSecondary, size: 20),
              const SizedBox(width: 12),
              Expanded(
                  child: Text(o.deliveryAddress.validate(),
                      style: primaryTextStyle(size: 14))),
            ],
          ),
        ),
      ],
    );
  }
}
