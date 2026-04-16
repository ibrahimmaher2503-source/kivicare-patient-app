import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kivicare_patient/configs.dart';
import 'package:kivicare_patient/screens/incident_management/incident_management_list_screen.dart';
import 'package:kivicare_patient/utils/price_widget.dart';
import 'package:nb_utils/nb_utils.dart';
import '../../../components/app_scaffold.dart';
import '../../../generated/assets.dart';
import '../../../main.dart';
import '../../Encounter/all_encounters_screen.dart';
import '../../other_patient/manage_other_patient_screen.dart';
import 'common_horizontal_profile_widget.dart';
import 'edit_user_profile_controller.dart';
import 'patient_wallet_history_screen.dart';
import 'profile_controller.dart';
import '../../../utils/app_common.dart';
import '../../../utils/colors.dart';
import '../../../utils/common_base.dart';
import '../other/settings_screen.dart';
import '../other/about_us_screen.dart';
import 'edit_user_profile.dart';
import 'package:url_launcher/url_launcher.dart';

class ProfileScreen extends StatelessWidget {
  ProfileScreen({super.key});

  final ProfileController profileController = Get.put(ProfileController());

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => AppScaffoldNew(
        appBartitleText: locale.value.profile,
        hasLeadingWidget: false,
        isLoading: profileController.isLoading,
        appBarVerticalSize: Get.height * 0.12,
        body: AnimatedScrollView(
          padding: const EdgeInsets.only(top: 16, bottom: 80),
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Profile Header Card
                Obx(
                  () => ProfilePicHorizotalWidget(
                    heroTag: loginUserData.value.profileImage,
                    profileImage: loginUserData.value.profileImage,
                    firstName: loginUserData.value.firstName,
                    lastName: loginUserData.value.lastName,
                    userName: loginUserData.value.userName,
                    subInfo: loginUserData.value.email,
                    onCameraTap: () {
                      EditUserProfileController editUserProfileController = EditUserProfileController(isProfilePhoto: true);
                      editUserProfileController.showBottomSheet(context);
                    },
                  ).onTap(() {
                    Get.to(() => EditUserProfileScreen(), duration: const Duration(milliseconds: 800));
                  }),
                ),

                // Wallet Balance Card with gradient
                24.height,
                Obx(() => _buildWalletCard(context)),

                // Account Section
                24.height,
                _buildSectionHeader(context, locale.value.editProfile),
                8.height,
                _buildGroupedCard(context, [
                  _buildSettingTile(
                    context,
                    title: locale.value.editProfile,
                    subtitle: locale.value.personalizeYourProfile,
                    iconPath: Assets.iconsIcEditprofileOutlined,
                    onTap: () {
                      Get.to(() => EditUserProfileScreen(), duration: const Duration(milliseconds: 800));
                    },
                  ),
                  _buildSubtleDivider(context),
                  _buildSettingTile(
                    context,
                    title: locale.value.otherPatient,
                    subtitle: locale.value.manageOtherPatient,
                    iconPath: Assets.iconsIcUsersThreeprofile,
                    onTap: () {
                      Get.to(() => ManageOtherPatientScreen(), duration: const Duration(milliseconds: 800));
                    },
                  ),
                ]),

                // Health Records Section
                24.height,
                _buildSectionHeader(context, locale.value.encounters),
                8.height,
                _buildGroupedCard(context, [
                  _buildSettingTile(
                    context,
                    title: locale.value.encounters,
                    subtitle: locale.value.seeYourEncounterData,
                    iconPath: Assets.iconsIcEncounter,
                    iconColor: appColorPrimary,
                    onTap: () {
                      Get.to(() => AllEncountersScreen());
                    },
                  ),
                  _buildSubtleDivider(context),
                  _buildSettingTile(
                    context,
                    title: locale.value.incidentManagement,
                    subtitle: locale.value.requestHelpForAnyMistakeHappen,
                    iconPath: Assets.iconsIcIncidentLock,
                    iconColor: appColorPrimary,
                    onTap: () {
                      Get.to(() => IncidentManagementListScreen());
                    },
                  ),
                ]),

                // Preferences Section
                24.height,
                _buildSectionHeader(context, locale.value.settings),
                8.height,
                _buildGroupedCard(context, [
                  _buildSettingTile(
                    context,
                    title: locale.value.settings,
                    subtitle: "${locale.value.changePassword}, ${locale.value.themeAndMore}",
                    iconPath: Assets.iconsIcSetting,
                    onTap: () {
                      Get.to(() => SettingScreen());
                    },
                  ),
                  _buildSubtleDivider(context),
                  _buildSettingTile(
                    context,
                    title: locale.value.aboutApp,
                    subtitle: locale.value.privacyPolicyTerms,
                    iconPath: Assets.iconsIcInfo,
                    onTap: () {
                      Get.to(() => const AboutScreen());
                    },
                  ),
                ]),

                // Support Section
                24.height,
                _buildSectionHeader(context, locale.value.contactUs),
                8.height,
                _buildGroupedCard(context, [
                  _buildSettingTile(
                    context,
                    title: locale.value.contactUs,
                    subtitle: locale.value.getInTouchWithSupport,
                    iconPath: Assets.iconsIcContactUs,
                    onTap: () {
                      commonLaunchUrl('$DOMAIN_URL/contact-us', launchMode: LaunchMode.externalApplication);
                    },
                  ),
                  _buildSubtleDivider(context),
                  _buildSettingTile(
                    context,
                    title: locale.value.rateApp,
                    subtitle: locale.value.showSomeLoveShare,
                    iconPath: Assets.iconsIcStar,
                    showTrailing: false,
                    onTap: () async {
                      handleRate();
                    },
                  ),
                ]),

                // Logout
                24.height,
                _buildLogoutButton(context),

                32.height,
                VersionInfoWidget(prefixText: '${locale.value.version}  ', textStyle: primaryTextStyle(color: secondaryTextColor)).center(),
                32.height,
              ],
            ).paddingSymmetric(horizontal: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildWalletCard(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Get.to(() => PatientWalletHistory());
      },
      child: Container(
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
              color: gradientStart.withValues(alpha: 0.3),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: commonLeadingWid(imgPath: Assets.iconsIcUnFillWallet, color: Colors.white, size: 22),
            ),
            16.width,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    locale.value.walletBalance,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      color: Colors.white.withValues(alpha: 0.8),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  4.height,
                  PriceWidget(
                    price: userWalletData.value.walletAmount,
                    color: Colors.white,
                    size: 22,
                    isBoldText: true,
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 16,
              color: Colors.white.withValues(alpha: 0.6),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(left: 4),
        child: Text(
          title.toUpperCase(),
          style: GoogleFonts.plusJakartaSans(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: secondaryTextColor,
            letterSpacing: 1.2,
          ),
        ),
      ),
    );
  }

  Widget _buildGroupedCard(BuildContext context, List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: isDarkMode.value ? surfaceElevatedDark : surfaceElevated,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: isDarkMode.value ? softShadowColorDark : softShadowColor,
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: children,
      ),
    );
  }

  Widget _buildSubtleDivider(BuildContext context) {
    return Divider(
      height: 1,
      thickness: 0.5,
      indent: 64,
      color: isDarkMode.value ? borderColor.withValues(alpha: 0.08) : borderColor.withValues(alpha: 0.2),
    );
  }

  Widget _buildSettingTile(
    BuildContext context, {
    required String title,
    String? subtitle,
    required String iconPath,
    Color? iconColor,
    bool showTrailing = true,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
          child: Row(
            children: [
              commonLeadingWid(imgPath: iconPath, color: iconColor).circularLightPrimaryBg(),
              16.width,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: boldTextStyle(size: 14)),
                    if (subtitle != null && subtitle.isNotEmpty) ...[
                      2.height,
                      Text(
                        subtitle,
                        style: secondaryTextStyle(size: 12),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              if (showTrailing)
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 14,
                  color: isDarkMode.value ? Colors.white38 : secondaryTextColor.withValues(alpha: 0.5),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isDarkMode.value ? surfaceElevatedDark : surfaceElevated,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: isDarkMode.value ? softShadowColorDark : softShadowColor,
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            showConfirmDialogCustom(
              primaryColor: appColorPrimary,
              context,
              negativeText: locale.value.cancel,
              positiveText: locale.value.logout,
              onAccept: (_) {
                profileController.handleLogout();
              },
              dialogType: DialogType.CONFIRMATION,
              subTitle: locale.value.doYouWantToLogout,
              title: locale.value.ohNoYouAreLeaving,
            );
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
            child: Row(
              children: [
                commonLeadingWid(imgPath: Assets.iconsIcLogout, color: cancelStatusColor).circularLightPrimaryBg(
                  color: isDarkMode.value ? cancelStatusColor.withValues(alpha: 0.15) : cancelStatusColor.withValues(alpha: 0.08),
                ),
                16.width,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(locale.value.logout, style: boldTextStyle(size: 14, color: cancelStatusColor)),
                      2.height,
                      Text(
                        locale.value.securelyLogOutOfAccount,
                        style: secondaryTextStyle(size: 12),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
