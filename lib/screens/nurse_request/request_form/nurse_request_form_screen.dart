import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kivicare_patient/components/app_scaffold.dart';
import 'package:kivicare_patient/main.dart';
import 'package:kivicare_patient/utils/colors.dart';
import 'package:nb_utils/nb_utils.dart';

import '../components/nurse_request_design.dart';
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
      topBarBgColor: gradientStart,
      scaffoldBackgroundColor:
          nurseRequestIsDark ? appScreenBackgroundDark : appScreenBackground,
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _FormSection(
                    title: locale.value.description,
                    icon: Icons.description_outlined,
                    child: ServiceDescriptionSection(
                      enController: controller.serviceEnController,
                      arController: controller.serviceArController,
                      errorMessage: controller.descriptionError,
                    ),
                  ),
                  16.height,
                  _FormSection(
                    title: locale.value.dateTime,
                    icon: Icons.event_available_outlined,
                    child: ScheduleSection(
                      preferredDate: controller.preferredDate,
                      preferredTime: controller.preferredTime,
                      durationHours: controller.durationHours,
                    ),
                  ),
                  16.height,
                  _FormSection(
                    title: locale.value.address,
                    icon: Icons.location_on_outlined,
                    child: AddressSection(
                      addressLine1Controller: controller.addressLine1Controller,
                      addressLine2Controller: controller.addressLine2Controller,
                      stateController: controller.stateController,
                      countryController: controller.countryController,
                      postalCodeController: controller.postalCodeController,
                      governorateId: controller.governorateId,
                      cityId: controller.cityId,
                      cityText: controller.cityText,
                    ),
                  ),
                  16.height,
                  _FormSection(
                    title: locale.value.contactPhone,
                    icon: Icons.call_outlined,
                    child: Obx(
                      () => ContactSection(
                        controller: controller.phoneController,
                        errorText: controller.fieldErrors['contact_number'],
                      ),
                    ),
                  ),
                  16.height,
                  _FormSection(
                    title: locale.value.patientNotes,
                    icon: Icons.notes_outlined,
                    child: NotesField(controller: controller.notesController),
                  ),
                  Obx(() {
                    final err = controller.topLevelError.value;
                    if (err == null || err.isEmpty) {
                      return const SizedBox.shrink();
                    }
                    return Container(
                      margin: const EdgeInsets.only(top: 16),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: cancelStatusColor.withValues(
                          alpha: nurseRequestIsDark ? 0.18 : 0.08,
                        ),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: cancelStatusColor.withValues(alpha: 0.28),
                        ),
                      ),
                      child: Text(
                        err,
                        style: const TextStyle(
                          color: cancelStatusColor,
                          fontSize: 13,
                        ),
                      ),
                    );
                  }),
                  24.height,
                ],
              ),
            ),
          ),
          Obx(
            () => SafeArea(
              top: false,
              child: Container(
                decoration: BoxDecoration(
                  color: nurseRequestSurface(context),
                  border: Border(
                    top: BorderSide(color: nurseRequestBorderColor(context)),
                  ),
                  boxShadow: nurseRequestIsDark
                      ? const []
                      : [
                          BoxShadow(
                            color: softShadowColor,
                            blurRadius: 16,
                            offset: const Offset(0, -6),
                          ),
                        ],
                ),
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                child: SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: controller.isSubmitting.value
                        ? null
                        : controller.submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: gradientStart,
                      disabledBackgroundColor: nurseRequestDisabledColor(
                        context,
                      ).withValues(alpha: 0.28),
                      foregroundColor: whiteTextColor,
                      disabledForegroundColor: nurseRequestMutedColor(context),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: controller.isSubmitting.value
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: whiteTextColor,
                                ),
                              ),
                              10.width,
                              Text(
                                locale.value.submitting,
                                style: boldTextStyle(
                                  color: whiteTextColor,
                                  size: 15,
                                ),
                              ),
                            ],
                          )
                        : Text(
                            locale.value.submit,
                            style: boldTextStyle(
                              color: whiteTextColor,
                              size: 16,
                            ),
                          ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FormSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;

  const _FormSection({
    required this.title,
    required this.icon,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: nurseRequestCardDecoration(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: gradientSecondaryStart, size: 18),
              8.width,
              Expanded(
                child: Text(
                  title,
                  style: boldTextStyle(size: 15),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          14.height,
          child,
        ],
      ),
    );
  }
}
