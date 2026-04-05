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
import '../../utils/price_widget.dart';
import 'model/test_order_model.dart';

class TestOrderDetailScreen extends StatefulWidget {
  final TestOrder orderData;

  const TestOrderDetailScreen({super.key, required this.orderData});

  @override
  State<TestOrderDetailScreen> createState() => _TestOrderDetailScreenState();
}

class _TestOrderDetailScreenState extends State<TestOrderDetailScreen> {
  final RxBool _isDownloading = false.obs;

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
        padding: const EdgeInsets.all(24),
        children: [
          16.height,

          // Order Header
          _buildOrderHeader(),
          20.height,

          // Order Info (patient, doctor, lab technician, clinical notes, created_at)
          _buildOrderInfoCard(),
          16.height,

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

  Widget _buildOrderInfoCard() {
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
          if (orderData.patient != null && orderData.patient!.name.isNotEmpty)
            _buildInfoRow(
              icon: Icons.person_outlined,
              label: locale.value.otherPatient,
              value: orderData.patient!.name,
            ),
          if (orderData.doctor != null && orderData.doctor!.name.isNotEmpty)
            _buildInfoRow(
              icon: Icons.medical_services_outlined,
              label: locale.value.doctor,
              value: orderData.doctor!.name,
            ),
          if (orderData.labTechnician != null && orderData.labTechnician.toString().isNotEmpty)
            _buildInfoRow(
              icon: Icons.biotech_outlined,
              label: locale.value.department,
              value: orderData.labTechnician.toString(),
            ),
          if (orderData.clinicalNotes.isNotEmpty)
            _buildInfoRow(
              icon: Icons.notes_outlined,
              label: locale.value.clinicalNotes,
              value: orderData.clinicalNotes,
            ),
          if (orderData.createdAt.isNotEmpty)
            _buildInfoRow(
              icon: Icons.access_time_outlined,
              label: locale.value.date,
              value: orderData.createdAt,
            ),
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: isDarkMode.value
                  ? appColorSecondary.withValues(alpha: 0.15)
                  : appColorSecondary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 16, color: appColorSecondary),
          ),
          12.width,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    letterSpacing: 0.1,
                    color: secondaryTextColor,
                  ),
                ),
                2.height,
                Text(
                  value,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.1,
                    color: isDarkMode.value ? Colors.white : primaryTextColor,
                  ),
                ),
              ],
            ),
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
          item.price > 0
              ? PriceWidget(
                  price: item.price,
                  size: 13,
                  color: secondaryTextColor,
                )
              : Text(
                  locale.value.freeLabel,
                  style: GoogleFonts.outfit(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.3,
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
                  if (item.resultNotes != null && item.resultNotes!.isNotEmpty) ...[
                    6.height,
                    Text(
                      '${locale.value.notes}: ${item.resultNotes}',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        color: secondaryTextColor,
                      ),
                    ),
                  ],
                  if (item.resultDate != null && item.resultDate!.isNotEmpty) ...[
                    6.height,
                    Text(
                      '${locale.value.date}: ${item.resultDate}',
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
          _buildFinancialRowWidget(locale.value.totalAmount, PriceWidget(price: orderData.totalAmount, size: 14)),
          if (orderData.discountAmount > 0) ...[
            8.height,
            _buildFinancialRowWidget(locale.value.discount, PriceWidget(price: orderData.discountAmount, size: 14, color: resultNormalColor), prefix: '-'),
          ],
          8.height,
          const Divider(),
          8.height,
          _buildFinancialRowWidget(
            locale.value.price,
            PriceWidget(price: orderData.finalAmount, size: 16, color: isDarkMode.value ? Colors.white : primaryTextColor),
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

  Widget _buildFinancialRowWidget(String label, Widget valueWidget, {bool isBold = false, String prefix = ''}) {
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
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (prefix.isNotEmpty) Text(prefix, style: GoogleFonts.plusJakartaSans(fontSize: isBold ? 16 : 14, fontWeight: isBold ? FontWeight.w700 : FontWeight.w600, color: isDarkMode.value ? Colors.white70 : secondaryTextColor)),
            valueWidget,
          ],
        ),
      ],
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
          Obx(() => GestureDetector(
            onTap: _isDownloading.value
                ? null
                : () async {
                    _isDownloading(true);
                    try {
                      final response = await CoreServiceApis.downloadTestReport(orderId: orderData.id);

                      if (response.statusCode != 200) {
                        throw Exception('${locale.value.somethingWentWrong} (${response.statusCode})');
                      }

                      final dir = await getApplicationDocumentsDirectory();
                      final fileName = 'LAB-REPORT-${orderData.orderNumber}.pdf';
                      final file = File('${dir.path}/$fileName');
                      await file.writeAsBytes(response.bodyBytes);

                      toast(locale.value.reportDownloaded);

                      // Try to open the file; silently ignore if platform doesn't support file:// URIs
                      try {
                        final uri = Uri.file(file.path);
                        if (await canLaunchUrl(uri)) {
                          await launchUrl(uri);
                        }
                      } catch (_) {
                        // File saved successfully but could not be opened directly
                      }
                    } catch (e) {
                      log("Download report error: $e");
                      toast(locale.value.somethingWentWrong);
                    } finally {
                      _isDownloading(false);
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
                child: _isDownloading.value
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
          )),
        if (canCancel) ...[
          if (canDownload) 12.height,
          GestureDetector(
            onTap: () => _showCancelDialog(context),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: labStatusCancelledColor),
              ),
              child: Center(
                child: Text(
                  locale.value.cancel,
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

  void _showCancelDialog(BuildContext context) {
    final reasonController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: isDarkMode.value ? surfaceElevatedDark : surfaceElevated,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(
            '${locale.value.cancel}?',
            style: GoogleFonts.outfit(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: isDarkMode.value ? Colors.white : primaryTextColor,
            ),
          ),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  locale.value.cancellationReason,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    letterSpacing: 0.1,
                    color: secondaryTextColor,
                  ),
                ),
                16.height,
                TextFormField(
                  controller: reasonController,
                  maxLines: 3,
                  maxLength: 500,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    letterSpacing: 0.1,
                    color: isDarkMode.value ? Colors.white : primaryTextColor,
                  ),
                  decoration: InputDecoration(
                    hintText: locale.value.cancellationReason,
                    hintStyle: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      letterSpacing: 0.1,
                      color: secondaryTextColor,
                    ),
                    filled: true,
                    fillColor: isDarkMode.value ? inputFillColorDark : inputFillColor,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return locale.value.thisFieldIsRequired;
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(
                locale.value.cancel,
                style: GoogleFonts.plusJakartaSans(color: secondaryTextColor),
              ),
            ),
            TextButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  Navigator.pop(ctx);
                  _cancelOrder(reasonController.text.trim());
                }
              },
              child: Text(
                locale.value.submit,
                style: GoogleFonts.plusJakartaSans(
                  color: labStatusCancelledColor,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        );
      },
    ).then((_) => reasonController.dispose());
  }

  Future<void> _cancelOrder(String reason) async {
    try {
      await CoreServiceApis.cancelTestOrder(
        orderId: orderData.id,
        request: {'cancellation_reason': reason},
      );
      toast(locale.value.testOrderCancelled);
      Get.back(result: true);
    } catch (e) {
      log("Cancel order error: $e");
      toast(locale.value.somethingWentWrong);
    }
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
