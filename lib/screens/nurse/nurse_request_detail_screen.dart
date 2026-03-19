import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../api/core_apis.dart';
import '../../components/app_scaffold.dart';
import '../../components/loader_widget.dart';
import '../../main.dart';
import '../../utils/app_common.dart';
import '../../utils/colors.dart';
import '../../utils/constants.dart';
import '../../utils/price_widget.dart';
import 'create_nurse_request_screen.dart';
import 'model/nurse_request_model.dart';

class NurseRequestDetailScreen extends StatelessWidget {
  final NurseRequest requestData;

  NurseRequestDetailScreen({
    super.key,
    required this.requestData,
  });

  final RxBool isLoading = false.obs;

  Color get _statusColor {
    switch (requestData.status.toLowerCase()) {
      case NurseRequestStatusConst.pending:
        return nurseStatusPendingColor;
      case NurseRequestStatusConst.confirmed:
        return nurseStatusConfirmedColor;
      case NurseRequestStatusConst.inProgress:
        return nurseStatusInProgressColor;
      case NurseRequestStatusConst.completed:
        return nurseStatusCompletedColor;
      case NurseRequestStatusConst.cancelled:
        return nurseStatusCancelledColor;
      default:
        return nurseStatusPendingColor;
    }
  }

  String get _statusLabel {
    switch (requestData.status.toLowerCase()) {
      case NurseRequestStatusConst.pending:
        return locale.value.nurseRequestPending;
      case NurseRequestStatusConst.confirmed:
        return locale.value.nurseRequestConfirmed;
      case NurseRequestStatusConst.inProgress:
        return locale.value.nurseRequestInProgress;
      case NurseRequestStatusConst.completed:
        return locale.value.nurseRequestCompleted;
      case NurseRequestStatusConst.cancelled:
        return locale.value.cancelled;
      default:
        return requestData.status;
    }
  }

  bool get _isPending => requestData.status.toLowerCase() == NurseRequestStatusConst.pending;

  bool get _isCancellable =>
      requestData.status.toLowerCase() == NurseRequestStatusConst.pending ||
      requestData.status.toLowerCase() == NurseRequestStatusConst.confirmed;

