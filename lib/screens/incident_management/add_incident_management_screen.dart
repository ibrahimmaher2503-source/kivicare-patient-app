import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nb_utils/nb_utils.dart';
import '../../components/app_scaffold.dart';
import '../../components/loader_widget.dart';
import '../../generated/assets.dart';
import '../../main.dart';
import '../../utils/app_common.dart';
import '../../utils/colors.dart';
import '../../utils/common_base.dart';
import 'incident_management_controller.dart';

class AddIncidentManagement extends StatelessWidget {
  AddIncidentManagement({super.key});

  final IncidentManagement controller = Get.put(IncidentManagement());
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return AppScaffoldNew(
      appBartitleText: locale.value.incidentManagement,
      appBarVerticalSize: Get.mediaQuery.size.height * 0.12,
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Form(
                    key: formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        16.height,

                        /// Section Header: Details
                        Text(
                          locale.value.incidentManagement,
                          style: GoogleFonts.outfit(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            letterSpacing: -0.3,
                            color: isDarkMode.value ? Colors.white : primaryTextColor,
                          ),
                        ),
                        16.height,

                        /// Title Field
                        AppTextField(
                          textStyle: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            letterSpacing: 0.1,
                            color: isDarkMode.value ? Colors.white : primaryTextColor,
                          ),
                          controller: controller.titleCont,
                          focus: controller.titleFocus,
                          nextFocus: controller.desFocus,
                          textFieldType: TextFieldType.NAME,
                          errorThisFieldRequired: locale.value.thisFieldIsRequired,
                          decoration: inputDecoration(
                            context,
                            hintText: locale.value.title,
                            fillColor: isDarkMode.value ? inputFillColorDark : inputFillColor,
                            filled: true,
                          ),
                          suffix: commonLeadingWid(imgPath: Assets.iconsIcNotebook, color: secondaryTextColor, size: 12).paddingAll(16),
                        ),
                        16.height,

                        /// Description Field
                        AppTextField(
                          isValidationRequired: true,
                          textStyle: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            letterSpacing: 0.1,
                            color: isDarkMode.value ? Colors.white : primaryTextColor,
                          ),
                          textFieldType: TextFieldType.MULTILINE,
                          controller: controller.desCont,
                          maxLength: 500,
                          minLines: 5,
                          focus: controller.desFocus,
                          errorThisFieldRequired: locale.value.thisFieldIsRequired,
                          decoration: inputDecoration(
                            context,
                            hintText: locale.value.enterYourDetailDescriptionForYourComplaint,
                            fillColor: isDarkMode.value ? inputFillColorDark : inputFillColor,
                            filled: true,
                          ),
                        ),
                        16.height,

