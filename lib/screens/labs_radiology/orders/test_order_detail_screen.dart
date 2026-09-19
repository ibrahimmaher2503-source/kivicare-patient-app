import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:kivicare_patient/screens/labs_radiology/labs_radiology_common.dart';
import 'package:kivicare_patient/components/loader_widget.dart';
import 'test_order_detail_controller.dart';
import 'components/order_status_badge.dart';
import 'components/status_timeline.dart';
import 'components/report_action_card.dart';
import 'components/cancel_order_dialog.dart';

class TestOrderDetailScreen extends StatelessWidget {
  final int orderId;

  const TestOrderDetailScreen({super.key, required this.orderId});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(TestOrderDetailController(orderId: orderId));

    return Scaffold(
      appBar: appBarWidget(
        locale.value.orderDetail,
        textColor: Colors.white,
        systemUiOverlayStyle: defaultSystemUiOverlayStyle(context),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () => controller.fetchOrderDetail(),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.order.value == null) {
          return const LoaderWidget().center();
        }

        final order = controller.order.value;
        if (order == null) {
          return Text(locale.value.noDataFound, style: secondaryTextStyle())
              .center();
        }

        return Stack(
          children: [
            AnimatedScrollView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildReferenceHeader(context, order),
                24.height,
                ReportActionCard(
                  hasReport: order.hasReport,
                  isDownloading: controller.isDownloading.value,
                  onDownload: () => controller.downloadReport(),
                ),
                24.height,
                _buildInfoCard(context, order),
                24.height,
                StatusTimeline(histories: order.statusHistories),
                if (order.canCancel) ...[
                  40.height,
                  AppButton(
                    text: locale.value.cancelOrder,
                    color: Colors.red.withValues(alpha: 0.1),
                    textStyle: boldTextStyle(color: Colors.red),
                    width: double.infinity,
                    onTap: () async {
                      final reason =
                          await Get.dialog<String>(const CancelOrderDialog());
                      if (reason != null) {
                        controller.cancelOrder(reason);
                      }
                    },
                  ),
                ],
                80.height,
              ],
            ),
            Obx(() => const LoaderWidget()
                .center()
                .visible(controller.isLoading.value)),
          ],
        );
      }),
    );
  }

  Widget _buildReferenceHeader(BuildContext context, dynamic order) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: boxDecorationDefault(
          color: context.cardColor, borderRadius: radius(12)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(locale.value.orderRef, style: secondaryTextStyle(size: 12)),
              4.height,
              Text(order.referenceNumber,
                  style: boldTextStyle(size: 18, color: context.primaryColor)),
            ],
          ),
          OrderStatusBadge(status: order.status),
        ],
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context, dynamic order) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: boxDecorationDefault(
          color: context.cardColor, borderRadius: radius(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoRow(locale.value.service, order.labTest?.name ?? 'N/A'),
          8.height,
          _buildInfoRow(locale.value.clinic, order.facility.name),
          Divider(height: 32, color: context.dividerColor),
          _buildInfoRow(locale.value.slotDate, order.slot.date),
          8.height,
          _buildInfoRow(locale.value.slotTime,
              '${order.slot.startTime} - ${order.slot.endTime}'),
          Divider(height: 32, color: context.dividerColor),
          _buildInfoRow(locale.value.paymentStatus,
              order.paymentStatus.displayLabel(locale.value)),
          8.height,
          _buildInfoRow(locale.value.pricing,
              '${order.totalAmount?.toStringAsFixed(0)} ${order.currency}',
              isBold: true),
          if (order.patientNotes.validate().isNotEmpty) ...[
            Divider(height: 32, color: context.dividerColor),
            Text(locale.value.patientNotes,
                style: secondaryTextStyle(size: 12)),
            4.height,
            Text(order.patientNotes!, style: primaryTextStyle(size: 14)),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: secondaryTextStyle()),
        Text(value,
            style:
                isBold ? boldTextStyle(size: 14) : primaryTextStyle(size: 14)),
      ],
    );
  }
}
