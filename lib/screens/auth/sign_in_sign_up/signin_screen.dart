import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kivicare_patient/utils/app_common.dart';
import '../../../components/app_logo_widget.dart';
import '../../../components/app_scaffold.dart';
import '../../../configs.dart';
import '../../../generated/assets.dart';
import '../../../main.dart';
import '../../../utils/constants.dart';
import 'sign_in_controller.dart';
import '../../../utils/colors.dart';
import '../../../utils/common_base.dart';
import '../password/forget_password_screen.dart';
import 'signup_screen.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> with SingleTickerProviderStateMixin {
  final SignInController signInController = Get.put(SignInController());
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
      isLoading: signInController.isLoading,
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
                  // -- Greeting Section --
                  Text(
                    '${locale.value.hello} ${signInController.userName.value.isNotEmpty ? signInController.userName.value : locale.value.guest}!',
                    style: GoogleFonts.outfit(
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.3,
                      color: isDarkMode.value ? Colors.white : appColorPrimary,
                    ),
                  ),
                  8.height,
                  Text(
                    '${locale.value.welcomeBackToThe}  $APP_NAME',
                    style: secondaryTextStyle(size: 14),
                  ),
                  32.height,

                  // -- Form Section --
                  Form(
                    key: signInController.signInformKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        AppTextField(
                          title: locale.value.email,
                          textStyle: primaryTextStyle(size: 12),
                          controller: signInController.emailCont,
                          focus: signInController.emailFocus,
                          nextFocus: signInController.passwordFocus,
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
                        AppTextField(
                          title: locale.value.password,
                          textStyle: primaryTextStyle(size: 12),
                          controller: signInController.passwordCont,
                          focus: signInController.passwordFocus,
                          // Optional
                          textFieldType: TextFieldType.PASSWORD,
                          obscureText: true,
                          decoration: inputDecoration(
                            context,
                            fillColor: context.cardColor,
                            filled: true,
                            hintText: "\u2022\u2022\u2022\u2022\u2022\u2022\u2022\u2022",
                          ),
                          suffixPasswordVisibleWidget: commonLeadingWid(imgPath: Assets.iconsIcEye, size: 14).paddingAll(12),
                          suffixPasswordInvisibleWidget: commonLeadingWid(imgPath: Assets.iconsIcEyeSlash, size: 14).paddingAll(12),
                        ),
                        Column(
                          children: [
                            Obx(() => Visibility(
                                  visible: signInController.loginSucessfull.isTrue,
                                  child: Column(
                                    children: [
                                      16.height,
                                      AppTextField(
                                        title: signInController.tryToAnother.isTrue ? locale.value.otpFromAuthenticatorApp : locale.value.otp,
                                        textStyle: primaryTextStyle(size: 12),
                                        controller: signInController.otpCont,
                                        focus: signInController.otpFocus,
                                        textFieldType: TextFieldType.NUMBER,
                                        inputFormatters: [
                                          FilteringTextInputFormatter.digitsOnly,
                                          LengthLimitingTextInputFormatter(6),
                                        ],
                                        validator: (value) {
                                          if (value == null || value.length != 6) {
                                            return locale.value.pleaseEnterValid6digitOTP;
                                          }
                                          return null;
                                        },
                                        decoration: inputDecoration(
                                          context,
                                          fillColor: context.cardColor,
                                          filled: true,
                                          hintText: "123456",
                                        ),
                                      ),
                                    ],
                                  ),
                                )),
                          ],
                        ),
                        8.height,
                        Obx(
                          () => Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              signInController.isGoogleAuthentication.value == 1
                                  ? TextButton(
                                      onPressed: () {
                                        signInController.tryToAnother.value = !signInController.tryToAnother.value;
                                      },
                                      child: Text(
                                        locale.value.tryToAnotherWay,
                                        style: primaryTextStyle(
                                          size: 12,
                                          color: appColorPrimary,
                                          fontStyle: FontStyle.italic,
                                          decorationColor: appColorPrimary,
                                        ),
                                      ),
                                    )
                                  : SizedBox(),
                            ],
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Obx(
                              () => CheckboxListTile(
                                checkColor: whiteColor,
                                value: signInController.isRememberMe.value,
                                activeColor: appColorPrimary,
                                visualDensity: VisualDensity.compact,
                                dense: true,
                                controlAffinity: ListTileControlAffinity.leading,
                                contentPadding: EdgeInsets.zero,
                                onChanged: (val) async {
                                  signInController.toggleSwitch();
                                },
                                checkboxShape: RoundedRectangleBorder(borderRadius: radius(4)),
                                side: BorderSide(color: secondaryTextColor.withValues(alpha: 0.5), width: 1.5),
                                title: Text(
                                  locale.value.rememberMe,
                                  style: secondaryTextStyle(color: darkGrayGeneral),
                                ),
                              ),
                            ).expand(),
                            TextButton(
                              onPressed: () {
                                Get.to(() => ForgetPassword());
                              },
                              child: Text(
                                locale.value.forgotPassword,
                                style: primaryTextStyle(
                                  size: 12,
                                  color: appColorPrimary,
                                  decoration: TextDecoration.underline,
                                  fontStyle: FontStyle.italic,
                                  decorationColor: appColorPrimary,
                                ),
                              ),
                            ),
                          ],
                        ),
                        24.height,

                        // -- CTA Button Row --
                        Row(
                          children: [
                            Obx(() => _buildGradientCTAButton(
                              text: signInController.loginSucessfull.isTrue ? locale.value.verify : locale.value.signIn,
                              onTap: () {
                                if (signInController.loginSucessfull.isTrue) {
                                  if (signInController.signInformKey.currentState!.validate()) {
                                    if (signInController.tryToAnother.isTrue) {
                                      signInController.verifyUser(authentication: "google2fa");
                                    } else {
                                      signInController.verifyUser(authentication: "email");
                                    }
                                  }
                                } else {
                                  if (signInController.signInformKey.currentState!.validate()) {
                                    signInController.signInformKey.currentState!.save();
                                    signInController.saveForm();
                                  }
                                }
                              },
                            )).expand(),

                            // -- Social Login Buttons --
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                if (appConfigs.value.googleLoginStatus == 1)
                                  _buildSocialButton(
                                    onTap: () => signInController.googleSignIn(),
                                    child: GoogleLogoWidget(size: 20),
                                  ),
                                if (isApple)
                                  _buildSocialButton(
                                    onTap: () => signInController.appleSignIn(),
                                    child: Image.asset(
                                      Assets.imagesAppleLogo,
                                      color: isDarkMode.value ? null : black,
                                      width: 20,
                                      height: 20,
                                    ),
                                  ).paddingLeft(12),
                              ],
                            ).paddingLeft(16),
                          ],
                        ),
                        24.height,

                        // -- Sign Up Link --
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(locale.value.notAMember, style: secondaryTextStyle()),
                            4.width,
                            InkWell(
                              onTap: () {
                                Get.to(() => SignUpScreen());
                              },
                              child: Text(
                                locale.value.registerNow,
                                style: boldTextStyle(
                                  size: 12,
                                  color: appColorSecondary,
                                  decorationColor: appColorSecondary,
                                ),
                              ),
                            ),
                          ],
                        ),
                        16.height,
                      ],
                    ),
                  ).paddingSymmetric(horizontal: 16),
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

  /// Refined social login button with subtle border
  Widget _buildSocialButton({required VoidCallback onTap, required Widget child}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 54,
        width: 54,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isDarkMode.value
              ? surfaceElevatedDark
              : surfaceElevated,
          shape: BoxShape.circle,
          border: Border.all(
            color: isDarkMode.value
                ? borderColorDark
                : whiteBorderColor,
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: isDarkMode.value
                  ? softShadowColorDark
                  : softShadowColor,
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Center(child: child),
      ),
    );
  }
}
