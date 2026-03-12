import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kivicare_patient/screens/service/model/service_list_model.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../../../components/loader_widget.dart';
import '../../../../../main.dart';
import '../../../../../utils/app_common.dart';
import '../../../../../utils/colors.dart';
import '../../../../../utils/empty_error_state_widget.dart';
import '../filter_controller.dart';

class FilterCategoryComponent extends StatelessWidget {
  final FilterController filterCont = Get.put(FilterController());

  FilterCategoryComponent({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Obx(
          () => SnapHelperWidget(
            future: filterCont.serviceListFuture.value,
            errorBuilder: (error) {
              return AnimatedScrollView(
                padding: const EdgeInsets.all(16),
                children: [
                  NoDataWidget(
                    title: error,
                    retryText: locale.value.reload,
                    imageWidget: const ErrorStateWidget(),
                    onRetry: () {
                      filterCont.servicePage(1);
                      filterCont.getServicesList();
                    },
                  ),
                ],
              ).paddingSymmetric(horizontal: 32);
            },
            loadingWidget: const LoaderWidget(),
            onSuccess: (data) {
              if (data.isEmpty) {
                return NoDataWidget(
                  title: locale.value.noCategoryFound,
                  retryText: locale.value.reload,
                  onRetry: () {
                    filterCont.servicePage(1);
                    filterCont.getServicesList();
                  },
                );
              } else {
                return Obx(
                  () => Stack(
                    children: [
                      AnimatedScrollView(
                        children: [
                          AnimatedWrap(
                            spacing: 0,
                            runSpacing: 0,
                            children: List.generate(filterCont.serviceList.length, (index) {
                              ServiceElement service = filterCont.serviceList[index];
                              final bool isSelected = filterCont.selectedServiceData.value.id == service.id;
                              return InkWell(
                                borderRadius: BorderRadius.circular(12),
                                onTap: () {
                                  filterCont.selectedServiceDataFunc(service);
                                },
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  margin: const EdgeInsets.all(4),
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? isDarkMode.value
                                            ? appColorSecondary.withValues(alpha: 0.2)
                                            : lightSecondaryColor
                                        : isDarkMode.value
                                            ? surfaceElevatedDark
                                            : surfaceElevated,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: isSelected
                                          ? appColorSecondary
                                          : isDarkMode.value
                                              ? glassStrokeDark
                                              : whiteBorderColor,
                                      width: isSelected ? 1.5 : 1,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      if (isSelected) ...[
                                        Icon(Icons.check_circle, color: appColorSecondary, size: 16),
                                        6.width,
                                      ],
                                      Flexible(
                                        child: Text(
                                          service.name.toString(),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: GoogleFonts.plusJakartaSans(
                                            fontSize: 12,
                                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                                            color: isSelected
                                                ? appColorSecondary
                                                : isDarkMode.value
                                                    ? Colors.white70
                                                    : primaryTextColor,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }),
                          ),
                        ],
                        onNextPage: () async {
                          if (!filterCont.isServiceLoading.value) {
                            filterCont.servicePage(filterCont.servicePage.value + 1);
                            filterCont.getServicesList();
                          }
                        },
                        onSwipeRefresh: () async {
                          filterCont.servicePage(1);
                          return await filterCont.getServicesList(showLoader: false);
                        },
                      ),
                      if (filterCont.isServiceLoading.isTrue) const LoaderWidget()
                    ],
                  ),
                );
              }
            },
          ),
        ).paddingOnly(bottom: 16, left: 16, right: 16).expand(),
      ],
    );
  }
}
