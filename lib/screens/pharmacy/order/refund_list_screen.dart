import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';
import '../../../api/pharmacy_apis.dart';
import '../../../components/app_scaffold.dart';
import '../../../main.dart';
import '../../../utils/colors.dart';
import '../../../utils/price_widget.dart';
import '../model/pharmacy_refund_model.dart';
import '../utils/pharmacy_constants.dart';
import '../utils/pharmacy_empty_state.dart';

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
          ? PharmacyEmptyState(
              icon: Icons.assignment_return_outlined,
              title: locale.value.pharmacyNoRefunds,
            )
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
    final Color statusColor =
        PharmacyConstants.getRefundStatusColor(refund.status ?? '');
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
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
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 40,
                height: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: statusColor.withValues(alpha: 0.20),
                    width: 1,
                  ),
                ),
                child: Icon(Icons.replay_rounded, color: statusColor, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  '${locale.value.orderNumber} #${refund.orderNumber}',
                  style: boldTextStyle(size: 14, color: appColorPrimary),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              _RefundStatusPill(
                color: statusColor,
                label: PharmacyConstants.refundStatusLabel(
                  locale.value,
                  refund.status.validate(),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            '${locale.value.pharmacyReason}: ${refund.reason}',
            style: primaryTextStyle(size: 13),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          if (refund.notes.validate().isNotEmpty) ...[
            const SizedBox(height: 4),
            Text('${locale.value.notes}: ${refund.notes}',
                style: secondaryTextStyle(size: 12),
                maxLines: 2,
                overflow: TextOverflow.ellipsis),
          ],
          const SizedBox(height: 14),
          Container(height: 1, color: whiteBorderColor),
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
                    Text(refund.createdAt ?? '',
                        style: primaryTextStyle(size: 12)),
                  ],
                ),
              ),
              if (refund.refundAmount != null)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(locale.value.pharmacyRefundAmount,
                        style: secondaryTextStyle(size: 12)),
                    const SizedBox(height: 2),
                    Text(formatCurrencyValue(refund.refundAmount),
                        style:
                            boldTextStyle(size: 15, color: appColorSecondary)),
                  ],
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RefundStatusPill extends StatelessWidget {
  final Color color;
  final String label;

  const _RefundStatusPill({required this.color, required this.label});

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
          Text(label, style: boldTextStyle(color: color, size: 12)),
        ],
      ),
    );
  }
}
