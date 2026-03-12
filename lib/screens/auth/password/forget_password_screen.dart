import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../components/cached_image_widget.dart';
import '../../../generated/assets.dart';
import '../../../main.dart';
import '../../../utils/app_common.dart';
import '../../../utils/colors.dart';
import '../../../utils/common_base.dart';
import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import '../../../components/app_scaffold.dart';
import 'forget_pass_controller.dart';

class ForgetPassword extends StatelessWidget {
  ForgetPassword({super.key});
  final ForgetPasswordController forgetPassController = Get.put(ForgetPasswordController());

  @override
  Widget build(BuildContext context) {
    return AppScaffoldNew(
      isLoading: forgetPassController.isLoading,
      appBartitleText: locale.value.forgotPassword,
      appBarVerticalSize: Get.height * 0.12,
      body: SizedBox(
        width: Get.width,
        height: Get.height,
        child: Stack(
          fit: StackFit.expand,
          children: [
            SingleChildScrollView(
              scrollDirection: Axis.vertical,
              padding: const EdgeInsets.only(left: 16, right: 16, bottom: 80, top: 46),
              child: Form(
                key: forgetPassController.forgotPassFormKey,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Header icon with gradient
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
                      child: const Icon(Icons.mail_outline_rounded, color: Colors.white, size: 28),
                    ),
                    24.height,
                    SizedBox(
                      width: Get.width * 0.8,
                      child: Text(
                        locale.value.resetYourPassword,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.outfit(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.5,
                          color: isDarkMode.value ? Colors.white : primaryTextColor,
                        ),
                      ),
                    ),
                    12.height,
                    SizedBox(
                      width: Get.width * 0.8,
                      child: Text(
                        locale.value.enterYourEmailAddressToResetYourNewPassword,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          color: secondaryTextColor,
                          letterSpacing: 0.1,
                        ),
                      ),
                    ),
                    32.height,
                    CachedImageWidget(
                      url: Assets.imagesForgotPassBg,
                      height: Get.height * 0.25,
                      width: Get.height * 0.25,
                      fit: BoxFit.contain,
                    ),
                    32.height,
                    // Email field with refined styling
                    Container(
                      decoration: BoxDecoration(
                        color: isDarkMode.value ? inputFillColorDark : inputFillColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: AppTextField(
                        title: locale.value.email,
                        textStyle: GoogleFonts.plusJakartaSans(fontSize: 14, letterSpacing: 0.1),
                        controller: forgetPassController.emailCont,
                        textFieldType: TextFieldType.EMAIL,
                        decoration: inputDecoration(
                          context,
                          fillColor: isDarkMode.value ? inputFillColorDark : inputFillColor,
                          filled: true,
                          hintText: "${locale.value.eG}  merry_456@gmail.com",
                        ),
                        suffix: commonLeadingWid(imgPath: Assets.iconsIcMail, size: 14).paddingAll(14),
                      ),
                    ),
                    48.height,
                    // Gradient CTA button
                    GestureDetector(
                      onTap: () {
                        if (forgetPassController.forgotPassFormKey.currentState!.validate()) {
                          forgetPassController.forgotPassFormKey.currentState!.save();
                          forgetPassController.saveForm();
                        }
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
                          locale.value.sendCode,
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
          ],
        ),
      ),
    );
  }
}
