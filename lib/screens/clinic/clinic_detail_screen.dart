import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kivicare_patient/utils/app_common.dart';
import 'package:kivicare_patient/utils/common_base.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../components/app_scaffold.dart';
import '../../components/cached_image_widget.dart';
import '../../components/loader_widget.dart';
import '../../generated/assets.dart';
import '../../main.dart';
import '../../utils/colors.dart';
import '../../utils/empty_error_state_widget.dart';
import 'clinic_detail_controller.dart';
import 'components/clinic_detail_btm_comp.dart';

class ClinicDetailScreen extends StatelessWidget {
  ClinicDetailScreen({super.key});

  final ClinicDetailController clinicDetailCont = Get.put(ClinicDetailController());

  @override
  Widget build(BuildContext context) {
    return AppScaffoldNew(
      isLoading: clinicDetailCont.isLoading,
      appBartitleText: locale.value.clinicDetail,
      appBarVerticalSize: Get.height * 0.12,
      body: RefreshIndicator(
        onRefresh: () {
          return clinicDetailCont.init(showLoader: false);
        },
        child: Obx(
          () => SnapHelperWidget(
            future: clinicDetailCont.getClinicDetail.value,
            errorBuilder: (error) {
              return NoDataWidget(
                title: error,
                retryText: locale.value.reload,
                imageWidget: const ErrorStateWidget(),
                onRetry: () {
                  clinicDetailCont.init();
                },
              ).paddingSymmetric(horizontal: 16);
            },
            loadingWidget: const LoaderWidget(),
            onSuccess: (clinicDetailRes) {
              return AnimatedScrollView(
                listAnimationType: ListAnimationType.FadeIn,
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  /// Hero image with rounded bottom corners
                  Container(
                    decoration: BoxDecoration(
                      color: isDarkMode.value ? surfaceElevatedDark : surfaceElevated,
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(24),
                        bottomRight: Radius.circular(24),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: isDarkMode.value ? softShadowColorDark : softShadowColor,
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        ClipRRect(
                          borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(24),
                            bottomRight: Radius.circular(24),
                          ),
                          child: CachedImageWidget(
                            url: clinicDetailCont.clinicData.value.clinicImage,
                            fit: BoxFit.cover,
                            width: Get.width,
                            height: Get.height * 0.28,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              /// Pincode badge
                              if (clinicDetailCont.clinicData.value.pincode.isNotEmpty)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: isDarkMode.value ? appColorSecondary.withValues(alpha: 0.15) : lightSecondaryColor,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: RichText(
                                    text: TextSpan(children: [
                                      TextSpan(text: "${locale.value.pincode}: ", style: secondaryTextStyle(size: 11)),
                                      TextSpan(
                                        text: clinicDetailCont.clinicData.value.pincode,
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                          color: appColorSecondary,
                                        ),
                                      ),
                                    ]),
                                  ),
                                ),
                              if (clinicDetailCont.clinicData.value.pincode.isNotEmpty) 8.height,

                              /// Clinic name
                              if (clinicDetailCont.clinicData.value.name.isNotEmpty)
                                Text(
                                  clinicDetailCont.clinicData.value.name,
                                  style: GoogleFonts.outfit(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w700,
                                    color: isDarkMode.value ? Colors.white : appColorPrimary,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              12.height,

                              /// Address row
                              if (clinicDetailCont.clinicData.value.address.isNotEmpty)
                                GestureDetector(
                                  onTap: () {
                                    launchMap(clinicDetailCont.clinicData.value.address);
                                  },
                                  child: Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(6),
                                        decoration: BoxDecoration(
                                          color: isDarkMode.value ? appColorSecondary.withValues(alpha: 0.15) : lightSecondaryColor,
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: const CachedImageWidget(url: Assets.iconsIcLocation, color: appColorSecondary, height: 14, width: 14),
                                      ),
                                      12.width,
                                      Expanded(
                                        child: Text(
                                          "${clinicDetailCont.clinicData.value.cityName} ${clinicDetailCont.clinicData.value.stateName} ${clinicDetailCont.clinicData.value.countryName}",
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: GoogleFonts.plusJakartaSans(fontSize: 13, color: secondaryTextColor),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              if (clinicDetailCont.clinicData.value.address.isNotEmpty) 12.height,

                              /// Contact & Status row
                              Row(
                                children: [
                                  if (clinicDetailCont.clinicData.value.contactNumber.trim().isNotEmpty)
                                    Expanded(
                                      child: GestureDetector(
                                        onTap: () {
                                          launchCall(clinicDetailCont.clinicData.value.contactNumber);
                                        },
                                        child: Row(
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.all(6),
                                              decoration: BoxDecoration(
                                                color: isDarkMode.value ? appColorSecondary.withValues(alpha: 0.15) : lightSecondaryColor,
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                              child: const CachedImageWidget(url: Assets.iconsIcCall, color: appColorSecondary, height: 14, width: 14),
                                            ),
                                            8.width,
                                            Flexible(
                                              child: Text(
                                                clinicDetailCont.clinicData.value.contactNumber,
                                                style: GoogleFonts.plusJakartaSans(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w600,
                                                  color: appColorPrimary,
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: getClinicStatusLightColor(clinicStatus: clinicDetailCont.clinicData.value.clinicStatus.toLowerCase()),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      getClinicStatus(status: clinicDetailCont.clinicData.value.clinicStatus.toLowerCase()),
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.green.shade600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              /// Email row
                              if (clinicDetailCont.clinicData.value.email.isNotEmpty) ...[
                                8.height,
                                GestureDetector(
                                  onTap: () {
                                    launchMail(clinicDetailCont.clinicData.value.email);
                                  },
                                  child: Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(6),
                                        decoration: BoxDecoration(
                                          color: isDarkMode.value ? appColorSecondary.withValues(alpha: 0.15) : lightSecondaryColor,
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: const CachedImageWidget(url: Assets.iconsIcMail, color: appColorSecondary, height: 14, width: 14),
                                      ),
                                      8.width,
                                      Flexible(
                                        child: Text(
                                          clinicDetailCont.clinicData.value.email,
                                          style: GoogleFonts.plusJakartaSans(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                            color: appColorPrimary,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],

                              /// Stats tiles
                              16.height,
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildInfoTile(
                                      context,
                                      title: clinicDetailCont.clinicData.value.totalAppointment.toString(),
                                      subtitle: locale.value.totalAppointmentsDone,
                                      icon: Icons.check_circle_outline,
                                    ),
                                  ),
                                  8.width,
                                  Expanded(
                                    child: _buildInfoTile(
                                      context,
                                      title: clinicDetailCont.clinicData.value.satisfactionPercentage.toString(),
                                      subtitle: locale.value.satisfactionToCustomer,
                                      icon: Icons.emoji_emotions_outlined,
                                    ),
                                  ),
                                  8.width,
                                  Expanded(
                                    child: _buildInfoTile(
                                      context,
                                      title: clinicDetailCont.clinicData.value.totalDoctors.toString(),
                                      subtitle: locale.value.totalVerifiedPatients,
                                      icon: Icons.verified_user_sharp,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  /// Description section
                  if (clinicDetailCont.clinicData.value.description.isNotEmpty)
                    Container(
                      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isDarkMode.value ? surfaceElevatedDark : surfaceElevated,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: isDarkMode.value ? softShadowColorDark : softShadowColor,
                            blurRadius: 12,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            locale.value.clinicDetail,
                            style: GoogleFonts.outfit(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: isDarkMode.value ? Colors.white : appColorPrimary,
                            ),
                          ),
                          8.height,
                          ReadMoreText(
                            parseHtmlString("${clinicDetailCont.clinicData.value.description} "),
                            trimLines: 4,
                            style: GoogleFonts.plusJakartaSans(fontSize: 13, color: secondaryTextColor, height: 1.5),
                            colorClickableText: appColorSecondary,
                            trimMode: TrimMode.Line,
                            trimCollapsedText: " ...${locale.value.readMore}",
                            trimExpandedText: locale.value.readLess,
                            locale: Localizations.localeOf(context),
                          ),
                        ],
                      ),
                    ),

                  /// Bottom sections
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                    child: ClinicDetailBtmComp(clinicDetailCont: clinicDetailCont),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildInfoTile(BuildContext context, {required String title, required String subtitle, required IconData icon}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      decoration: BoxDecoration(
        color: isDarkMode.value ? surfaceElevatedDark.withValues(alpha: 0.7) : surfaceSubtle,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDarkMode.value ? glassStrokeDark : whiteBorderColor,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: isDarkMode.value ? appColorSecondary.withValues(alpha: 0.15) : lightSecondaryColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: appColorSecondary, size: 18),
          ),
          8.height,
          Text(
            title,
            style: GoogleFonts.outfit(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: isDarkMode.value ? Colors.white : appColorPrimary,
            ),
            maxLines: 1,
          ),
          4.height,
          Text(
            subtitle,
            style: GoogleFonts.plusJakartaSans(fontSize: 10, color: secondaryTextColor),
            maxLines: 2,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}