import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../api/core_apis.dart';
import '../../main.dart';
import 'model/hospital_model.dart';

class CreateAdmissionController extends GetxController {
  // Form key
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  // Hospital & Department
  Rx<Hospital?> selectedHospital = Rx<Hospital?>(null);
  Rx<IcuDepartment?> selectedDepartment = Rx<IcuDepartment?>(null);

  // Patient Information controllers
  TextEditingController patientNameCont = TextEditingController();
  TextEditingController patientAgeCont = TextEditingController();
  TextEditingController nationalIdCont = TextEditingController();
  TextEditingController insuranceNumberCont = TextEditingController();

  // Case Details controllers
  TextEditingController medicalConditionCont = TextEditingController();
  TextEditingController diagnosisCont = TextEditingController();
  TextEditingController currentLocationCont = TextEditingController();

  // Emergency Contact controllers
  TextEditingController contactNameCont = TextEditingController();
  TextEditingController contactPhoneCont = TextEditingController();
  TextEditingController relationshipCont = TextEditingController();

  // Payment controllers
  TextEditingController insuranceProviderCont = TextEditingController();

  // Focus nodes
  FocusNode patientNameFocus = FocusNode();
  FocusNode patientAgeFocus = FocusNode();
  FocusNode nationalIdFocus = FocusNode();
  FocusNode insuranceNumberFocus = FocusNode();
  FocusNode medicalConditionFocus = FocusNode();
  FocusNode diagnosisFocus = FocusNode();
  FocusNode currentLocationFocus = FocusNode();
  FocusNode contactNameFocus = FocusNode();
  FocusNode contactPhoneFocus = FocusNode();
  FocusNode relationshipFocus = FocusNode();
  FocusNode insuranceProviderFocus = FocusNode();

  // Reactive state
  RxString patientGender = ''.obs;
  RxString caseType = ''.obs;
  RxString urgency = ''.obs;
  RxString paymentMethod = ''.obs;
  RxBool needsVentilator = false.obs;
  RxBool needsOxygen = false.obs;
  RxBool needsAmbulance = false.obs;
  RxList<File> medicalReports = RxList<File>();
  RxBool isLoading = false.obs;

  /// Pre-sets hospital when navigated from hospital detail screen.
  void initWithHospital(Hospital hospital) {
    selectedHospital(hospital);
  }

