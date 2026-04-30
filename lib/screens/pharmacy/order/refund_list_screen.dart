import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';
import '../../../api/pharmacy_apis.dart';
import '../../../components/app_scaffold.dart';
import '../../../utils/empty_error_state_widget.dart';
import '../../../main.dart';
import '../../../utils/colors.dart';
import '../model/pharmacy_refund_model.dart';
import '../utils/pharmacy_constants.dart';

class RefundListController extends GetxController {
  RxBool isLoading = false.obs;
  RxList<PharmacyRefund> refunds = <PharmacyRefund>[].obs;
  RxInt page = 1.obs;
  RxBool isLastPage = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchRefunds();
  }

  Future<void> fetchRefunds() async {
    if (isLoading.value) return;
    isLoading(true);

    try {
      final res = await PharmacyApis.getRefunds(page: page.value);
      if (res != null && res['data'] != null) {
        final List<PharmacyRefund> newItems = (res['data'] as List)
            .map((e) => PharmacyRefund.fromJson(e))
            .toList();
        if (page.value == 1) {
          refunds(newItems);
        } else {
          refunds.addAll(newItems);
        }
        isLastPage(newItems.length < 10);
      }
    } catch (e) {
      log('Error fetching refunds: $e');
    } finally {
      isLoading(false);
    }
  }

  Future<void> loadMore() async {
    if (!isLastPage.value && !isLoading.value) {
      page.value++;
      await fetchRefunds();
    }
  }

  @override
  Future<void> refresh() async {
    page(1);
    isLastPage(false);
    await fetchRefunds();
  }
}

class RefundListScreen extends StatelessWidget {
  RefundListScreen({super.key});

  final RefundListController controller = Get.put(RefundListController());

  @override
  Widget build(BuildContext context) {
    return AppScaffoldNew(
      appBartitleText: locale.value.refundRequests,
      isLoading: controller.isLoading,
      body: Obx(() => controller.refunds.isEmpty && !controller.isLoading.value
          ? NoDataWidget(
              title: locale.value.pharmacyNoRefunds,
              imageWidget: const ErrorStateWidget(),
              onRetry: () => controller.refresh(),
            ).center()
          : AnimatedScrollView(
              padding: const EdgeInsets.all(16),
              onSwipeRefresh: () => controller.refresh(),
              onNextPage: () => controller.loadMore(),
              children: [
                ...controller.refunds
                    .map((refund) => _RefundWidget(refund: refund)),
              ],
            )),
    );
  }
}

class _RefundWidget extends StatelessWidget {
  final PharmacyRefund refund;

  const _RefundWidget({required this.refund});

  @override
  Widget build(BuildContext context) {
    return Container(
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
              Text('${locale.value.orderNumber} #${refund.orderNumber}',
                  style: boldTextStyle()),
              _buildStatusBadge(refund.status ?? ''),
            ],
          ),
          const SizedBox(height: 8),
          Text('${locale.value.pharmacyReason}: ${refund.reason}', style: primaryTextStyle(size: 14)),
          if (refund.notes.validate().isNotEmpty) ...[
            const SizedBox(height: 4),
            Text('${locale.value.notes}: ${refund.notes}',
                style: secondaryTextStyle(size: 12),
                maxLines: 2,
                overflow: TextOverflow.ellipsis),
          ],
          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(locale.value.placedOn,
                      style: secondaryTextStyle(size: 10)),
                  Text(refund.createdAt ?? '',
                      style: primaryTextStyle(size: 12)),
                ],
              ),
              if (refund.refundAmount != null)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(locale.value.pharmacyRefundAmount, style: secondaryTextStyle(size: 10)),
                    Text('${refund.refundAmount} LE',
                        style: boldTextStyle(color: Colors.green)),
                  ],
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    final Color color = PharmacyConstants.getRefundStatusColor(status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: boxDecorationDefault(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8)),
      child: Text(status.capitalizeFirstLetter(),
          style: boldTextStyle(color: color, size: 12)),
    );
  }
}
