import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:kivicare_patient/components/cached_image_widget.dart';

import '../../../../../components/loader_widget.dart';
import '../../../../../generated/assets.dart';
import '../../../../../main.dart';
import '../../../../../utils/app_common.dart';
import '../../../../../utils/colors.dart';
import '../../../../../utils/common_base.dart';
import '../../../../../utils/empty_error_state_widget.dart';
import '../../../../clinic/model/clinics_res_model.dart';
import '../../filter_controller.dart';
import 'filter_search_clinic_component.dart';

class FilterClinicComponent extends StatelessWidget {
  final FilterController filterCont = Get.put(FilterController());

  FilterClinicComponent({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FilterSearchClinicComponent(
          filterClinicController: filterCont,
          onFieldSubmitted: (p0) {
            hideKeyboard(context);
          },
        ).paddingSymmetric(horizontal: 16),
        12.height,
        Obx(
          () => SnapHelperWidget(
            future: filterCont.clinicListFuture.value,
            errorBuilder: (error) {
              return AnimatedScrollView(
                padding: const EdgeInsets.all(16),
                children: [
                  NoDataWidget(
                    title: error,
                    retryText: locale.value.reload,
                    imageWidget: const ErrorStateWidget(),
                    onRetry: () {
                      filterCont.clinicPage(1);
                      filterCont.getClinicsList();
                    },
                  ),
                ],
              ).paddingSymmetric(horizontal: 32);
            },
            loadingWidget: const LoaderWidget(),
            onSuccess: (data) {
              if (filterCont.clinicList.isEmpty) {
                return AnimatedScrollView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    NoDataWidget(
                      title: locale.value.noClinicsFoundAtAMoment,
                      subTitle: locale.value.looksLikeThereIsNoClinicForThisServiceWellKee,
                      retryText: locale.value.reload,
                      imageWidget: const EmptyStateWidget(),
                      onRetry: () async {
                        filterCont.clinicPage(1);
                        filterCont.getClinicsList();
                      },
                    ),
                  ],
                ).paddingSymmetric(horizontal: 32).visible(!filterCont.isClinicLoading.value);
              } else {
                return Obx(
                  () => Stack(
                    children: [
                      AnimatedScrollView(
                        children: [
                          AnimatedWrap(
                            spacing: 0,
                            runSpacing: 0,
                            children: List.generate(filterCont.clinicList.length, (index) {
                              Clinic clinic = filterCont.clinicList[index];
                              final bool isSelected = filterCont.selectedClinicData.value.id == clinic.id;
                              return InkWell(
                                borderRadius: BorderRadius.circular(16),
                                onTap: () {
                                  filterCont.selectedClinicDataFunc(clinic);
                                },
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  margin: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: isDarkMode.value ? surfaceElevatedDark : surfaceElevated,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: isSelected
                                          ? appColorSecondary
                                          : isDarkMode.value
                                              ? glassStrokeDark
                                              : whiteBorderColor,
                                      width: isSelected ? 1.5 : 1,
                                    ),
                                    boxShadow: isSelected
                                        ? [
                                            BoxShadow(
                                              color: appColorSecondary.withValues(alpha: 0.15),
                                              blurRadius: 8,
                                              offset: const Offset(0, 2),
                                            ),
                                          ]
                                        : [],
                                  ),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      ClipRRect(
                                        borderRadius: const BorderRadius.only(
                                          topLeft: Radius.circular(16),
                                          bottomLeft: Radius.circular(16),
                                        ),
                                        child: CachedImageWidget(
                                          url: clinic.clinicImage,
                                          height: 75,
                                          width: 75,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                      8.width,
                                      Expanded(
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            8.height,
                                            Text(
                                              clinic.name.toString(),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: GoogleFonts.plusJakartaSans(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w600,
                                                color: isDarkMode.value ? Colors.white : appColorPrimary,
                                              ),
                                            ),
                                            4.height,
                                            Row(
                                              children: [
                                                const CachedImageWidget(url: Assets.iconsIcLocation, color: appColorSecondary, width: 12, height: 12),
                                                6.width,
                                                Expanded(
                                                  child: Text(
                                                    clinic.address,
                                                    style: GoogleFonts.plusJakartaSans(fontSize: 11, color: secondaryTextColor),
                                                    maxLines: 1,
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            6.height,
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                                              decoration: BoxDecoration(
                                                color: getClinicStatusLightColor(clinicStatus: clinic.clinicStatus.toLowerCase()),
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                              child: Text(
                                                getClinicStatus(status: clinic.clinicStatus.toLowerCase()),
                                                style: GoogleFonts.plusJakartaSans(
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.w600,
                                                  color: Colors.green.shade600,
                                                ),
                                              ),
                                            ),
                                            6.height,
                                          ],
                                        ),
                                      ),
                                      if (isSelected)
                                        Container(
                                          margin: const EdgeInsets.only(top: 8, right: 8),
                                          child: Icon(Icons.check_circle, color: appColorSecondary, size: 20),
                                        ),
                                    ],
                                  ),
                                ),
                              );
                            }),
                          ),
                        ],
                        onNextPage: () async {
                          if (!filterCont.isClinicLoading.value) {
                            filterCont.clinicPage(filterCont.clinicPage.value + 1);
                            filterCont.getClinicsList();
                          }
                        },
                        onSwipeRefresh: () async {
                          filterCont.clinicPage(1);
                          return await filterCont.getClinicsList(showLoader: false);
                        },
                      ),
                      if (filterCont.isClinicLoading.isTrue) const LoaderWidget()
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