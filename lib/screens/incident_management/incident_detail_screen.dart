import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kivicare_patient/utils/colors.dart';
import 'package:kivicare_patient/utils/common_base.dart';
import 'package:nb_utils/nb_utils.dart';
import '../../api/core_apis.dart';
import '../../components/app_scaffold.dart';
import '../../components/cached_image_widget.dart';
import '../../main.dart';
import '../../utils/app_common.dart';
import '../../utils/constants.dart';
import '../auth/model/common_model.dart';
import 'components/incident_description_component.dart';
import 'incident_management_controller.dart';
import 'model/incident_response_model.dart';

class IncidentDetailScreen extends StatelessWidget {
  final Incident incident;
  final bool isClosed;
  final bool isRejected;

  const IncidentDetailScreen({
    super.key,
    required this.incident,
    required this.incidentController,
    required this.isClosed,
    required this.isRejected,
  });

  final IncidentManagement incidentController;

  Color get _statusColor {
    final typeName = incident.incidenceTypeName.toLowerCase();
    if (typeName == 'open') return confirmedStatusColor;
    if (typeName == 'closed') return completedStatusColor;
    return cancelStatusColor;
  }

  String get _statusLabel {
    return incidentStatuses
        .firstWhere(
          (e) => incident.incidenceTypeName.toLowerCase().contains(e.slug),
          orElse: () => CMNModel(slug: incident.incidenceTypeName.toLowerCase()),
        )
        .name;
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffoldNew(
      appBartitleText: "${locale.value.incident} #${incident.id}",
      hasLeadingWidget: true,
      appBarVerticalSize: Get.height * 0.12,
      body: AnimatedScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        listAnimationType: ListAnimationType.Scale,
        fadeInConfiguration: FadeInConfiguration(duration: GetNumUtils(1).seconds),
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          16.height,
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '#${incident.id}',
                style: GoogleFonts.outfit(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.3,
                  color: appColorSecondary,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  gradient: LinearGradient(
                    colors: [
                      _statusColor.withValues(alpha: 0.15),
                      _statusColor.withValues(alpha: 0.08),
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
                        color: _statusColor,
                      ),
                    ),
                    6.width,
                    Text(
                      _statusLabel,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.1,
                        color: _statusColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          8.height,
          Text(
            incident.createdAt.validate().dateInddMMMyyyyHHmmAmPmFormat,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              letterSpacing: 0.1,
              color: secondaryTextColor,
            ),
          ),
          IncidentDescriptionComponent(description: incident.description.validate(), title: incident.title.validate()),
          IncidentDescriptionComponent(description: incident.email.validate(), title: locale.value.email),
          IncidentDescriptionComponent(description: incident.phone.validate(), title: locale.value.phoneNumber),
          16.height,
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: CachedImageWidget(
              url: incident.fileUrl.validate(),
              fit: BoxFit.cover,
              width: Get.width,
              height: 230,
              radius: 16,
            ),
          ),
          16.height,
          Container(
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
            padding: const EdgeInsets.all(16),
            child: Obx(() {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text.rich(
                              TextSpan(
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 12,
                                  letterSpacing: 0.1,
                                  color: secondaryTextColor,
                                ),
                                children: [
                                  TextSpan(text: "${locale.value.createdBy} "),
                                  TextSpan(
                                    text: incident.name,
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 0.1,
                                      color: isDarkMode.value ? Colors.white : primaryTextColor,
                                    ),
                                  ),
                                  TextSpan(text: " on ${incident.createdAt.dateInddMMMyyyyHHmmAmPmFormat}"),
                                ],
                              ),
                            ),
                            12.height,
                          ],
                        ),
                      ),
                    ],
                  ),
                  if (incident.reply.validate().isNotEmpty) ...[
                    Text(
                      locale.value.reply,
                      style: GoogleFonts.outfit(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        letterSpacing: -0.3,
                        color: secondaryTextColor,
                      ),
                    ),
                    8.height,
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isDarkMode.value ? inputFillColorDark : inputFillColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        incident.reply.validate(),
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          letterSpacing: 0.1,
                          color: secondaryTextColor,
                        ),
                      ),
                    ),
                  ],
                  16.height,
                  GestureDetector(
                    onTap: onMarkClosed,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: [gradientSecondaryStart, gradientSecondaryEnd]),
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
                        locale.value.markAsClosed,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.1,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ).visible(!isClosed && !isRejected),
                ],
              );
            }),
          ),
        ],
      ).paddingSymmetric(horizontal: 16),
    );
  }

  Future<void> onMarkClosed() async {
    final request = {
      "incident_type": 2, // 2 is the ID for "Closed"
    };
    incidentController.isLoading(true);
    await CoreServiceApis.updateIncidentStatus(incidentId: incident.id, request: request).then((res) {
      toast(res.message);
      incidentController.incidencePage(1);
      incidentController.getIncidents();
      Get.back();
    }).catchError((e) {
      toast(e.toString());
    }).whenComplete(() {
      incidentController.isLoading(false);
    });
  }
}
