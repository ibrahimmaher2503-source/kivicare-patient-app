import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../main.dart';
import '../../../utils/colors.dart';
import '../../../utils/common_base.dart';
import '../../../utils/app_common.dart';
import '../../../utils/view_all_label_component.dart';
import '../../booking/components/appointment_card.dart';
import '../home_controller.dart';

class UpcomingAppointmentComponents extends StatelessWidget {
  UpcomingAppointmentComponents({super.key});
  final HomeController homeScreenController = Get.find();

  @override
  Widget build(BuildContext context) {
    if (homeScreenController.dashboardData.value.upcomingAppointment.isEmpty) {
      return const Offstage();
    }

    final appointment = homeScreenController.dashboardData.value.upcomingAppointment.first;
    final Color statusAccentColor = getBookingStatusColor(status: appointment.status);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ViewAllLabel(label: locale.value.upcomingAppointments, isShowAll: false),
        8.height,
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: isDarkMode.value ? softShadowColorDark : softShadowColor,
                blurRadius: 16,
                offset: const Offset(0, 4),
                spreadRadius: 0,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Container(
              decoration: BoxDecoration(
                color: isDarkMode.value ? surfaceElevatedDark : surfaceElevated,
                border: Border(
                  left: BorderSide(
                    color: statusAccentColor,
                    width: 4,
                  ),
                ),
              ),
              child: AppointmentCard(appointment: appointment),
            ),
          ),
        ),
      ],
    ).paddingSymmetric(horizontal: 16);
  }
}
