import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kivicare_patient/components/app_scaffold.dart';
import 'package:kivicare_patient/locale/languages.dart';
import 'package:kivicare_patient/screens/facility_booking/facility_booking_controller.dart';
import 'package:kivicare_patient/screens/facility_booking/facility_slot_calendar_screen.dart';
import 'package:kivicare_patient/utils/colors.dart';
import 'package:kivicare_patient/utils/lab_test_constants.dart';
import 'package:nb_utils/nb_utils.dart';

class FacilitySelectionScreen extends StatelessWidget {
  const FacilitySelectionScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<FacilityBookingController>(
      init: FacilityBookingController(),
      builder: (controller) {
        return AppScaffold(
          appBarTitle: 'Select Facility',
          body: Obx(
            () => SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Facility Type', style: boldTextStyle(size: 14)),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _FacilityTypeButton(
                          label: 'Lab',
                          isSelected: controller.facilityType.value == FacilityType.lab,
                          onTap: () => controller.setFacilityType(FacilityType.lab),
                          icon: Icons.science,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _FacilityTypeButton(
                          label: 'Radiology',
                          isSelected: controller.facilityType.value == FacilityType.radiology,
                          onTap: () => controller.setFacilityType(FacilityType.radiology),
                          icon: Icons.medical_services,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Text('Available Facilities', style: boldTextStyle(size: 14)),
                  const SizedBox(height: 12),
                  if (controller.facilityType.value == FacilityType.lab)
                    _LabsList(controller: controller)
                  else
                    _RadiologyCentersList(controller: controller),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _FacilityTypeButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final IconData icon;

  const _FacilityTypeButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? appColorPrimary.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? appColorPrimary : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, size: 32, color: isSelected ? appColorPrimary : Colors.grey),
            const SizedBox(height: 8),
            Text(label, style: boldTextStyle(size: 12, color: isSelected ? appColorPrimary : Colors.grey)),
          ],
        ),
      ),
    );
  }
}

class _LabsList extends StatelessWidget {
  final FacilityBookingController controller;
  const _LabsList({required this.controller});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 5,
      itemBuilder: (context, index) {
        return InkWell(
          onTap: () {
            controller.selectFacility(index + 1);
            Get.to(() => FacilitySlotCalendarScreen(
              facilityId: index + 1,
              facilityType: FacilityType.lab,
              facilityName: 'Lab ${index + 1}',
            ));
          },
          borderRadius: BorderRadius.circular(8),
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: appStore.isDarkMode ? cardDarkColor : Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: appStore.isDarkMode ? Colors.grey.shade800 : Colors.grey.shade200),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Lab ${index + 1}', style: boldTextStyle(size: 13)),
                    const SizedBox(height: 4),
                    Text('Downtown Location', style: secondaryTextStyle(size: 11)),
                  ],
                ),
                const Icon(Icons.arrow_forward, size: 20),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _RadiologyCentersList extends StatelessWidget {
  final FacilityBookingController controller;
  const _RadiologyCentersList({required this.controller});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 3,
      itemBuilder: (context, index) {
        return InkWell(
          onTap: () {
            controller.selectFacility(index + 1);
            Get.to(() => FacilitySlotCalendarScreen(
              facilityId: index + 1,
              facilityType: FacilityType.radiology,
              facilityName: 'Radiology Center ${index + 1}',
            ));
          },
          borderRadius: BorderRadius.circular(8),
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: appStore.isDarkMode ? cardDarkColor : Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: appStore.isDarkMode ? Colors.grey.shade800 : Colors.grey.shade200),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Radiology Center ${index + 1}', style: boldTextStyle(size: 13)),
                    const SizedBox(height: 4),
                    Text('Modern Imaging Equipment', style: secondaryTextStyle(size: 11)),
                  ],
                ),
                const Icon(Icons.arrow_forward, size: 20),
              ],
            ),
          ),
        );
      },
    );
  }
}
