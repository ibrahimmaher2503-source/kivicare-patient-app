import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kivicare_patient/utils/app_common.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../components/app_scaffold.dart';
import '../../components/cached_image_widget.dart';
import '../../components/loader_widget.dart';
import '../../components/social_media_element.dart';
import '../../generated/assets.dart';
import '../../main.dart';
import '../../utils/colors.dart';
import '../../utils/common_base.dart';
import '../../utils/empty_error_state_widget.dart';
import 'components/doctor_detail_btm_comp.dart';
import 'doctor_detail_controller.dart';

class DoctorDetailScreen extends StatelessWidget {
  DoctorDetailScreen({super.key});

  final DoctorDetailController doctorDetailCont = Get.put(DoctorDetailController());

  @override
  Widget build(BuildContext context) {
    return AppScaffoldNew(
      appBartitleText: locale.value.doctorDetail,
      appBarVerticalSize: Get.height * 0.12,
      isLoading: doctorDetailCont.isLoading,
      body: RefreshIndicator(
        onRefresh: () {
          return doctorDetailCont.init(showLoader: false);
        },
        child: Obx(
          () => SnapHelperWidget(
            future: doctorDetailCont.getDoctorDetail.value,
            errorBuilder: (error) {
              return NoDataWidget(
                title: error,
                retryText: locale.value.reload,
                imageWidget: const ErrorStateWidget(),
                onRetry: () {
                  doctorDetailCont.init();
                },
              ).paddingSymmetric(horizontal: 16);
            },
            loadingWidget: const LoaderWidget(),
            onSuccess: (data) {
              return AnimatedScrollView(
                listAnimationType: ListAnimationType.FadeIn,
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  /// Hero image area with gradient overlay
                  Stack(
                    children: [
                      CachedImageWidget(
                        url: doctorDetailCont.doctorData.value.profileImage,
                        fit: BoxFit.cover,
                        width: Get.width,
                        height: Get.height * 0.35,
                      ),
                      // Bottom gradient overlay for smooth transition
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          height: 80,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                (isDarkMode.value ? surfaceElevatedDark : surfaceElevated).withValues(alpha: 0.8),
                                isDarkMode.value ? surfaceElevatedDark : surfaceElevated,
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  /// Doctor info card
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      color: isDarkMode.value ? surfaceElevatedDark : surfaceElevated,
                      boxShadow: [
                        BoxShadow(
                          color: isDarkMode.value ? softShadowColorDark : softShadowColor,
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                          spreadRadius: 0,
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: doctorDetailCont.doctorData.value.fullName.isNotEmpty ? MainAxisAlignment.spaceBetween : MainAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          doctorDetailCont.doctorData.value.fullName,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: GoogleFonts.outfit(
                                            fontSize: 20,
                                            fontWeight: FontWeight.w700,
                                            letterSpacing: -0.3,
                                            color: isDarkMode.value ? whiteTextColor : appColorPrimary,
                                          ),
                                        ),
                                        const CachedImageWidget(url: Assets.iconsIcVerified, width: 14, height: 14).paddingLeft(8),
                                      ],
                                    ).paddingRight(16).flexible().visible(doctorDetailCont.doctorData.value.fullName.isNotEmpty),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: isDarkMode.value ? appColorAccent.withValues(alpha: 0.12) : lightAccentColor,
                                        borderRadius: BorderRadius.circular(22),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const CachedImageWidget(
                                            url: Assets.iconsIcStarFilled,
                                            color: appColorAccent,
                                            height: 12,
                                          ),
                                          8.width,
                                          Text(
                                            doctorDetailCont.doctorData.value.averageRating.toString(),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: GoogleFonts.plusJakartaSans(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w700,
                                              color: isDarkMode.value ? whiteTextColor : appColorPrimary,
                                            ),
                                          ).paddingTop(2),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Text(
                                      doctorDetailCont.doctorData.value.expert,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color: appColorSecondary,
                                      ),
                                    ).flexible(),
                                  ],
                                ).paddingTop(8).visible(doctorDetailCont.doctorData.value.expert.isNotEmpty),
                              ],
                            ).flexible(),
                          ],
                        ),
                        Row(
                          children: [
                            Text(
                              locale.value.socialMedia,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                                color: secondaryTextColor,
                              ),
                            ),
                            12.width,
                            SocialMediaElement(
                              iconPath: Assets.socialMediaIcX,
                              onPressed: () {
                                commonLaunchUrl(doctorDetailCont.doctorData.value.twitterLink, launchMode: LaunchMode.externalApplication);
                              },
                            ).paddingRight(8).visible(doctorDetailCont.doctorData.value.twitterLink.isNotEmpty),
                            SocialMediaElement(
                              iconPath: Assets.socialMediaIcDribble,
                              onPressed: () {
                                commonLaunchUrl(doctorDetailCont.doctorData.value.dribbbleLink, launchMode: LaunchMode.externalApplication);
                              },
                            ).paddingRight(8).visible(doctorDetailCont.doctorData.value.dribbbleLink.isNotEmpty),
                            SocialMediaElement(
                              iconPath: Assets.socialMediaIcFb,
                              onPressed: () {
                                commonLaunchUrl(doctorDetailCont.doctorData.value.facebookLink, launchMode: LaunchMode.externalApplication);
                              },
                            ).paddingRight(8).visible(doctorDetailCont.doctorData.value.facebookLink.isNotEmpty),
                            SocialMediaElement(
                              iconPath: Assets.socialMediaIcInsta,
                              onPressed: () {
                                commonLaunchUrl(doctorDetailCont.doctorData.value.instagramLink, launchMode: LaunchMode.externalApplication);
                              },
                            ).visible(doctorDetailCont.doctorData.value.instagramLink.isNotEmpty),
                          ],
                        ).paddingTop(16).visible(
                              doctorDetailCont.doctorData.value.twitterLink.isNotEmpty ||
                                  doctorDetailCont.doctorData.value.dribbbleLink.isNotEmpty ||
                                  doctorDetailCont.doctorData.value.facebookLink.isNotEmpty ||
                                  doctorDetailCont.doctorData.value.instagramLink.isNotEmpty,
                            ),
                      ],
                    ),
                  ),
                  24.height,

                  /// About section
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ReadMoreText(
                        parseHtmlString(doctorDetailCont.doctorData.value.aboutSelf),
                        trimLines: 4,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: secondaryTextColor,
                          height: 1.6,
                        ),
                        colorClickableText: appColorSecondary,
                        trimMode: TrimMode.Line,
                        trimCollapsedText: " ...${locale.value.readMore}",
                        trimExpandedText: locale.value.readLess,
                        locale: Localizations.localeOf(context),
                      ).paddingBottom(16).visible(doctorDetailCont.doctorData.value.aboutSelf.isNotEmpty),
                      DoctorDetailBtmComp(doctorDetailCont: doctorDetailCont),
                      32.height,
                    ],
                  ).paddingSymmetric(horizontal: 16),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
