import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:nb_utils/nb_utils.dart';
import '../../../api/icu_apis.dart';
import '../../../main.dart';
import '../../../utils/common_base.dart';
import '../../../utils/constants.dart';
import '../components/icu_shimmer.dart';
import '../components/urgency_radio_group.dart';
import '../models/icu_department_model.dart';
import 'admission_request_form_controller.dart';
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
          Form(
            key: controller.formKey,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Obx(() => controller.hospital.value != null
                      ? HospitalLockField(
                          hospital: controller.hospital.value!,
                          onChange: () {
                            controller.hospital.value = null;
                            controller.department.value = null;
                          },
                        )
                      : AppButton(
                          text: locale.value.selectHospital,
                          width: Get.width,
                          onTap: () {
                            // TODO: Open Hospital Selection Screen
                          },
                        )),
                  16.height,
                  Obx(() => AppTextField(
                        readOnly: true,
                        controller: TextEditingController(text: controller.department.value?.name ?? ''),
                        textFieldType: TextFieldType.NAME,
                        decoration: inputDecoration(
                          context,
                          labelText: locale.value.selectDepartment,
                        ).copyWith(
                          suffixIcon: const Icon(Icons.arrow_drop_down_rounded),
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
                  Text(locale.value.basicInformation.toUpperCase(), style: boldTextStyle(size: 14, color: context.primaryColor)),
                  16.height,
                  AppTextField(
                    controller: controller.patientNameCont,
                    textFieldType: TextFieldType.NAME,
                    decoration: inputDecoration(context, labelText: locale.value.patientName),
                  ),
                  16.height,
                  Row(
                    children: [
                      AppTextField(
                        controller: controller.patientAgeCont,
                        textFieldType: TextFieldType.NUMBER,
                        decoration: inputDecoration(context, labelText: locale.value.patientAge),
                      ).expand(),
                      16.width,
                      Obx(() => DropdownButtonFormField<String>(
                            // ignore: deprecated_member_use
                            value: controller.patientGender.value,
                            decoration: inputDecoration(context, labelText: locale.value.patientGender),
                            items: [
                              DropdownMenuItem(value: 'male', child: Text(locale.value.male)),
                              DropdownMenuItem(value: 'female', child: Text(locale.value.female)),
                              DropdownMenuItem(value: 'other', child: Text(locale.value.other)),
                            ],
                            onChanged: (val) => controller.patientGender.value = val!,
                          )).expand(),
                    ],
                  ),
                  16.height,
                  AppTextField(
                    controller: controller.nationalIdCont,
                    textFieldType: TextFieldType.NUMBER,
                    decoration: inputDecoration(context, labelText: locale.value.nationalId),
                  ),
                  24.height,
                  Text(locale.value.diagnosis.toUpperCase(), style: boldTextStyle(size: 14, color: context.primaryColor)),
                  16.height,
                  AppTextField(
                    controller: controller.diagnosisCont,
                    textFieldType: TextFieldType.MULTILINE,
                    maxLines: 3,
                    decoration: inputDecoration(context, labelText: locale.value.diagnosis),
                  ),
                  16.height,
                  AppTextField(
                    controller: controller.currentConditionCont,
                    textFieldType: TextFieldType.MULTILINE,
                    maxLines: 3,
                    decoration: inputDecoration(context, labelText: locale.value.currentCondition),
                  ),
                  16.height,
                  AppTextField(
                    controller: controller.medicalHistoryCont,
                    textFieldType: TextFieldType.MULTILINE,
                    maxLines: 3,
                    decoration: inputDecoration(context, labelText: locale.value.medicalHistory),
                  ),
                  24.height,
                  Obx(() => UrgencyRadioGroup(
                        selectedUrgency: controller.urgency.value,
                        onChanged: controller.setUrgency,
                      )),
                  24.height,
                  Text(locale.value.preferredDate.toUpperCase(), style: boldTextStyle(size: 14, color: context.primaryColor)),
                  16.height,
                  Obx(() => AppTextField(
                        readOnly: true,
                        controller: TextEditingController(
                            text: controller.preferredDate.value != null ? DateFormat(DateFormatConst.yyyy_MM_dd).format(controller.preferredDate.value!) : ''),
                        textFieldType: TextFieldType.NAME,
                        decoration: inputDecoration(context, labelText: locale.value.preferredDate),
                        onTap: () => controller.selectDate(context),
                      )),
                  24.height,
                  Text(locale.value.accompanyingName.toUpperCase(), style: boldTextStyle(size: 14, color: context.primaryColor)),
                  16.height,
                  AppTextField(
                    controller: controller.accompanyingNameCont,
                    textFieldType: TextFieldType.NAME,
                    decoration: inputDecoration(context, labelText: locale.value.accompanyingName),
                  ),
                  16.height,
                  AppTextField(
                    controller: controller.accompanyingRelationCont,
                    textFieldType: TextFieldType.NAME,
                    decoration: inputDecoration(context, labelText: locale.value.accompanyingRelation),
                  ),
                  16.height,
                  AppTextField(
                    controller: controller.accompanyingPhoneCont,
                    textFieldType: TextFieldType.PHONE,
                    decoration: inputDecoration(context, labelText: locale.value.accompanyingPhone),
                  ),
                  32.height,
                  AppButton(
                    text: locale.value.submit,
                    width: Get.width,
                    color: context.primaryColor,
                    onTap: controller.submit,
                  ),
                  50.height,
                ],
              ),
            ),
          ),
          Obx(() => Loader().visible(controller.isLoading.value)),
        ],
      ),
    );
  }

  void _showDepartmentSelection(BuildContext context, AdmissionRequestFormController controller) {
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
              future: IcuApis.getHospitalDepartments(controller.hospital.value!.id),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const IcuShimmer(itemCount: 3, height: 60);
                }
                if (snapshot.hasError) {
                  return Text(snapshot.error.toString()).center();
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
                        controller.department.value = dept;
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
