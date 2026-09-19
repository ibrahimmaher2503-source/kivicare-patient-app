// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kivicare_patient/configs.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:kivicare_patient/utils/colors.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../components/app_scaffold.dart';
import '../../../components/cached_image_widget.dart';
import '../../../utils/app_common.dart';
import '../model/theme_mode_data_model.dart';
import 'settings_controller.dart';
import '../../../main.dart';
import '../../../utils/common_base.dart';
import '../../../utils/push_notification_service.dart';
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
        body: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.fromLTRB(
            16,
            20,
            16,
            28 + MediaQuery.paddingOf(context).bottom,
          ),
          children: [
            _SettingsGroup(
              children: [
                Obx(
                  () => _SettingsRow(
                    title: locale.value.language,
                    icon: Icons.language_rounded,
                    onTap: () => _showLanguagePicker(context),
                    trailing: DropdownButtonHideUnderline(
                      child: DropdownButton(
                        elevation: 1,
                        dropdownColor: context.cardColor,
                        borderRadius: BorderRadius.circular(defaultRadius),
                        items: localeLanguageList.map((element) {
                          return DropdownMenuItem(
                            value: element,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (element.flag != null)
                                  CachedImageWidget(
                                      url: element.flag.validate(),
                                      height: 24,
                                      width: 24),
                                6.width,
                                if (element.name != null)
                                  Text(element.name.validate(),
                                      style: primaryTextStyle(size: 14)),
                              ],
                            ).paddingSymmetric(horizontal: 12),
                          );
                        }).toList(),
                        onChanged: (newValue) async {
                          if (newValue is LanguageDataModel) {
                            await settingsController.changeLanguage(newValue);
                          }
                        },
                        value: settingsController.selectedLang.value.id
                                    .validate() >
                                0
                            ? settingsController.selectedLang.value
                            : localeLanguageList.first,
                      ),
                    ),
                  ),
                ),
                Obx(
                  () => _SettingsRow(
                    title: locale.value.appTheme,
                    icon: Icons.brightness_6_rounded,
                    trailing: DropdownButtonHideUnderline(
                      child: DropdownButton(
                        elevation: 1,
                        dropdownColor: context.cardColor,
                        borderRadius: BorderRadius.circular(defaultRadius),
                        items: settingsController.themeModes.map((element) {
                          return DropdownMenuItem(
                            value: element,
                            child: Text(
                              element.mode == 'Light'
                                  ? locale.value.themeLight
                                  : element.mode == 'Dark'
                                      ? locale.value.themeDark
                                      : locale.value.themeSystem,
                              style: primaryTextStyle(size: 13),
                            ).paddingSymmetric(horizontal: 12),
                          );
                        }).toList(),
                        onChanged: (newValue) {
                          if (newValue is ThemeModeData) {
                            settingsController.dropdownValue(newValue);
                            toggleThemeMode(
                                themeId:
                                    settingsController.dropdownValue.value.id);
                          }
                        },
                        value: !settingsController
                                .dropdownValue.value.id.isNegative
                            ? settingsController.dropdownValue.value
                            : settingsController.themeModes.first,
                      ),
                    ),
                  ),
                ),
                _SettingsRow(
                  title: locale.value.enableNotifications,
                  icon: Icons.notifications_active_outlined,
                  onTap: () async {
                    final allowed = await PushNotificationService()
                        .requestNotificationPermission();
                    if (!allowed) {
                      toast(locale.value.notificationPermissionDenied);
                      await openAppSettings();
                    }
                  },
                  trailing: const Icon(Icons.chevron_right_rounded),
                ),
              ],
            ),
            if (isLoggedIn.value) ...[
              18.height,
              _SettingsGroup(
                children: [
                  _SettingsRow(
                    title: locale.value.changePassword,
                    icon: Icons.lock_outline_rounded,
                    onTap: () => Get.to(() => ChangePassword()),
                    trailing: const Icon(Icons.chevron_right_rounded),
                  ),
                  _SettingsRow(
                    title: locale.value.deleteAccount,
                    icon: Icons.delete_outline_rounded,
                    destructive: true,
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
                    trailing: const Icon(Icons.chevron_right_rounded),
                  ),
                ],
              ),
            ],
            if (!isLoggedIn.value) ...[
              18.height,
              _SettingsGroup(
                children: [
                  _SettingsRow(
                    title: locale.value.aboutApp,
                    icon: Icons.info_outline_rounded,
                    onTap: () => Get.to(() => const AboutScreen()),
                    trailing: const Icon(Icons.chevron_right_rounded),
                  ),
                  _SettingsRow(
                    title: locale.value.contactUs,
                    icon: Icons.support_agent_rounded,
                    onTap: () => commonLaunchUrl('$DOMAIN_URL/contact-us',
                        launchMode: LaunchMode.externalApplication),
                    trailing: const Icon(Icons.chevron_right_rounded),
                  ),
                  _SettingsRow(
                    title: locale.value.signIn,
                    icon: Icons.login_rounded,
                    onTap: () => doIfLoggedIn(() {}),
                    trailing: const Icon(Icons.chevron_right_rounded),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _showLanguagePicker(BuildContext context) async {
    final selected = await showModalBottomSheet<LanguageDataModel>(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: localeLanguageList
              .map((language) => ListTile(
                    title: Text(language.name.validate()),
                    trailing: language.languageCode ==
                            settingsController.selectedLang.value.languageCode
                        ? const Icon(Icons.check_rounded)
                        : null,
                    onTap: () => Navigator.of(sheetContext).pop(language),
                  ))
              .toList(),
        ),
      ),
    );
    if (selected != null) {
      await settingsController.changeLanguage(selected);
    }
  }
}

class _SettingsGroup extends StatelessWidget {
  final List<Widget> children;

  const _SettingsGroup({required this.children});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: isDarkMode.value ? surfaceElevatedDark : surfaceElevated,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDarkMode.value ? borderColorDark : glassStrokeDark,
        ),
        boxShadow: isDarkMode.value
            ? const []
            : const [
                BoxShadow(
                  color: softShadowColor,
                  blurRadius: 18,
                  offset: Offset(0, 6),
                ),
              ],
      ),
      child: Column(
        children: [
          for (var index = 0; index < children.length; index++) ...[
            children[index],
            if (index < children.length - 1)
              Divider(
                height: 1,
                indent: 72,
                endIndent: 16,
                color: isDarkMode.value ? borderColorDark : gray100,
              ),
          ],
        ],
      ),
    );
  }
}

class _SettingsRow extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool destructive;

  const _SettingsRow({
    required this.title,
    required this.icon,
    this.trailing,
    this.onTap,
    this.destructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final foreground = destructive
        ? deleteTextColor
        : (isDarkMode.value ? textPrimaryDark : primaryTextColor);
    final iconForeground = destructive ? deleteTextColor : appColorSecondary;
    return Semantics(
      button: onTap != null,
      label: title,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: SizedBox(
          height: 76,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: iconForeground.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: Icon(icon, color: iconForeground, size: 21),
                ),
                14.width,
                Expanded(
                  child: Text(
                    title,
                    style: primaryTextStyle(
                      size: 15,
                      color: foreground,
                      weight: FontWeight.w600,
                    ),
                  ),
                ),
                if (trailing != null)
                  IconTheme(
                    data: IconThemeData(
                      color: isDarkMode.value ? textSecondaryDark : gray500,
                      size: 21,
                    ),
                    child: trailing!,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
