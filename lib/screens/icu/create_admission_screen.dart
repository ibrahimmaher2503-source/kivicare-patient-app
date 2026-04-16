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
import 'create_admission_controller.dart';
import 'model/hospital_model.dart';

class CreateAdmissionScreen extends StatefulWidget {
  final Hospital? preSelectedHospital;

  const CreateAdmissionScreen({
    super.key,
    this.preSelectedHospital,
  });

  @override
  State<CreateAdmissionScreen> createState() => _CreateAdmissionScreenState();
}

class _CreateAdmissionScreenState extends State<CreateAdmissionScreen> {
  late final CreateAdmissionController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.put(CreateAdmissionController());
    if (widget.preSelectedHospital != null) {
      controller.initWithHospital(widget.preSelectedHospital!);
    }
  }

  @override
  void dispose() {
    Get.delete<CreateAdmissionController>();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffoldNew(
      appBartitleText: locale.value.createAdmissionRequest,
      appBarVerticalSize: Get.mediaQuery.size.height * 0.12,
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Form(
                    key: controller.formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        16.height,

                        // Section 1: Hospital
                        _buildSectionHeader(
                          icon: Icons.local_hospital_outlined,
                          title: locale.value.hospitals,
                        ),
                        12.height,
                        Obx(() => _buildHospitalSection()),
                        24.height,

                        // Section 2: Patient Information
                        _buildSectionHeader(
                          icon: Icons.person_outline_rounded,
                          title: locale.value.patientInformation,
                        ),
                        16.height,
                        _buildPatientInfoSection(),
                        24.height,

                        // Section 3: Case Details
                        _buildSectionHeader(
                          icon: Icons.medical_information_outlined,
                          title: locale.value.caseDetailsLabel,
                        ),
                        16.height,
                        _buildCaseDetailsSection(),
                        24.height,

                        // Section 4: Emergency Contact
                        _buildSectionHeader(
                          icon: Icons.emergency_outlined,
                          title: locale.value.emergencyContact,
                        ),
                        16.height,
                        _buildEmergencyContactSection(),
                        24.height,

                        // Section 5: Payment
                        _buildSectionHeader(
                          icon: Icons.payment_outlined,
                          title: locale.value.paymentInformation,
                        ),
                        16.height,
                        Obx(() => _buildPaymentSection()),
                        24.height,

                        // Section 6: Medical Reports
                        _buildSectionHeader(
                          icon: Icons.attach_file_rounded,
                          title: locale.value.medicalReportsLabel,
                        ),
                        16.height,
                        Obx(() => _buildMedicalReportsSection()),
                        24.height,
                      ],
                    ).paddingSymmetric(horizontal: 16),
                  ),
                ),
              ),

              // Submit Button
              _buildSubmitButton(),
            ],
          ),
          Obx(() => const LoaderWidget().visible(controller.isLoading.value)),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Section Header
  // ---------------------------------------------------------------------------
  Widget _buildSectionHeader({required IconData icon, required String title}) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: appColorSecondary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: appColorSecondary, size: 20),
        ),
        12.width,
        Expanded(
          child: Text(
            title,
            style: GoogleFonts.outfit(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.3,
              color: isDarkMode.value ? Colors.white : primaryTextColor,
            ),
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Section 1: Hospital
  // ---------------------------------------------------------------------------
  Widget _buildHospitalSection() {
    final hospital = controller.selectedHospital.value;

    if (hospital != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Read-only hospital card
          Container(
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
                if (hospital.logo.isNotEmpty)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: CachedImageWidget(
                      url: hospital.logo,
                      height: 50,
                      width: 50,
                      fit: BoxFit.cover,
                      radius: 10,
                    ),
                  ),
                if (hospital.logo.isNotEmpty) 12.width,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        hospital.name,
                        style: GoogleFonts.outfit(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          letterSpacing: -0.3,
                          color: isDarkMode.value ? Colors.white : primaryTextColor,
                        ),
                      ),
                      if (hospital.address.isNotEmpty) ...[
                        4.height,
                        Text(
                          hospital.address,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            letterSpacing: 0.1,
                            color: secondaryTextColor,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Department dropdown (optional, from hospital.departments)
          if (hospital.departments.isNotEmpty) ...[
            16.height,
            DropdownButtonFormField<IcuDepartment>(
              initialValue: controller.selectedDepartment.value,
              decoration: inputDecoration(
                context,
                hintText: locale.value.icuDepartments,
                fillColor: isDarkMode.value ? inputFillColorDark : inputFillColor,
                filled: true,
              ),
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                letterSpacing: 0.1,
                color: isDarkMode.value ? Colors.white : primaryTextColor,
              ),
              dropdownColor: isDarkMode.value ? surfaceElevatedDark : surfaceElevated,
              items: hospital.departments.map((dept) {
                return DropdownMenuItem<IcuDepartment>(
                  value: dept,
                  child: Text(
                    dept.name,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      letterSpacing: 0.1,
                      color: isDarkMode.value ? Colors.white : primaryTextColor,
                    ),
                  ),
                );
              }).toList(),
              onChanged: (val) {
                controller.selectedDepartment(val);
              },
            ),
          ],
        ],
      );
    }

    // No hospital pre-selected — show a placeholder prompt
    return Container(
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
          Icon(Icons.local_hospital_outlined, color: secondaryTextColor, size: 22),
          8.width,
          Text(
            locale.value.hospitals,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.1,
              color: secondaryTextColor,
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Section 2: Patient Information
  // ---------------------------------------------------------------------------
  Widget _buildPatientInfoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Patient Name (required)
        AppTextField(
          isValidationRequired: true,
          textStyle: _inputTextStyle(),
          textFieldType: TextFieldType.NAME,
          controller: controller.patientNameCont,
          focus: controller.patientNameFocus,
          nextFocus: controller.patientAgeFocus,
          maxLength: 255,
          errorThisFieldRequired: locale.value.thisFieldIsRequired,
          decoration: inputDecoration(
            context,
            hintText: locale.value.patientName,
            fillColor: isDarkMode.value ? inputFillColorDark : inputFillColor,
            filled: true,
          ),
        ),
        16.height,

        // Patient Age (required, 0-150)
        AppTextField(
          isValidationRequired: true,
          textStyle: _inputTextStyle(),
          textFieldType: TextFieldType.PHONE,
          controller: controller.patientAgeCont,
          focus: controller.patientAgeFocus,
          nextFocus: controller.nationalIdFocus,
          errorThisFieldRequired: locale.value.thisFieldIsRequired,
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            _RangeTextInputFormatter(min: 0, max: 150),
          ],
          decoration: inputDecoration(
            context,
            hintText: locale.value.patientAge,
            fillColor: isDarkMode.value ? inputFillColorDark : inputFillColor,
            filled: true,
          ),
        ),
        16.height,

        // Patient Gender (required, male/female toggle)
        Text(
          locale.value.patientGender,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.1,
            color: secondaryTextColor,
          ),
        ),
        8.height,
        Obx(() => _buildToggleSelector(
              options: ['male', 'female'],
              labels: [locale.value.maleLabel, locale.value.femaleLabel],
              selectedValue: controller.patientGender.value,
              onChanged: (val) => controller.patientGender(val),
            )),
        16.height,

        // National ID (optional)
        AppTextField(
          isValidationRequired: false,
          textStyle: _inputTextStyle(),
          textFieldType: TextFieldType.OTHER,
          controller: controller.nationalIdCont,
          focus: controller.nationalIdFocus,
          maxLength: 50,
          decoration: inputDecoration(
            context,
            hintText: locale.value.nationalId,
            fillColor: isDarkMode.value ? inputFillColorDark : inputFillColor,
            filled: true,
          ),
        ),
        16.height,

        // Insurance Number (conditional — shown only when payment_method = insurance)
        Obx(() {
          if (controller.paymentMethod.value != 'insurance') return const SizedBox.shrink();
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppTextField(
                isValidationRequired: true,
                textStyle: _inputTextStyle(),
                textFieldType: TextFieldType.OTHER,
                controller: controller.insuranceNumberCont,
                focus: controller.insuranceNumberFocus,
                maxLength: 100,
                errorThisFieldRequired: locale.value.thisFieldIsRequired,
                decoration: inputDecoration(
                  context,
                  hintText: locale.value.insuranceNumberLabel,
                  fillColor: isDarkMode.value ? inputFillColorDark : inputFillColor,
                  filled: true,
                ),
              ),
              16.height,
            ],
          );
        }),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Section 3: Case Details
  // ---------------------------------------------------------------------------
  Widget _buildCaseDetailsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Medical Condition (required, multiline)
        AppTextField(
          isValidationRequired: true,
          textStyle: _inputTextStyle(),
          textFieldType: TextFieldType.MULTILINE,
          controller: controller.medicalConditionCont,
          focus: controller.medicalConditionFocus,
          nextFocus: controller.diagnosisFocus,
          maxLength: 5000,
          minLines: 4,
          errorThisFieldRequired: locale.value.thisFieldIsRequired,
          decoration: inputDecoration(
            context,
            hintText: locale.value.medicalCondition,
            fillColor: isDarkMode.value ? inputFillColorDark : inputFillColor,
            filled: true,
          ),
        ),
        16.height,

        // Diagnosis (optional)
        AppTextField(
          isValidationRequired: false,
          textStyle: _inputTextStyle(),
          textFieldType: TextFieldType.OTHER,
          controller: controller.diagnosisCont,
          focus: controller.diagnosisFocus,
          maxLength: 500,
          decoration: inputDecoration(
            context,
            hintText: locale.value.diagnosisLabel,
            fillColor: isDarkMode.value ? inputFillColorDark : inputFillColor,
            filled: true,
          ),
        ),
        16.height,

        // Case Type (required, dropdown with 8 IcuCaseTypeConst options)
        Text(
          locale.value.caseTypeLabel,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.1,
            color: secondaryTextColor,
          ),
        ),
        8.height,
        Obx(() => DropdownButtonFormField<String>(
              initialValue: controller.caseType.value.isEmpty ? null : controller.caseType.value,
              decoration: inputDecoration(
                context,
                hintText: locale.value.caseTypeLabel,
                fillColor: isDarkMode.value ? inputFillColorDark : inputFillColor,
                filled: true,
              ),
              style: _inputTextStyle(),
              dropdownColor: isDarkMode.value ? surfaceElevatedDark : surfaceElevated,
              items: _caseTypeOptions.map((type) {
                return DropdownMenuItem<String>(
                  value: type,
                  child: Text(
                    _caseTypeLabel(type),
                    style: _inputTextStyle(),
                  ),
                );
              }).toList(),
              onChanged: (val) {
                if (val != null) controller.caseType(val);
              },
            )),
        16.height,

        // Urgency (required, 3-option selector with color coding)
        Text(
          locale.value.urgencyLabel,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.1,
            color: secondaryTextColor,
          ),
        ),
        8.height,
        Obx(() => _buildUrgencySelector()),
        16.height,

        // Needs Ventilator (switch)
        Obx(() => _buildSwitchTile(
              label: locale.value.needsVentilator,
              value: controller.needsVentilator.value,
              onChanged: (val) => controller.needsVentilator(val),
            )),
        8.height,

        // Needs Oxygen (switch)
        Obx(() => _buildSwitchTile(
              label: locale.value.needsOxygen,
              value: controller.needsOxygen.value,
              onChanged: (val) => controller.needsOxygen(val),
            )),
        16.height,

        // Current Location (optional)
        AppTextField(
          isValidationRequired: false,
          textStyle: _inputTextStyle(),
          textFieldType: TextFieldType.OTHER,
          controller: controller.currentLocationCont,
          focus: controller.currentLocationFocus,
          nextFocus: controller.contactNameFocus,
          maxLength: 500,
          decoration: inputDecoration(
            context,
            hintText: locale.value.currentLocationLabel,
            fillColor: isDarkMode.value ? inputFillColorDark : inputFillColor,
            filled: true,
          ),
        ),
        16.height,

        // Needs Ambulance (switch)
        Obx(() => _buildSwitchTile(
              label: locale.value.needsAmbulance,
              value: controller.needsAmbulance.value,
              onChanged: (val) => controller.needsAmbulance(val),
            )),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Section 4: Emergency Contact
  // ---------------------------------------------------------------------------
  Widget _buildEmergencyContactSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Contact Name (required)
        AppTextField(
          isValidationRequired: true,
          textStyle: _inputTextStyle(),
          textFieldType: TextFieldType.NAME,
          controller: controller.contactNameCont,
          focus: controller.contactNameFocus,
          nextFocus: controller.contactPhoneFocus,
          maxLength: 255,
          errorThisFieldRequired: locale.value.thisFieldIsRequired,
          decoration: inputDecoration(
            context,
            hintText: locale.value.contactNameLabel,
            fillColor: isDarkMode.value ? inputFillColorDark : inputFillColor,
            filled: true,
          ),
        ),
        16.height,

        // Contact Phone (required)
        AppTextField(
          isValidationRequired: true,
          textStyle: _inputTextStyle(),
          textFieldType: TextFieldType.PHONE,
          controller: controller.contactPhoneCont,
          focus: controller.contactPhoneFocus,
          nextFocus: controller.relationshipFocus,
          maxLength: 50,
          errorThisFieldRequired: locale.value.thisFieldIsRequired,
          keyboardType: TextInputType.phone,
          inputFormatters: [FilteringTextInputFormatter.allow(RegExp('[0-9+]'))],
          decoration: inputDecoration(
            context,
            hintText: locale.value.contactPhoneLabel,
            fillColor: isDarkMode.value ? inputFillColorDark : inputFillColor,
            filled: true,
          ),
        ),
        16.height,

        // Relationship to Patient (optional)
        AppTextField(
          isValidationRequired: false,
          textStyle: _inputTextStyle(),
          textFieldType: TextFieldType.OTHER,
          controller: controller.relationshipCont,
          focus: controller.relationshipFocus,
          maxLength: 100,
          decoration: inputDecoration(
            context,
            hintText: locale.value.relationshipLabel,
            fillColor: isDarkMode.value ? inputFillColorDark : inputFillColor,
            filled: true,
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Section 5: Payment
  // ---------------------------------------------------------------------------
  Widget _buildPaymentSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Payment Method (required, insurance/cash toggle)
        Text(
          locale.value.paymentMethodLabel,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.1,
            color: secondaryTextColor,
          ),
        ),
        8.height,
        _buildToggleSelector(
          options: ['insurance', 'cash'],
          labels: [locale.value.insuranceLabel, locale.value.cashLabel],
          selectedValue: controller.paymentMethod.value,
          onChanged: (val) => controller.paymentMethod(val),
        ),
        16.height,

        // Insurance Provider (conditional — shown only when insurance selected)
        if (controller.paymentMethod.value == 'insurance') ...[
          AppTextField(
            isValidationRequired: true,
            textStyle: _inputTextStyle(),
            textFieldType: TextFieldType.OTHER,
            controller: controller.insuranceProviderCont,
            focus: controller.insuranceProviderFocus,
            maxLength: 255,
            errorThisFieldRequired: locale.value.thisFieldIsRequired,
            decoration: inputDecoration(
              context,
              hintText: locale.value.insuranceProviderLabel,
              fillColor: isDarkMode.value ? inputFillColorDark : inputFillColor,
              filled: true,
            ),
          ),
        ],
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Section 6: Medical Reports
  // ---------------------------------------------------------------------------
  Widget _buildMedicalReportsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Attach Reports button
        GestureDetector(
          onTap: () => controller.pickFiles(),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color: isDarkMode.value ? inputFillColorDark : inputFillColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: appColorSecondary.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.upload_file_rounded, color: appColorSecondary, size: 22),
                8.width,
                Text(
                  locale.value.attachReports,
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
        ),
        8.height,

        // Supported formats hint
        Text(
          locale.value.supportedFileFormats,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 11,
            letterSpacing: 0.1,
            color: secondaryTextColor,
          ),
        ),

        // Attached files list
        if (controller.medicalReports.isNotEmpty) ...[
          12.height,
          ...List.generate(controller.medicalReports.length, (index) {
            final file = controller.medicalReports[index];
            final fileName = file.path.split('/').last.split('\\').last;
            final fileSizeBytes = file.lengthSync();
            final fileSizeStr = _formatFileSize(fileSizeBytes);

            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: isDarkMode.value ? surfaceElevatedDark : surfaceElevated,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: isDarkMode.value ? softShadowColorDark : softShadowColor,
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Icon(
                    _fileIcon(fileName),
                    color: appColorSecondary,
                    size: 20,
                  ),
                  12.width,
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          fileName,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0.1,
                            color: isDarkMode.value ? Colors.white : primaryTextColor,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        2.height,
                        Text(
                          fileSizeStr,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11,
                            letterSpacing: 0.1,
                            color: secondaryTextColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  8.width,
                  GestureDetector(
                    onTap: () => controller.removeFile(index),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: cancelStatusColor.withValues(alpha: 0.1),
                      ),
                      child: Icon(Icons.close, color: cancelStatusColor, size: 16),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Submit Button
  // ---------------------------------------------------------------------------
  Widget _buildSubmitButton() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Obx(() => GestureDetector(
              onTap: controller.isLoading.value
                  ? null
                  : () async {
                      await controller.submitRequest();
                    },
              child: AnimatedOpacity(
                opacity: controller.isLoading.value ? 0.6 : 1.0,
                duration: const Duration(milliseconds: 200),
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
            )),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Reusable toggle selector (two-option pill)
  // ---------------------------------------------------------------------------
  Widget _buildToggleSelector({
    required List<String> options,
    required List<String> labels,
    required String selectedValue,
    required ValueChanged<String> onChanged,
  }) {
    return Row(
      children: List.generate(options.length, (index) {
        final isSelected = selectedValue == options[index];
        return Expanded(
          child: GestureDetector(
            onTap: () => onChanged(options[index]),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(vertical: 12),
              margin: EdgeInsets.only(right: index == 0 ? 8 : 0, left: index == 1 ? 8 : 0),
              decoration: BoxDecoration(
                color: isSelected
                    ? appColorSecondary.withValues(alpha: 0.12)
                    : (isDarkMode.value ? inputFillColorDark : inputFillColor),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected ? appColorSecondary : (isDarkMode.value ? borderColorDark : borderColor),
                  width: isSelected ? 1.5 : 1,
                ),
              ),
              child: Text(
                labels[index],
                textAlign: TextAlign.center,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  letterSpacing: 0.1,
                  color: isSelected ? appColorSecondary : secondaryTextColor,
                ),
              ),
            ),
          ),
        );
      }),
    );
  }

  // ---------------------------------------------------------------------------
  // Urgency selector with color coding
  // ---------------------------------------------------------------------------
  Widget _buildUrgencySelector() {
    final urgencyOptions = [
      (value: IcuUrgencyConst.critical, label: locale.value.criticalLabel, color: urgencyCriticalColor),
      (value: IcuUrgencyConst.urgent, label: locale.value.urgentLabel, color: urgencyUrgentColor),
      (value: IcuUrgencyConst.standard, label: locale.value.standardLabel, color: urgencyStandardColor),
    ];

    return Row(
      children: urgencyOptions.map((option) {
        final isSelected = controller.urgency.value == option.value;
        return Expanded(
          child: GestureDetector(
            onTap: () => controller.urgency(option.value),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(vertical: 12),
              margin: EdgeInsets.only(
                right: option.value != IcuUrgencyConst.standard ? 6 : 0,
                left: option.value != IcuUrgencyConst.critical ? 6 : 0,
              ),
              decoration: BoxDecoration(
                color: isSelected
                    ? option.color.withValues(alpha: 0.12)
                    : (isDarkMode.value ? inputFillColorDark : inputFillColor),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected ? option.color : (isDarkMode.value ? borderColorDark : borderColor),
                  width: isSelected ? 1.5 : 1,
                ),
              ),
              child: Text(
                option.label,
                textAlign: TextAlign.center,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  letterSpacing: 0.1,
                  color: isSelected ? option.color : secondaryTextColor,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  // ---------------------------------------------------------------------------
  // Switch tile for boolean toggles
  // ---------------------------------------------------------------------------
  Widget _buildSwitchTile({
    required String label,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: isDarkMode.value ? surfaceElevatedDark : surfaceElevated,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.1,
                color: isDarkMode.value ? Colors.white : primaryTextColor,
              ),
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: Colors.white,
            activeTrackColor: appColorSecondary,
            inactiveThumbColor: Colors.white,
            inactiveTrackColor: isDarkMode.value ? borderColorDark : borderColor,
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  TextStyle _inputTextStyle() {
    return GoogleFonts.plusJakartaSans(
      fontSize: 12,
      letterSpacing: 0.1,
      color: isDarkMode.value ? Colors.white : primaryTextColor,
    );
  }

  /// All 8 case type constant values.
  List<String> get _caseTypeOptions => [
        IcuCaseTypeConst.stroke,
        IcuCaseTypeConst.cardiac,
        IcuCaseTypeConst.postOperative,
        IcuCaseTypeConst.ventilator,
        IcuCaseTypeConst.neonatal,
        IcuCaseTypeConst.pediatric,
        IcuCaseTypeConst.burns,
        IcuCaseTypeConst.general,
      ];

  /// Converts a case type constant value into a human-readable label.
  String _caseTypeLabel(String type) {
    switch (type) {
      case IcuCaseTypeConst.stroke:
        return locale.value.caseTypeStroke;
      case IcuCaseTypeConst.cardiac:
        return locale.value.caseTypeCardiac;
      case IcuCaseTypeConst.postOperative:
        return locale.value.caseTypePostOperative;
      case IcuCaseTypeConst.ventilator:
        return locale.value.caseTypeVentilator;
      case IcuCaseTypeConst.neonatal:
        return locale.value.caseTypeNeonatal;
      case IcuCaseTypeConst.pediatric:
        return locale.value.caseTypePediatric;
      case IcuCaseTypeConst.burns:
        return locale.value.caseTypeBurns;
      case IcuCaseTypeConst.general:
        return locale.value.caseTypeGeneral;
      default:
        return type;
    }
  }

  /// Returns an icon based on the file extension.
  IconData _fileIcon(String fileName) {
    final ext = fileName.split('.').last.toLowerCase();
    switch (ext) {
      case 'pdf':
        return Icons.picture_as_pdf_rounded;
      case 'jpg':
      case 'jpeg':
      case 'png':
        return Icons.image_outlined;
      case 'doc':
      case 'docx':
        return Icons.description_outlined;
      default:
        return Icons.insert_drive_file_outlined;
    }
  }

  /// Formats byte count into a human-readable size string.
  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
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
