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

class NurseRequestDetailScreen extends StatefulWidget {
  final NurseRequest requestData;

  const NurseRequestDetailScreen({
    super.key,
    required this.requestData,
  });

  @override
  State<NurseRequestDetailScreen> createState() => _NurseRequestDetailScreenState();
}

class _NurseRequestDetailScreenState extends State<NurseRequestDetailScreen>
    with SingleTickerProviderStateMixin {
  final RxBool isLoading = false.obs;
  late final AnimationController _borderController;

  NurseRequest get requestData => widget.requestData;

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
  void initState() {
    super.initState();
    _borderController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    )..repeat();
  }

  @override
  void dispose() {
    _borderController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Build timeline sections
    final List<_TimelineSection> sections = [];
    int sectionIndex = 0;

    if (requestData.nurse != null) {
      sections.add(_TimelineSection(
        title: locale.value.nurseDetails,
        index: sectionIndex++,
        child: _buildInfoContainer(
          children: [
            _buildInfoRow(locale.value.nurses, requestData.nurse!.name),
            if (requestData.nurse!.specialization.isNotEmpty)
              _buildInfoRow(locale.value.specialization, requestData.nurse!.specialization),
          ],
        ),
      ));
    }

    sections.add(_TimelineSection(
      title: locale.value.serviceDescription,
      index: sectionIndex++,
      child: _buildInfoContainer(
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
    ));

    if (requestData.patientNotes.isNotEmpty) {
      sections.add(_TimelineSection(
        title: locale.value.patientNotes,
        index: sectionIndex++,
        child: Container(
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
      ));
    }

    if (requestData.address != null && requestData.address!.fullAddress.isNotEmpty) {
      sections.add(_TimelineSection(
        title: locale.value.addressLine1,
        index: sectionIndex++,
        child: _buildInfoContainer(
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
      ));
    }

    if (requestData.adminNotes != null && requestData.adminNotes!.isNotEmpty) {
      sections.add(_TimelineSection(
        title: locale.value.adminNotes,
        index: sectionIndex++,
        child: Container(
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
      ));
    }

    if (requestData.cancellationReason != null && requestData.cancellationReason!.isNotEmpty) {
      sections.add(_TimelineSection(
        title: locale.value.cancellationReason,
        index: sectionIndex++,
        child: Container(
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
      ));
    }

    return AppScaffoldNew(
      appBartitleText: '#${requestData.id}',
      hasLeadingWidget: true,
      appBarVerticalSize: Get.height * 0.12,
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Gradient Header with status badge
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              appColorPrimary.withValues(alpha: isDarkMode.value ? 0.4 : 0.08),
                              appColorSecondary.withValues(alpha: isDarkMode.value ? 0.2 : 0.04),
                            ],
                          ),
                          borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(24),
                            bottomRight: Radius.circular(24),
                          ),
                        ),
                        child: Column(
                          children: [
                            Text(
                              '#${requestData.id}',
                              style: GoogleFonts.outfit(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                letterSpacing: -0.3,
                                color: secondaryTextColor,
                              ),
                            ),
                            12.height,
                            // Animated gradient border status badge
                            AnimatedBuilder(
                              animation: _borderController,
                              builder: (context, child) {
                                return Container(
                                  padding: const EdgeInsets.all(2),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(24),
                                    gradient: SweepGradient(
                                      startAngle: _borderController.value * 6.28,
                                      colors: [
                                        _statusColor,
                                        _statusColor.withValues(alpha: 0.3),
                                        _statusColor,
                                      ],
                                    ),
                                  ),
                                  child: child,
                                );
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(22),
                                  color: isDarkMode.value ? surfaceElevatedDark : surfaceElevated,
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      width: 8,
                                      height: 8,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: _statusColor,
                                        boxShadow: [
                                          BoxShadow(
                                            color: _statusColor.withValues(alpha: 0.5),
                                            blurRadius: 4,
                                          ),
                                        ],
                                      ),
                                    ),
                                    8.width,
                                    Text(
                                      _statusLabel,
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: 0.1,
                                        color: _statusColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            if (requestData.createdAt.isNotEmpty) ...[
                              10.height,
                              Text(
                                requestData.createdAt,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 13,
                                  letterSpacing: 0.1,
                                  color: secondaryTextColor,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      20.height,

                      // Timeline sections
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: List.generate(sections.length, (index) {
                            final section = sections[index];
                            final isLast = index == sections.length - 1;

                            return TweenAnimationBuilder<double>(
                              tween: Tween(begin: 0.0, end: 1.0),
                              duration: Duration(milliseconds: 400 + (section.index * 100)),
                              builder: (context, value, child) {
                                return Opacity(
                                  opacity: value,
                                  child: Transform.translate(
                                    offset: Offset(0, 20 * (1 - value)),
                                    child: child,
                                  ),
                                );
                              },
                              child: IntrinsicHeight(
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Timeline line and dot
                                    SizedBox(
                                      width: 24,
                                      child: Column(
                                        children: [
                                          Container(
                                            width: 12,
                                            height: 12,
                                            margin: const EdgeInsets.only(top: 4),
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: _statusColor.withValues(alpha: 0.2),
                                              border: Border.all(
                                                color: _statusColor,
                                                width: 2.5,
                                              ),
                                            ),
                                          ),
                                          if (!isLast)
                                            Expanded(
                                              child: Container(
                                                width: 2,
                                                margin: const EdgeInsets.symmetric(vertical: 4),
                                                decoration: BoxDecoration(
                                                  gradient: LinearGradient(
                                                    begin: Alignment.topCenter,
                                                    end: Alignment.bottomCenter,
                                                    colors: [
                                                      _statusColor.withValues(alpha: 0.3),
                                                      _statusColor.withValues(alpha: 0.08),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                    12.width,
                                    // Section content
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            section.title,
                                            style: GoogleFonts.outfit(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                              letterSpacing: -0.3,
                                              color: isDarkMode.value ? Colors.white : primaryTextColor,
                                            ),
                                          ),
                                          12.height,
                                          section.child,
                                          20.height,
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }),
                        ),
                      ),
                      32.height,
                    ],
                  ),
                ),
              ),

              // Action Buttons
              if (_isPending || _isCancellable)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDarkMode.value ? surfaceElevatedDark : surfaceElevated,
                    boxShadow: [
                      BoxShadow(
                        color: isDarkMode.value ? softShadowColorDark : softShadowColor,
                        blurRadius: 16,
                        offset: const Offset(0, -4),
                      ),
                    ],
                  ),
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
                                gradient: const LinearGradient(colors: [gradientSecondaryStart, gradientSecondaryEnd]),
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: appColorSecondary.withValues(alpha: 0.3),
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
                          child: _CancelButton(
                            onTap: () => _showCancelDialog(context),
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

class _TimelineSection {
  final String title;
  final int index;
  final Widget child;

  _TimelineSection({
    required this.title,
    required this.index,
    required this.child,
  });
}

/// Cancel button with red glow on press
class _CancelButton extends StatefulWidget {
  final VoidCallback onTap;

  const _CancelButton({required this.onTap});

  @override
  State<_CancelButton> createState() => _CancelButtonState();
}

class _CancelButtonState extends State<_CancelButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: nurseStatusCancelledColor.withValues(alpha: _isPressed ? 0.18 : 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: nurseStatusCancelledColor.withValues(alpha: 0.3)),
          boxShadow: _isPressed
              ? [
                  BoxShadow(
                    color: nurseStatusCancelledColor.withValues(alpha: 0.25),
                    blurRadius: 12,
                    spreadRadius: 1,
                  ),
                ]
              : [],
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
    );
  }
}
