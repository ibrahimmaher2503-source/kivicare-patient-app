import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nb_utils/nb_utils.dart';
import '../../../../components/loader_widget.dart';
import '../../../../main.dart';
import '../../../../utils/common_base.dart';
import '../../../components/app_scaffold.dart';
import '../../../generated/assets.dart';
import '../../../utils/colors.dart';
import '../../../utils/constants.dart';
import 'common_profile_widget.dart';
import 'edit_user_profile_controller.dart';
import '../../../utils/app_common.dart';

class EditUserProfileScreen extends StatelessWidget {
  EditUserProfileScreen({super.key});
  final EditUserProfileController editUserProfileController = Get.put(EditUserProfileController());
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return AppScaffoldNew(
      appBartitleText: locale.value.editProfile,
      appBarVerticalSize: Get.height * 0.12,
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  24.height,
                  // Profile Photo Section
                  Obx(() => ProfilePicWidget(
                        heroTag: editUserProfileController.imageFile.value.path.isNotEmpty
                            ? editUserProfileController.imageFile.value.path
                            : loginUserData.value.profileImage.isNotEmpty
                                ? loginUserData.value.profileImage
                                : loginUserData.value.profileImage,
                        profileImage: editUserProfileController.imageFile.value.path.isNotEmpty
                            ? editUserProfileController.imageFile.value.path
                            : loginUserData.value.profileImage.isNotEmpty
                                ? loginUserData.value.profileImage
                                : loginUserData.value.profileImage,
                        firstName: loginUserData.value.firstName,
                        lastName: loginUserData.value.lastName,
                        userName: loginUserData.value.userName,
                        showOnlyPhoto: true,
                        onCameraTap: () {
                          hideKeyboard(context);
                          editUserProfileController.showBottomSheet(context);
                        },
                        onPicTap: () {
                          hideKeyboard(context);
                          editUserProfileController.showBottomSheet(context);
                        },
                      )),

                  // Personal Information Section
                  32.height,
                  _buildSectionLabel(context, locale.value.firstName.toUpperCase()),
                  8.height,
                  AppTextField(
                    textStyle: primaryTextStyle(size: 14),
                    controller: editUserProfileController.fNameCont,
                    focus: editUserProfileController.fNameFocus,
                    nextFocus: editUserProfileController.lNameFocus,
                    textFieldType: TextFieldType.NAME,
                    decoration: inputDecoration(
                      context,
                      labelText: locale.value.firstName,
                      hintText: "${locale.value.eG}  ${locale.value.merry}",
                    ),
                    suffix: commonLeadingWid(imgPath: Assets.navigationIcUserOutlined, color: secondaryTextColor, size: 12).paddingAll(16),
                  ),
                  16.height,
                  AppTextField(
                    textStyle: primaryTextStyle(size: 14),
                    controller: editUserProfileController.lNameCont,
                    focus: editUserProfileController.lNameFocus,
                    nextFocus: editUserProfileController.emailFocus,
                    textFieldType: TextFieldType.NAME,
                    decoration: inputDecoration(
                      context,
                      labelText: locale.value.lastName,
                      hintText: "${locale.value.eG}  ${locale.value.doe}",
                    ),
                    suffix: commonLeadingWid(imgPath: Assets.navigationIcUserOutlined, color: secondaryTextColor, size: 12).paddingAll(16),
                  ),

                  // Contact Information Section
                  24.height,
                  _buildSectionLabel(context, locale.value.email.toUpperCase()),
                  8.height,
                  AppTextField(
                    textStyle: primaryTextStyle(size: 14),
                    controller: editUserProfileController.emailCont,
                    focus: editUserProfileController.emailFocus,
                    nextFocus: editUserProfileController.mobileFocus,
                    readOnly: loginUserData.value.isSocialLoginType,
                    textFieldType: TextFieldType.EMAIL_ENHANCED,
                    decoration: inputDecoration(
                      context,
                      labelText: locale.value.email,
                    ),
                    suffix: commonLeadingWid(imgPath: Assets.iconsIcMail, color: secondaryTextColor, size: 12).paddingAll(16),
                  ),
                  16.height,
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Obx(
                        () => AppTextField(
                          textStyle: primaryTextStyle(size: 14),
                          textFieldType: TextFieldType.OTHER,
                          controller: TextEditingController(text: " +${editUserProfileController.pickedPhoneCode.value.phoneCode}"),
                          focus: editUserProfileController.phoneCodeFocus,
                          nextFocus: editUserProfileController.mobileFocus,
                          errorThisFieldRequired: locale.value.thisFieldIsRequired,
                          readOnly: true,
                          onTap: () {
                            pickCountry(context, onSelect: (Country country) {
                              editUserProfileController.pickedPhoneCode(country);
                              editUserProfileController.phoneCodeCont.text = editUserProfileController.pickedPhoneCode.value.phoneCode;
                            });
                          },
                          textAlign: TextAlign.center,
                          decoration: inputDecoration(
                            context,
                            hintText: "",
                            prefixIcon: Text(
                              editUserProfileController.pickedPhoneCode.value.flagEmoji,
                            ).paddingOnly(top: 2, left: 8),
                            prefixIconConstraints: BoxConstraints.tight(const Size(24, 24)),
                            suffixIcon: const Icon(
                              Icons.keyboard_arrow_down_rounded,
                              color: dividerColor,
                              size: 22,
                            ).paddingOnly(right: 32),
                            suffixIconConstraints: BoxConstraints.tight(const Size(24, 24)),
                          ),
                        ),
                      ).expand(flex: 3),
                      16.width,
                      AppTextField(
                        textStyle: primaryTextStyle(size: 14),
                        textFieldType: TextFieldType.PHONE,
                        controller: editUserProfileController.mobileCont,
                        focus: editUserProfileController.mobileFocus,
                        errorThisFieldRequired: locale.value.thisFieldIsRequired,
                        keyboardType: TextInputType.phone,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        decoration: inputDecoration(
                          context,
                          labelText: locale.value.contactNumber,
                        ),
                        suffix: commonLeadingWid(imgPath: Assets.iconsIcCall, color: secondaryTextColor, size: 12).paddingAll(16),
                      ).expand(flex: 8),
                    ],
                  ),

                  // Address Section
                  24.height,
                  _buildSectionLabel(context, locale.value.address.toUpperCase()),
                  8.height,
                  AppTextField(
                    isValidationRequired: false,
                    textStyle: primaryTextStyle(size: 14),
                    textFieldType: TextFieldType.MULTILINE,
                    controller: editUserProfileController.addressCont,
                    focus: editUserProfileController.addressFocus,
                    errorThisFieldRequired: locale.value.thisFieldIsRequired,
                    decoration: inputDecoration(
                      context,
                      labelText: locale.value.address,
                      hintText: "${locale.value.eG} 123, ${locale.value.mainStreet}",
                    ),
                  ),

                  // Gender & DOB Section
                  24.height,
                  _buildSectionLabel(context, locale.value.gender.toUpperCase()),
                  8.height,
                  Obx(
                    () => HorizontalList(
                      itemCount: genders.length,
                      spacing: 12,
                      runSpacing: 12,
                      padding: EdgeInsets.zero,
                      itemBuilder: (context, index) {
                        return Obx(
                          () {
                            final isSelected = editUserProfileController.selectedGender.value.id == genders[index].id;
                            return InkWell(
                              onTap: () {
                                editUserProfileController.selectedGender(genders[index]);
                                loginUserData.value.gender = editUserProfileController.selectedGender.value.slug;
                              },
                              borderRadius: BorderRadius.circular(12),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? appColorPrimary
                                      : (isDarkMode.value ? inputFillColorDark : inputFillColor),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: isSelected
                                        ? appColorPrimary
                                        : (isDarkMode.value ? borderColorDark : borderColor.withValues(alpha: 0.3)),
                                    width: isSelected ? 1.5 : 1,
                                  ),
                                ),
                                child: Text(
                                  genders[index].name,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 13,
                                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                                    color: isSelected ? Colors.white : (isDarkMode.value ? Colors.white70 : secondaryTextColor),
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                  24.height,
                  _buildSectionLabel(context, locale.value.dateOfBirth.toUpperCase()),
                  8.height,
                  AppTextField(
                    controller: editUserProfileController.dateOfBirthCont,
                    textStyle: primaryTextStyle(size: 14),
                    textFieldType: TextFieldType.OTHER,
                    readOnly: true,
                    onTap: () {
                      editUserProfileController.pickDate(context);
                    },
                    decoration: inputDecoration(
                      context,
                      hintText: DateFormatConst.DD_MM_YYYY,
                    ),
                    suffix: const Icon(
                      Icons.calendar_today,
                      color: secondaryTextColor,
                    ).paddingAll(16),
                  ),

                  // Save Button
                  40.height,
                  _buildSaveButton(context),
                  32.height,
                ],
              ),
            ).paddingSymmetric(horizontal: 24),
          ),
          Obx(() => const LoaderWidget().visible(editUserProfileController.isLoading.value)),
        ],
      ),
    );
  }

  Widget _buildSectionLabel(BuildContext context, String label) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        label,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: secondaryTextColor,
          letterSpacing: 1.0,
        ),
      ),
    );
  }

  Widget _buildSaveButton(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        editUserProfileController.updateUserProfile();
      },
      child: Container(
        width: Get.width,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [gradientSecondaryStart, gradientSecondaryEnd],
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: gradientSecondaryStart.withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: Text(
            locale.value.update,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              letterSpacing: 0.3,
            ),
          ),
        ),
      ),
    );
  }
}
