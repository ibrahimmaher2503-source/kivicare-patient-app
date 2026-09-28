import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:kivicare_patient/screens/labs_radiology/labs_radiology_common.dart';
import 'package:kivicare_patient/components/loader_widget.dart';
import '../models/facility_model.dart';
import '../models/lab_test_model.dart';
import 'slot_selection_controller.dart';
import 'components/calendar_strip.dart';
import 'components/slot_grid.dart';
import '../booking_confirmation/booking_confirmation_screen.dart'; // Will be created next

class SlotSelectionScreen extends StatelessWidget {
  final FacilityModel facility;
  final LabTestModel test;

  const SlotSelectionScreen(
      {super.key, required this.facility, required this.test});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(SlotSelectionController(facility: facility));

    return Scaffold(
      appBar: appBarWidget(
        locale.value.selectTime,
        textColor: Colors.white,
        systemUiOverlayStyle: defaultSystemUiOverlayStyle(context),
      ),
      body: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              16.height,
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(locale.value.selectDate, style: boldTextStyle()),
              ),
              16.height,
              Obx(() => CalendarStrip(
                    availableDates: controller.availableDates,
                    selectedDate: controller.selectedDate.value,
                    onDateSelected: controller.onDateSelected,
                  )),
              24.height,
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child:
                    Text(locale.value.availableSlots, style: boldTextStyle()),
              ),
              16.height,
              Expanded(
                child: Obx(() => SlotGrid(
                      slots: controller.currentSlots,
                      selectedSlot: controller.selectedSlot.value,
                      onSlotSelected: controller.onSlotSelected,
                    )),
              ),
            ],
          ),
          Obx(() => const LoaderWidget()
              .center()
              .visible(controller.isLoading.value)),
        ],
      ),
      bottomNavigationBar: Obx(() => Container(
            padding: const EdgeInsets.all(16),
            decoration: boxDecorationDefault(
                color: context.cardColor, borderRadius: radius(0)),
            child: AppButton(
              text: locale.value.continueToConfirm,
              color: context.primaryColor,
              textStyle: boldTextStyle(color: Colors.white),
              width: double.infinity,
              enabled: controller.selectedSlot.value != null,
              onTap: () async {
                if (controller.selectedSlot.value != null &&
                    controller.selectedDate.value != null) {
                  await doIfLoggedIn(() => Get.to(
                        () => BookingConfirmationScreen(
                          facility: facility,
                          test: test,
                          selectedDate: controller.selectedDate.value!,
                          selectedSlot: controller.selectedSlot.value!,
                        ),
                      ));
                } else {
                  toast(locale.value.selectASlot);
                }
              },
            ),
          ).visible(!controller.isLoading.value)),
    );
  }
}
