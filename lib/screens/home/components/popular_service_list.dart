import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kivicare_patient/screens/service/components/popular_service_card.dart';
import 'package:kivicare_patient/screens/service/service_list_controller.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../components/app_scaffold.dart';
import '../../../components/accessible_filter_button.dart';
import '../../../components/loader_widget.dart';
import '../../../main.dart';
import '../../../utils/colors.dart';
import '../../../utils/empty_error_state_widget.dart';
import '../../booking/filter/filter_screen.dart';
import '../../booking/filter/model/filter_params.dart';
import '../../service/model/service_list_model.dart';
import '../../service/popular_search_service.dart';

class PopularServiceListScreen extends StatelessWidget {
  final String? title;
  final bool isFromClinicDetail;
  final bool isFromDashboard;

  PopularServiceListScreen(
      {super.key,
      this.title,
      this.isFromClinicDetail = false,
      this.isFromDashboard = false});

  final ServiceListController popularServiceCont =
      Get.put(ServiceListController(), tag: 'popular-service-list');
  int get activeFilterCount {
    var count = 0;
    if (popularServiceCont.clinicId.value > 0) count++;
    if (popularServiceCont.category.value.id > 0) count++;
    if (popularServiceCont.priceMin.value.isNotEmpty ||
        popularServiceCont.priceMax.value.isNotEmpty) {
      count++;
    }
    if (popularServiceCont.governorateId.value != null) count++;
    return count;
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffoldNew(
      appBartitleText: title,
      appBarVerticalSize: Get.height * 0.12,
      isLoading: popularServiceCont.isLoading,
      body: Obx(
        () => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                PopularSearchServiceWidget(
                  popularServiceController: popularServiceCont,
                  onFieldSubmitted: (p0) {
                    hideKeyboard(context);
                    popularServiceCont.getServiceList();
                  },
                ).expand(),
                12.width,
                AccessibleFilterButton(
                  count: activeFilterCount,
                  onPressed: () {
                    popularServiceCont.searchCont.clear();
                    popularServiceCont.page(1);
                    Get.to(
                        () => FilterScreen(
                              displayName: "service",
                              serviceController: popularServiceCont,
                            ),
                        arguments: FilterParams(
                          moduleType: 'service',
                          clinicId: popularServiceCont.clinicId.value,
                          serviceType: popularServiceCont.serviceType.value,
                          priceMin: popularServiceCont.priceMin.value,
                          priceMax: popularServiceCont.priceMax.value,
                          governorateId: popularServiceCont.governorateId.value,
                          cityId: popularServiceCont.cityId.value,
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
              future: popularServiceCont.serviceListFuture.value,
              errorBuilder: (error) {
                return NoDataWidget(
                  title: locale.value.somethingWentWrong,
                  retryText: locale.value.reload,
                  imageWidget: const ErrorStateWidget(),
                  onRetry: () {
                    popularServiceCont.page(1);
                    popularServiceCont.getServiceList();
                  },
                ).paddingSymmetric(horizontal: 32);
              },
              loadingWidget: popularServiceCont.isLoading.value
                  ? const Offstage()
                  : const LoaderWidget(),
              onSuccess: (p0) {
                if (popularServiceCont.serviceList.isEmpty &&
                    !popularServiceCont.isLoading.value) {
                  return NoDataWidget(
                    title: locale.value.noServicesFoundAtAMoment,
                    subTitle:
                        '${locale.value.looksLikeThereIsNoServicesForThis}, ${locale.value.wellKeepYouPostedWhenTheresAnUpdate}',
                    titleTextStyle: primaryTextStyle(),
                    imageWidget: const EmptyStateWidget(),
                    retryText: locale.value.reload,
                    onRetry: () {
                      popularServiceCont.page(1);
                      popularServiceCont.getServiceList();
                    },
                  ).paddingSymmetric(horizontal: 32);
                }

                return AnimatedScrollView(
                  padding: const EdgeInsets.all(16),
                  physics: const AlwaysScrollableScrollPhysics(),
                  listAnimationType: ListAnimationType.FadeIn,
                  onSwipeRefresh: () async {
                    popularServiceCont.isPopular(1);
                    popularServiceCont.page(1);
                    return await popularServiceCont.getServiceList(
                        showLoader: false);
                  },
                  onNextPage: () async {
                    if (!popularServiceCont.isLastPage.value) {
                      popularServiceCont
                          .page(popularServiceCont.page.value + 1);

                      popularServiceCont.getServiceList(showLoader: false);
                    }
                  },
                  children: [
                    AnimatedWrap(
                      runSpacing: 16,
                      spacing: 16,
                      itemCount: popularServiceCont.serviceList.length,
                      listAnimationType: ListAnimationType.FadeIn,
                      itemBuilder: (ctx, index) {
                        ServiceElement serviceElement =
                            popularServiceCont.serviceList[index];
                        return PopularServiceCard(
                            serviceElement: serviceElement,
                            isFromClinicDetail: isFromClinicDetail);
                      },
                    ),
                  ],
                );
              },
            ).expand(),
          ],
        ),
      ),
    );
  }
}
