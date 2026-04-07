import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../components/app_scaffold.dart';
import '../../components/governorates_city_picker.dart';
import '../../components/loader_widget.dart';
import '../../main.dart';
import '../../utils/app_common.dart';
import '../../utils/colors.dart';
import 'components/radiology_center_card.dart';
import 'radiology_centers_controller.dart';

class RadiologyCentersScreen extends StatefulWidget {
  const RadiologyCentersScreen({super.key});

  @override
  State<RadiologyCentersScreen> createState() => _RadiologyCentersScreenState();
}

class _RadiologyCentersScreenState extends State<RadiologyCentersScreen> {
  late final RadiologyCentersController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.put(RadiologyCentersController());
  }

  @override
  void dispose() {
    Get.delete<RadiologyCentersController>();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => AppScaffoldNew(
        appBartitleText: locale.value.radiologyCenters,
        hasLeadingWidget: true,
        appBarVerticalSize: Get.height * 0.12,
        isLoading: controller.isLoading,
        body: Obx(
          () => SnapHelperWidget(
            future: controller.centersFuture.value,
            initialData: controller.centers.isNotEmpty ? controller.centers : null,
            errorBuilder: (error) {
              return _buildEmptyState();
            },
            loadingWidget: controller.isLoading.value ? const Offstage() : const LoaderWidget(),
            onSuccess: (_) {
              return AnimatedScrollView(
                listAnimationType: ListAnimationType.FadeIn,
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  16.height,
                  // Search Bar
                  AppTextField(
                    textStyle: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      letterSpacing: 0.1,
                      color: isDarkMode.value ? Colors.white : primaryTextColor,
                    ),
                    controller: controller.searchCont,
                    textFieldType: TextFieldType.OTHER,
                    onChanged: controller.onSearchChanged,
                    decoration: InputDecoration(
                      hintText: '${locale.value.searchHere}...',
                      hintStyle: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        letterSpacing: 0.1,
                        color: secondaryTextColor,
                      ),
                      prefixIcon: const Icon(Icons.search, color: secondaryTextColor),
                      filled: true,
                      fillColor: isDarkMode.value ? inputFillColorDark : inputFillColor,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                  ),
                  16.height,
                  // Scan Type Filter Chips
                  _buildScanTypeChips(),
                  16.height,
                  // Location Filter
                  Obx(() => GovernoratesCityPicker(
                    selectedGovernorateId: controller.selectedGovernorateId.value,
                    selectedCityId: controller.selectedCityId.value,
                    onGovernorateChanged: controller.onGovernorateChanged,
                    onCityChanged: controller.onCityChanged,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                  )),
                  16.height,
                  // Center List
                  Builder(
                    builder: (_) {
                      if (controller.centers.isEmpty) {
                        return _buildEmptyState().paddingTop(Get.height * 0.1);
                      }

                      return Column(
                        children: controller.centers.map((center) {
                          return RadiologyCenterCard(centerData: center).paddingBottom(16);
                        }).toList(),
                      );
                    },
                  ),
                ],
                onNextPage: () async {
                  if (!controller.isLastPage.value) {
                    controller.page(controller.page.value + 1);
                    await controller.getCenters();
                  }
                },
                onSwipeRefresh: () async {
                  controller.page(1);
                  return await controller.getCenters();
                },
              ).paddingOnly(bottom: 10);
            },
          ),
        ).paddingTop(16),
      ),
    );
  }

  Widget _buildScanTypeChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Obx(() => Row(
        children: List.generate(controller.scanTypeFilters.length, (index) {
          final filter = controller.scanTypeFilters[index];
          return Obx(() {
            final isSelected = controller.selectedScanType.value == filter['key'];
            return GestureDetector(
              onTap: () => controller.onScanTypeChanged(filter['key']!),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: EdgeInsets.only(right: index < controller.scanTypeFilters.length - 1 ? 12 : 0),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  gradient: isSelected
                      ? const LinearGradient(colors: [gradientSecondaryStart, gradientSecondaryEnd])
                      : null,
                  color: isSelected ? null : (isDarkMode.value ? surfaceElevatedDark : surfaceElevated),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: isSelected
                          ? appColorSecondary.withValues(alpha: 0.3)
                          : (isDarkMode.value ? softShadowColorDark : softShadowColor),
                      blurRadius: isSelected ? 12 : 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Text(
                  filter['label']!,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.1,
                    color: isSelected
                        ? Colors.white
                        : (isDarkMode.value ? Colors.white70 : primaryTextColor),
                  ),
                ),
              ),
            );
          });
        }),
      )),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.medical_information_outlined,
            size: Get.height * 0.1,
            color: const Color(0xFF7C4DFF).withValues(alpha: 0.3),
          ),
          30.height,
          Text(
            locale.value.noRadiologyCentersFound,
            style: GoogleFonts.outfit(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.5,
              color: isDarkMode.value ? Colors.white : primaryTextColor,
            ),
          ),
        ],
      ),
    );
  }
}
