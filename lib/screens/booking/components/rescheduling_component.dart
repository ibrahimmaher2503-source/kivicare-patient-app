// ignore_for_file: must_be_immutable

import 'package:date_picker_timeline/date_picker_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:kivicare_patient/utils/common_base.dart';

import '../../../../components/bottom_selection_widget.dart';
import '../../../../main.dart';
import '../../../components/loader_widget.dart';
import '../../../utils/app_common.dart';
import '../../../utils/colors.dart';
import '../../../utils/empty_error_state_widget.dart';
import '../../../utils/view_all_label_component.dart';
import '../appointment_detail_controller.dart';
import '../model/appointments_res_model.dart';

class ReschedulingComponent extends StatelessWidget {
  ReschedulingComponent({super.key, required this.bookingDetail});

  Rx<AppointmentData> bookingDetail;

  final AppointmentDetailController appointmentDetailCont = Get.find();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Column(
          children: [
            16.height,
            Obx(
              () => SnapHelperWidget(
                future: appointmentDetailCont.timeSlotsFuture.value,
                errorBuilder: (error) {
                  return NoDataWidget(
                    title: error,
                    retryText: locale.value.reload,
                    imageWidget: const ErrorStateWidget(),
                    onRetry: () {
                      appointmentDetailCont.getTimeSlot();
                    },
                  ).paddingSymmetric(horizontal: 32);
                },
                loadingWidget: appointmentDetailCont.isLoading.value ? const Offstage() : const LoaderWidget(),
                onSuccess: (p0) {
                  if (appointmentDetailCont.slots.isEmpty) {
                    return NoDataWidget(title: locale.value.noTimeSlotsAvailable).paddingTop(12);
                  }

                  return Obx(
                    () => Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ViewAllLabel(label: locale.value.chooseTime, isShowAll: false).paddingOnly(right: 8),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: isDarkMode.value ? surfaceElevatedDark : surfaceElevated,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: isDarkMode.value ? softShadowColorDark : softShadowColor,
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              AnimatedWrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: List.generate(
                                  appointmentDetailCont.slots.length,
                                  (i) {
                                    String slot = appointmentDetailCont.slots[i];
                                    return Obx(
                                      () {
                                        final bool isActive = appointmentDetailCont.selectedSlot.value == slot;
                                        return GestureDetector(
                                          onTap: () {
                                            appointmentDetailCont.selectedSlot(slot);
                                            appointmentDetailCont.onDateTimeChange();
                                          },
                                          child: AnimatedContainer(
                                            duration: const Duration(milliseconds: 200),
                                            width: Get.width / 4 - 27,
                                            padding: const EdgeInsets.symmetric(vertical: 12),
                                            decoration: BoxDecoration(
                                              gradient: isActive
                                                  ? const LinearGradient(
                                                      begin: Alignment.topLeft,
                                                      end: Alignment.bottomRight,
                                                      colors: [gradientStart, gradientEnd],
                                                    )
                                                  : null,
                                              color: isActive ? null : (isDarkMode.value ? inputFillColorDark : inputFillColor),
                                              borderRadius: BorderRadius.circular(12),
                                              border: isActive
                                                  ? null
                                                  : Border.all(
                                                      color: isDarkMode.value ? borderColorDark : whiteBorderColor,
                                                      width: 0.5,
                                                    ),
                                              boxShadow: isActive
                                                  ? [
                                                      BoxShadow(
                                                        color: gradientStart.withValues(alpha: 0.25),
                                                        blurRadius: 8,
                                                        offset: const Offset(0, 3),
                                                      ),
                                                    ]
                                                  : null,
                                            ),
                                            child: Text(
                                              slot,
                                              textAlign: TextAlign.center,
                                              style: GoogleFonts.plusJakartaSans(
                                                fontSize: 12,
                                                fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                                                color: isActive ? Colors.white : (isDarkMode.value ? Colors.white70 : appColorPrimary),
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            16.height,
          ],
        ),
        Obx(() => const LoaderWidget().visible(appointmentDetailCont.isLoading.value)),
      ],
    );
  }
}

void handleRescheduleClick({required BuildContext context, required RxBool isLoading, required Rx<AppointmentData> appointmentDetail, required AppointmentDetailController appointmentDetailCont}) {
  serviceCommonBottomSheet(
    context,
    child: BottomSelectionSheet(
      heightRatio: 0.6,
      title: locale.value.rescheduleBooking,
      hideSearchBar: true,
      hintText: locale.value.searchForService,
      searchTextCont: TextEditingController(),
      hasError: false,
      isLoading: appointmentDetailCont.isUpdateBookingLoading,
      isEmpty: false,
      noDataTitle: locale.value.statusListIsEmpty,
      noDataSubTitle: locale.value.thereAreNoStatusListedAtTheMomentStayTunedFor,
      listWidget: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              children: [
                ViewAllLabel(label: locale.value.chooseDate, isShowAll: false).paddingOnly(right: 8),
                Container(
                  decoration: BoxDecoration(
                    color: isDarkMode.value ? surfaceElevatedDark : surfaceElevated,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: isDarkMode.value ? softShadowColorDark : softShadowColor,
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: DatePicker(
                    DateTime.now(),
                    initialSelectedDate: DateTime.now(),
                    selectionColor: lightPrimaryColor,
                    selectedTextColor: appColorPrimary,
                    height: 90,
                    onDateChange: (date) {
                      appointmentDetailCont.selectedDate(date.formatDateYYYYmmdd());
                      appointmentDetailCont.selectedSlot("");
                      appointmentDetailCont.getTimeSlot();
                      appointmentDetailCont.onDateTimeChange();
                    },
                  ),
                ),
                ReschedulingComponent(bookingDetail: appointmentDetail),
              ],
            ),
          ).paddingBottom(56),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Obx(
              () {
                final bool isEnabled = appointmentDetailCont.updateBtnVisible.value;
                return GestureDetector(
                  onTap: isEnabled
                      ? () {
                          showConfirmDialogCustom(
                            context,
                            title: locale.value.doYouWantToChangeTheTimeSlotOfThisAppointment,
                            positiveText: locale.value.yes,
                            negativeText: locale.value.no,
                            primaryColor: context.primaryColor,
                            onAccept: (ctx) {
                              appointmentDetailCont.handleUpdateClick(context);
                            },
                          );
                        }
                      : null,
                  child: Container(
                    width: Get.width,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: isEnabled
                            ? [gradientSecondaryStart, gradientSecondaryEnd]
                            : [gradientSecondaryStart.withValues(alpha: 0.4), gradientSecondaryEnd.withValues(alpha: 0.4)],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: isEnabled
                          ? [
                              BoxShadow(
                                color: gradientSecondaryStart.withValues(alpha: 0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ]
                          : [],
                    ),
                    child: Text(
                      locale.value.update,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ).expand(),
    ),
    onSheetClose: (p0) {
      appointmentDetailCont.updateBtnVisible(false);
      appointmentDetailCont.selectedDate(DateTime.now().formatDateYYYYmmdd());
      appointmentDetailCont.selectedSlot("");
    },
  );
}
