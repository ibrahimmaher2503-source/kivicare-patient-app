import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../components/app_scaffold.dart';
import '../../components/cached_image_widget.dart';
import '../../components/loader_widget.dart';
import '../../main.dart';
import '../../utils/app_common.dart';
import '../../utils/colors.dart';
import '../../utils/common_base.dart';
import '../../utils/constants.dart';
import 'create_nurse_request_controller.dart';
import 'model/nurse_model.dart';
import 'model/nurse_request_model.dart';
import 'nurse_list_screen.dart';

class CreateNurseRequestScreen extends StatefulWidget {
  final Nurse? preSelectedNurse;
  final NurseRequest? editRequest;

  const CreateNurseRequestScreen({
    super.key,
    this.preSelectedNurse,
    this.editRequest,
  });

  @override
  State<CreateNurseRequestScreen> createState() => _CreateNurseRequestScreenState();
}

class _CreateNurseRequestScreenState extends State<CreateNurseRequestScreen> {
  late final CreateNurseRequestController controller;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    controller = Get.put(CreateNurseRequestController());
    if (widget.preSelectedNurse != null) {
      controller.setNurse(widget.preSelectedNurse!);
    }
    if (widget.editRequest != null) {
      controller.initForEdit(widget.editRequest!);
    }
  }

  @override
  void dispose() {
    Get.delete<CreateNurseRequestController>();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffoldNew(
      appBartitleText: controller.isEditMode ? locale.value.editNurseRequest : locale.value.createNurseRequest,
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

                        // Section: Select Nurse
                        Text(
                          locale.value.selectNurse,
                          style: GoogleFonts.outfit(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            letterSpacing: -0.3,
                            color: isDarkMode.value ? Colors.white : primaryTextColor,
                          ),
                        ),
                        12.height,
                        Obx(() => _buildNurseSelector(context)),
                        24.height,

                        // Section: Service Details
                        Text(
                          locale.value.serviceDescription,
                          style: GoogleFonts.outfit(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            letterSpacing: -0.3,
                            color: isDarkMode.value ? Colors.white : primaryTextColor,
                          ),
                        ),
                        16.height,

                        // Service Description
                        AppTextField(
                          isValidationRequired: true,
                          textStyle: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            letterSpacing: 0.1,
                            color: isDarkMode.value ? Colors.white : primaryTextColor,
                          ),
                          textFieldType: TextFieldType.MULTILINE,
                          controller: controller.serviceDescriptionCont,
                          focus: controller.serviceDescriptionFocus,
                          nextFocus: controller.durationHoursFocus,
                          maxLength: 500,
                          minLines: 3,
                          errorThisFieldRequired: locale.value.thisFieldIsRequired,
                          decoration: inputDecoration(
                            context,
                            hintText: locale.value.serviceDescription,
                            fillColor: isDarkMode.value ? inputFillColorDark : inputFillColor,
                            filled: true,
                          ),
                        ),
                        16.height,

                        // Preferred Date
                        AppTextField(
                          isValidationRequired: true,
                          textStyle: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            letterSpacing: 0.1,
                            color: isDarkMode.value ? Colors.white : primaryTextColor,
                          ),
                          textFieldType: TextFieldType.OTHER,
                          controller: controller.preferredDateCont,
                          readOnly: true,
                          onTap: () => _pickDate(context),
                          errorThisFieldRequired: locale.value.thisFieldIsRequired,
                          decoration: inputDecoration(
                            context,
                            hintText: locale.value.preferredDate,
                            fillColor: isDarkMode.value ? inputFillColorDark : inputFillColor,
                            filled: true,
                            suffixIcon: const Icon(Icons.calendar_today_outlined, color: secondaryTextColor, size: 20).paddingAll(12),
                          ),
                        ),
                        16.height,

                        // Preferred Time
                        AppTextField(
                          isValidationRequired: true,
                          textStyle: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            letterSpacing: 0.1,
                            color: isDarkMode.value ? Colors.white : primaryTextColor,
                          ),
                          textFieldType: TextFieldType.OTHER,
                          controller: controller.preferredTimeCont,
                          readOnly: true,
                          onTap: () => _pickTime(context),
                          errorThisFieldRequired: locale.value.thisFieldIsRequired,
                          decoration: inputDecoration(
                            context,
                            hintText: locale.value.preferredTime,
                            fillColor: isDarkMode.value ? inputFillColorDark : inputFillColor,
                            filled: true,
                            suffixIcon: const Icon(Icons.access_time_outlined, color: secondaryTextColor, size: 20).paddingAll(12),
                          ),
                        ),
                        16.height,

                        // Duration Hours (1-24)
                        AppTextField(
                          isValidationRequired: true,
                          textStyle: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            letterSpacing: 0.1,
                            color: isDarkMode.value ? Colors.white : primaryTextColor,
                          ),
                          textFieldType: TextFieldType.PHONE,
                          controller: controller.durationHoursCont,
                          focus: controller.durationHoursFocus,
                          nextFocus: controller.contactNumberFocus,
                          errorThisFieldRequired: locale.value.thisFieldIsRequired,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            _RangeTextInputFormatter(min: 1, max: 24),
                          ],
                          decoration: inputDecoration(
                            context,
                            hintText: locale.value.durationHours,
                            fillColor: isDarkMode.value ? inputFillColorDark : inputFillColor,
                            filled: true,
                          ),
                        ),
                        16.height,

                        // Contact Number
                        AppTextField(
                          textStyle: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            letterSpacing: 0.1,
                            color: isDarkMode.value ? Colors.white : primaryTextColor,
                          ),
                          textFieldType: TextFieldType.PHONE,
                          controller: controller.contactNumberCont,
                          focus: controller.contactNumberFocus,
                          nextFocus: controller.patientNotesFocus,
                          errorThisFieldRequired: locale.value.thisFieldIsRequired,
                          keyboardType: TextInputType.phone,
                          inputFormatters: [FilteringTextInputFormatter.allow(RegExp('[0-9+]'))],
                          decoration: inputDecoration(
                            context,
                            hintText: locale.value.contactNumber,
                            fillColor: isDarkMode.value ? inputFillColorDark : inputFillColor,
                            filled: true,
                          ),
                        ),
                        16.height,

                        // Patient Notes (optional)
                        AppTextField(
                          isValidationRequired: false,
                          textStyle: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            letterSpacing: 0.1,
                            color: isDarkMode.value ? Colors.white : primaryTextColor,
                          ),
                          textFieldType: TextFieldType.MULTILINE,
                          controller: controller.patientNotesCont,
                          focus: controller.patientNotesFocus,
                          nextFocus: controller.addressLine1Focus,
                          maxLength: 500,
                          minLines: 3,
                          decoration: inputDecoration(
                            context,
                            hintText: locale.value.patientNotes,
                            fillColor: isDarkMode.value ? inputFillColorDark : inputFillColor,
                            filled: true,
                          ),
                        ),
                        24.height,

                        // Section: Address
                        Text(
                          locale.value.addressLine1,
                          style: GoogleFonts.outfit(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            letterSpacing: -0.3,
                            color: isDarkMode.value ? Colors.white : primaryTextColor,
                          ),
                        ),
                        16.height,

                        // Address Line 1
                        AppTextField(
                          isValidationRequired: true,
                          textStyle: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            letterSpacing: 0.1,
                            color: isDarkMode.value ? Colors.white : primaryTextColor,
                          ),
                          textFieldType: TextFieldType.OTHER,
                          controller: controller.addressLine1Cont,
                          focus: controller.addressLine1Focus,
                          nextFocus: controller.addressLine2Focus,
                          errorThisFieldRequired: locale.value.thisFieldIsRequired,
                          decoration: inputDecoration(
                            context,
                            hintText: locale.value.addressLine1,
                            fillColor: isDarkMode.value ? inputFillColorDark : inputFillColor,
                            filled: true,
                          ),
                        ),
                        16.height,

                        // Address Line 2 (optional)
                        AppTextField(
                          isValidationRequired: false,
                          textStyle: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            letterSpacing: 0.1,
                            color: isDarkMode.value ? Colors.white : primaryTextColor,
                          ),
                          textFieldType: TextFieldType.OTHER,
                          controller: controller.addressLine2Cont,
                          focus: controller.addressLine2Focus,
                          nextFocus: controller.cityFocus,
                          decoration: inputDecoration(
                            context,
                            hintText: locale.value.addressLine2,
                            fillColor: isDarkMode.value ? inputFillColorDark : inputFillColor,
                            filled: true,
                          ),
                        ),
                        16.height,

                        // City + State row
                        Row(
                          children: [
                            Expanded(
                              child: AppTextField(
                                isValidationRequired: true,
                                textStyle: GoogleFonts.plusJakartaSans(
                                  fontSize: 12,
                                  letterSpacing: 0.1,
                                  color: isDarkMode.value ? Colors.white : primaryTextColor,
                                ),
                                textFieldType: TextFieldType.OTHER,
                                controller: controller.cityCont,
                                focus: controller.cityFocus,
                                nextFocus: controller.stateFocus,
                                errorThisFieldRequired: locale.value.thisFieldIsRequired,
                                decoration: inputDecoration(
                                  context,
                                  hintText: locale.value.city,
                                  fillColor: isDarkMode.value ? inputFillColorDark : inputFillColor,
                                  filled: true,
                                ),
                              ),
                            ),
                            16.width,
                            Expanded(
                              child: AppTextField(
                                isValidationRequired: false,
                                textStyle: GoogleFonts.plusJakartaSans(
                                  fontSize: 12,
                                  letterSpacing: 0.1,
                                  color: isDarkMode.value ? Colors.white : primaryTextColor,
                                ),
                                textFieldType: TextFieldType.OTHER,
                                controller: controller.stateCont,
                                focus: controller.stateFocus,
                                nextFocus: controller.countryFocus,
                                decoration: inputDecoration(
                                  context,
                                  // TODO: Add locale getter for 'State' when available
                                  hintText: 'State',
                                  fillColor: isDarkMode.value ? inputFillColorDark : inputFillColor,
                                  filled: true,
                                ),
                              ),
                            ),
                          ],
                        ),
                        16.height,

                        // Country + Postal Code row
                        Row(
                          children: [
                            Expanded(
                              child: AppTextField(
                                isValidationRequired: false,
                                textStyle: GoogleFonts.plusJakartaSans(
                                  fontSize: 12,
                                  letterSpacing: 0.1,
                                  color: isDarkMode.value ? Colors.white : primaryTextColor,
                                ),
                                textFieldType: TextFieldType.OTHER,
                                controller: controller.countryCont,
                                focus: controller.countryFocus,
                                nextFocus: controller.postalCodeFocus,
                                decoration: inputDecoration(
                                  context,
                                  // TODO: Add locale getter for 'Country' when available
                                  hintText: 'Country',
                                  fillColor: isDarkMode.value ? inputFillColorDark : inputFillColor,
                                  filled: true,
                                ),
                              ),
                            ),
                            16.width,
                            Expanded(
                              child: AppTextField(
                                isValidationRequired: false,
                                textStyle: GoogleFonts.plusJakartaSans(
                                  fontSize: 12,
                                  letterSpacing: 0.1,
                                  color: isDarkMode.value ? Colors.white : primaryTextColor,
                                ),
                                textFieldType: TextFieldType.OTHER,
                                controller: controller.postalCodeCont,
                                focus: controller.postalCodeFocus,
                                decoration: inputDecoration(
                                  context,
                                  hintText: locale.value.postalCode,
                                  fillColor: isDarkMode.value ? inputFillColorDark : inputFillColor,
                                  filled: true,
                                ),
                              ),
                            ),
                          ],
                        ),
                        16.height,
                      ],
                    ).paddingSymmetric(horizontal: 16),
                  ),
                ),
              ),

              // Submit Button
              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: GestureDetector(
                    onTap: () async {
                      if (formKey.currentState?.validate() ?? false) {
                        if (controller.selectedNurse.value == null) {
                          toast(locale.value.selectNurse);
                          return;
                        }
                        if (controller.isEditMode) {
                          await controller.updateRequest();
                        } else {
                          await controller.submitRequest();
                        }
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

  Widget _buildNurseSelector(BuildContext context) {
    final nurse = controller.selectedNurse.value;

    if (nurse != null) {
      return GestureDetector(
        onTap: () => _navigateToSelectNurse(),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isDarkMode.value ? surfaceElevatedDark : surfaceElevated,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: isDarkMode.value ? softShadowColorDark : softShadowColor,
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: CachedImageWidget(
                  url: nurse.profileImage,
                  height: 50,
                  width: 50,
                  fit: BoxFit.cover,
                  radius: 10,
                ),
              ),
              12.width,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      nurse.name,
                      style: GoogleFonts.outfit(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        letterSpacing: -0.3,
                        color: isDarkMode.value ? Colors.white : primaryTextColor,
                      ),
                    ),
                    4.height,
                    if (nurse.specialization.isNotEmpty)
                      Text(
                        nurse.specialization,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          letterSpacing: 0.1,
                          color: appColorSecondary,
                        ),
                      ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: secondaryTextColor),
            ],
          ),
        ),
      );
    }

    return GestureDetector(
      onTap: () => _navigateToSelectNurse(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: isDarkMode.value ? inputFillColorDark : inputFillColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDarkMode.value ? borderColorDark : borderColor,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_circle_outline_rounded, color: appColorSecondary, size: 22),
            8.width,
            Text(
              locale.value.selectNurse,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.1,
                color: appColorSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToSelectNurse() {
    // Navigate to nurse list for selection
    Get.to(() => NurseListScreen())?.then((_) {
      // Selection is handled via the controller
    });
  }

  Future<void> _pickDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: appColorSecondary,
              onPrimary: Colors.white,
              surface: isDarkMode.value ? surfaceElevatedDark : surfaceElevated,
              onSurface: isDarkMode.value ? Colors.white : primaryTextColor,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      controller.preferredDateCont.text = '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
    }
  }

  Future<void> _pickTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: appColorSecondary,
              onPrimary: Colors.white,
              surface: isDarkMode.value ? surfaceElevatedDark : surfaceElevated,
              onSurface: isDarkMode.value ? Colors.white : primaryTextColor,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      controller.preferredTimeCont.text = '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
    }
  }
}

class _RangeTextInputFormatter extends TextInputFormatter {
  final int min;
  final int max;

  _RangeTextInputFormatter({required this.min, required this.max});

  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.isEmpty) return newValue;
    final intValue = int.tryParse(newValue.text);
    if (intValue == null) return oldValue;
    if (intValue < min || intValue > max) return oldValue;
    return newValue;
  }
}