                        /// Phone Code + Phone Number
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Obx(
                              () => AppTextField(
                                textStyle: GoogleFonts.plusJakartaSans(
                                  fontSize: 12,
                                  letterSpacing: 0.1,
                                  color: isDarkMode.value ? Colors.white : primaryTextColor,
                                ),
                                textFieldType: TextFieldType.OTHER,
                                controller: TextEditingController(text: " +${controller.pickedPhoneCode.value.phoneCode}"),
                                focus: controller.phoneCodeFocus,
                                nextFocus: controller.mobileFocus,
                                errorThisFieldRequired: locale.value.thisFieldIsRequired,
                                readOnly: true,
                                onTap: () {
                                  pickCountry(context, onSelect: (Country country) {
                                    controller.pickedPhoneCode(country);
                                    controller.phoneCodeCont.text = controller.pickedPhoneCode.value.phoneCode;
                                  });
                                },
                                textAlign: TextAlign.center,
                                decoration: inputDecoration(
                                  context,
                                  hintText: "",
                                  prefixIcon: Text(
                                    controller.pickedPhoneCode.value.flagEmoji,
                                  ).paddingOnly(top: 2, left: 8),
                                  prefixIconConstraints: BoxConstraints.tight(const Size(24, 24)),
                                  suffixIcon: const Icon(
                                    Icons.keyboard_arrow_down_rounded,
                                    color: dividerColor,
                                    size: 22,
                                  ).paddingOnly(right: 32),
                                  suffixIconConstraints: BoxConstraints.tight(const Size(24, 24)),
                                  fillColor: isDarkMode.value ? inputFillColorDark : inputFillColor,
                                  filled: true,
                                ),
                              ),
                            ).expand(flex: 3),
                            16.width,
                            AppTextField(
                              textStyle: GoogleFonts.plusJakartaSans(
                                fontSize: 12,
                                letterSpacing: 0.1,
                                color: isDarkMode.value ? Colors.white : primaryTextColor,
                              ),
                              textFieldType: TextFieldType.PHONE,
                              controller: controller.mobileCont,
                              focus: controller.mobileFocus,
                              errorThisFieldRequired: locale.value.thisFieldIsRequired,
                              keyboardType: TextInputType.phone,
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(RegExp('[0-9]')),
                              ],
                              decoration: inputDecoration(
                                context,
                                hintText: locale.value.phoneNumber,
                                fillColor: isDarkMode.value ? inputFillColorDark : inputFillColor,
                                filled: true,
                              ),
                              suffix: commonLeadingWid(imgPath: Assets.iconsIcCall, color: secondaryTextColor, size: 12).paddingAll(16),
                            ).expand(flex: 8),
                          ],
                        ),
                        16.height,

                        /// Email Field
                        AppTextField(
                          textStyle: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            letterSpacing: 0.1,
                            color: isDarkMode.value ? Colors.white : primaryTextColor,
                          ),
                          controller: controller.emailCont,
                          focus: controller.emailFocus,
                          nextFocus: controller.mobileFocus,
                          textFieldType: TextFieldType.EMAIL_ENHANCED,
                          errorThisFieldRequired: locale.value.thisFieldIsRequired,
                          errorInvalidEmail: locale.value.pleaseEnterValidEmail,
                          decoration: inputDecoration(
                            context,
                            hintText: locale.value.email,
                            fillColor: isDarkMode.value ? inputFillColorDark : inputFillColor,
                            filled: true,
                          ),
                          suffix: commonLeadingWid(imgPath: Assets.iconsIcMail, color: secondaryTextColor, size: 12).paddingAll(16),
                        ),
                        16.height,

                        /// Image Picker Field
                        AppTextField(
                          isValidationRequired: true,
                          textStyle: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            letterSpacing: 0.1,
                            color: isDarkMode.value ? Colors.white : primaryTextColor,
                          ),
                          textFieldType: TextFieldType.USERNAME,
                          controller: controller.imageTitleCont,
                          focus: controller.imageTitleFocus,
                          onTap: () => controller.pickImage(),
                          readOnly: true,
                          errorThisFieldRequired: locale.value.thisFieldIsRequired,
                          decoration: inputDecoration(
                            suffixIcon: Container(
                              decoration: BoxDecoration(
                                borderRadius: const BorderRadius.only(
                                  bottomRight: Radius.circular(12),
                                  topRight: Radius.circular(12),
                                ),
                                color: isDarkMode.value ? surfaceElevatedDark : inputFillColor,
                              ),
                              width: 75,
                              child: Center(
                                child: Text(
                                  locale.value.browse,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0.1,
                                    color: appColorSecondary,
                                  ),
                                ),
                              ),
                            ),
                            context,
                            hintText: locale.value.chooseImage,
                            fillColor: isDarkMode.value ? inputFillColorDark : inputFillColor,
                            filled: true,
                          ),
                        ),
                        16.height,
                      ],
                    ).paddingSymmetric(horizontal: 16),
                  ),
                ),
              ),

              /// Submit Button
              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: GestureDetector(
                    onTap: () async {
                      if (formKey.currentState!.validate()) {
                        controller
                            .submitAPI(
                          title: controller.titleCont.text,
                          description: controller.desCont.text,
                          phoneCode: controller.phoneCodeCont.text,
                          mobileNumber: controller.mobileCont.text,
                          email: controller.emailCont.text,
                          imageFile: controller.imageFile.value,
                        ).then(
                          (value) async {
                            controller.clearTextFields();
                            await controller.getIncidents();
                            Get.back();
                          },
                        );
                      }
                    },
                    child: Container(
                      width: Get.width,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: [gradientSecondaryStart, gradientSecondaryEnd]),
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
                        textAlign: TextAlign.center,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.1,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          Obx(() => const LoaderWidget().visible(controller.isLoading.value)),
        ],
      ),
    );
  }
}
