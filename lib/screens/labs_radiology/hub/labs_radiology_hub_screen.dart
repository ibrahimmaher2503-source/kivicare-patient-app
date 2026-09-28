import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:kivicare_patient/main.dart';
import 'package:kivicare_patient/utils/app_common.dart';
import 'package:kivicare_patient/utils/common_base.dart';
import 'package:kivicare_patient/utils/colors.dart';
import 'package:kivicare_patient/components/loader_widget.dart';
import 'package:kivicare_patient/components/no_data_found_widget.dart';
import 'package:kivicare_patient/utils/empty_error_state_widget.dart';
import '../models/facility_type.dart';
import '../models/lab_test_model.dart';
import 'labs_radiology_hub_controller.dart';
import 'components/facility_card.dart';
import 'components/facility_type_selector.dart';
import 'components/location_filter_chip.dart';
import '../shared/components/labs_shimmer.dart';
import '../categories/test_categories_screen.dart';
import '../facility_detail/facility_detail_screen.dart';
import '../orders/test_orders_list_screen.dart';
import '../slot_selection/slot_selection_screen.dart';

class LabsRadiologyHubScreen extends StatefulWidget {
  final LabTestModel? initialTest;

  const LabsRadiologyHubScreen({super.key, this.initialTest});

  @override
  State<LabsRadiologyHubScreen> createState() => _LabsRadiologyHubScreenState();
}

class _LabsRadiologyHubScreenState extends State<LabsRadiologyHubScreen> {
  late final String _controllerTag;
  late final LabsRadiologyHubController controller;

  @override
  void initState() {
    super.initState();
    _controllerTag = 'labs_hub_${identityHashCode(this)}';
    controller = Get.put(
      LabsRadiologyHubController(initialLabTestId: widget.initialTest?.id),
      tag: _controllerTag,
    );
  }

  @override
  void dispose() {
    if (Get.isRegistered<LabsRadiologyHubController>(tag: _controllerTag)) {
      Get.delete<LabsRadiologyHubController>(
        tag: _controllerTag,
        force: true,
      );
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        systemOverlayStyle: defaultSystemUiOverlayStyle(context),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [gradientStart, gradientEnd],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: Text(
          locale.value.labsAndRadiology,
          style: boldTextStyle(color: Colors.white, size: 18),
        ),
        actions: [
          _HubAppBarAction(
            icon: Icons.receipt_long_outlined,
            semanticLabel: locale.value.myTestOrders,
            onTap: () => doIfLoggedIn(
              () => Get.to(() => const TestOrdersListScreen()),
            ),
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

                    if (controller.errorMessage.value.isNotEmpty &&
                        list.isEmpty) {
                      return ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.all(24),
                        children: [
                          const ErrorStateWidget(),
                          12.height,
                          Text(
                            locale.value.somethingWentWrongPleaseTryAgainLater,
                            textAlign: TextAlign.center,
                          ),
                          12.height,
                          FilledButton.icon(
                            onPressed: controller.fetchData,
                            icon: const Icon(Icons.refresh),
                            label: Text(locale.value.retry),
                          ),
                        ],
                      );
                    }

                    if (list.isEmpty) {
                      return ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.all(24),
                        children: [
                          80.height,
                          NoDataFoundWidget(
                            text: locale.value.noFacilitiesFound,
                          ),
                        ],
                      );
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
                      itemCount: list.length +
                          (controller.isLoadingMore.value ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index == list.length) {
                          return const Padding(
                            padding: EdgeInsets.all(16),
                            child: Center(child: CircularProgressIndicator()),
                          );
                        }

                        if (index >= list.length - 3) {
                          controller.loadMore();
                        }

                        final facility = list[index];
                        return FacilityCard(
                          facility: facility,
                          onTap: () {
                            final selectedTest = widget.initialTest;
                            if (selectedTest != null) {
                              doIfLoggedIn(() => Get.to(
                                    () => SlotSelectionScreen(
                                      facility: facility,
                                      test: selectedTest,
                                    ),
                                  ));
                            } else {
                              Get.to(
                                () => FacilityDetailScreen(
                                  facility: facility,
                                ),
                              );
                            }
                          },
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
      floatingActionButton: Obx(() => widget.initialTest == null &&
              controller.facilityType.value == FacilityType.lab
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
          if (widget.initialTest == null)
            FacilityTypeSelector(
              selectedType: controller.facilityType.value,
              onTypeChanged: (type) => controller.switchType(type),
            )
          else
            Semantics(
              container: true,
              label:
                  '${locale.value.selectedTest}: ${widget.initialTest!.name}',
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: appColorPrimary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: appColorPrimary.withValues(alpha: 0.18),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.science_outlined,
                      color: appColorPrimary,
                    ),
                    10.width,
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            locale.value.selectedTest,
                            style: secondaryTextStyle(size: 12),
                          ),
                          Text(
                            widget.initialTest!.name,
                            style: boldTextStyle(size: 14),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          16.height,
          Semantics(
            textField: true,
            label: controller.facilityType.value == FacilityType.lab
                ? locale.value.searchLabs
                : locale.value.searchRadiologyCenters,
            child: AppTextField(
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

/// Rounded translucent action button for the hub app bar, matching the
/// home top-bar action style on the navy header.
class _HubAppBarAction extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final String semanticLabel;

  const _HubAppBarAction({
    required this.icon,
    required this.onTap,
    required this.semanticLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.only(end: 12, start: 4),
      child: Semantics(
        container: true,
        button: true,
        label: semanticLabel,
        child: ExcludeSemantics(
          child: Tooltip(
            message: semanticLabel,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onTap,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  width: 48,
                  height: 48,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: Colors.white.withValues(alpha: 0.22), width: 1),
                  ),
                  child: Icon(icon, color: Colors.white, size: 20),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
