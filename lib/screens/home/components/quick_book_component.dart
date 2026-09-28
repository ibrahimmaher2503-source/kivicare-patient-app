import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kivicare_patient/components/cached_image_widget.dart';
import 'package:kivicare_patient/screens/home/components/clinic_list_widget.dart';
import 'package:kivicare_patient/screens/home/components/quick_book_controller.dart';
import 'package:kivicare_patient/utils/common_base.dart';
import 'package:kivicare_patient/utils/view_all_label_component.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:get/get.dart';

import '../../../components/bottom_selection_widget.dart';
import '../../../components/loader_widget.dart';
import '../../../main.dart';
import '../../../utils/colors.dart';
import '../../../utils/empty_error_state_widget.dart';
import '../../../../utils/app_common.dart';
import '../home_controller.dart';

class QuickBookComponent extends StatelessWidget {
  QuickBookComponent({super.key});

  final QuickBookController quickBookController =
      Get.put(QuickBookController());
  final HomeController homeScreenController = Get.find();

  @override
  Widget build(BuildContext context) {
    return Obx(() => Container(
          child: Column(
            children: [
              16.height,
              ViewAllLabel(
                label: locale.value.quicklyBookYourAppointmentNow,
                isShowAll: false,
              ),
              8.height,
              _QuickBookProgress(currentStep: quickBookController.currentStep),
              8.height,
              _QuickBookHint(message: quickBookController.onboardingHint.value),
              12.height,
              _AccessibleFieldAction(
                semanticLabel: locale.value.selectService,
                semanticHint: locale.value.chooseService,
                onActivate: () {
                  quickBookController.currentPage.value = 1;
                  quickBookController.serviceList.clear();
                  quickBookController.getServiceList();
                  serviceCommonBottomSheet(
                    context,
                    child: Obx(
                      () => BottomSelectionSheet(
                        title: locale.value.chooseService,
                        hintText: locale.value.searchForService,
                        hasError:
                            quickBookController.hasErrorFetchingServices.value,
                        isEmpty: quickBookController.serviceList.isEmpty,
                        isLoading: quickBookController.isLoading,
                        currentPage: quickBookController.currentPage,
                        searchApiCall: (p0) {
                          log("Search Spec ==> $p0");
                          quickBookController.searchService(p0);
                          quickBookController.getServiceList();
                        },
                        onRetry: () {
                          quickBookController.currentPage.value = 1;
                          quickBookController.serviceList.clear();
                          quickBookController.getServiceList();
                        },
                        listWidget: AnimatedListView(
                          shrinkWrap: true,
                          itemCount: quickBookController.serviceList.length,
                          padding: EdgeInsets.zero,
                          physics: const AlwaysScrollableScrollPhysics(),
                          listAnimationType: ListAnimationType.Slide,
                          itemBuilder: (ctx, index) {
                            return Semantics(
                              button: true,
                              label:
                                  quickBookController.serviceList[index].name,
                              hint: locale.value.selectService,
                              child: GestureDetector(
                                onTap: () {
                                  hideKeyboard(context);
                                  quickBookController.onServiceSelected(
                                      quickBookController.serviceList[index]);
                                  Get.back();
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  margin: const EdgeInsets.only(bottom: 12),
                                  decoration: boxDecorationDefault(
                                    borderRadius: BorderRadius.circular(6),
                                    color: isDarkMode.value
                                        ? appScreenBackgroundDark
                                        : appScreenBackground,
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      CachedImageWidget(
                                        url: quickBookController
                                            .serviceList[index].serviceImage,
                                        width: 60,
                                        radius: 6,
                                        fit: BoxFit.cover,
                                        height: 60,
                                      ),
                                      12.width,
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                              quickBookController
                                                  .serviceList[index].name
                                                  .toString(),
                                              style: boldTextStyle(
                                                  size: 16,
                                                  color: isDarkMode.value
                                                      ? null
                                                      : darkGrayTextColor)),
                                          2.height,
                                          Text(
                                              quickBookController
                                                  .serviceList[index]
                                                  .description
                                                  .toString(),
                                              style: primaryTextStyle(
                                                  size: 12,
                                                  color: dividerColor)),
                                        ],
                                      ).expand()
                                    ],
                                  ),
                                ),
                              ).visible(!quickBookController.isLoading.value),
                            );
                          },
                          onNextPage: () async {
                            if (!quickBookController.hasMoreData.value) {
                              quickBookController.currentPage += 1;
                              quickBookController.getServiceList();
                            }
                          },
                          onSwipeRefresh: () async {
                            quickBookController.currentPage.value = 1;
                          },
                        ).expand(),
                      ),
                    ),
                  );
                },
                child: SizedBox(
                  height: 40,
                  child: AppTextField(
                    readOnly: true,
                    onTap: () {},
                    controller: quickBookController.serviceCont,
                    textFieldType: TextFieldType.NAME,
                    textStyle:
                        primaryTextStyle(decorationColor: appColorPrimary),
                    decoration: inputDecorationWithOutBorder(
                      context,
                      hintText: locale.value.selectService,
                      filled: true,
                      fillColor: context.cardColor,
                    ),
                    suffix: Icon(Icons.arrow_drop_down_outlined,
                        color: Colors.grey),
                  ),
                ),
              ),
              16.height,
              _AccessibleFieldAction(
                semanticLabel: locale.value.selectClinic,
                semanticHint: quickBookController.canPickClinic
                    ? locale.value.chooseClinic
                    : locale.value.selectService,
                onActivate: () {
                  if (!quickBookController.canPickClinic) {
                    quickBookController.updateHint();
                    return;
                  }
                  quickBookController.getClinicList();
                  serviceCommonBottomSheet(
                    context,
                    child: Obx(
                      () => BottomSelectionSheet(
                        title: locale.value.chooseClinic,
                        hintText: locale.value.searchForClinic,
                        hasError:
                            quickBookController.hasErrorFetchingClinic.value,
                        isEmpty: !quickBookController.isLoading.value &&
                            quickBookController.clinicList.isEmpty,
                        isLoading: quickBookController.isLoading,
                        searchApiCall: (p0) {
                          quickBookController.searchClinic(p0);
                          quickBookController.getClinicList();
                        },
                        onRetry: () {
                          quickBookController.getClinicList();
                        },
                        listWidget: ClinicListWidget(
                                clinicList: quickBookController.clinicList)
                            .expand(),
                      ),
                    ),
                  );
                },
                child: SizedBox(
                  height: 40,
                  child: AppTextField(
                    readOnly: true,
                    onTap: () {},
                    controller: quickBookController.clinicCont,
                    textFieldType: TextFieldType.NAME,
                    textStyle:
                        primaryTextStyle(decorationColor: appColorPrimary),
                    decoration: inputDecorationWithOutBorder(
                      context,
                      hintText: locale.value.selectClinic,
                      filled: true,
                      fillColor: quickBookController.canPickClinic
                          ? context.cardColor
                          : (isDarkMode.value
                              ? appScreenBackgroundDark.withValues(alpha: 0.35)
                              : gray100),
                    ),
                    suffix: Icon(
                      Icons.arrow_drop_down_outlined,
                      color: quickBookController.canPickClinic
                          ? Colors.grey
                          : gray400,
                    ),
                  ),
                ),
              ),
              16.height,
              _AccessibleFieldAction(
                semanticLabel: locale.value.chooseDate,
                semanticHint: quickBookController.canPickDate
                    ? locale.value.chooseDate
                    : locale.value.selectClinic,
                onActivate: () async {
                  if (!quickBookController.canPickDate) {
                    quickBookController.updateHint();
                    return;
                  }
                  DateTime? selectedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime(2101),
                  );
                  if (selectedDate != null) {
                    quickBookController.onDateSelected(selectedDate);
                    quickBookController.getTimeSlot(showLoader: true);
                  }
                },
                child: SizedBox(
                  height: 40,
                  child: AppTextField(
                    readOnly: true,
                    onTap: () {},
                    controller: quickBookController.dateCont,
                    textStyle:
                        primaryTextStyle(decorationColor: appColorPrimary),
                    decoration: inputDecorationWithOutBorder(
                      context,
                      hintText: locale.value.chooseDate,
                      filled: true,
                      fillColor: quickBookController.canPickDate
                          ? context.cardColor
                          : (isDarkMode.value
                              ? appScreenBackgroundDark.withValues(alpha: 0.35)
                              : gray100),
                    ),
                    textFieldType: TextFieldType.NAME,
                    suffix: Icon(
                      Icons.date_range_rounded,
                      color: quickBookController.canPickDate
                          ? Colors.grey
                          : gray400,
                    ),
                  ),
                ),
              ),
              16.height,
              _AccessibleFieldAction(
                semanticLabel: locale.value.chooseTime,
                semanticHint: quickBookController.canPickTime
                    ? locale.value.chooseTime
                    : locale.value.chooseDate,
                onActivate: () {
                  if (!quickBookController.canPickTime) {
                    quickBookController.updateHint();
                    return;
                  }
                  quickBookController.getTimeSlot(showLoader: true);
                },
                child: SizedBox(
                  height: 40,
                  child: AppTextField(
                    onTap: () {},
                    readOnly: true,
                    controller: quickBookController.timeCont,
                    textStyle:
                        primaryTextStyle(decorationColor: appColorPrimary),
                    decoration: inputDecorationWithOutBorder(
                      context,
                      hintText: locale.value.chooseTime,
                      filled: true,
                      fillColor: quickBookController.canPickTime
                          ? context.cardColor
                          : (isDarkMode.value
                              ? appScreenBackgroundDark.withValues(alpha: 0.35)
                              : gray100),
                    ),
                    textFieldType: TextFieldType.NAME,
                    suffix: Icon(
                      Icons.arrow_drop_down_outlined,
                      color: quickBookController.canPickTime
                          ? Colors.grey
                          : gray400,
                    ),
                  ),
                ),
              ),

