import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kivicare_patient/components/app_scaffold.dart';
import 'package:kivicare_patient/screens/clinic/components/week_time_comnponents.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../main.dart';
import '../../../utils/app_common.dart';
import '../../../utils/colors.dart';
import '../clinic_detail_controller.dart';
import '../model/clinic_detail_model.dart';

class ClinicSessionComponent extends StatelessWidget {
  final ClinicDetailController clinicDetailCont;

  const ClinicSessionComponent({super.key, required this.clinicDetailCont});

  @override
  Widget build(BuildContext context) {
    return AppScaffoldNew(
      appBartitleText: locale.value.session,
      scaffoldBackgroundColor: context.scaffoldBackgroundColor,
      appBarVerticalSize: Get.height * 0.12,
      body: RefreshIndicator(
        onRefresh: () {
          return clinicDetailCont.init(showLoader: false);
        },
        child: Obx(
          () => AnimatedListView(
            listAnimationType: ListAnimationType.FadeIn,
            padding: const EdgeInsets.all(16),
            shrinkWrap: true,
            itemCount: clinicDetailCont.clinicData.value.allClinicSession.length,
            itemBuilder: (ctx, index) {
              AllClinicSession allClinicSessionData = clinicDetailCont.clinicData.value.allClinicSession[index];

              return Container(
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: isDarkMode.value ? surfaceElevatedDark : surfaceElevated,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: isDarkMode.value ? softShadowColorDark : softShadowColor,
                      blurRadius: 12,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          width: 4,
                          height: 20,
                          decoration: BoxDecoration(
                            color: allClinicSessionData.isHoliday ? dividerColor : appColorSecondary,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        12.width,
                        Text(
                          allClinicSessionData.day.capitalize.toString(),
                          style: GoogleFonts.outfit(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: allClinicSessionData.isHoliday ? dividerColor : (isDarkMode.value ? Colors.white : appColorPrimary),
                          ),
                        ).expand(),
                        if (allClinicSessionData.isHoliday)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: cancelStatusColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              locale.value.clinicClosed,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: cancelStatusColor,
                              ),
                            ),
                          ),
                      ],
                    ),
                    if (!allClinicSessionData.isHoliday) WeekTimeComponent(weekData: allClinicSessionData),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}