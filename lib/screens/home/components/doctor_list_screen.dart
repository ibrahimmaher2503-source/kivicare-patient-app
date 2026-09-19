import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../components/accessible_filter_button.dart';
import '../../../components/app_scaffold.dart';
import '../../../components/loader_widget.dart';
import '../../../main.dart';
import '../../../utils/colors.dart';
import '../../../utils/app_common.dart';
import '../../../utils/empty_error_state_widget.dart';
import '../../booking/filter/filter_screen.dart';
import '../../booking/filter/model/filter_params.dart';
import '../../doctor/components/search_doctor_service.dart';
import '../../doctor/doctor_list_controller.dart';
import '../../doctor/model/doctor_list_res.dart';
import '../../doctor/components/popular_doctor_card.dart';

class DoctorViewListScreen extends StatelessWidget {
  final String? title;
  final bool isFromClinicDetail;
  final bool isFromDashboard;

  DoctorViewListScreen(
      {super.key,
      this.title,
      this.isFromClinicDetail = false,
      this.isFromDashboard = false});

  final DoctorListController doctorListCont = Get.put(DoctorListController());
  int get activeFilterCount {
    var count = 0;
    if (doctorListCont.clinicId.value > 0) count++;
    if (currentSelectedService.value.id > 0) count++;
    if (doctorListCont.ratingMin.value.isNotEmpty ||
        doctorListCont.ratingMax.value.isNotEmpty) {
      count++;
    }
    if (doctorListCont.governorateId.value != null) count++;
    return count;
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffoldNew(
      appBartitleText: title,
      appBarVerticalSize: Get.height * 0.12,
      isLoading: doctorListCont.isLoading,
      body: Obx(
        () => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                SearchDoctorWidget(
                  doctorController: doctorListCont,
                  onFieldSubmitted: (p0) {
                    hideKeyboard(context);
                  },
                ).expand(),
                12.width,
                AccessibleFilterButton(
                  count: activeFilterCount,
                  onPressed: () {
                    doctorListCont.searchDoctorCont.clear();
                    doctorListCont.page(1);
                    Get.to(
                        () => FilterScreen(
                              filterType: "doctor",
                              displayName: "doctor",
                            ),
                        arguments: FilterParams(
                          moduleType: 'doctor',
                          clinicId: doctorListCont.clinicId.value,
                          serviceType: doctorListCont.serviceType.value,
                          ratingMin: doctorListCont.ratingMin.value,
                          ratingMax: doctorListCont.ratingMax.value,
                          governorateId: doctorListCont.governorateId.value,
                          cityId: doctorListCont.cityId.value,
                        ), binding: BindingsBuilder(() {
                      setStatusBarColor(
                        transparentColor,
                        statusBarIconBrightness: Brightness.light,
                        statusBarBrightness: Brightness.light,
                        systemNavigationBarColor: whiteTextColor,
                      );
                    }));
                  },
                ),
              ],
            ).paddingAll(16),
            SnapHelperWidget(
              future: doctorListCont.doctorsFuture.value,
              errorBuilder: (error) {
                return NoDataWidget(
                  title: locale.value.somethingWentWrongPleaseTryAgainLater,
                  retryText: locale.value.reload,
                  imageWidget: const ErrorStateWidget(),
                  onRetry: () {
                    doctorListCont.page(1);
                    doctorListCont.getDoctors();
                  },
                ).paddingSymmetric(horizontal: 32);
              },
              loadingWidget: doctorListCont.isLoading.value
                  ? const Offstage()
                  : const LoaderWidget(),
              onSuccess: (p0) {
                if (doctorListCont.doctors.isEmpty &&
                    !doctorListCont.isLoading.value) {
                  return NoDataWidget(
                    title: locale.value.noDoctorsFoundAtAMoment,
                    subTitle:
                        'Looks like there is no doctors, ${locale.value.wellKeepYouPostedWhenTheresAnUpdate}',
                    titleTextStyle: primaryTextStyle(),
                    imageWidget: const EmptyStateWidget(),
                    retryText: locale.value.reload,
                    onRetry: () {
                      doctorListCont.page(1);
                      doctorListCont.getDoctors();
                    },
                  ).paddingSymmetric(horizontal: 32);
                }

                return AnimatedScrollView(
                  padding: const EdgeInsets.all(16),
                  physics: const AlwaysScrollableScrollPhysics(),
                  listAnimationType: ListAnimationType.FadeIn,
                  onSwipeRefresh: () async {
                    doctorListCont.page(1);
                    return await doctorListCont.getDoctors(showLoader: false);
                  },
                  onNextPage: () async {
                    if (!doctorListCont.isLastPage.value) {
                      doctorListCont.page(doctorListCont.page.value + 1);
                      doctorListCont.getDoctors();
                    }
                  },
                  children: [
                    AnimatedWrap(
                      runSpacing: 16,
                      spacing: 16,
                      itemCount: doctorListCont.doctors.length,
                      direction: Axis.horizontal,
                      listAnimationType: ListAnimationType.FadeIn,
                      itemBuilder: (ctx, index) {
                        Doctor doctorElement = doctorListCont.doctors[index];
                        return PopularDoctorCard(
                            doctorElement: doctorElement,
                            isFromClinicDetail: isFromClinicDetail);
                      },
                    ),
                  ],
                ).visible(!doctorListCont.isLoading.value);
              },
            ).expand(),
          ],
        ),
      ),
    );
  }
}
