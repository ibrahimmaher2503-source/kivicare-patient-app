import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kivicare_patient/utils/colors.dart';
import 'package:kivicare_patient/utils/common_base.dart';
import 'package:nb_utils/nb_utils.dart';
import '../../api/core_apis.dart';
import '../../components/app_scaffold.dart';
import '../../components/cached_image_widget.dart';
import '../../main.dart';
import '../../network/network_utils.dart';
import '../../utils/constants.dart';
import '../auth/model/common_model.dart';
import 'components/incident_description_conponent.dart';
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

  @override
  Widget build(BuildContext context) {
    final statusName = incident.statusName.isNotEmpty
        ? incident.statusName
        : incident.incidenceTypeName;
    final normalizedStatus = statusName.toLowerCase();
    final status = incidentStatuses.firstWhere(
      (e) => normalizedStatus.contains(e.slug),
      orElse: () => CMNModel(slug: normalizedStatus),
    );
    return AppScaffoldNew(
      appBartitleText: "${locale.value.incident} #${incident.id}",
      hasLeadingWidget: true,
      appBarVerticalSize: Get.height * 0.12,
      body: AnimatedScrollView(
        physics: AlwaysScrollableScrollPhysics(),
        listAnimationType: ListAnimationType.Scale,
        fadeInConfiguration:
            FadeInConfiguration(duration: GetNumUtils(1).seconds),
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          16.height,
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('#${incident.id}',
                  style: boldTextStyle(color: context.primaryColor)),
              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)),
                color: normalizedStatus.contains('open')
                    ? context.primaryColor
                    : normalizedStatus.contains('closed')
                        ? Colors.green
                        : redTextColor,
                child: Text(
                  status.name,
                  style: primaryTextStyle(size: 14, color: Colors.white),
                ).paddingSymmetric(horizontal: 14, vertical: 5),
              ),
            ],
          ),
          8.height,
          Text(incident.createdAt.validate().dateInddMMMyyyyHHmmAmPmFormat,
              style: secondaryTextStyle()),
          IncidentDescriptionComponent(
              description: incident.description.validate(),
              title: incident.title.validate()),
          IncidentDescriptionComponent(
              description: incident.email.validate(),
              title: locale.value.email),
          IncidentDescriptionComponent(
              description: incident.phone.validate(),
              title: locale.value.phoneNumber),
          16.height,
          CachedImageWidget(
            url: incident.fileUrl.validate(),
            fit: BoxFit.cover,
            width: Get.width,
            height: 230,
            radius: defaultRadius,
          ),
          16.height,
          Container(
            decoration: boxDecorationWithRoundedCorners(
              backgroundColor: context.cardColor, // dark card color
              borderRadius: radius(12),
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
                                style: secondaryTextStyle(size: 12),
                                children: [
                                  TextSpan(text: "${locale.value.createdBy} "),
                                  TextSpan(
                                      text: incident.name,
                                      style: boldTextStyle(size: 14)),
                                  TextSpan(
                                      text:
                                          " ${locale.value.createdOn} ${incident.createdAt.dateInddMMMyyyyHHmmAmPmFormat}"),
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
                    Text(locale.value.reply,
                        style:
                            boldTextStyle(size: 14, color: secondaryTextColor)),
                    8.height,
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: context.scaffoldBackgroundColor,
                        borderRadius: radius(10),
                      ),
                      child: Text(
                        incident.reply.validate(),
                        style: secondaryTextStyle(size: 13),
                      ),
                    ),
                  ],
                  AppButton(
                    width: double.infinity,
                    elevation: 0,
                    text: locale.value.markAsClosed,
                    textColor: Colors.white,
                    color: context.primaryColor,
                    shapeBorder:
                        RoundedRectangleBorder(borderRadius: radius(12)),
                    onTap: onMarkClosed,
                  ).paddingTop(16).visible(!isClosed && !isRejected),
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
    await CoreServiceApis.updateIncidentStatus(
            incidentId: incident.id, request: request)
        .then((res) {
      toast(
          sanitizeBackendMessage(res.message, locale.value.somethingWentWrong));
      incidentController.incidencePage(1);
      incidentController.getIncidents();
      Get.back();
    }).catchError((e) {
      toast(sanitizeBackendMessage(e, locale.value.somethingWentWrong));
    }).whenComplete(() {
      incidentController.isLoading(false);
    });
  }
}
