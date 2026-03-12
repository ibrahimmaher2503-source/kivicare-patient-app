import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kivicare_patient/main.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:kivicare_patient/components/app_scaffold.dart';

import '../../../utils/app_common.dart';
import '../../../utils/colors.dart';
import 'components/type_list_component.dart';
import 'filter_controller.dart';

class FilterScreen extends StatelessWidget {
  final String filterType;
  final String? displayName;

  FilterScreen({super.key, this.filterType = 'service', this.displayName});

  final FilterController filterCont = Get.put(FilterController());

  @override
  Widget build(BuildContext context) {
    return AppScaffoldNew(
      appBartitleText: locale.value.filterBy,
      appBarVerticalSize: Get.height * 0.12,
      actions: [
        Obx(
          () => TextButton(
            onPressed: () {
              filterCont.resetFilter(filterType, displayName ?? 'service');
            },
            child: Text(
              locale.value.reset,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: whiteTextColor,
              ),
            ),
          ),
        )
      ],
      body: Container(
        height: Get.height,
        width: double.infinity,
        decoration: BoxDecoration(
          color: isDarkMode.value ? appScreenBackgroundDark : appScreenBackground,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            16.height,
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                FilterTypeListComponent(
                  filterList: displayName == "service"
                      ? filterCont.serviceFilterList
                      : displayName == "clinic"
                          ? filterCont.clinicFilterList
                          : displayName == "category"
                              ? filterCont.categoryFilterList
                              : filterCont.filterList,
                ).expand(flex: 1),
                Obx(() => filterCont.viewFilterWidget(displayName ?? "")),
              ],
            ).expand(),
            Container(
              decoration: BoxDecoration(
                color: isDarkMode.value ? surfaceElevatedDark : surfaceElevated,
                boxShadow: [
                  BoxShadow(
                    color: isDarkMode.value ? softShadowColorDark : softShadowColorMedium,
                    blurRadius: 16,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              width: Get.width,
              padding: const EdgeInsets.all(16),
              child: Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [gradientSecondaryStart, gradientSecondaryEnd],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: appColorSecondary.withValues(alpha: 0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: AppButton(
                  width: Get.width,
                  text: locale.value.apply,
                  color: Colors.transparent,
                  elevation: 0,
                  textStyle: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                  shapeBorder: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  onTap: () {
                    log('--------------------here000000000000000000');
                    log(filterType);
                    filterCont.applyFilter(filterType);
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
