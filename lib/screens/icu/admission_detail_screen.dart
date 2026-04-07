import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../api/core_apis.dart';
import '../../components/app_scaffold.dart';
import '../../components/loader_widget.dart';
import '../../main.dart';
import '../../utils/app_common.dart';
import '../../utils/colors.dart';
import '../../utils/constants.dart';
import 'model/icu_admission_model.dart';

class AdmissionDetailScreen extends StatefulWidget {
  final IcuAdmissionRequest? requestData;
  final int? requestId;

  const AdmissionDetailScreen({
    super.key,
    this.requestData,
    this.requestId,
  });

  @override
  State<AdmissionDetailScreen> createState() => _AdmissionDetailScreenState();
}

class _AdmissionDetailScreenState extends State<AdmissionDetailScreen>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  final RxBool isLoading = false.obs;
  late final AnimationController _borderController;

  late Rx<IcuAdmissionRequest?> _requestData;

  IcuAdmissionRequest? get requestData => _requestData.value;

  Color get _statusColor {
    switch (requestData?.status.toLowerCase() ?? '') {
      case IcuAdmissionStatusConst.pending:
        return icuStatusPendingColor;
      case IcuAdmissionStatusConst.accepted:
        return icuStatusAcceptedColor;
      case IcuAdmissionStatusConst.rejected:
        return icuStatusRejectedColor;
      case IcuAdmissionStatusConst.infoRequested:
        return icuStatusInfoRequestedColor;
      case IcuAdmissionStatusConst.cancelled:
        return icuStatusCancelledColor;
      default:
        return icuStatusPendingColor;
    }
  }

  String get _statusLabel {
    switch (requestData?.status.toLowerCase() ?? '') {
      case IcuAdmissionStatusConst.pending:
        return locale.value.pending;
      case IcuAdmissionStatusConst.accepted:
        return locale.value.acceptedLabel;
      case IcuAdmissionStatusConst.rejected:
        return locale.value.rejectedLabel;
      case IcuAdmissionStatusConst.infoRequested:
        return locale.value.infoRequestedLabel;
      case IcuAdmissionStatusConst.cancelled:
        return locale.value.cancelled;
      default:
        return requestData?.status ?? '';
    }
  }

  Color get _urgencyColor {
    switch (requestData?.urgency.toLowerCase() ?? '') {
      case IcuUrgencyConst.critical:
        return urgencyCriticalColor;
      case IcuUrgencyConst.urgent:
        return urgencyUrgentColor;
      case IcuUrgencyConst.standard:
        return urgencyStandardColor;
      default:
        return urgencyStandardColor;
    }
  }

  String get _urgencyLabel {
    switch (requestData?.urgency.toLowerCase() ?? '') {
      case IcuUrgencyConst.critical:
        return locale.value.criticalLabel;
      case IcuUrgencyConst.urgent:
        return locale.value.urgentLabel;
      case IcuUrgencyConst.standard:
        return locale.value.standardLabel;
      default:
        return requestData?.urgency ?? '';
    }
  }

  bool get _isPending => requestData?.status.toLowerCase() == IcuAdmissionStatusConst.pending;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _borderController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    )..repeat();

    _requestData = Rx<IcuAdmissionRequest?>(widget.requestData);

    if (widget.requestData == null && widget.requestId != null) {
      _fetchDetail();
    }
  }

  Future<void> _fetchDetail() async {
    isLoading(true);
    final id = widget.requestId ?? widget.requestData?.id ?? -1;
    if (id == -1) return;
    await CoreServiceApis.getIcuAdmissionDetail(admissionId: id).then((res) {
      _requestData(res);
    }).catchError((e) {
      toast(locale.value.somethingWentWrong);
    }).whenComplete(() => isLoading(false));
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      _borderController.stop();
    } else if (state == AppLifecycleState.resumed) {
      _borderController.repeat();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _borderController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (requestData == null) {
        return AppScaffoldNew(
          appBartitleText: locale.value.admissionRequestDetails,
          hasLeadingWidget: true,
          appBarVerticalSize: Get.height * 0.12,
          body: const Center(child: LoaderWidget()),
        );
      }

      // Build timeline sections
      final List<_TimelineSection> sections = [];
      int sectionIndex = 0;

      // Patient Information section
      if (requestData!.patientInfo != null) {
        final pi = requestData!.patientInfo!;
        final children = <Widget>[];
        if (pi.patientName.isNotEmpty) children.add(_buildInfoRow(locale.value.patientName, pi.patientName));
        if (pi.patientAge > 0) children.add(_buildInfoRow(locale.value.patientAge, pi.patientAge.toString()));
        if (pi.patientGender.isNotEmpty) children.add(_buildInfoRow(locale.value.patientGender, pi.patientGender.capitalizeFirstLetter()));
        if (pi.nationalId.isNotEmpty) children.add(_buildInfoRow(locale.value.nationalId, pi.nationalId));
        if (pi.insuranceNumber.isNotEmpty) children.add(_buildInfoRow(locale.value.insuranceNumberLabel, pi.insuranceNumber));

        if (children.isNotEmpty) {
          sections.add(_TimelineSection(
            title: locale.value.patientInformation,
            index: sectionIndex++,
            child: _buildInfoContainer(children: children),
          ));
        }
      }

      // Case Details section
      if (requestData!.caseDetails != null) {
        final cd = requestData!.caseDetails!;
        final children = <Widget>[];
        if (cd.medicalCondition.isNotEmpty) children.add(_buildInfoRow(locale.value.medicalCondition, cd.medicalCondition));
        if (cd.diagnosis.isNotEmpty) children.add(_buildInfoRow(locale.value.diagnosisLabel, cd.diagnosis));
        if (cd.caseType.isNotEmpty) children.add(_buildInfoRow(locale.value.caseTypeLabel, cd.caseType.replaceAll('_', ' ').capitalizeFirstLetter()));
        children.add(_buildBoolRow(locale.value.needsVentilator, cd.needsVentilator));
        children.add(_buildBoolRow(locale.value.needsOxygen, cd.needsOxygen));
        children.add(_buildBoolRow(locale.value.needsAmbulance, cd.needsAmbulance));
        if (cd.currentLocation.isNotEmpty) children.add(_buildInfoRow(locale.value.currentLocationLabel, cd.currentLocation));

        if (children.isNotEmpty) {
          sections.add(_TimelineSection(
            title: locale.value.caseDetailsLabel,
            index: sectionIndex++,
            child: _buildInfoContainer(children: children),
          ));
        }
      }

      // Emergency Contact section
      if (requestData!.contact != null) {
        final ct = requestData!.contact!;
        final children = <Widget>[];
        if (ct.contactName.isNotEmpty) children.add(_buildInfoRow(locale.value.contactNameLabel, ct.contactName));
        if (ct.contactPhone.isNotEmpty) children.add(_buildInfoRow(locale.value.contactPhoneLabel, ct.contactPhone));
        if (ct.relationshipToPatient.isNotEmpty) children.add(_buildInfoRow(locale.value.relationshipLabel, ct.relationshipToPatient.capitalizeFirstLetter()));

        if (children.isNotEmpty) {
          sections.add(_TimelineSection(
            title: locale.value.emergencyContact,
            index: sectionIndex++,
            child: _buildInfoContainer(children: children),
          ));
        }
      }

      // Hospital & Department section
      if (requestData!.hospital != null || requestData!.icuDepartment != null) {
        final children = <Widget>[];
        if (requestData!.hospital != null && requestData!.hospital!.name.isNotEmpty) {
          children.add(_buildInfoRow(locale.value.hospitals, requestData!.hospital!.name));
        }
        if (requestData!.icuDepartment != null) {
          final dept = requestData!.icuDepartment!;
          if (dept.name.isNotEmpty) children.add(_buildInfoRow(locale.value.icuDepartments, dept.name));
          if (dept.specialtyType.isNotEmpty) children.add(_buildInfoRow(locale.value.specialization, dept.specialtyType.replaceAll('_', ' ').capitalizeFirstLetter()));
        }

        if (children.isNotEmpty) {
          sections.add(_TimelineSection(
            title: locale.value.hospitalDetails,
            index: sectionIndex++,
            child: _buildInfoContainer(children: children),
          ));
        }
      }

      // Payment section
      if (requestData!.paymentMethod.isNotEmpty || requestData!.insuranceProvider.isNotEmpty) {
        final children = <Widget>[];
        if (requestData!.paymentMethod.isNotEmpty) {
          children.add(_buildInfoRow(locale.value.paymentMethodLabel, requestData!.paymentMethod.capitalizeFirstLetter()));
        }
        if (requestData!.insuranceProvider.isNotEmpty) {
          children.add(_buildInfoRow(locale.value.insuranceProviderLabel, requestData!.insuranceProvider));
        }

        if (children.isNotEmpty) {
          sections.add(_TimelineSection(
            title: locale.value.paymentInformation,
            index: sectionIndex++,
            child: _buildInfoContainer(children: children),
          ));
        }
      }

      // Admin Response section (only if data exists)
      if (requestData!.adminNotes.isNotEmpty || requestData!.rejectionReason.isNotEmpty || requestData!.responseDate.isNotEmpty) {
        final children = <Widget>[];
        if (requestData!.adminNotes.isNotEmpty) {
          children.add(_buildInfoRow(locale.value.adminNotes, requestData!.adminNotes));
        }
        if (requestData!.rejectionReason.isNotEmpty) {
          children.add(_buildRejectionRow(requestData!.rejectionReason));
        }
        if (requestData!.responseDate.isNotEmpty) {
          children.add(_buildInfoRow(locale.value.submit, _formatDate(requestData!.responseDate)));
        }

        if (children.isNotEmpty) {
          sections.add(_TimelineSection(
            title: locale.value.adminNotes,
            index: sectionIndex++,
            child: requestData!.rejectionReason.isNotEmpty && requestData!.adminNotes.isEmpty
                ? Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: icuStatusRejectedColor.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: icuStatusRejectedColor.withValues(alpha: 0.2)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: children,
                    ),
                  )
                : _buildInfoContainer(children: children),
          ));
        }
      }

      // Medical Reports section
      if (requestData!.medicalReports.isNotEmpty) {
        sections.add(_TimelineSection(
          title: locale.value.medicalReportsLabel,
          index: sectionIndex++,
          child: _buildMedicalReportsSection(requestData!.medicalReports),
        ));
      }

      // Timestamps
      if (requestData!.createdAt.isNotEmpty) {
        sections.add(_TimelineSection(
          title: locale.value.requestNumberLabel,
          index: sectionIndex++,
          child: _buildInfoContainer(
            children: [
              _buildInfoRow(locale.value.requestNumberLabel, requestData!.requestNumber),
              _buildInfoRow(locale.value.submit, _formatDate(requestData!.createdAt)),
            ],
          ),
        ));
      }

      return AppScaffoldNew(
        appBartitleText: requestData!.requestNumber.isNotEmpty ? requestData!.requestNumber : '#${requestData!.id}',
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
                        // Gradient Header with status + urgency badges
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
                                requestData!.requestNumber.isNotEmpty ? requestData!.requestNumber : '#${requestData!.id}',
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
                              10.height,
                              // Urgency badge
                              if (requestData!.urgency.isNotEmpty)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20),
                                    gradient: LinearGradient(
                                      colors: [
                                        _urgencyColor.withValues(alpha: 0.15),
                                        _urgencyColor.withValues(alpha: 0.08),
                                      ],
                                    ),
                                    border: Border.all(
                                      color: _urgencyColor.withValues(alpha: 0.2),
                                      width: 1,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.priority_high_rounded, size: 14, color: _urgencyColor),
                                      4.width,
                                      Text(
                                        _urgencyLabel,
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w700,
                                          letterSpacing: 0.2,
                                          color: _urgencyColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              if (requestData!.createdAt.isNotEmpty) ...[
                                10.height,
                                Text(
                                  _formatDate(requestData!.createdAt),
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

                // Action Buttons - Cancel only when pending
                if (_isPending)
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
    });
  }

  String _formatDate(String rawDate) {
    final parsed = DateTime.tryParse(rawDate);
    if (parsed == null) return rawDate;
    return DateFormat(DateFormatConst.D_MMMM_yyyy).format(parsed.toLocal());
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
                  _cancelRequest(reasonController.text.trim());
                }
              },
              child: Text(
                locale.value.confirm,
                style: GoogleFonts.plusJakartaSans(color: icuStatusRejectedColor, fontWeight: FontWeight.w700),
              ),
            ),
          ],
        );
      },
    ).then((_) => reasonController.dispose());
  }

  Future<void> _cancelRequest(String reason) async {
    isLoading(true);
    final request = <String, dynamic>{
      'cancellation_reason': reason,
    };
    final id = requestData?.id ?? -1;
    await CoreServiceApis.cancelIcuAdmission(admissionId: id, request: request).then((res) {
      toast(locale.value.admissionCancelled);
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

  Widget _buildBoolRow(String label, bool value) {
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
          Icon(
            value ? Icons.check_circle_rounded : Icons.cancel_rounded,
            size: 20,
            color: value ? const Color(0xFF4CAF50) : icuStatusRejectedColor,
          ),
          6.width,
          Text(
            value ? locale.value.yes : locale.value.no,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.1,
              color: value ? const Color(0xFF4CAF50) : icuStatusRejectedColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRejectionRow(String reason) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: icuStatusRejectedColor.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: icuStatusRejectedColor.withValues(alpha: 0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              locale.value.rejectedLabel,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.1,
                color: icuStatusRejectedColor,
              ),
            ),
            6.height,
            Text(
              reason,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                letterSpacing: 0.1,
                color: icuStatusRejectedColor,
                height: 1.6,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMedicalReportsSection(List<MedicalReport> reports) {
    return _buildInfoContainer(
      children: reports.map((report) {
        return GestureDetector(
          onTap: () async {
            if (report.url.isNotEmpty) {
              final uri = Uri.tryParse(report.url);
              if (uri != null) {
                await launchUrl(uri, mode: LaunchMode.externalApplication);
              }
            }
          },
          child: Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    gradient: LinearGradient(
                      colors: [
                        appColorSecondary.withValues(alpha: 0.15),
                        appColorAccent.withValues(alpha: 0.08),
                      ],
                    ),
                  ),
                  child: const Center(
                    child: Icon(Icons.description_outlined, size: 20, color: appColorSecondary),
                  ),
                ),
                12.width,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        report.name.isNotEmpty ? report.name : locale.value.medicalReportsLabel,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.1,
                          color: isDarkMode.value ? Colors.white : primaryTextColor,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (report.size > 0)
                        Text(
                          _formatFileSize(report.size),
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            letterSpacing: 0.1,
                            color: secondaryTextColor,
                          ),
                        ),
                    ],
                  ),
                ),
                if (report.url.isNotEmpty)
                  Icon(
                    Icons.open_in_new_rounded,
                    size: 18,
                    color: appColorSecondary,
                  ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1048576) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / 1048576).toStringAsFixed(1)} MB';
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
          color: icuStatusRejectedColor.withValues(alpha: _isPressed ? 0.18 : 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: icuStatusRejectedColor.withValues(alpha: 0.3)),
          boxShadow: _isPressed
              ? [
                  BoxShadow(
                    color: icuStatusRejectedColor.withValues(alpha: 0.25),
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
            color: icuStatusRejectedColor,
          ),
        ),
      ),
    );
  }
}
