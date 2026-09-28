import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';
import '../../../api/icu_apis.dart';
import '../../../main.dart';
import '../../../utils/common_base.dart';
import '../components/icu_shimmer.dart';
import '../components/urgency_radio_group.dart';
import '../models/icu_department_model.dart';
import '../models/hospital_model.dart';
import '../hospitals/hospital_list_screen.dart';
import 'admission_request_form_controller.dart';
import 'admission_request_form_validators.dart';
import 'components/hospital_lock_field.dart';

class AdmissionRequestFormScreen extends StatelessWidget {
  const AdmissionRequestFormScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AdmissionRequestFormController());

    return Scaffold(
      appBar: AppBar(title: Text(locale.value.icuAdmission)),
      body: Stack(
        children: [
          Obx(() => AbsorbPointer(
                absorbing: controller.isLoading.value,
                child: Form(
                  key: controller.formKey,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Obx(() => controller.hospital.value != null
                            ? HospitalLockField(
                                hospital: controller.hospital.value!,
                                onChange: controller.clearHospital,
                              )
                            : AppButton(
                                text: locale.value.selectHospital,
                                width: Get.width,
                                onTap: () async {
                                  final selected = await Get.to<Hospital>(
                                    () => const HospitalListScreen(
                                      selectionMode: true,
                                    ),
                                  );
                                  if (selected != null) {
                                    controller.setHospital(selected);
                                  }
                                },
                              )),
                        16.height,
                        Obx(() => AppTextField(
                              readOnly: true,
                              controller: controller.departmentCont,
                              textFieldType: TextFieldType.NAME,
                              decoration: inputDecoration(
                                context,
                                labelText: locale.value.selectDepartment,
                              ).copyWith(
                                suffixIcon:
                                    const Icon(Icons.arrow_drop_down_rounded),
                              ),
                              onTap: () {
                                if (controller.hospital.value == null) {
                                  toast(locale.value.pleaseSelectHospital);
                                  return;
                                }
                                // Open Department Selection Bottom Sheet
                                _showDepartmentSelection(context, controller);
                              },
                            )),
                        24.height,
                        Text(locale.value.basicInformation.toUpperCase(),
                            style: boldTextStyle(
                                size: 14, color: context.primaryColor)),
                        16.height,
                        AppTextField(
                          controller: controller.patientNameCont,
                          textFieldType: TextFieldType.NAME,
                          validator: (value) =>
                              AdmissionRequestFormValidators.requiredText(
                            value,
                            requiredMessage: locale.value.thisFieldIsRequired,
                          ),
                          decoration: inputDecoration(context,
                              labelText: locale.value.patientName),
                        ),
                        16.height,
                        Column(
                          children: [
                            AppTextField(
                              controller: controller.patientAgeCont,
                              textFieldType: TextFieldType.NUMBER,
                              validator: (value) =>
                                  AdmissionRequestFormValidators.age(
                                value,
                                requiredMessage:
                                    locale.value.thisFieldIsRequired,
                                invalidMessage: locale.value.invalidPatientAge,
                              ),
                              decoration: inputDecoration(context,
                                  labelText: locale.value.patientAge),
                            ),
                            16.height,
                            Obx(() => DropdownButtonFormField<String>(
                                  // ignore: deprecated_member_use
                                  value: controller.patientGender.value,
                                  decoration: inputDecoration(context,
                                      labelText: locale.value.patientGender),
                                  items: [
                                    DropdownMenuItem(
                                        value: 'male',
                                        child: Text(locale.value.male)),
                                    DropdownMenuItem(
                                        value: 'female',
                                        child: Text(locale.value.female)),
                                    DropdownMenuItem(
                                        value: 'other',
                                        child: Text(locale.value.other)),
                                  ],
                                  onChanged: (val) =>
                                      controller.patientGender.value = val!,
                                )),
                          ],
                        ),
                        16.height,
                        AppTextField(
                          controller: controller.nationalIdCont,
                          textFieldType: TextFieldType.NUMBER,
                          decoration: inputDecoration(context,
                              labelText: locale.value.nationalId),
                        ),
                        24.height,
                        Text(locale.value.diagnosis.toUpperCase(),
                            style: boldTextStyle(
                                size: 14, color: context.primaryColor)),
                        16.height,
                        AppTextField(
                          controller: controller.diagnosisCont,
                          textFieldType: TextFieldType.MULTILINE,
                          maxLines: 3,
                          maxLength: 2000,
                          validator: (value) =>
                              AdmissionRequestFormValidators.requiredText(
                            value,
                            requiredMessage: locale.value.thisFieldIsRequired,
                            maxLength: 2000,
                            maxLengthMessage:
                                locale.value.additionalNotesTooLong,
                          ),
                          decoration: inputDecoration(context,
                              labelText: locale.value.diagnosis),
                        ),
                        16.height,
                        AppTextField(
                          controller: controller.currentConditionCont,
                          textFieldType: TextFieldType.MULTILINE,
                          maxLines: 3,
                          maxLength: 2000,
                          validator: (value) =>
                              AdmissionRequestFormValidators.optionalText(
                            value,
                            maxLength: 2000,
                            maxLengthMessage:
                                locale.value.additionalNotesTooLong,
                          ),
                          decoration: inputDecoration(context,
                              labelText: locale.value.currentCondition),
                        ),
                        16.height,
                        AppTextField(
                          controller: controller.attendingDoctorCont,
                          textFieldType: TextFieldType.NAME,
                          decoration: inputDecoration(context,
                              labelText: locale.value.attendingDoctor),
                        ),
                        16.height,
                        AppTextField(
                          controller: controller.medicalHistoryCont,
                          textFieldType: TextFieldType.MULTILINE,
                          maxLines: 3,
                          maxLength: 2000,
                          validator: (value) =>
                              AdmissionRequestFormValidators.optionalText(
                            value,
                            maxLength: 2000,
                            maxLengthMessage:
                                locale.value.additionalNotesTooLong,
                          ),
                          decoration: inputDecoration(context,
                              labelText: locale.value.medicalHistory),
                        ),
                        16.height,
                        AppTextField(
                          controller: controller.currentMedicationsCont,
                          textFieldType: TextFieldType.MULTILINE,
                          maxLines: 3,
                          maxLength: 2000,
                          validator: (value) =>
                              AdmissionRequestFormValidators.optionalText(
                            value,
                            maxLength: 2000,
                            maxLengthMessage:
                                locale.value.additionalNotesTooLong,
                          ),
                          decoration: inputDecoration(context,
                              labelText: locale.value.currentMedications),
                        ),
                        16.height,
                        AppTextField(
                          controller: controller.allergiesCont,
                          textFieldType: TextFieldType.MULTILINE,
                          maxLines: 3,
                          maxLength: 2000,
                          validator: (value) =>
                              AdmissionRequestFormValidators.optionalText(
                            value,
                            maxLength: 2000,
                            maxLengthMessage:
                                locale.value.additionalNotesTooLong,
                          ),
                          decoration: inputDecoration(context,
                              labelText: locale.value.allergies),
                        ),
                        16.height,
                        AppTextField(
                          controller: controller.additionalNotesCont,
                          textFieldType: TextFieldType.MULTILINE,
                          maxLines: 3,
                          maxLength: 2000,
                          validator: (value) =>
                              AdmissionRequestFormValidators.optionalText(
                            value,
                            maxLength: 2000,
                            maxLengthMessage:
                                locale.value.additionalNotesTooLong,
                          ),
                          decoration: inputDecoration(context,
                              labelText: locale.value.additionalNotesOptional),
                        ),
                        24.height,
                        Obx(() => UrgencyRadioGroup(
                              selectedUrgency: controller.urgency.value,
                              onChanged: controller.setUrgency,
                            )),
                        24.height,
                        Text(locale.value.preferredDate.toUpperCase(),
                            style: boldTextStyle(
                                size: 14, color: context.primaryColor)),
                        16.height,
                        Obx(() => AppTextField(
                              readOnly: true,
                              controller: controller.preferredDateCont,
                              textFieldType: TextFieldType.NAME,
                              decoration: inputDecoration(context,
                                  labelText: locale.value.preferredDate),
                              onTap: () => controller.selectDate(context),
                            )),
                        24.height,
                        Text(locale.value.accompanyingName.toUpperCase(),
                            style: boldTextStyle(
                                size: 14, color: context.primaryColor)),
                        16.height,
                        AppTextField(
                          controller: controller.accompanyingNameCont,
                          textFieldType: TextFieldType.NAME,
                          validator: (value) =>
                              AdmissionRequestFormValidators.requiredText(
                            value,
                            requiredMessage: locale.value.thisFieldIsRequired,
                          ),
                          decoration: inputDecoration(context,
                              labelText: locale.value.accompanyingName),
                        ),
                        16.height,
                        AppTextField(
                          controller: controller.accompanyingRelationCont,
                          textFieldType: TextFieldType.NAME,
                          decoration: inputDecoration(context,
                              labelText: locale.value.accompanyingRelation),
                        ),
                        16.height,
                        AppTextField(
                          controller: controller.accompanyingPhoneCont,
                          textFieldType: TextFieldType.PHONE,
                          validator: (value) =>
                              AdmissionRequestFormValidators.phone(
                            value,
                            requiredMessage: locale.value.thisFieldIsRequired,
                            invalidMessage: locale.value.invalidPhone,
                          ),
                          decoration: inputDecoration(context,
                              labelText: locale.value.accompanyingPhone),
                        ),
                        32.height,
                        Obx(() => AppButton(
                              text: controller.isLoading.value
                                  ? locale.value.submitting
                                  : locale.value.submit,
                              width: Get.width,
                              color: context.primaryColor,
                              disabledColor:
                                  context.primaryColor.withValues(alpha: 0.5),
                              enabled: !controller.isLoading.value,
                              onTap: controller.submit,
                            )),
                        50.height,
                      ],
                    ),
                  ),
                ),
              )),
          Obx(() => Loader().visible(controller.isLoading.value)),
        ],
      ),
    );
  }

  void _showDepartmentSelection(
      BuildContext context, AdmissionRequestFormController controller) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            16.height,
            Text(locale.value.selectDepartment, style: boldTextStyle(size: 18)),
            16.height,
            FutureBuilder<List<IcuDepartment>>(
              future:
                  IcuApis.getHospitalDepartments(controller.hospital.value!.id),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const IcuShimmer(itemCount: 3, height: 60);
                }
                if (snapshot.hasError) {
                  return Text(
                          locale.value.somethingWentWrongPleaseTryAgainLater)
                      .center();
                }
                final departments = snapshot.data ?? [];
                return ListView.builder(
                  shrinkWrap: true,
                  itemCount: departments.length,
                  itemBuilder: (context, index) {
                    final dept = departments[index];
                    return ListTile(
                      title: Text(dept.name),
                      onTap: () {
                        controller.setDepartment(dept);
                        finish(context);
                      },
                    );
                  },
                );
              },
            ),
            16.height,
          ],
        );
      },
    );
  }
}
