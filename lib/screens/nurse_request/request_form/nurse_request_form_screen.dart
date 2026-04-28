import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kivicare_patient/components/app_scaffold.dart';
import 'package:kivicare_patient/main.dart';
import 'package:kivicare_patient/utils/colors.dart';
import 'package:nb_utils/nb_utils.dart';

import 'components/address_section.dart';
import 'components/contact_section.dart';
import 'components/notes_field.dart';
import 'components/schedule_section.dart';
import 'components/service_description_section.dart';
import 'nurse_request_form_controller.dart';

class NurseRequestFormScreen extends StatelessWidget {
  const NurseRequestFormScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // In-memory only — no GetStorage (clarification C3)
    final controller = Get.put(NurseRequestFormController(), permanent: false);

    return AppScaffoldNew(
      appBartitleText: locale.value.newRequest,
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _SectionHeader(locale.value.serviceDescriptionEnglish.split('(').first.trim()),
                  12.height,
                  ServiceDescriptionSection(
                    enController: controller.serviceEnController,
                    arController: controller.serviceArController,
                    errorMessage: controller.descriptionError,
                  ),
                  24.height,
                  _SectionHeader(locale.value.preferredDate),
                  12.height,
                  ScheduleSection(
                    preferredDate: controller.preferredDate,
                    preferredTime: controller.preferredTime,
                    durationHours: controller.durationHours,
                  ),
                  24.height,
                  _SectionHeader(locale.value.addressLine1),
                  12.height,
                  AddressSection(
                    addressLine1Controller: controller.addressLine1Controller,
                    addressLine2Controller: controller.addressLine2Controller,
                    stateController: controller.stateController,
                    countryController: controller.countryController,
                    postalCodeController: controller.postalCodeController,
                    governorateId: controller.governorateId,
                    cityId: controller.cityId,
                    cityText: controller.cityText,
                  ),
                  24.height,
                  _SectionHeader(locale.value.contactPhone),
                  12.height,
                  Obx(() => ContactSection(
                    controller: controller.phoneController,
                    errorText: controller.fieldErrors['contact_phone'],
                  )),
                  24.height,
                  _SectionHeader(locale.value.patientNotes),
                  12.height,
                  NotesField(controller: controller.notesController),
                  Obx(() {
                    final err = controller.topLevelError.value;
                    if (err == null || err.isEmpty) return const SizedBox.shrink();
                    return Container(
                      margin: const EdgeInsets.only(top: 16),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.red.shade200),
                      ),
                      child: Text(err, style: const TextStyle(color: Colors.red, fontSize: 13)),
                    );
                  }),
                  32.height,
                ],
              ),
            ),
          ),
          Obx(() => SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: controller.isSubmitting.value ? null : controller.submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: gradientStart,
                    disabledBackgroundColor: Colors.grey.shade300,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: controller.isSubmitting.value
                      ? const CircularProgressIndicator(strokeWidth: 2, color: Colors.white)
                      : Text(locale.value.submit, style: boldTextStyle(color: Colors.white, size: 16)),
                ),
              ),
            ),
          )),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader(this.title);

  @override
  Widget build(BuildContext context) {
    return Text(title, style: boldTextStyle(size: 15));
  }
}
