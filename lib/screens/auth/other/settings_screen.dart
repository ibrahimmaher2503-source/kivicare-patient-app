// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kivicare_patient/configs.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:kivicare_patient/utils/colors.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../components/app_scaffold.dart';
import '../../../components/cached_image_widget.dart';
import '../../../generated/assets.dart';
import '../../../utils/app_common.dart';
import '../model/theme_mode_data_model.dart';
import 'settings_controller.dart';
import '../../../locale/app_localizations.dart';
import '../../../locale/languages.dart';
import '../../../main.dart';
import '../../../utils/common_base.dart';
import '../../../utils/local_storage.dart';
import '../../../utils/constants.dart';
import 'about_us_screen.dart';
import '../password/change_password_screen.dart';

class SettingScreen extends StatelessWidget {
  SettingScreen({super.key});

  final SettingsController settingsController = Get.put(SettingsController());

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => AppScaffoldNew(
        appBartitleText: locale.value.settings,
        hasLeadingWidget: isLoggedIn.value,
        appBarVerticalSize: Get.height * 0.12,
        body: AnimatedScrollView(
          padding: const EdgeInsets.only(top: 16, bottom: 80),
          children: [
            Column(
              children: [
                // Preferences Section
                _buildSectionHeader(locale.value.appTheme),
                8.height,
                _buildGroupedCard([
                  // Language Tile
                  Obx(
                    () => _buildSettingTile(
                      title: locale.value.language,
                      subtitle: settingsController.selectedLang.value.name ?? '',
                      iconPath: Assets.iconsIcLanguage,
                      trailing: _buildChip(
                        settingsController.selectedLang.value.name ?? localeLanguageList.first.name ?? '',
                      ),
                      onTap: () => _showLanguageSheet(context),
                    ),
                  ),
                  _buildSubtleDivider(),
                  // Theme Tile
                  Obx(
                    () => _buildSettingTile(
                      title: locale.value.appTheme,
                      subtitle: settingsController.dropdownValue.value.mode.isNotEmpty
                          ? settingsController.dropdownValue.value.mode
                          : settingsController.themeModes.first.mode,
                      iconPath: Assets.iconsIcDarkMode,
                      trailing: _buildChip(
                        settingsController.dropdownValue.value.mode.isNotEmpty
                            ? settingsController.dropdownValue.value.mode
                            : settingsController.themeModes.first.mode,
                      ),
                      onTap: () => _showThemeSheet(context),
                    ),
                  ),
                ]),

                // Security Section (logged in only)
                if (isLoggedIn.value) ...[
                  24.height,
                  _buildSectionHeader(locale.value.changePassword),
                  8.height,
                  _buildGroupedCard([
                    _buildSettingTile(
                      title: locale.value.changePassword,
                      subtitle: locale.value.yourNewPasswordMust,
                      iconPath: Assets.iconsIcLock,
                      onTap: () => Get.to(() => ChangePassword()),
                    ),
                  ]),
                ],

                // Info Section (logged out only)
                if (!isLoggedIn.value) ...[
                  24.height,
                  _buildSectionHeader(locale.value.aboutApp),
                  8.height,
                  _buildGroupedCard([
                    _buildSettingTile(
                      title: locale.value.aboutApp,
                      subtitle: locale.value.privacyPolicyTerms,
                      iconPath: Assets.iconsIcInfo,
                      onTap: () => Get.to(() => const AboutScreen()),
                    ),
                    _buildSubtleDivider(),
                    _buildSettingTile(
                      title: locale.value.contactUs,
                      subtitle: locale.value.getInTouchWithSupport,
                      iconPath: Assets.iconsIcContactUs,
                      onTap: () {
                        commonLaunchUrl('$DOMAIN_URL/contact-us', launchMode: LaunchMode.externalApplication);
                      },
                    ),
                  ]),
                  24.height,
                  _buildSignInButton(context),
                ],

                // Danger Zone (logged in only)
                if (isLoggedIn.value) ...[
                  24.height,
                  _buildSectionHeader(locale.value.deleteAccount),
                  8.height,
                  _buildDangerCard(context),
                ],

                32.height,
              ],
            ).paddingSymmetric(horizontal: 16),
          ],
        ),
      ),
    );
  }

  // ── Section Header ──────────────────────────────────────────────────
  Widget _buildSectionHeader(String title) {
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

  // ── Grouped Card Container ──────────────────────────────────────────
  Widget _buildGroupedCard(List<Widget> children) {
    return Obx(
      () => Container(
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
        child: Column(children: children),
      ),
    );
  }

  // ── Subtle Divider ──────────────────────────────────────────────────
  Widget _buildSubtleDivider() {
    return Obx(
      () => Divider(
        height: 1,
        thickness: 0.5,
        indent: 64,
        color: isDarkMode.value ? borderColor.withValues(alpha: 0.08) : borderColor.withValues(alpha: 0.2),
      ),
    );
  }

  // ── Setting Tile ────────────────────────────────────────────────────
  Widget _buildSettingTile({
    required String title,
    String? subtitle,
    required String iconPath,
    Widget? trailing,
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
              commonLeadingWid(imgPath: iconPath, color: appColorPrimary).circularLightPrimaryBg(),
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
              trailing ??
                  Obx(
                    () => Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 14,
                      color: isDarkMode.value ? Colors.white38 : secondaryTextColor.withValues(alpha: 0.5),
                    ),
                  ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Chip Badge ──────────────────────────────────────────────────────
  Widget _buildChip(String label) {
    return Obx(
      () => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isDarkMode.value ? appColorSecondary.withValues(alpha: 0.12) : lightSecondaryColor,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: appColorSecondary,
              ),
            ),
            6.width,
            const Icon(Icons.keyboard_arrow_down_rounded, size: 16, color: appColorSecondary),
          ],
        ),
      ),
    );
  }

  // ── Sign In Button ──────────────────────────────────────────────────
  Widget _buildSignInButton(BuildContext context) {
    return GestureDetector(
      onTap: () => doIfLoggedIn(() {}),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
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
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.login_rounded, color: Colors.white, size: 20),
            10.width,
            Text(
              locale.value.signIn,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Danger Zone Card (Delete Account) ───────────────────────────────
  Widget _buildDangerCard(BuildContext context) {
    return Obx(
      () => Container(
        decoration: BoxDecoration(
          color: isDarkMode.value ? surfaceElevatedDark : surfaceElevated,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDarkMode.value ? cancelStatusColor.withValues(alpha: 0.15) : cancelStatusColor.withValues(alpha: 0.1),
          ),
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
              ifNotTester(() async {
                if (await isNetworkAvailable()) {
                  showConfirmDialogCustom(
                    context,
                    negativeText: locale.value.cancel,
                    positiveText: locale.value.delete,
                    onAccept: (_) {
                      settingsController.handleDeleteAccountClick();
                    },
                    dialogType: DialogType.DELETE,
                    title: locale.value.deleteAccountConfirmation,
                  );
                } else {
                  toast(locale.value.yourInternetIsNotWorking);
                }
              });
            },
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
              child: Row(
                children: [
                  commonLeadingWid(imgPath: Assets.iconsIcDelete, color: cancelStatusColor).circularLightPrimaryBg(
                    color: isDarkMode.value ? cancelStatusColor.withValues(alpha: 0.15) : cancelStatusColor.withValues(alpha: 0.08),
                  ),
                  16.width,
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(locale.value.deleteAccount, style: boldTextStyle(size: 14, color: cancelStatusColor)),
                        2.height,
                        Text(
                          locale.value.deleteAccountConfirmation,
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
      ),
    );
  }

  // ── Language Bottom Sheet ────────────────────────────────────────────
  void _showLanguageSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _LanguageSheetContent(settingsController: settingsController),
    );
  }

  // ── Theme Bottom Sheet ──────────────────────────────────────────────
  void _showThemeSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _ThemeSheetContent(settingsController: settingsController),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════
// Language Selection Bottom Sheet
// ═══════════════════════════════════════════════════════════════════════
class _LanguageSheetContent extends StatelessWidget {
  final SettingsController settingsController;
  const _LanguageSheetContent({required this.settingsController});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        decoration: BoxDecoration(
          color: isDarkMode.value ? appScreenBackgroundDark : appScreenBackground,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: secondaryTextColor.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            20.height,
            // Title
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                locale.value.language,
                style: GoogleFonts.outfit(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: isDarkMode.value ? Colors.white : primaryTextColor,
                  letterSpacing: -0.3,
                ),
              ),
            ),
            20.height,
            // Language Options
            ...localeLanguageList.map((lang) {
              final isSelected = settingsController.selectedLang.value.languageCode == lang.languageCode;
              return _buildLanguageOption(context, lang, isSelected);
            }),
            16.height,
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageOption(BuildContext context, LanguageDataModel lang, bool isSelected) {
    return Obx(
      () => GestureDetector(
        onTap: () async {
          settingsController.selectedLang(lang);
          settingsController.isLoading(true);
          await setValue(SELECTED_LANGUAGE_CODE, lang.languageCode);
          selectedLanguageDataModel = lang;
          BaseLanguage temp = await const AppLocalizations().load(Locale(lang.languageCode.validate()));
          locale = temp.obs;
          setValueToLocal(SELECTED_LANGUAGE_CODE, lang.languageCode.validate());
          selectedLanguageCode(lang.languageCode!);
          Get.updateLocale(Locale(lang.languageCode.validate()));
          settingsController.isLoading(false);
          settingsController.onLanguageChange();
          Get.back();
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
          decoration: BoxDecoration(
            color: isSelected
                ? (isDarkMode.value ? appColorSecondary.withValues(alpha: 0.12) : lightSecondaryColor)
                : (isDarkMode.value ? surfaceElevatedDark : surfaceElevated),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelected ? appColorSecondary.withValues(alpha: 0.4) : Colors.transparent,
              width: 1.5,
            ),
            boxShadow: [
              if (!isSelected)
                BoxShadow(
                  color: isDarkMode.value ? softShadowColorDark : softShadowColor,
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
            ],
          ),
          child: Row(
            children: [
              if (lang.flag != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: CachedImageWidget(url: lang.flag.validate(), height: 28, width: 28),
                ),
              14.width,
              Expanded(
                child: Text(
                  lang.name.validate(),
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 15,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected
                        ? appColorSecondary
                        : (isDarkMode.value ? Colors.white : primaryTextColor),
                  ),
                ),
              ),
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isSelected ? appColorSecondary : Colors.transparent,
                  border: Border.all(
                    color: isSelected ? appColorSecondary : secondaryTextColor.withValues(alpha: 0.3),
                    width: isSelected ? 0 : 1.5,
                  ),
                ),
                child: isSelected
                    ? const Icon(Icons.check_rounded, size: 14, color: Colors.white)
                    : const SizedBox.shrink(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════
// Theme Selection Bottom Sheet
// ═══════════════════════════════════════════════════════════════════════
class _ThemeSheetContent extends StatelessWidget {
  final SettingsController settingsController;
  const _ThemeSheetContent({required this.settingsController});

  IconData _themeIcon(int id) {
    if (id == THEME_MODE_LIGHT) return Icons.light_mode_rounded;
    if (id == THEME_MODE_DARK) return Icons.dark_mode_rounded;
    return Icons.brightness_auto_rounded;
  }

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        decoration: BoxDecoration(
          color: isDarkMode.value ? appScreenBackgroundDark : appScreenBackground,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: secondaryTextColor.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            20.height,
            // Title
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                locale.value.appTheme,
                style: GoogleFonts.outfit(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: isDarkMode.value ? Colors.white : primaryTextColor,
                  letterSpacing: -0.3,
                ),
              ),
            ),
            20.height,
            // Theme Options
            ...settingsController.themeModes.map((theme) {
              final isSelected = settingsController.dropdownValue.value.id == theme.id ||
                  (settingsController.dropdownValue.value.id.isNegative && theme.id == settingsController.themeModes.first.id);
              return _buildThemeOption(context, theme, isSelected);
            }),
            16.height,
          ],
        ),
      ),
    );
  }

  Widget _buildThemeOption(BuildContext context, ThemeModeData theme, bool isSelected) {
    return Obx(
      () => GestureDetector(
        onTap: () {
          settingsController.dropdownValue(theme);
          toggleThemeMode(themeId: theme.id);
          Get.back();
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
          decoration: BoxDecoration(
            color: isSelected
                ? (isDarkMode.value ? appColorSecondary.withValues(alpha: 0.12) : lightSecondaryColor)
                : (isDarkMode.value ? surfaceElevatedDark : surfaceElevated),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelected ? appColorSecondary.withValues(alpha: 0.4) : Colors.transparent,
              width: 1.5,
            ),
            boxShadow: [
              if (!isSelected)
                BoxShadow(
                  color: isDarkMode.value ? softShadowColorDark : softShadowColor,
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: isSelected
                      ? appColorSecondary.withValues(alpha: 0.15)
                      : (isDarkMode.value ? Colors.white.withValues(alpha: 0.06) : surfaceSubtle),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  _themeIcon(theme.id),
                  size: 20,
                  color: isSelected ? appColorSecondary : secondaryTextColor,
                ),
              ),
              14.width,
              Expanded(
                child: Text(
                  theme.mode,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 15,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected
                        ? appColorSecondary
                        : (isDarkMode.value ? Colors.white : primaryTextColor),
                  ),
                ),
              ),
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isSelected ? appColorSecondary : Colors.transparent,
                  border: Border.all(
                    color: isSelected ? appColorSecondary : secondaryTextColor.withValues(alpha: 0.3),
                    width: isSelected ? 0 : 1.5,
                  ),
                ),
                child: isSelected
                    ? const Icon(Icons.check_rounded, size: 14, color: Colors.white)
                    : const SizedBox.shrink(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
