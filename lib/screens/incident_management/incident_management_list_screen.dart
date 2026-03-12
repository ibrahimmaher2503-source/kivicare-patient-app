import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nb_utils/nb_utils.dart';
import '../../components/app_scaffold.dart';
import '../../components/cached_image_widget.dart';
import '../../components/loader_widget.dart';
import '../../generated/assets.dart';
import '../../main.dart';
import '../../utils/app_common.dart';
import '../../utils/colors.dart';
import 'add_incident_management_screen.dart';
import 'components/incedent_management_card.dart';
import 'incident_management_controller.dart';
import 'model/incident_status_model.dart';

class IncidentManagementListScreen extends StatelessWidget {
  IncidentManagementListScreen({super.key});

  final IncidentManagement controller = Get.put(IncidentManagement());

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => AppScaffoldNew(
        appBartitleText: locale.value.incidentManagement,
        hasLeadingWidget: true,
        appBarVerticalSize: Get.height * 0.12,
        isLoading: controller.isLoading,
        actions: [
          controller.incidents.isNotEmpty
              ? IconButton(
                  onPressed: () async {
                    controller.clearTextFields();
                    Get.to(() => AddIncidentManagement());
                  },
                  icon: const Icon(Icons.add_circle_outline_rounded, size: 28, color: Colors.white),
                ).paddingOnly(right: 8)
              : const SizedBox(),
        ],
        body: Obx(
          () => SnapHelperWidget(
            future: controller.incidenceFuture.value,
            initialData: controller.incidents.isNotEmpty ? controller.incidents : null,
            errorBuilder: (error) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CachedImageWidget(
                      url: Assets.iconsIcIncidentAlert,
                      height: Get.height * 0.12,
                      color: appColorPrimary,
                      fit: BoxFit.fitHeight,
                    ),
                    30.height,
                    Text(
                      locale.value.noQueryYet,
                      style: GoogleFonts.outfit(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        letterSpacing: -0.5,
                        color: isDarkMode.value ? Colors.white : primaryTextColor,
                      ),
                    ),
                    10.height,
                    Text(
                      locale.value.toSubmitYourProblemsSimplyPressAddButtonAndExplainYourConcern,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        letterSpacing: 0.1,
                        color: darkGrayGeneral,
                      ),
                      textAlign: TextAlign.center,
                    ).paddingOnly(left: 12, right: 12),
                    30.height,
                    _buildAddButton(),
                  ],
                ),
              );
            },
            loadingWidget: controller.isLoading.value ? const Offstage() : const LoaderWidget(),
            onSuccess: (_) {
              return AnimatedScrollView(
                listAnimationType: ListAnimationType.FadeIn,
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  /// Filter Chips
                  if (controller.incidents.isNotEmpty)
                    AnimatedWrap(
                      spacing: 12,
                      runSpacing: 8,
                      children: List.generate(controller.filterStatus.length, (index) {
                        final filterStatus = controller.filterStatus[index];
                        return Obx(() {
                          final isSelected = controller.selectedTab.value.type == filterStatus.type;
                          return GestureDetector(
                            onTap: () {
                              controller.selectedTab(filterStatus);
                              controller.incidencePage(1);
                              controller.getIncidents();
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                              decoration: BoxDecoration(
                                gradient: isSelected
                                    ? LinearGradient(colors: [gradientStart, gradientEnd])
                                    : null,
                                color: isSelected ? null : (isDarkMode.value ? surfaceElevatedDark : surfaceElevated),
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: isSelected
                                        ? appColorPrimary.withValues(alpha: 0.3)
                                        : (isDarkMode.value ? softShadowColorDark : softShadowColor),
                                    blurRadius: isSelected ? 12 : 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Text(
                                filterStatus.name,
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
                    ),
                  16.height,
                  Builder(
                    builder: (_) {
                      final selectedType = controller.selectedTab.value.type;
                      final filteredIncidents = controller.incidents.where((incident) {
                        if (selectedType == IncidentStatus.all) return true;
                        return incident.incidenceTypeName.toLowerCase() == selectedType.name.toLowerCase();
                      }).toList();
                      filteredIncidents.sort((a, b) => b.createdAt.compareTo(a.createdAt));
                      if (filteredIncidents.isEmpty) {
                        return Column(
                          children: [
                            CachedImageWidget(
                              url: Assets.iconsIcIncidentAlert,
                              height: Get.height * 0.12,
                              color: appColorPrimary,
                              fit: BoxFit.fitHeight,
                            ),
                            30.height,
                            Text(
                              locale.value.noQueryYet,
                              style: GoogleFonts.outfit(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                                letterSpacing: -0.5,
                                color: isDarkMode.value ? Colors.white : primaryTextColor,
                              ),
                            ),
                            10.height,
                            Text(
                              locale.value.toSubmitYourProblemsSimplyPressAddButtonAndExplainYourConcern,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 13,
                                letterSpacing: 0.1,
                                color: darkGrayGeneral,
                              ),
                              textAlign: TextAlign.center,
                            ).paddingOnly(left: 12, right: 12),
                            30.height,
                            _buildAddButton(),
                          ],
                        ).paddingTop(Get.height * 0.15);
                      }

                      return Column(
                        children: filteredIncidents.map((incident) {
                          return IncidentManagementCard(
                            incidentController: controller,
                            incidentData: incident,
                            onUpdateBooking: () {
                              controller.incidencePage(1);
                              controller.getIncidents();
                            },
                          ).paddingBottom(16);
                        }).toList(),
                      );
                    },
                  ),
                ],
                onNextPage: () async {
                  if (!controller.isIncidenceLastPage.value) {
                    controller.incidencePage(controller.incidencePage.value + 1);
                    await controller.getIncidents();
                  }
                },
                onSwipeRefresh: () async {
                  controller.incidencePage(1);
                  return await controller.getIncidents();
                },
              ).paddingOnly(bottom: 10);
            },
          ),
        ).paddingTop(16),
      ),
    );
  }

  Widget _buildAddButton() {
    return GestureDetector(
      onTap: () {
        controller.clearTextFields();
        Get.to(() => AddIncidentManagement());
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 12),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [gradientSecondaryStart, gradientSecondaryEnd]),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: appColorSecondary.withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Text(
          locale.value.add,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.1,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
