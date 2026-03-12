import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:nb_utils/nb_utils.dart';

import '../../../components/cached_image_widget.dart';
import '../../../generated/assets.dart';
import '../../../main.dart';
import '../../../utils/app_common.dart';
import '../../../utils/colors.dart';
import '../../../utils/common_base.dart';
import '../clinic_detail_screen.dart';
import '../model/clinics_res_model.dart';
import '../../service/service_list_controller.dart';

class PopularClinicCard extends StatelessWidget {
  final Clinic clinicElement;
  final double? width;

  const PopularClinicCard({super.key, required this.clinicElement, this.width});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: isDarkMode.value ? softShadowColorDark : softShadowColor,
            blurRadius: 20,
            offset: const Offset(0, 6),
            spreadRadius: 0,
          ),
        ],
      ),
      width: width ?? Get.width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
                child: CachedImageWidget(
                  url: clinicElement.clinicImage,
                  width: Get.width,
                  fit: BoxFit.cover,
                  height: Get.height * 0.24,
                ),
              ).onTap((){
                currentSelectedClinic(clinicElement);
                Get.delete<ServiceListController>();
                Get.to(() => ClinicDetailScreen(), arguments: clinicElement);
              }),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    clinicElement.name,
                    style: boldTextStyle(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ).expand(),
                ],
              ).paddingTop(16),
              GestureDetector(
                onTap: () {
                  launchMap(clinicElement.address);
                },
                behavior: HitTestBehavior.translucent,
                child: Row(
                  children: [
                    CachedImageWidget(url: Assets.iconsIcLocation, color: iconColor, width: 16, height: 16),
                    12.width,
                    Text(
                      clinicElement.address,
                      style: secondaryTextStyle(),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ).expand(),
                  ],
                ),
              ).paddingTop(12),
              Row(
                children: [
                  GestureDetector(
                    onTap: () {},
                    behavior: HitTestBehavior.translucent,
                    child: Row(
                      children: [
                        const CachedImageWidget(url: Assets.iconsIcCall, color: iconColor, width: 14, height: 14),
                        12.width,
                        GestureDetector(onTap: (){
                          launchCall(clinicElement.contactNumber);
                        },child: Text(clinicElement.contactNumber, style: primaryTextStyle(color: appColorPrimary))),
                        Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                          decoration: boxDecorationDefault(
                            color: getClinicStatusLightColor(clinicStatus: clinicElement.clinicStatus.toLowerCase()),
                            borderRadius: radius(22),
                          ),
                          child: Text(
                            getClinicStatus(status: clinicElement.clinicStatus.toLowerCase()),
                            style: boldTextStyle(size: 10, color: getClinicStatusColor(clinicStatus: clinicElement.clinicStatus.toLowerCase())),
                          ),
                        )
                      ],
                    ),
                  ).expand(),
                ],
              ).paddingTop(8),
              GestureDetector(
                onTap: () {
                  currentSelectedClinic(clinicElement);
                  Get.delete<ServiceListController>();
                  Get.to(() => ClinicDetailScreen(), arguments: clinicElement);
                },
                behavior: HitTestBehavior.translucent,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: appColorSecondary.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(locale.value.viewDetail, style: boldTextStyle(color: appColorSecondary, size: 12)),
                      4.width,
                      Icon(Icons.arrow_forward_ios_rounded, size: 11, color: appColorSecondary),
                    ],
                  ),
                ),
              ),
              12.height,
            ],
          ).paddingSymmetric(horizontal: 16),
        ],
      ),
    );
  }
}