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
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildOrderBrief(context),
                  const SizedBox(height: 20),
                  Text(locale.value.refundReason,
                      style: boldTextStyle(size: 16, color: appColorPrimary)),
                  const SizedBox(height: 12),
                  _buildReasonList(context, controller),
                  const SizedBox(height: 20),
                  Text(locale.value.pharmacyAdditionalNotes,
                      style: boldTextStyle(size: 16, color: appColorPrimary)),
                  const SizedBox(height: 8),
                  _buildNotesField(context, controller),
                ],
              ),
            ),
          ),
          _buildSubmitBar(context, controller),
        ],
      ),
    );
  }

  Widget _buildOrderBrief(BuildContext context) {
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
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  '${locale.value.orderNumber} #${order.orderNumber}',
                  style: boldTextStyle(size: 15, color: appColorPrimary),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Text('${order.totalAmount} LE',
                  style: boldTextStyle(size: 16, color: appColorPrimary)),
            ],
          ),
          const SizedBox(height: 10),
          Container(height: 1, color: whiteBorderColor),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(locale.value.placedOn,
                  style: secondaryTextStyle(size: 12)),
              Text(order.createdAt ?? '',
                  style: primaryTextStyle(size: 12)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildReasonList(
      BuildContext context, RefundRequestController controller) {
    return Obx(() => Column(
          children: controller.reasons.map((r) {
            final bool isSelected =
                controller.selectedReasonCode.value == r.code;
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => controller.selectedReasonCode(r.code),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 14),
                  decoration: BoxDecoration(
                    color:
                        isSelected ? lightSecondaryColor : surfaceElevated,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected
                          ? appColorSecondary
                          : whiteBorderColor,
                      width: isSelected ? 1.5 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 22,
                        height: 22,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isSelected
                              ? appColorSecondary
                              : Colors.transparent,
                          border: Border.all(
                              color: isSelected
                                  ? appColorSecondary
                                  : gray400,
                              width: 1.5),
                        ),
                        child: isSelected
                            ? const Icon(Icons.check,
                                color: Colors.white, size: 14)
                            : null,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          r.label,
                          style: isSelected
                              ? boldTextStyle(
                                  size: 14, color: appColorPrimary)
                              : primaryTextStyle(size: 14),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ));
  }

  Widget _buildNotesField(
      BuildContext context, RefundRequestController controller) {
    return Container(
      decoration: BoxDecoration(
        color: inputFillColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: whiteBorderColor, width: 1),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      child: TextField(
        controller: controller.notesController,
        maxLines: 6,
        minLines: 4,
        style: primaryTextStyle(size: 14),
        decoration: InputDecoration(
          hintText: locale.value.pharmacyDescribeIssue,
          hintStyle: secondaryTextStyle(size: 13),
          border: InputBorder.none,
          isCollapsed: true,
          contentPadding: const EdgeInsets.symmetric(vertical: 10),
        ),
      ),
    );
  }

  Widget _buildSubmitBar(
      BuildContext context, RefundRequestController controller) {
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
      child: GestureDetector(
        onTap: controller.submitRefund,
        child: Container(
          width: double.infinity,
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
          child: Text(locale.value.submitRequest,
              style: boldTextStyle(color: Colors.white, size: 15)),
        ),
      ),
    );
  }
}
