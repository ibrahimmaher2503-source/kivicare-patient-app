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
import '../../utils/constants.dart';
import '../auth/model/login_response.dart';
import '../auth/profile/common_profile_widget.dart';
import 'add_other_patient_controller.dart';

class AddOtherPatientScreen extends StatelessWidget {
  final UserData memberData;
  final String titleText;

  AddOtherPatientScreen({super.key, required this.memberData, required this.titleText});

  final AddOtherPatientController addOtherPatientController = Get.put(AddOtherPatientController());

  @override
  Widget build(BuildContext context) {
    return AppScaffoldNew(
      appBartitleText: titleText,
      appBarVerticalSize: Get.height * 0.12,
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Form(
              key: addOtherPatientController.addMemberFormKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  16.height,

                  /// Profile picture with refined presentation
                  Obx(
                    () => ProfilePicWidget(
                      heroTag: addOtherPatientController.imageFile.value.path.isNotEmpty ? addOtherPatientController.imageFile.value.path : memberData.profileImage,
                      profileImage: addOtherPatientController.imageFile.value.path.isNotEmpty ? addOtherPatientController.imageFile.value.path : memberData.profileImage,
                      firstName: memberData.firstName,
                      lastName: memberData.lastName,
                      picSize: 120,
                      showOnlyPhoto: true,
                      onCameraTap: () {
                        addOtherPatientController.showBottomSheet(context);
                      },
                      onPicTap: () {
                        addOtherPatientController.showBottomSheet(context);
                      },
                    ),
                  ),
                  32.height,

                  /// First Name field
                  AppTextField(
                    textStyle: GoogleFonts.plusJakartaSans(fontSize: 13, letterSpacing: 0.1),
                    controller: addOtherPatientController.fNameCont,
                    focus: addOtherPatientController.fNameFocus,
                    nextFocus: addOtherPatientController.lNameFocus,
                    textFieldType: TextFieldType.NAME,
                    decoration: inputDecoration(
                      context,
                      labelText: locale.value.firstName,
                      hintText: "${locale.value.eG}  ${locale.value.merry}",
                      fillColor: isDarkMode.value ? inputFillColorDark : inputFillColor,
                      filled: true,
                    ),
                    suffix: commonLeadingWid(imgPath: Assets.navigationIcUserOutlined, color: secondaryTextColor, size: 12).paddingAll(16),
                  ),
                  16.height,

                  /// Last Name field
                  AppTextField(
                    textStyle: GoogleFonts.plusJakartaSans(fontSize: 13, letterSpacing: 0.1),
                    controller: addOtherPatientController.lNameCont,
                    focus: addOtherPatientController.lNameFocus,
                    nextFocus: addOtherPatientController.mobileFocus,
                    textFieldType: TextFieldType.NAME,
                    decoration: inputDecoration(
                      context,
                      labelText: locale.value.lastName,
                      hintText: "${locale.value.eG}  ${locale.value.doe}",
                      fillColor: isDarkMode.value ? inputFillColorDark : inputFillColor,
                      filled: true,
                    ),
                    suffix: commonLeadingWid(imgPath: Assets.navigationIcUserOutlined, color: secondaryTextColor, size: 12).paddingAll(16),
                  ),
                  16.height,

                  /// Phone number row
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Obx(
                        () => AppTextField(
                          textStyle: GoogleFonts.plusJakartaSans(fontSize: 13, letterSpacing: 0.1),
                          textFieldType: TextFieldType.OTHER,
                          controller: TextEditingController(text: "  +${addOtherPatientController.pickedPhoneCode.value.phoneCode}"),
                          focus: addOtherPatientController.phoneCodeFocus,
                          nextFocus: addOtherPatientController.mobileFocus,
                          errorThisFieldRequired: locale.value.thisFieldIsRequired,
                          readOnly: true,
                          onTap: () {
                            pickCountry(context, onSelect: (Country country) {
                              addOtherPatientController.pickedPhoneCode(country);
                              addOtherPatientController.phoneCodeCont.text = addOtherPatientController.pickedPhoneCode.value.phoneCode;
                            });
                          },
                          textAlign: TextAlign.center,
                          decoration: inputDecoration(
                            context,
                            hintText: "",
                            prefixIcon: Text(
                              addOtherPatientController.pickedPhoneCode.value.flagEmoji,
                            ).paddingOnly(top: 2, left: 8),
                            prefixIconConstraints: BoxConstraints.tight(const Size(24, 24)),
                            suffixIcon: const Icon(
                              Icons.keyboard_arrow_down_rounded,
                              color: dividerColor,
                              size: 22,
                            ).paddingOnly(right: 32),
                            suffixIconConstraints: BoxConstraints.tight(const Size(32, 24)),
                            fillColor: isDarkMode.value ? inputFillColorDark : inputFillColor,
                            filled: true,
                          ),
                        ),
                      ).expand(flex: 4),
                      16.width,
                      AppTextField(
                        textStyle: GoogleFonts.plusJakartaSans(fontSize: 13, letterSpacing: 0.1),
                        textFieldType: TextFieldType.PHONE,
                        controller: addOtherPatientController.mobileCont,
                        focus: addOtherPatientController.mobileFocus,
                        errorThisFieldRequired: locale.value.thisFieldIsRequired,
                        keyboardType: TextInputType.phone,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        decoration: inputDecoration(
                          context,
                          labelText: locale.value.contactNumber,
                          fillColor: isDarkMode.value ? inputFillColorDark : inputFillColor,
                          filled: true,
                        ),
                        suffix: commonLeadingWid(imgPath: Assets.iconsIcCall, color: secondaryTextColor, size: 12).paddingAll(16),
                      ).expand(flex: 8),
                    ],
                  ),
                  16.height,

                  /// Date of Birth section
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        locale.value.dateOfBirth,
                        style: GoogleFonts.outfit(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          letterSpacing: -0.3,
                          color: isDarkMode.value ? Colors.white : appColorPrimary,
                        ),
                      ),
                      8.height,
                      AppTextField(
                        controller: addOtherPatientController.dateOfBirthCont,
                        textStyle: GoogleFonts.plusJakartaSans(fontSize: 13, letterSpacing: 0.1),
                        textFieldType: TextFieldType.OTHER,
                        isValidationRequired: true,
                        errorThisFieldRequired: locale.value.birthdateIsRequired,
                        validator: (value) {
                          if (addOtherPatientController.dateOfBirthCont.text.isEmpty) {
                            return locale.value.birthdateIsRequired;
                          } else {
                            return null;
                          }
                        },
                        onTap: () {
                          addOtherPatientController.pickDate(context);
                        },
                        decoration: inputDecoration(
                          context,
                          hintText: DateFormatConst.yyyy_MM_dd,
                          fillColor: isDarkMode.value ? inputFillColorDark : inputFillColor,
                          filled: true,
                        ),
                        suffix: commonLeadingWid(
                          imgPath: Assets.iconsIcCake,
                          color: secondaryTextColor,
                          size: 12,
                        ).paddingAll(16),
                      ),
                    ],
                  ),
                  16.height,

                  /// Gender selection with chip-style buttons
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        locale.value.gender,
                        style: GoogleFonts.outfit(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          letterSpacing: -0.3,
                          color: isDarkMode.value ? Colors.white : appColorPrimary,
                        ),
                      ),
                      8.height,
                      Obx(
                        () => HorizontalList(
                          itemCount: genders.length,
                          spacing: 16,
                          runSpacing: 16,
                          padding: EdgeInsets.zero,
                          itemBuilder: (context, index) {
                            return Obx(
                              () {
                                final isSelected = addOtherPatientController.selectedGender.value.id == genders[index].id;
                                return InkWell(
                                  onTap: () {
                                    addOtherPatientController.selectedGender(genders[index]);
                                  },
                                  borderRadius: BorderRadius.circular(12),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      gradient: isSelected
                                          ? const LinearGradient(colors: [gradientStart, gradientEnd])
                                          : null,
                                      color: isSelected
                                          ? null
                                          : isDarkMode.value
                                              ? surfaceElevatedDark
                                              : inputFillColor,
                                      boxShadow: isSelected
                                          ? [
                                              BoxShadow(
                                                color: appColorPrimary.withValues(alpha: 0.2),
                                                blurRadius: 8,
                                                offset: const Offset(0, 2),
                                              ),
                                            ]
                                          : null,
                                    ),
                                    child: Text(
                                      getOtherPatientGender(gender: genders[index].name),
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 13,
                                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                                        letterSpacing: 0.1,
                                        color: isSelected
                                            ? Colors.white
                                            : secondaryTextColor,
                                      ),
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                  16.height,

                  /// Relation selection with chip-style buttons
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        locale.value.relation,
                        style: GoogleFonts.outfit(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          letterSpacing: -0.3,
                          color: isDarkMode.value ? Colors.white : appColorPrimary,
                        ),
                      ),
                      8.height,
                      Obx(
                        () => AnimatedWrap(
                          itemCount: relation.length,
                          spacing: 16,
                          runSpacing: 16,
                          itemBuilder: (context, index) {
                            return Obx(
                              () {
                                final isSelected = addOtherPatientController.selectedRelation.value.id == relation[index].id;
                                return InkWell(
                                  onTap: () {
                                    addOtherPatientController.selectedRelation(relation[index]);
                                  },
                                  borderRadius: BorderRadius.circular(12),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      gradient: isSelected
                                          ? const LinearGradient(colors: [gradientStart, gradientEnd])
                                          : null,
                                      color: isSelected
                                          ? null
                                          : isDarkMode.value
                                              ? surfaceElevatedDark
                                              : inputFillColor,
                                      boxShadow: isSelected
                                          ? [
                                              BoxShadow(
                                                color: appColorPrimary.withValues(alpha: 0.2),
                                                blurRadius: 8,
                                                offset: const Offset(0, 2),
                                              ),
                                            ]
                                          : null,
                                    ),
                                    child: Text(
                                      getOtherPatientRelation(relation: relation[index].name),
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 13,
                                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                                        letterSpacing: 0.1,
                                        color: isSelected
                                            ? Colors.white
                                            : secondaryTextColor,
                                      ),
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                  32.height,

                  /// Save button with teal gradient
                  Container(
                    width: Get.width,
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
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () async {
                          hideKeyboard(context);
                          addOtherPatientController.handleAddOtherPatient();
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                          child: Center(
                            child: Text(
                              locale.value.save,
                              style: GoogleFonts.outfit(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                                letterSpacing: -0.3,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  24.height,
                ],
              ),
            ),
          ),
          Obx(() => const LoaderWidget().visible(addOtherPatientController.isLoading.value)),
        ],
      ),
    );
  }
}
