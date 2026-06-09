import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:kivicare_patient/main.dart';
import 'package:kivicare_patient/utils/app_common.dart';
import 'package:kivicare_patient/utils/common_base.dart';
import 'package:kivicare_patient/utils/colors.dart';
import 'package:kivicare_patient/components/loader_widget.dart';
import 'package:kivicare_patient/components/no_data_found_widget.dart';
import '../models/facility_type.dart';
import 'labs_radiology_hub_controller.dart';
import 'components/facility_card.dart';
import 'components/facility_type_selector.dart';
import 'components/location_filter_chip.dart';
import '../shared/components/labs_shimmer.dart';
import '../categories/test_categories_screen.dart';
import '../facility_detail/facility_detail_screen.dart';

class LabsRadiologyHubScreen extends StatelessWidget {
  final controller = Get.put(LabsRadiologyHubController());

  LabsRadiologyHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarWidget(
        locale.value.labsAndRadiology,
        textColor: Colors.white,
        systemUiOverlayStyle: defaultSystemUiOverlayStyle(context),
        actions: [
          IconButton(
            icon: const Icon(Icons.history, color: Colors.white),
            onPressed: () {
              // Navigate to my orders
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Obx(() => _buildHeader(context)),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () => controller.fetchData(showLoader: false),
                  child: Obx(() {
                    final list =
                        controller.facilityType.value == FacilityType.lab
                            ? controller.labs
                            : controller.radiologyCenters;

                    if (controller.isLoading.value && list.isEmpty) {
                      return const LabsFacilityShimmer();
                    }

                    if (list.isEmpty) {
                      return NoDataFoundWidget(
                              text: locale.value.noFacilitiesFound)
                          .center();
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
                      itemCount: list.length,
                      itemBuilder: (context, index) {
                        final facility = list[index];
                        return FacilityCard(
                          facility: facility,
                          onTap: () => Get.to(
                              () => FacilityDetailScreen(facility: facility)),
                        );
                      },
                    );
                  }),
                ),
              ),
            ],
          ),
          // Subtle refresh spinner only when the CURRENT tab already shows
          // data (e.g. pull-to-refresh). When the current list is empty the
          // shimmer handles the loading state, so don't stack a spinner on it.
          Obx(() {
            final currentList =
                controller.facilityType.value == FacilityType.lab
                    ? controller.labs
                    : controller.radiologyCenters;
            return const LoaderWidget()
                .center()
                .visible(controller.isLoading.value && currentList.isNotEmpty);
          }),
        ],
      ),
      floatingActionButton:
          Obx(() => controller.facilityType.value == FacilityType.lab
              ? FloatingActionButton.extended(
                  onPressed: () => Get.to(() => const TestCategoriesScreen()),
                  label: Text(locale.value.browseTestCategories),
                  icon: const Icon(Icons.category_outlined),
                )
              : const SizedBox.shrink()),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: boxDecorationDefault(
        color: context.scaffoldBackgroundColor,
        borderRadius: radius(0),
        boxShadow: defaultBoxShadow(),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FacilityTypeSelector(
            selectedType: controller.facilityType.value,
            onTypeChanged: (type) => controller.switchType(type),
          ),
          16.height,
          AppTextField(
            textFieldType: TextFieldType.NAME,
            onChanged: (v) => controller.updateSearch(v),
            decoration: inputDecoration(
              context,
              labelText: controller.facilityType.value == FacilityType.lab
                  ? locale.value.searchLabs
                  : locale.value.searchRadiologyCenters,
              prefixIcon: const Icon(Icons.search, color: secondaryTextColor),
            ),
          ),
          12.height,
          Obx(() => LocationFilterChip(
                selectedGovernorateId: controller.selectedGovernorateId.value,
                selectedCityId: controller.selectedCityId.value,
                selectedGovernorateName:
                    controller.selectedGovernorateName.value,
                selectedCityName: controller.selectedCityName.value,
                onLocationChanged: (result) {
                  if (result != null) {
                    controller.updateLocation(
                      governorateId: result.governorateId,
                      cityId: result.cityId,
                      governorateName: result.governorate
                          ?.displayName(selectedLanguageCode.value),
                      cityName:
                          result.city?.displayName(selectedLanguageCode.value),
                    );
                  }
                },
              )),
        ],
      ),
    );
  }
}