  @override
  Widget build(BuildContext context) {
    return AppScaffoldNew(
      appBartitleText: '#${requestData.id}',
      hasLeadingWidget: true,
      appBarVerticalSize: Get.height * 0.12,
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: AnimatedScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  listAnimationType: ListAnimationType.Scale,
                  fadeInConfiguration: FadeInConfiguration(duration: GetNumUtils(1).seconds),
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    16.height,

                    // Status Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '#${requestData.id}',
                          style: GoogleFonts.outfit(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.3,
                            color: appColorSecondary,
                          ),
                        ),
                        _buildStatusChip(_statusLabel, _statusColor),
                      ],
                    ),
                    8.height,
                    if (requestData.createdAt.isNotEmpty)
                      Text(
                        requestData.createdAt,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          letterSpacing: 0.1,
                          color: secondaryTextColor,
                        ),
                      ),
                    24.height,

                    // Nurse Info Section
                    if (requestData.nurse != null) ...[
                      _buildSectionTitle(locale.value.nurseDetails),
                      12.height,
                      _buildInfoContainer(
                        children: [
                          _buildInfoRow(locale.value.nurses, requestData.nurse!.name),
                          if (requestData.nurse!.specialization.isNotEmpty)
                            _buildInfoRow(locale.value.specialization, requestData.nurse!.specialization),
                        ],
                      ),
                      16.height,
                    ],

                    // Service Details Section
                    _buildSectionTitle(locale.value.serviceDescription),
                    12.height,
                    _buildInfoContainer(
                      children: [
                        if (requestData.serviceDescription.isNotEmpty)
                          _buildInfoRow(locale.value.serviceDescription, requestData.serviceDescription),
                        if (requestData.preferredDate.isNotEmpty)
                          _buildInfoRow(locale.value.preferredDate, requestData.preferredDate),
                        if (requestData.preferredTime.isNotEmpty)
                          _buildInfoRow(locale.value.preferredTime, requestData.preferredTime),
                        if (requestData.durationHours > 0)
                          _buildInfoRow(locale.value.durationHours, '${requestData.durationHours} ${locale.value.hours}'),
                        if (requestData.contactNumber.isNotEmpty)
                          _buildInfoRow(locale.value.contactNumber, requestData.contactNumber),
                        if (requestData.totalAmount > 0)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(
                                  width: 120,
                                  child: Text(
                                    locale.value.totalAmount,
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 13,
                                      letterSpacing: 0.1,
                                      color: secondaryTextColor,
                                    ),
                                  ),
                                ),
                                8.width,
                                Expanded(child: PriceWidget(price: requestData.totalAmount)),
                              ],
                            ),
                          ),
                      ],
                    ),
                    16.height,

                    // Patient Notes
                    if (requestData.patientNotes.isNotEmpty) ...[
                      _buildSectionTitle(locale.value.patientNotes),
                      12.height,
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isDarkMode.value ? inputFillColorDark : inputFillColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          requestData.patientNotes,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13,
                            letterSpacing: 0.1,
                            color: secondaryTextColor,
                            height: 1.6,
                          ),
                        ),
                      ),
                      16.height,
                    ],

                    // Address Section
                    if (requestData.address != null && requestData.address!.fullAddress.isNotEmpty) ...[
                      _buildSectionTitle(locale.value.addressLine1),
                      12.height,
                      _buildInfoContainer(
                        children: [
                          if (requestData.address!.addressLine1.isNotEmpty)
                            _buildInfoRow(locale.value.addressLine1, requestData.address!.addressLine1),
                          if (requestData.address!.addressLine2.isNotEmpty)
                            _buildInfoRow(locale.value.addressLine2, requestData.address!.addressLine2),
                          if (requestData.address!.city.isNotEmpty)
                            _buildInfoRow(locale.value.city, requestData.address!.city),
                          if (requestData.address!.postalCode.isNotEmpty)
                            _buildInfoRow(locale.value.postalCode, requestData.address!.postalCode),
                        ],
                      ),
                      16.height,
                    ],

                    // Admin Notes
                    if (requestData.adminNotes != null && requestData.adminNotes!.isNotEmpty) ...[
                      _buildSectionTitle(locale.value.adminNotes),
                      12.height,
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isDarkMode.value ? inputFillColorDark : inputFillColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          requestData.adminNotes!,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13,
                            letterSpacing: 0.1,
                            color: secondaryTextColor,
                            height: 1.6,
                          ),
                        ),
                      ),
                      16.height,
                    ],

                    // Cancellation Info
                    if (requestData.cancellationReason != null && requestData.cancellationReason!.isNotEmpty) ...[
                      _buildSectionTitle(locale.value.cancellationReason),
                      12.height,
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: nurseStatusCancelledColor.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: nurseStatusCancelledColor.withValues(alpha: 0.2)),
                        ),
                        child: Text(
                          requestData.cancellationReason!,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13,
                            letterSpacing: 0.1,
                            color: nurseStatusCancelledColor,
                            height: 1.6,
                          ),
                        ),
                      ),
                      16.height,
                    ],

                    32.height,
                  ],
                ).paddingSymmetric(horizontal: 16),
              ),

              // Action Buttons
              if (_isPending || _isCancellable)
                Container(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      if (_isPending)
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              Get.to(() => CreateNurseRequestScreen(editRequest: requestData));
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(colors: [gradientStart, gradientEnd]),
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: appColorPrimary.withValues(alpha: 0.3),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Text(
                                locale.value.editNurseRequest,
                                textAlign: TextAlign.center,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.1,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                      if (_isPending) 12.width,
                      if (_isCancellable)
                        Expanded(
                          child: GestureDetector(
                            onTap: () => _showCancelDialog(context),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              decoration: BoxDecoration(
                                color: nurseStatusCancelledColor.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: nurseStatusCancelledColor.withValues(alpha: 0.3)),
                              ),
                              child: Text(
                                locale.value.cancel,
                                textAlign: TextAlign.center,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.1,
                                  color: nurseStatusCancelledColor,
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
            ],
          ),
          Obx(() => const LoaderWidget().visible(isLoading.value)),
        ],
      ),
    );
  }

  void _showCancelDialog(BuildContext context) {
    final reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: isDarkMode.value ? surfaceElevatedDark : surfaceElevated,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(
            locale.value.cancel,
            style: GoogleFonts.outfit(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: isDarkMode.value ? Colors.white : primaryTextColor,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${locale.value.cancel}?',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  letterSpacing: 0.1,
                  color: secondaryTextColor,
                ),
              ),
              16.height,
              AppTextField(
                textStyle: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  letterSpacing: 0.1,
                  color: isDarkMode.value ? Colors.white : primaryTextColor,
                ),
                controller: reasonController,
                textFieldType: TextFieldType.MULTILINE,
                minLines: 3,
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
              ),
            ],
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
              onPressed: () async {
                Navigator.pop(ctx);
                await _cancelRequest(reasonController.text.trim());
              },
              child: Text(
                locale.value.submit,
                style: GoogleFonts.plusJakartaSans(color: nurseStatusCancelledColor, fontWeight: FontWeight.w700),
              ),
            ),
          ],
        );
      },
    ).then((_) => reasonController.dispose());
  }

  Future<void> _cancelRequest(String reason) async {
    isLoading(true);
    final request = <String, dynamic>{};
    if (reason.isNotEmpty) {
      request['cancellation_reason'] = reason;
    }
    await CoreServiceApis.cancelNurseRequest(requestId: requestData.id, request: request).then((res) {
      toast(locale.value.nurseRequestCancelled);
      Get.back();
    }).catchError((e) {
      toast(locale.value.somethingWentWrong);
    }).whenComplete(() {
      isLoading(false);
    });
  }

  Widget _buildStatusChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: LinearGradient(
          colors: [
            color.withValues(alpha: 0.15),
            color.withValues(alpha: 0.08),
          ],
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color,
            ),
          ),
          6.width,
          Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.1,
              color: color,
            ),
          ),
        ],
      ),
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

  Widget _buildInfoContainer({required List<Widget> children}) {
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
        children: children,
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                letterSpacing: 0.1,
                color: secondaryTextColor,
              ),
            ),
          ),
          8.width,
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.1,
                color: isDarkMode.value ? Colors.white : primaryTextColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
