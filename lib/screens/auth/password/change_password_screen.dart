import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../components/app_scaffold.dart';
import '../../../generated/assets.dart';
import '../../../main.dart';
import '../sign_in_sign_up/password_rule_item.dart';
import 'change_password_controller.dart';

import '../../../utils/app_common.dart';
import '../../../utils/colors.dart';
import '../../../utils/common_base.dart';

class ChangePassword extends StatelessWidget {
  ChangePassword({super.key});
  final ChangePassController changePassController = Get.put(ChangePassController());
  final GlobalKey<FormState> _changePassformKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      isCenterTitle: true,
      appBartitleText: locale.value.changePassword,
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _changePassformKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              32.height,
              // Header icon container
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [gradientSecondaryStart, gradientSecondaryEnd]),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: appColorSecondary.withValues(alpha: 0.2),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(Icons.lock_outline_rounded, color: Colors.white, size: 28),
              ),
              24.height,
              SizedBox(
                width: Get.width * 0.8,
                child: Text(
                  locale.value.yourNewPasswordMust,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    color: secondaryTextColor,
                    letterSpacing: 0.1,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              48.height,
              // Old password field with card styling
              Container(
                decoration: BoxDecoration(
                  color: isDarkMode.value ? inputFillColorDark : inputFillColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: AppTextField(
                  title: locale.value.oldPassword,
                  textStyle: GoogleFonts.plusJakartaSans(fontSize: 14, letterSpacing: 0.1),
                  controller: changePassController.oldPasswordCont,
                  textFieldType: TextFieldType.PASSWORD,
                  obscureText: true,
                  decoration: inputDecoration(
                    context,
                    fillColor: isDarkMode.value ? inputFillColorDark : inputFillColor,
                    filled: true,
                    hintText: "${locale.value.eG} #123@156",
                  ),
                  suffixPasswordVisibleWidget: Icon(Icons.remove_red_eye_outlined, color: secondaryTextColor.withValues(alpha: 0.5)),
                  suffixPasswordInvisibleWidget: commonLeadingWid(imgPath: Assets.iconsIcEyeSlash, color: secondaryTextColor.withValues(alpha: 0.5)).paddingAll(12),
                ),
              ),
              20.height,
              // New password field
              Container(
                decoration: BoxDecoration(
                  color: isDarkMode.value ? inputFillColorDark : inputFillColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Focus(
                  onFocusChange: (value) {
                    changePassController.newPasshasFocus(value);
                  },
                  child: AppTextField(
                    title: locale.value.newPassword,
                    textStyle: GoogleFonts.plusJakartaSans(fontSize: 14, letterSpacing: 0.1),
                    controller: changePassController.newpasswordCont,
                    textFieldType: TextFieldType.PASSWORD,
                    obscureText: true,
                    onChanged: (val) => changePassController.checkPasswordRules(val),
                    decoration: inputDecoration(
                      context,
                      fillColor: isDarkMode.value ? inputFillColorDark : inputFillColor,
                      filled: true,
                      hintText: "${locale.value.eG}  #123@156",
                    ),
                    suffixPasswordVisibleWidget: Icon(Icons.remove_red_eye_outlined, color: secondaryTextColor.withValues(alpha: 0.5)),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return locale.value.passwordIsRequired;
                      } else if (value.length < 8) {
                        return locale.value.passwordTooShort;
                      } else if (!changePassController.hasSpecial.value || !changePassController.hasNumber.value || !changePassController.hasUppercase.value || !changePassController.hasLetter.value) {
                        return locale.value.passwordDoesNotMeetRequirements;
                      }
                      return null;
                    },
                    suffixPasswordInvisibleWidget: commonLeadingWid(imgPath: Assets.iconsIcEyeSlash, color: secondaryTextColor.withValues(alpha: 0.5)).paddingAll(12),
                  ),
                ),
              ),
              8.height,
              // Password rules card
              Obx(
                () => AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  padding: changePassController.newPasshasFocus.value ? const EdgeInsets.all(16) : EdgeInsets.zero,
                  decoration: changePassController.newPasshasFocus.value
                      ? BoxDecoration(
                          color: isDarkMode.value ? surfaceElevatedDark : surfaceElevated,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: isDarkMode.value ? softShadowColorDark : softShadowColor,
                              blurRadius: 16,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        )
                      : null,
                  child: AnimatedSize(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    child: changePassController.newPasshasFocus.value
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              PasswordRuleItem(
                                isValid: changePassController.hasUppercase.value,
                                text: locale.value.passwordMustIncludeAtLeastOneCapitalCharacter,
                              ),
                              PasswordRuleItem(
                                isValid: changePassController.hasLetter.value,
                                text: locale.value.passwordMustIncludeAtLeastOneLowercaseCharacter,
                              ),
                              PasswordRuleItem(
                                isValid: changePassController.hasNumber.value,
                                text: locale.value.passwordMustIncludeAtLeastOneNumber,
                              ),
                              PasswordRuleItem(
                                isValid: changePassController.hasSpecial.value,
                                text: locale.value.passwordMustIncludeSpacialCharacter,
                              ),
                            ],
                          )
                        : const SizedBox.shrink(),
                  ),
                ),
              ),
              20.height,
              // Confirm password field
              Container(
                decoration: BoxDecoration(
                  color: isDarkMode.value ? inputFillColorDark : inputFillColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: AppTextField(
                  title: locale.value.confirmNewPassword,
                  textStyle: GoogleFonts.plusJakartaSans(fontSize: 14, letterSpacing: 0.1),
                  controller: changePassController.confirmPasswordCont,
                  textFieldType: TextFieldType.PASSWORD,
                  obscureText: true,
                  decoration: inputDecoration(
                    context,
                    fillColor: isDarkMode.value ? inputFillColorDark : inputFillColor,
                    filled: true,
                    hintText: "${locale.value.eG}  #123@156",
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return locale.value.passwordIsRequired;
                    } else if (value != changePassController.newpasswordCont.text) {
                      return locale.value.yourNewPasswordDoesnT;
                    }
                    return null;
                  },
                  suffixPasswordVisibleWidget: Icon(Icons.remove_red_eye_outlined, color: secondaryTextColor.withValues(alpha: 0.5)),
                  suffixPasswordInvisibleWidget: commonLeadingWid(imgPath: Assets.iconsIcEyeSlash, color: secondaryTextColor.withValues(alpha: 0.5)).paddingAll(12),
                ),
              ),
              48.height,
              // Gradient CTA button
              GestureDetector(
                onTap: () async {
                  ifNotTester(() async {
                    if (await isNetworkAvailable()) {
                      if (_changePassformKey.currentState!.validate()) {
                        _changePassformKey.currentState!.save();
                        changePassController.saveForm();
                      }
                    } else {
                      toast(locale.value.yourInternetIsNotWorking);
                    }
                  });
                },
                child: Container(
                  width: Get.width,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  alignment: Alignment.center,
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
                    locale.value.submit,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: 0.1,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
