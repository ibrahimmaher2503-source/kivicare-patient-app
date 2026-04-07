import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:kivicare_patient/components/loader_widget.dart';
import 'package:kivicare_patient/utils/colors.dart';

import '../../components/app_scaffold.dart';
import '../../main.dart';
import '../../utils/empty_error_state_widget.dart';

import 'components/choose_category_components.dart';
import 'components/greetings_component.dart';
import 'components/doctor_quick_book_component.dart';
import 'components/quick_services_component.dart';
import 'components/perfect_clinic_list.dart';
import '../service/components/popular_service_component.dart';
import 'components/slider_component.dart';
import '../doctor/components/popular_doctor_component.dart';
import 'components/upcoming_appointment_components.dart';
import 'home_controller.dart';
import 'model/dashboard_res_model.dart';
import 'components/doctor_quick_book_controller.dart';

class HomeScreen extends StatelessWidget {
  HomeScreen({super.key});

  final HomeController homeScreenController = Get.find();

  /// Staggered fade-in + slide-up for each home section
  Widget _staggeredSection({required Widget child, required int index}) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 480 + (index * 90)),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - value)),
          child: Opacity(opacity: value, child: child),
        );
      },
      child: child,
    );
  }

  /// Thin gradient divider between sections
  Widget _sectionDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        height: 1,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              appColorPrimary.withValues(alpha: 0.0),
              appColorPrimary.withValues(alpha: 0.07),
              appColorSecondary.withValues(alpha: 0.07),
              appColorPrimary.withValues(alpha: 0.0),
            ],
            stops: const [0.0, 0.3, 0.7, 1.0],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffoldNew(
      hasLeadingWidget: false,
      isBlurBackgroundinLoader: true,
      isLoading: homeScreenController.isLoading,
      appBarVerticalSize: Get.height * 0.21,
      appBarChild: const GreetingsComponent(),
      body: RefreshIndicator(
        onRefresh: () async {
          if (Get.isRegistered<DoctorQuickBookController>()) {
            Get.find<DoctorQuickBookController>().reset();
          }
          return await homeScreenController.getDashboardDetail(isFromSwipeRefresh: true);
        },
        child: Obx(
          () => SnapHelperWidget(
            future: homeScreenController.getDashboardDetailFuture.value,
            initialData: homeScreenController.dashboardData.value.categories.isEmpty ? null : DashboardRes(data: homeScreenController.dashboardData.value),
            errorBuilder: (error) {
              return NoDataWidget(
                title: error,
                retryText: locale.value.reload,
                imageWidget: const ErrorStateWidget(),
                onRetry: () {
                  homeScreenController.init();
                },
              ).paddingSymmetric(horizontal: 16);
            },
            loadingWidget: homeScreenController.isLoading.value ? const Offstage() : const LoaderWidget(),
            onSuccess: (dashboardData) {
              return SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 90),
                physics: const AlwaysScrollableScrollPhysics(),
                scrollDirection: Axis.vertical,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _staggeredSection(index: 0, child: ChooseCategoryComponents()),
                    const SizedBox(height: 8),
                    _staggeredSection(index: 1, child: SliderComponent()),
                    const SizedBox(height: 28),
                    _sectionDivider(),
                    const SizedBox(height: 20),
                    _staggeredSection(index: 2, child: DoctorQuickBookComponent()),
                    const SizedBox(height: 28),
                    _sectionDivider(),
                    const SizedBox(height: 20),
                    _staggeredSection(index: 3, child: const QuickServicesComponent()),
                    const SizedBox(height: 28),
                    _sectionDivider(),
                    const SizedBox(height: 20),
                    _staggeredSection(index: 4, child: UpcomingAppointmentComponents()),
                    const SizedBox(height: 28),
                    _sectionDivider(),
                    const SizedBox(height: 20),
                    _staggeredSection(index: 5, child: PopularDoctorComponent()),
                    const SizedBox(height: 28),
                    _sectionDivider(),
                    const SizedBox(height: 20),
                    _staggeredSection(index: 6, child: PopularServiceComponent()),
                    const SizedBox(height: 28),
                    _sectionDivider(),
                    const SizedBox(height: 20),
                    _staggeredSection(index: 7, child: PerfectClinicComponent()),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
