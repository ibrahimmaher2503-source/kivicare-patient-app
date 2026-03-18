import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../components/app_scaffold.dart';
import '../../components/cached_image_widget.dart';
import '../../components/loader_widget.dart';
import '../../main.dart';
import '../../utils/app_common.dart';
import '../../utils/colors.dart';
import '../../utils/empty_error_state_widget.dart';
import 'appointments_controller.dart';
import 'components/appointment_card.dart';
import 'model/appointment_status_model.dart';

class AppointmentsScreen extends StatelessWidget {
  AppointmentsScreen({super.key});

  final AppointmentsController appointmentsCont = Get.put(AppointmentsController());

  @override
  Widget build(BuildContext context) {
    return AppScaffoldNew(
      appBartitleText: locale.value.appointments,
      hasLeadingWidget: false,
      appBarVerticalSize: Get.height * 0.12,
      isLoading: appointmentsCont.isLoading,
      body: Obx(
        () => SnapHelperWidget(
          future: appointmentsCont.getAppointments.value,
          initialData: appointmentsCont.appointments.isNotEmpty ? appointmentsCont.appointments : null,
          errorBuilder: (error) {
            return NoDataWidget(
              title: error,
              retryText: locale.value.reload,
              imageWidget: const ErrorStateWidget(),
              onRetry: () {
                appointmentsCont.page(1);
                appointmentsCont.getAppointmentList();
              },
            ).paddingSymmetric(horizontal: 16);
          },
          loadingWidget: appointmentsCont.isLoading.value ? const Offstage() : const LoaderWidget(),
          onSuccess: (booking) {
            return Obx(
              () => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  HorizontalList(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    spacing: 12,
                    itemCount: filterStatus.length,
                    itemBuilder: (ctx, index) {
                      AppointmentStatusModel filterStatus1 = filterStatus[index];
                      return Obx(
                        () {
                          final bool isActive = appointmentsCont.selectedTab.value.type == filterStatus1.type;
                          return GestureDetector(
                            onTap: () {
                              appointmentsCont.selectedTab(filterStatus[index]);
                              appointmentsCont.page(1);
                              appointmentsCont.getAppointmentList(status: appointmentsCont.selectedTab.value.type.toString());
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 250),
                              curve: Curves.easeOut,
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                              decoration: BoxDecoration(
                                gradient: isActive
                                    ? const LinearGradient(
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                        colors: [gradientSecondaryStart, gradientSecondaryEnd],
                                      )
                                    : null,
                                color: isActive ? null : (isDarkMode.value ? surfaceElevatedDark : surfaceElevated),
                                borderRadius: BorderRadius.circular(12),
                                border: isActive
                                    ? null
                                    : Border.all(
                                        color: isDarkMode.value ? borderColorDark : whiteBorderColor,
                                        width: 1,
                                      ),
                                boxShadow: isActive
                                    ? [
                                        BoxShadow(
                                          color: gradientSecondaryStart.withValues(alpha: 0.3),
                                          blurRadius: 8,
                                          offset: const Offset(0, 4),
                                        ),
                                      ]
                                    : [
                                        BoxShadow(
                                          color: isDarkMode.value ? softShadowColorDark : softShadowColor,
                                          blurRadius: 8,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  CachedImageWidget(
                                    url: filterStatus1.icon,
                                    fit: BoxFit.fitHeight,
                                    height: 14,
                                    color: isActive ? whiteTextColor : secondaryTextColor,
                                  ),
                                  6.width,
                                  Text(
                                    filterStatus1.name?.value ?? '',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 13,
                                      fontWeight: isActive ? FontWeight.w700 : FontWeight.w600,
                                      color: isActive ? whiteTextColor : secondaryTextColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                  24.height,
                  AnimatedListView(
                    shrinkWrap: true,
                    itemCount: appointmentsCont.appointments.length,
                    listAnimationType: ListAnimationType.None,
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.only(left: 16, right: 16, bottom: 80),
                    emptyWidget: NoDataWidget(
                      title: locale.value.noAppointmentsFound,
                      imageWidget: const EmptyStateWidget(),
                      subTitle: locale.value.thereAreCurrentlyNoAppointmentsAvailableStart,
                    ).paddingSymmetric(horizontal: 16).paddingBottom(Get.height * 0.1),
                    itemBuilder: (context, index) {
                      return AppointmentCard(
                        appointment: appointmentsCont.appointments[index],
                        onUpdateBooking: () {
                          appointmentsCont.page(1);
                          appointmentsCont.getAppointmentList();
                        },
                      ).paddingBottom(16);
                    },
                    onNextPage: () async {
                      if (!appointmentsCont.isLastPage.value) {
                        appointmentsCont.page(appointmentsCont.page.value + 1);
                        appointmentsCont.getAppointmentList();
                      }
                    },
                    onSwipeRefresh: () async {
                      appointmentsCont.page(1);
                      return await appointmentsCont.getAppointmentList(showLoader: false);
                    },
                  ).expand(),
                ],
              ),
            );
          },
        ).makeRefreshable,
      ).paddingTop(16),
    );
  }
}