  /// Opens a file picker for medical reports (pdf, jpg, png, doc, docx).
  /// Validates each file is under 10MB before adding.
  Future<void> pickFiles() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png', 'doc', 'docx'],
        allowMultiple: true,
      );

      if (result != null && result.files.isNotEmpty) {
        for (final platformFile in result.files) {
          if (platformFile.path == null) continue;

          // Validate file size (max 10MB)
          final file = File(platformFile.path!);
          final fileSizeInMB = file.lengthSync() / (1024 * 1024);

          if (fileSizeInMB > 10) {
            toast('${platformFile.name} exceeds 10MB limit');
            continue;
          }

          medicalReports.add(file);
        }
      }
    } catch (e) {
      toast(e.toString());
      log("pickFiles error: $e");
    }
  }

  /// Removes a file from the medical reports list at the given index.
  void removeFile(int index) {
    if (index >= 0 && index < medicalReports.length) {
      medicalReports.removeAt(index);
    }
  }

  /// Validates all required fields including conditional insurance validation.
  /// Returns true if the form is valid.
  bool validateForm() {
    if (!(formKey.currentState?.validate() ?? false)) return false;

    if (selectedHospital.value == null) {
      toast(locale.value.thisFieldIsRequired);
      return false;
    }

    if (patientGender.value.isEmpty) {
      toast(locale.value.thisFieldIsRequired);
      return false;
    }

    if (caseType.value.isEmpty) {
      toast(locale.value.thisFieldIsRequired);
      return false;
    }

    if (urgency.value.isEmpty) {
      toast(locale.value.thisFieldIsRequired);
      return false;
    }

    if (paymentMethod.value.isEmpty) {
      toast(locale.value.thisFieldIsRequired);
      return false;
    }

    // Conditional insurance validation
    if (paymentMethod.value == 'insurance') {
      if (insuranceNumberCont.text.trim().isEmpty) {
        toast(locale.value.thisFieldIsRequired);
        return false;
      }
      if (insuranceProviderCont.text.trim().isEmpty) {
        toast(locale.value.thisFieldIsRequired);
        return false;
      }
    }

    return true;
  }

  /// Builds the flat request map matching the API contract for multipart submission.
  Map<String, dynamic> _buildRequestBody() {
    final body = <String, dynamic>{
      'hospital_id': selectedHospital.value!.id,
      'patient_name': patientNameCont.text.trim(),
      'patient_age': patientAgeCont.text.trim(),
      'patient_gender': patientGender.value,
      'medical_condition': medicalConditionCont.text.trim(),
      'case_type': caseType.value,
      'urgency': urgency.value,
      'needs_ventilator': needsVentilator.value ? '1' : '0',
      'needs_oxygen': needsOxygen.value ? '1' : '0',
      'needs_ambulance': needsAmbulance.value ? '1' : '0',
      'contact_name': contactNameCont.text.trim(),
      'contact_phone': contactPhoneCont.text.trim(),
      'payment_method': paymentMethod.value,
    };

    // Optional fields
    if (selectedDepartment.value != null) {
      body['icu_department_id'] = selectedDepartment.value!.id;
    }

    if (nationalIdCont.text.trim().isNotEmpty) {
      body['national_id'] = nationalIdCont.text.trim();
    }

    if (insuranceNumberCont.text.trim().isNotEmpty) {
      body['insurance_number'] = insuranceNumberCont.text.trim();
    }

    if (diagnosisCont.text.trim().isNotEmpty) {
      body['diagnosis'] = diagnosisCont.text.trim();
    }

    if (currentLocationCont.text.trim().isNotEmpty) {
      body['current_location'] = currentLocationCont.text.trim();
    }

    if (relationshipCont.text.trim().isNotEmpty) {
      body['relationship_to_patient'] = relationshipCont.text.trim();
    }

    if (insuranceProviderCont.text.trim().isNotEmpty) {
      body['insurance_provider'] = insuranceProviderCont.text.trim();
    }

    return body;
  }

  /// Submits the ICU admission request via multipart API call.
  /// On success: shows toast, navigates back.
  /// On error: shows toast, preserves form data.
  Future<void> submitRequest() async {
    if (isLoading.value) return;
    if (!validateForm()) return;

    isLoading(true);
    FocusManager.instance.primaryFocus?.unfocus();

    final body = _buildRequestBody();

    await CoreServiceApis.createIcuAdmission(
      request: body,
      medicalReports: medicalReports.isNotEmpty ? medicalReports.toList() : null,
    ).then((value) {
      toast(locale.value.admissionSubmitted);
      isLoading(false);
      Get.back();
    }).catchError((e) {
      isLoading(false);
      toast(e.toString());
      log("submitRequest error: $e");
    });
  }

  @override
  void onClose() {
    patientNameCont.dispose();
    patientAgeCont.dispose();
    nationalIdCont.dispose();
    insuranceNumberCont.dispose();
    medicalConditionCont.dispose();
    diagnosisCont.dispose();
    currentLocationCont.dispose();
    contactNameCont.dispose();
    contactPhoneCont.dispose();
    relationshipCont.dispose();
    insuranceProviderCont.dispose();
    patientNameFocus.dispose();
    patientAgeFocus.dispose();
    nationalIdFocus.dispose();
    insuranceNumberFocus.dispose();
    medicalConditionFocus.dispose();
    diagnosisFocus.dispose();
    currentLocationFocus.dispose();
    contactNameFocus.dispose();
    contactPhoneFocus.dispose();
    relationshipFocus.dispose();
    insuranceProviderFocus.dispose();
    super.onClose();
  }
}
