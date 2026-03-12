import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../components/app_dialogue_component.dart';
import '../../components/app_scaffold.dart';
import '../../components/loader_widget.dart';
import '../../generated/assets.dart';
import '../../main.dart';
import '../../utils/app_common.dart';
import '../../utils/colors.dart';
import '../../utils/common_base.dart';
import '../../utils/empty_error_state_widget.dart';
import '../auth/model/login_response.dart';
import 'add_other_patient_screen.dart';
import 'component/member_component.dart';
import 'manage_other_patient_controller.dart';

class ManageOtherPatientScreen extends StatelessWidget {
  ManageOtherPatientScreen({super.key});

  final ManageOtherPatientController managePatientController = Get.put(ManageOtherPatientController());

  @override
  Widget build(BuildContext context) {
    return AppScaffoldNew(
      appBartitleText: locale.value.managePatient,
      isLoading: managePatientController.isLoading,
      appBarVerticalSize: Get.height * 0.12,
      actions: [
        GestureDetector(
          onTap: () {
            Get.to(() => AddOtherPatientScreen(titleText: locale.value.addPatient, memberData: UserData()))?.then((value) {
              if (value == true) managePatientController.onRefresh();
            });
          },
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: commonLeadingWid(
              imgPath: Assets.iconsIcPlusCircle,
              color: whiteTextColor,
              size: 22,
            ),
          ).paddingAll(12),
        ),
      ],
      body: Column(
        children: [
          Obx(() {
            return SnapHelperWidget(
              future: managePatientController.otherPatientListFuture.value,
              loadingWidget: managePatientController.isLoading.value ? const Offstage() : const LoaderWidget(),
              errorBuilder: (error) {
                return NoDataWidget(
                  title: error,
                  retryText: locale.value.reload,
                  imageWidget: const ErrorStateWidget(),
                  onRetry: () async {
                    await managePatientController.onRefresh();
                  },
                ).paddingSymmetric(horizontal: 32);
              },
              onSuccess: (data) {
                return AnimatedListView(
                  shrinkWrap: true,
                  padding: const EdgeInsets.only(top: 16, left: 16, right: 16),
                  physics: const AlwaysScrollableScrollPhysics(),
                  listAnimationType: ListAnimationType.FadeIn,
                  onSwipeRefresh: managePatientController.onRefresh,
                  onNextPage: managePatientController.onNextPage,
                  emptyWidget: NoDataWidget(
                    title: locale.value.noPatientsFound,
                    titleTextStyle: GoogleFonts.outfit(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      letterSpacing: -0.3,
                      color: isDarkMode.value ? Colors.white : appColorPrimary,
                    ),
                    imageWidget: const EmptyStateWidget(),
                    retryText: locale.value.reload,
                    onRetry: () async {
                      await managePatientController.onRefresh();
                    },
                  ).paddingSymmetric(horizontal: 32).visible(!managePatientController.isLoading.value),
                  itemCount: managePatientController.otherPatientList.length,
                  itemBuilder: (context, index) {
                    UserData member = managePatientController.otherPatientList[index];

                    return MemberComponent(
                      memberData: member,
                      onEdit: () {
                        Get.to(
                          () => AddOtherPatientScreen(titleText: locale.value.editPatient, memberData: member),
                          arguments: member,
                        )?.then((value) {
                          if (value == true) managePatientController.onRefresh();
                        });
                      },
                      onDelete: () {
                        Get.bottomSheet(
                          enableDrag: true,
                          isScrollControlled: true,
                          AppDialogueComponent(
                            confirmText: locale.value.delete,
                            confirmationImage: Assets.iconsIcTrashBottom,
                            borderRadius: radiusOnly(topLeft: 20, topRight: 20),
                            onConfirm: () {
                              managePatientController.handleDeleteMember(member.id);
                            },
                            titleText: locale.value.deleteConfirmation,
                            subTitleText: locale.value.doYouWantToDeleteYourOtherPatientsProfile,
                          ),
                        );
                      },
                    ).paddingBottom(16);
                  },
                );
              },
            ).expand();
          }),
        ],
      ),
    );
  }
}
