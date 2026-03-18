import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../api/core_apis.dart';
import '../../components/app_scaffold.dart';
import '../../main.dart';
import '../../utils/app_common.dart';
import '../../utils/colors.dart';
import 'model/test_order_model.dart';

class TestOrderDetailScreen extends StatefulWidget {
  final TestOrder orderData;

  const TestOrderDetailScreen({super.key, required this.orderData});

  @override
  State<TestOrderDetailScreen> createState() => _TestOrderDetailScreenState();
}

class _TestOrderDetailScreenState extends State<TestOrderDetailScreen> {
  bool _isDownloading = false;

  TestOrder get orderData => widget.orderData;

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return labStatusPendingColor;
      case 'confirmed':
        return labStatusConfirmedColor;
      case 'sample_collected':
        return labStatusSampleCollectedColor;
      case 'processing':
        return labStatusProcessingColor;
      case 'completed':
        return labStatusCompletedColor;
      case 'delivered':
        return labStatusDeliveredColor;
      case 'cancelled':
        return labStatusCancelledColor;
      default:
        return labStatusPendingColor;
    }
  }

  String _statusLabel(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return locale.value.pending;
      case 'confirmed':
        return locale.value.confirmed;
      case 'sample_collected':
        return locale.value.sampleCollected;
      case 'processing':
        return locale.value.processing;
      case 'completed':
        return locale.value.completed;
      case 'delivered':
        return locale.value.delivered;
      case 'cancelled':
        return locale.value.cancelled;
      default:
        return status;
    }
  }

  Color _resultStatusColor(String? resultStatus) {
    switch (resultStatus?.toLowerCase()) {
      case 'normal':
        return resultNormalColor;
      case 'abnormal':
        return resultAbnormalColor;
      case 'critical':
        return resultCriticalColor;
      default:
        return secondaryTextColor;
    }
  }

  String _resultStatusLabel(String? resultStatus) {
    switch (resultStatus?.toLowerCase()) {
      case 'normal':
        return locale.value.resultNormal;
      case 'abnormal':
        return locale.value.resultAbnormal;
      case 'critical':
        return locale.value.resultCritical;
      default:
        return resultStatus ?? '';
    }
  }

  String get _priorityLabel {
    switch (orderData.priority.toLowerCase()) {
      case 'routine':
        return locale.value.priorityRoutine;
      case 'urgent':
        return locale.value.priorityUrgent;
      case 'stat':
        return locale.value.priorityStat;
      default:
        return orderData.priority;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffoldNew(
      appBartitleText: locale.value.testOrderDetails,
      hasLeadingWidget: true,
      appBarVerticalSize: Get.height * 0.12,
      body: AnimatedScrollView(
        listAnimationType: ListAnimationType.FadeIn,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        children: [
          16.height,

          // Order Header
          _buildOrderHeader(),
          20.height,

          // Items List
          _buildSectionTitle(locale.value.labTests),
          12.height,
          ...orderData.items.map((item) => _buildItemCard(item).paddingBottom(12)),

          // Financial Summary
          16.height,
          _buildFinancialSummary(),

          // Action Buttons
          24.height,
          _buildActionButtons(context),
          16.height,
        ],
      ).paddingTop(16),
    );
  }

  Widget _buildOrderHeader() {
    final statusColor = _statusColor(orderData.status);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [gradientStart, gradientEnd],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: appColorPrimary.withValues(alpha: 0.3),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '#${orderData.orderNumber}',
                style: GoogleFonts.outfit(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.5,
                  color: Colors.white,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: statusColor.withValues(alpha: 0.2),
                  border: Border.all(color: statusColor.withValues(alpha: 0.4)),
                ),
                child: Text(
                  _statusLabel(orderData.status),
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          12.height,
          Row(
            children: [
              Icon(Icons.calendar_today_outlined, size: 14, color: Colors.white70),
              6.width,
              Text(
                orderData.orderDate,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  color: Colors.white70,
                ),
              ),
              20.width,
              Icon(Icons.flag_outlined, size: 14, color: Colors.white70),
              6.width,
              Text(
                _priorityLabel,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.white70,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildItemCard(TestOrderItem item) {
    final hasResult = item.resultValue != null && item.resultValue!.isNotEmpty;
    final resultColor = _resultStatusColor(item.resultStatus);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDarkMode.value ? surfaceElevatedDark : surfaceElevated,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: isDarkMode.value ? softShadowColorDark : softShadowColor,
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  item.labTest?.name ?? '',
                  style: GoogleFonts.outfit(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.3,
                    color: isDarkMode.value ? Colors.white : primaryTextColor,
                  ),
                ),
              ),
              if (item.labTest?.code != null && item.labTest!.code.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: isDarkMode.value
                        ? appColorPrimary.withValues(alpha: 0.2)
                        : appColorPrimary.withValues(alpha: 0.08),
                  ),
                  child: Text(
                    item.labTest!.code,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                      color: appColorPrimary,
                    ),
                  ),
                ),
            ],
          ),
          8.height,

          // Price
          Text(
            '\$${item.price.toStringAsFixed(2)}',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: secondaryTextColor,
            ),
          ),

          // Result Display
          if (hasResult) ...[
            12.height,
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: resultColor.withValues(alpha: 0.08),
                border: Border.all(color: resultColor.withValues(alpha: 0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${locale.value.resultValue}: ${item.resultValue}${item.resultUnit != null ? " ${item.resultUnit}" : ""}',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: resultColor,
                        ),
                      ),
                      if (item.resultStatus != null)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: resultColor.withValues(alpha: 0.15),
                          ),
                          child: Text(
                            _resultStatusLabel(item.resultStatus),
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: resultColor,
                            ),
                          ),
                        ),
                    ],
                  ),
                  if (item.referenceRange != null && item.referenceRange!.isNotEmpty) ...[
                    6.height,
                    Text(
                      '${locale.value.referenceRange}: ${item.referenceRange}',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        color: secondaryTextColor,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFinancialSummary() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDarkMode.value ? surfaceElevatedDark : surfaceElevated,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: isDarkMode.value ? softShadowColorDark : softShadowColor,
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle(locale.value.totalAmount),
          16.height,
          _buildFinancialRow(locale.value.totalAmount, '\$${orderData.totalAmount.toStringAsFixed(2)}'),
          if (orderData.discountAmount > 0) ...[
            8.height,
            _buildFinancialRow(locale.value.discount, '-\$${orderData.discountAmount.toStringAsFixed(2)}', valueColor: resultNormalColor),
          ],
          8.height,
          const Divider(),
          8.height,
          _buildFinancialRow(
            locale.value.price,
            '\$${orderData.finalAmount.toStringAsFixed(2)}',
            isBold: true,
          ),
          12.height,
          _buildFinancialRow(
            locale.value.paymentStatus,
            orderData.paymentStatus.capitalizeFirst ?? orderData.paymentStatus,
            valueColor: orderData.paymentStatus.toLowerCase() == 'paid' ? resultNormalColor : labStatusPendingColor,
          ),
        ],
      ),
    );
  }

  Widget _buildFinancialRow(String label, String value, {Color? valueColor, bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: isBold ? 15 : 13,
            fontWeight: isBold ? FontWeight.w700 : FontWeight.w500,
            color: isDarkMode.value ? Colors.white70 : secondaryTextColor,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.plusJakartaSans(
            fontSize: isBold ? 16 : 14,
            fontWeight: isBold ? FontWeight.w700 : FontWeight.w600,
            color: valueColor ?? (isDarkMode.value ? Colors.white : primaryTextColor),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    final canCancel = orderData.status.toLowerCase() == 'pending' || orderData.status.toLowerCase() == 'confirmed';
    final canDownload = orderData.status.toLowerCase() == 'completed' || orderData.status.toLowerCase() == 'delivered';

    if (!canCancel && !canDownload) return const SizedBox.shrink();

    return Column(
      children: [
        if (canDownload)
          GestureDetector(
            onTap: _isDownloading
                ? null
                : () async {
                    setState(() => _isDownloading = true);
                    try {
                      final response = await CoreServiceApis.downloadTestReport(orderId: orderData.id);

                      if (response.statusCode != 200) {
                        throw Exception('Failed to download report (status ${response.statusCode})');
                      }

                      final dir = await getApplicationDocumentsDirectory();
                      final fileName = 'LAB-REPORT-${orderData.orderNumber}.pdf';
                      final file = File('${dir.path}/$fileName');
                      await file.writeAsBytes(response.bodyBytes);

                      toast(locale.value.reportDownloaded);

                      final uri = Uri.file(file.path);
                      if (await canLaunchUrl(uri)) {
                        await launchUrl(uri);
                      }
                    } catch (e) {
                      log("Download report error: $e");
                      toast(e.toString());
                    } finally {
                      setState(() => _isDownloading = false);
                    }
                  },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [gradientSecondaryStart, gradientSecondaryEnd],
                ),
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: appColorSecondary.withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Center(
                child: _isDownloading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.download_outlined, color: Colors.white, size: 20),
                          8.width,
                          Text(
                            locale.value.downloadReport,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.1,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ),
        if (canCancel) ...[
          if (canDownload) 12.height,
          GestureDetector(
            onTap: () {
              showConfirmDialogCustom(
                context,
                title: locale.value.testOrderCancelled,
                dialogType: DialogType.CONFIRMATION,
                positiveText: locale.value.cancelled,
                onAccept: (_) async {
                  try {
                    await CoreServiceApis.cancelTestOrder(
                      orderId: orderData.id,
                      request: {'reason': 'Cancelled by patient'},
                    );
                    toast(locale.value.testOrderCancelled);
                    Get.back(result: true);
                  } catch (e) {
                    log("Cancel order error: $e");
                    toast(e.toString());
                  }
                },
              );
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: labStatusCancelledColor),
              ),
              child: Center(
                child: Text(
                  locale.value.cancelled,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.1,
                    color: labStatusCancelledColor,
                  ),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.outfit(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.3,
        color: isDarkMode.value ? Colors.white : primaryTextColor,
      ),
    );
  }
}
