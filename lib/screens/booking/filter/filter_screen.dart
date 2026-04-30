import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kivicare_patient/main.dart';
import 'package:kivicare_patient/utils/common_base.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:kivicare_patient/components/app_scaffold.dart';

import '../../../utils/app_common.dart';
import '../../../utils/colors.dart';
import '../../location_filter/governorate_selection_screen.dart';
import '../../location_filter/models/location_filter_result.dart';
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
              style: boldTextStyle(size: 14, color: whiteTextColor),
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
            _LocationFilterTile(filterCont: filterCont).paddingSymmetric(horizontal: 16),
            const SizedBox(height: 12),
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
              decoration: boxDecorationDefault(borderRadius: radius(0), color: context.cardColor),
              width: Get.width,
              padding: const EdgeInsets.all(16),
              child: AppButton(
                width: Get.width,
                text: locale.value.apply,
                color: appColorPrimary,
                textStyle: appButtonTextStyleWhite,
                onTap: () {
                  log('--------------------here000000000000000000');
                  log(filterType);
                  filterCont.applyFilter(filterType);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LocationFilterTile extends StatelessWidget {
  final FilterController filterCont;
  const _LocationFilterTile({required this.filterCont});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final dark = isDarkMode.value;
      final govId = filterCont.selectedGovernorateId.value;
      final gov = filterCont.selectedGovernorate.value;
      final city = filterCont.selectedCity.value;
      final lang = selectedLanguageCode.value;

      String label;
      if (govId == null) {
        label = locale.value.allLocations;
      } else if (city != null) {
        label = locale.value.locationFilterFormat
            .replaceAll('{governorate}', gov?.displayName(lang) ?? '')
            .replaceAll('{city}', city.displayName(lang));
      } else if (gov != null) {
        label = gov.displayName(lang);
      } else {
        label = locale.value.allLocations;
      }

      return InkWell(
        onTap: () => _openLocationFlow(filterCont),
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            color: dark ? surfaceElevatedDark : surfaceElevated,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: govId == null
                  ? (dark ? borderColorDark : whiteBorderColor)
                  : appColorSecondary,
              width: govId == null ? 1 : 1.5,
            ),
          ),
          child: Row(
            children: [
              Icon(Icons.location_on, color: appColorSecondary, size: 22),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(locale.value.location,
                        style: secondaryTextStyle(size: 12)),
                    const SizedBox(height: 2),
                    Text(
                      label,
                      style: boldTextStyle(size: 15),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios,
                  color: dark ? textTertiaryDark : appBodyColor, size: 14),
            ],
          ),
        ),
      );
    });
  }

  Future<void> _openLocationFlow(FilterController c) async {
    final result = await Get.to<LocationFilterResult>(
      () => GovernorateSelectionScreen(
        initiallySelectedId: c.selectedGovernorateId.value,
        initiallySelectedCityId: c.selectedCityId.value,
      ),
    );
    if (result == null) return;
    if (c.isClosed) return;
    if (result.cleared) {
      await c.clearLocationSelection();
    } else {
      await c.applyLocationSelection(
        governorateId: result.governorateId,
        cityId: result.cityId,
        governorate: result.governorate,
        city: result.city,
      );
    }
  }
}