              Obx(
                () {
                  return SnapHelperWidget(
                    future: quickBookController.slotsFuture.value,
                    errorBuilder: (error) {
                      return NoDataWidget(
                        title: locale.value.somethingWentWrong,
                        retryText: locale.value.reload,
                        imageWidget: const ErrorStateWidget(),
                        onRetry: () {
                          quickBookController.getTimeSlot(showLoader: true);
                        },
                      ).paddingSymmetric(horizontal: 32);
                    },
                    loadingWidget: quickBookController.isLoading.value
                        ? const Offstage()
                        : const LoaderWidget(),
                    onSuccess: (p0) {
                      if (quickBookController.slots.isEmpty &&
                          quickBookController.isLoading.value == false) {
                        return NoDataWidget(
                                title: locale.value.noTimeSlotsAvailable)
                            .paddingBottom(12)
                            .visible(
                                quickBookController.dateCont.text.isNotEmpty &&
                                    quickBookController
                                        .serviceCont.text.isNotEmpty);
                      }

                      return Obx(
                        () => Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            16.height,
                            ViewAllLabel(
                                    label: locale.value.chooseTime,
                                    isShowAll: false)
                                .paddingOnly(right: 8)
                                .visible(quickBookController.isLoading.value ==
                                    false),
                            LoaderWidget()
                                .visible(quickBookController.isLoading.value),
                            Container(
                              padding: const EdgeInsets.all(16),
                              width: Get.width,
                              alignment: Alignment.center,
                              decoration: boxDecorationDefault(
                                  color: context.cardColor),
                              child: AnimatedWrap(
                                spacing: 12,
                                runSpacing: 12,
                                alignment: WrapAlignment.start,
                                crossAxisAlignment: WrapCrossAlignment.start,
                                children: List.generate(
                                  quickBookController.slots.length,
                                  (i) {
                                    String slot = quickBookController.slots[i];
                                    return Obx(
                                      () => Semantics(
                                        button: true,
                                        selected: quickBookController
                                                .selectedSlot.value ==
                                            slot,
                                        label: slot,
                                        hint: locale.value.chooseTime,
                                        child: GestureDetector(
                                          onTap: () {
                                            quickBookController
                                                .onSlotSelected(slot);
                                          },
                                          child: Container(
                                            width: Get.width / 3 - 32,
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 12),
                                            decoration:
                                                boxDecorationWithRoundedCorners(
                                              backgroundColor: quickBookController
                                                          .selectedSlot.value ==
                                                      slot
                                                  ? appColorPrimary
                                                  : context
                                                      .scaffoldBackgroundColor,
                                              borderRadius:
                                                  BorderRadius.circular(
                                                      defaultRadius / 2),
                                            ),
                                            child: Text(
                                              slot,
                                              textAlign: TextAlign.center,
                                              style: primaryTextStyle(
                                                size: 12,
                                                color: (quickBookController
                                                            .selectedSlot
                                                            .value ==
                                                        slot)
                                                    ? Colors.white
                                                    : appColorPrimary,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ).visible(!quickBookController.isLoading.value),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),

              Obx(
                () => Column(
                  children: [
                    16.height,
                    Semantics(
                      button: true,
                      label: locale.value.bookNow,
                      hint: locale.value.confirmAppointment,
                      child: AppButton(
                        text: locale.value.bookNow,
                        color: appColorPrimary,
                        textStyle: boldTextStyle(color: Colors.white),
                        onTap: () {
                          doIfLoggedIn(() {
                            quickBookController.bookAppointment();
                          });
                        },
                        width: Get.width,
                        shapeBorder: RoundedRectangleBorder(
                            borderRadius: radius(defaultRadius)),
                      ),
                    )
                  ],
                ).visible(quickBookController.selectedSlot.value != ""),
              ),
              // 16.height,
            ],
          ).paddingAll(16),
        ).visible(homeScreenController.isLoading.value == false));
  }
}

class _QuickBookProgress extends StatelessWidget {
  final int currentStep;

  const _QuickBookProgress({required this.currentStep});

  @override
  Widget build(BuildContext context) {
    final labels = [
      locale.value.selectService,
      locale.value.selectClinic,
      locale.value.chooseDate,
      locale.value.chooseTime,
    ];

    return SizedBox(
      height: 34,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: labels.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final isActive = currentStep >= (index + 1);
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: isActive
                  ? (isDarkMode.value
                      ? appColorSecondary.withValues(alpha: 0.24)
                      : lightSecondaryColor)
                  : (isDarkMode.value
                      ? appScreenBackgroundDark.withValues(alpha: 0.45)
                      : gray100),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(
                color: isActive
                    ? appColorSecondary.withValues(alpha: 0.45)
                    : borderColor.withValues(alpha: 0.5),
              ),
            ),
            child: Text(
              '${index + 1}. ${labels[index]}',
              style: primaryTextStyle(
                size: 12,
                color: isActive ? appColorSecondary : secondaryTextColor,
                weight: isActive ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          );
        },
      ),
    );
  }
}

class _AccessibleFieldAction extends StatelessWidget {
  final Widget child;
  final String semanticLabel;
  final String semanticHint;
  final VoidCallback onActivate;

  const _AccessibleFieldAction({
    required this.child,
    required this.semanticLabel,
    required this.semanticHint,
    required this.onActivate,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: semanticLabel,
      hint: semanticHint,
      onTap: onActivate,
      child: Shortcuts(
        shortcuts: const <ShortcutActivator, Intent>{
          SingleActivator(LogicalKeyboardKey.enter): ActivateIntent(),
          SingleActivator(LogicalKeyboardKey.space): ActivateIntent(),
        },
        child: Actions(
          actions: <Type, Action<Intent>>{
            ActivateIntent: CallbackAction<ActivateIntent>(
              onInvoke: (intent) {
                onActivate();
                return null;
              },
            ),
          },
          child: Focus(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: onActivate,
              child: ExcludeSemantics(
                child: AbsorbPointer(
                  child: child,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _QuickBookHint extends StatelessWidget {
  final String message;

  const _QuickBookHint({required this.message});

  @override
  Widget build(BuildContext context) {
    if (message.isEmpty) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: isDarkMode.value
            ? appScreenBackgroundDark.withValues(alpha: 0.5)
            : lightSecondaryColor.withValues(alpha: 0.65),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: appColorSecondary.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline_rounded,
              size: 16, color: appColorSecondary),
          8.width,
          Expanded(
            child: Text(
              message,
              style: primaryTextStyle(
                  size: 12, color: appColorSecondary, weight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}

void serviceCommonBottomSheet(BuildContext context,
    {required Widget child, final Function(dynamic)? onSheetClose}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(30),
        topRight: Radius.circular(30),
      ),
    ),
    builder: (context) => child,
  ).then((value) {
    onSheetClose?.call(value);
  });
}
