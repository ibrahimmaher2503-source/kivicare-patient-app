import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:kivicare_patient/screens/clinic/search_clinic_widget.dart';
import 'package:kivicare_patient/utils/colors.dart';

import '../../components/app_scaffold.dart';
import '../../components/loader_widget.dart';
import '../../main.dart';
import '../../utils/empty_error_state_widget.dart';
import '../../utils/view_all_label_component.dart';
import '../doctor/doctor_list_screen.dart';
import 'clinic_list_controller.dart';
import 'components/clinic_card.dart';
import 'model/clinics_res_model.dart';

class ClinicListScreen extends StatelessWidget {
  ClinicListScreen({super.key});

  final ClinicListController clinicListCont = Get.put(ClinicListController());

  @override
  Widget build(BuildContext context) {
    return AppScaffoldNew(
      appBartitleText: locale.value.clinics,
      scaffoldBackgroundColor: context.scaffoldBackgroundColor,
      appBarVerticalSize: Get.height * 0.12,
      isLoading: clinicListCont.isLoading,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SearchClinicWidget(
            clinicListController: clinicListCont,
            onFieldSubmitted: (p0) {
              hideKeyboard(context);
            },
          ).paddingOnly(left: 16, right: 16, top: 16, bottom: 8),
          ViewAllLabel(
            label: "${locale.value.availableClinicsFor} ${clinicListCont.service.value.name}",
            isShowAll: false,
            maxLines: 1,
            expandedText: true,
            textOverflow: TextOverflow.ellipsis,
          ).paddingSymmetric(horizontal: 16),
          8.height,
          Obx(
            () => SnapHelperWidget(
              future: clinicListCont.clinicsFuture.value,
              errorBuilder: (error) {
                return NoDataWidget(
                  title: error,
                  retryText: locale.value.reload,
                  imageWidget: const ErrorStateWidget(),
                  onRetry: () {
                    clinicListCont.page(1);
                    clinicListCont.getClinicList();
                  },
                ).paddingSymmetric(horizontal: 32);
              },
              loadingWidget: clinicListCont.isLoading.value ? const Offstage() : const LoaderWidget(),
              onSuccess: (p0) {
                return AnimatedListView(
                  shrinkWrap: true,
                  padding: const EdgeInsets.only(left: 16, right: 16, top: 8, bottom: 80),
                  itemCount: clinicListCont.clinics.length,
                  physics: const AlwaysScrollableScrollPhysics(),
                  emptyWidget: SingleChildScrollView(
                    child: NoDataWidget(
                      title: locale.value.noClinicsFoundAtAMoment,
                      subTitle: locale.value.looksLikeThereIsNoClinicForThisServiceWellKee,
                      titleTextStyle: primaryTextStyle(),
                      imageWidget: const EmptyStateWidget(),
                      retryText: locale.value.reload,
                      onRetry: () {
                        clinicListCont.page(1);
                        clinicListCont.getClinicList();
                      },
                    ).paddingSymmetric(horizontal: 16),
                  ).center(),
                  itemBuilder: (context, index) {
                    Clinic clinic = clinicListCont.clinics[index];
                    return ClinicCard(clinicData: clinic).paddingBottom(12);
                  },
                  onNextPage: () async {
                    if (!clinicListCont.isLastPage.value) {
                      clinicListCont.page(clinicListCont.page.value + 1);
                      clinicListCont.getClinicList();
                    }
                  },
                  onSwipeRefresh: () async {
                    clinicListCont.page(1);
                    return await clinicListCont.getClinicList(showLoader: false);
                  },
                );
              },
            ),
          ).expand(),
        ],
      ),
      fabWidget: Obx(
        () => Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [gradientSecondaryStart, gradientSecondaryEnd],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: appColorSecondary.withValues(alpha: 0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: FloatingActionButton(
            backgroundColor: Colors.transparent,
            elevation: 0,
            onPressed: () {
              if (!clinicListCont.selectedClinic.value.id.isNegative) {
                Get.to(() => DoctorsListScreen(), arguments: clinicListCont.selectedClinic.value.id);
              }
            },
            child: const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 20),
          ),
        ).visible(clinicListCont.clinics.isNotEmpty && (!clinicListCont.selectedClinic.value.id.isNegative)),
      ),
    );
  }
}
