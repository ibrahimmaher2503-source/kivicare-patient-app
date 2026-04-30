import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';
import '../../../api/pharmacy_apis.dart';
import '../../../components/app_scaffold.dart';
import '../../../main.dart';
import '../../../utils/colors.dart';
import '../../../utils/common_base.dart';
import '../model/pharmacy_order_model.dart';
import 'refund_list_screen.dart';

class RefundReason {
  final String code;
  final String label;

  const RefundReason(this.code, this.label);
}

class RefundRequestController extends GetxController {
  final PharmacyOrder order;
  RxBool isLoading = false.obs;
  late RxString selectedReasonCode;
  TextEditingController notesController = TextEditingController();

  List<RefundReason> get reasons => [
        RefundReason('damaged_product', locale.value.damagedProduct),
        RefundReason('wrong_product_received', locale.value.wrongProductReceived),
        RefundReason('expired_product', locale.value.expiredProduct),
        RefundReason('quality_issue', locale.value.qualityIssue),
        RefundReason('other', locale.value.other),
      ];

  RefundRequestController({required this.order}) {
    selectedReasonCode = reasons.first.code.obs;
  }

  Future<void> submitRefund() async {
    if (selectedReasonCode.value.isEmpty) {
      toast(locale.value.pharmacySelectReason);
      return;
    }

    isLoading(true);
    try {
      final res = await PharmacyApis.requestRefund(
        orderId: order.id!,
        reason: selectedReasonCode.value,
        notes: notesController.text,
      );
      if (res != null) {
        toast(locale.value.pharmacyRefundSubmitted);
        Get.off(() => RefundListScreen());
      }
    } catch (e) {
      toast(e.toString());
    } finally {
      isLoading(false);
    }
  }

  @override
  void onClose() {
    notesController.dispose();
    super.onClose();
  }
}

class RefundRequestScreen extends StatelessWidget {
  final PharmacyOrder order;

  const RefundRequestScreen({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(RefundRequestController(order: order));

    return AppScaffoldNew(
      appBartitleText: locale.value.requestRefund,
      isLoading: controller.isLoading,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildOrderBrief(context),
            const SizedBox(height: 24),
            Text(locale.value.refundReason, style: boldTextStyle()),
            const SizedBox(height: 12),
            _buildReasonDropdown(context, controller),
            const SizedBox(height: 24),
            Text(locale.value.pharmacyAdditionalNotes, style: boldTextStyle()),
            const SizedBox(height: 8),
            AppTextField(
              controller: controller.notesController,
              textFieldType: TextFieldType.MULTILINE,
              maxLines: 5,
              minLines: 3,
              decoration: inputDecoration(context,
                  hintText: locale.value.pharmacyDescribeIssue),
            ),
            const SizedBox(height: 32),
            AppButton(
              text: locale.value.submitRequest,
              color: appColorPrimary,
              textColor: Colors.white,
              width: Get.width,
              shapeBorder: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              onTap: controller.submitRefund,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderBrief(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: boxDecorationDefault(
          color: lightPrimaryColor, borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('${locale.value.orderNumber} #${order.orderNumber}',
                  style: boldTextStyle()),
              Text('${order.totalAmount} LE',
                  style: boldTextStyle(color: appColorSecondary)),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(locale.value.placedOn, style: secondaryTextStyle(size: 12)),
              Text(order.createdAt ?? '', style: primaryTextStyle(size: 12)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildReasonDropdown(
      BuildContext context, RefundRequestController controller) {
    return Obx(() => Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: boxDecorationDefault(
              color: context.cardColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: context.dividerColor)),
          child: DropdownButton<String>(
            value: controller.selectedReasonCode.value,
            isExpanded: true,
            underline: const Offstage(),
            items: controller.reasons
                .map((e) => DropdownMenuItem(
                    value: e.code,
                    child: Text(e.label, style: primaryTextStyle())))
                .toList(),
            onChanged: (val) => controller.selectedReasonCode(val!),
          ),
        ));
  }
}
