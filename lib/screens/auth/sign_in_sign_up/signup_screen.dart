import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:kivicare_patient/components/app_logo_widget.dart';
import 'package:kivicare_patient/utils/constants.dart';
import 'package:kivicare_patient/utils/app_common.dart';

import '../../../components/app_scaffold.dart';
import '../../../configs.dart';
import '../../../generated/assets.dart';
import '../../../main.dart';
import '../../../utils/colors.dart';
import '../../../utils/common_base.dart';
import 'password_rule_item.dart';
import 'sign_up_controller.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> with SingleTickerProviderStateMixin {
  final SignUpController signUpController = Get.put(SignUpController());
  late AnimationController _animController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOut,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.05),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOut,
    ));
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffoldNew(
      isLoading: signUpController.isLoading,
      hasLeadingWidget: false,
      clipBehaviorSplitRegion: Clip.none,
      body: Stack(
        clipBehavior: Clip.none,
        children: [
          FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: AnimatedScrollView(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // -- Heading Section --
                  Text(
                    locale.value.createYourAccount,
                    style: GoogleFonts.outfit(
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.3,
                      color: isDarkMode.value ? Colors.white : appColorPrimary,
                    ),
                  ),
                  8.height,
                  Text(
                    locale.value.registerYourAccountForBetterExperience,
                    style: secondaryTextStyle(size: 14),
                  ),
                  32.height,

                  // -- Form Section --
                  Form(
                    key: signUpController.signUpformKey,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // -- Name Fields Section --
                        AppTextField(
                          title: locale.value.firstName,
                          textStyle: primaryTextStyle(size: 12),
                          controller: signUpController.firstNameCont,
                          focus: signUpController.fisrtNameFocus,
                          nextFocus: signUpController.lastNameFocus,
                          textFieldType: TextFieldType.NAME,
                          decoration: inputDecoration(
                            context,
                            fillColor: context.cardColor,
                            filled: true,
                            hintText: "${locale.value.eG} ${locale.value.merry}",
                          ),
                          suffix: commonLeadingWid(imgPath: Assets.navigationIcUserOutlined, size: 14).paddingAll(14),
                        ),
                        16.height,
                        AppTextField(
                          title: locale.value.lastName,
                          textStyle: primaryTextStyle(size: 12),
                          controller: signUpController.lastNameCont,
                          focus: signUpController.lastNameFocus,
                          nextFocus: signUpController.emailFocus,
                          textFieldType: TextFieldType.NAME,
                          decoration: inputDecoration(
                            context,
                            fillColor: context.cardColor,
                            filled: true,
                            hintText: "${locale.value.eG}  ${locale.value.doe}",
                          ),
                          suffix: commonLeadingWid(imgPath: Assets.navigationIcUserOutlined, size: 14).paddingAll(14),
                        ),

                        24.height,

                        // Subtle visual separator between name & credentials sections
                        Container(
                          height: 1,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.transparent,
                                isDarkMode.value
                                    ? borderColorDark.withValues(alpha: 0.4)
                                    : whiteBorderColor,
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),

                        24.height,

                        // -- Credentials Section --
                        AppTextField(
                          title: locale.value.email,
                          textStyle: primaryTextStyle(size: 12),
                          controller: signUpController.emailCont,
                          focus: signUpController.emailFocus,
                          nextFocus: signUpController.passwordFocus,
                          textFieldType: TextFieldType.EMAIL_ENHANCED,
                          decoration: inputDecoration(
                            context,
                            fillColor: context.cardColor,
                            filled: true,
                            hintText: "${locale.value.eG} merry_456@gmail.com",
                          ),
                          suffix: commonLeadingWid(imgPath: Assets.iconsIcMail, size: 14).paddingAll(14),
                        ),
                        16.height,
                        Focus(
                          onFocusChange: (value) {
                            signUpController.passContHasFocus(value);
                          },
                          child: AppTextField(
                            title: locale.value.password,
                            textStyle: primaryTextStyle(size: 12),
                            controller: signUpController.passwordCont,
                            focus: signUpController.passwordFocus,
                            textFieldType: TextFieldType.PASSWORD,
                            obscureText: true,
                            onChanged: (val) => signUpController.checkPasswordRules(val),
                            decoration: inputDecoration(
                              context,
                              fillColor: context.cardColor,
                              filled: true,
                              hintText: "${locale.value.eG} #1234@1567",
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return locale.value.passwordIsRequired;
                              } else if (value.length < 8) {
                                return locale.value.passwordTooShort;
                              } else if (!signUpController.hasSpecial.value || !signUpController.hasNumber.value || !signUpController.hasUppercase.value || !signUpController.hasLetter.value) {
                                return locale.value.passwordDoesNotMeetRequirements;
                              }
                              return null;
                            },
                            suffixPasswordVisibleWidget: commonLeadingWid(imgPath: Assets.iconsIcEye, size: 14).paddingAll(12),
                            suffixPasswordInvisibleWidget: commonLeadingWid(imgPath: Assets.iconsIcEyeSlash, size: 14).paddingAll(12),
                          ),
                        ),
                        8.height,

                        // -- Password Rules --
                        Obx(
                          () => AnimatedSize(
                            duration: const Duration(milliseconds: 250),
                            curve: Curves.easeInOut,
                            child: signUpController.passContHasFocus.value
                                ? Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: isDarkMode.value
                                          ? surfaceElevatedDark
                                          : surfaceSubtle,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: isDarkMode.value
                                            ? borderColorDark
                                            : whiteBorderColor,
                                        width: 1,
                                      ),
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        PasswordRuleItem(
                                          isValid: signUpController.hasUppercase.value,
                                          text: locale.value.passwordMustIncludeAtLeastOneCapitalCharacter,
                                        ),
                                        6.height,
                                        PasswordRuleItem(
                                          isValid: signUpController.hasLetter.value,
                                          text: locale.value.passwordMustIncludeAtLeastOneLowercaseCharacter,
                                        ),
                                        6.height,
                                        PasswordRuleItem(
                                          isValid: signUpController.hasNumber.value,
                                          text: locale.value.passwordMustIncludeAtLeastOneNumber,
                                        ),
                                        6.height,
                                        PasswordRuleItem(
                                          isValid: signUpController.hasSpecial.value,
                                          text: locale.value.passwordMustIncludeSpacialCharacter,
                                        ),
                                      ],
                                    ),
                                  )
                                : const SizedBox.shrink(),
                          ),
                        ),

                        16.height,

                        // -- Terms & Conditions --
                        Obx(
                          () => Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 24,
                                height: 24,
                                child: Checkbox(
                                  checkColor: whiteColor,
                                  value: signUpController.isAcceptedTc.value,
                                  activeColor: appColorSecondary,
                                  visualDensity: VisualDensity.compact,
                                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                  splashRadius: 0,
                                  shape: RoundedRectangleBorder(borderRadius: radius(4)),
                                  side: BorderSide(color: secondaryTextColor.withValues(alpha: 0.5), width: 1.5),
                                  onChanged: (val) async {
                                    signUpController.isAcceptedTc.value = !signUpController.isAcceptedTc.value;
                                  },
                                ),
                              ),
                              12.width,
                              RichTextWidget(
                                list: [
                                  TextSpan(text: "${locale.value.iAgreeToThe} ", style: secondaryTextStyle()),
                                  TextSpan(
                                    text: locale.value.termsConditions,
                                    style: primaryTextStyle(color: appColorPrimary, size: 12, decoration: TextDecoration.underline, decorationColor: appColorPrimary),
                                    recognizer: TapGestureRecognizer()
                                      ..onTap = () {
                                        commonLaunchUrl(TERMS_CONDITION_URL, launchMode: LaunchMode.externalApplication);
                                      },
                                  ),
                                  TextSpan(text: " ${locale.value.and} ", style: secondaryTextStyle()),
                                  TextSpan(
                                    text: locale.value.privacyPolicy,
                                    style: primaryTextStyle(color: appColorPrimary, size: 12, decoration: TextDecoration.underline, decorationColor: appColorPrimary),
                                    recognizer: TapGestureRecognizer()
                                      ..onTap = () {
                                        commonLaunchUrl(PRIVACY_POLICY_URL, launchMode: LaunchMode.externalApplication);
                                      },
                                  ),
                                ],
                              ).expand(),
                            ],
                          ),
                        ),
                        24.height,

                        // -- Gradient CTA Button --
                        _buildGradientCTAButton(
                          text: locale.value.signUp,
                          onTap: () {
                            if (signUpController.signUpformKey.currentState!.validate()) {
                              signUpController.signUpformKey.currentState!.save();
                              signUpController.saveForm();
                            }
                          },
                        ),
                      ],
                    ),
                  ).paddingSymmetric(horizontal: 16),

                  // -- Sign In Link --
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(locale.value.alreadyHaveAnAccount, style: secondaryTextStyle()),
                      4.width,
                      InkWell(
                          onTap: () {
                            Get.back();
                          },
                          child: Text(
                            locale.value.signIn,
                            style: boldTextStyle(
                              size: 12,
                              color: appColorSecondary,
                              decorationColor: appColorSecondary,
                            ),
                          )),
                    ],
                  ).paddingOnly(top: 24, bottom: 16),
                ],
              ).paddingOnly(top: Get.height * 0.11),
            ),
          ),
          Positioned(
            width: Get.width,
            top: -Constants.appLogoSize / 2,
            child: const AppLogoWidget(),
          ),
        ],
      ),
    );
  }

  /// Premium gradient CTA button with teal gradient
  Widget _buildGradientCTAButton({required String text, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 54,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [gradientSecondaryStart, gradientSecondaryEnd],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: gradientSecondaryStart.withValues(alpha: 0.25),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: Text(
            text,
            style: boldTextStyle(color: Colors.white, size: 14),
          ),
        ),
      ),
    );
  }
}
