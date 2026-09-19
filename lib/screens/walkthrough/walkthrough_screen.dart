import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:percent_indicator/percent_indicator.dart';
import '../../components/cached_image_widget.dart';
import '../../main.dart';
import 'walkthrough_controller.dart';
import '../../utils/colors.dart';
import '../../utils/push_notification_service.dart';

class WalkthroughScreen extends StatelessWidget {
  WalkthroughScreen({super.key});
  final WalkthroughController walkthroughController =
      Get.put(WalkthroughController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.scaffoldBackgroundColor,
      body: Stack(
        children: [
          PageView.builder(
            itemCount: walkthroughController.walkthroughDetails.length,
            controller: walkthroughController.pageController,
            onPageChanged: (int index) {
              walkthroughController.currentPage(index);
            },
            itemBuilder: (context, index) {
              return CachedImageWidget(
                url: walkthroughController.walkthroughDetails[index].image
                    .validate(),
                fit: BoxFit.cover,
                width: Get.width,
                height: Get.height,
              );
            },
          ),
          PositionedDirectional(
            top: 0,
            end: 8,
            child: SafeArea(
              child: TextButton(
                onPressed: walkthroughController.handleSkip,
                child: Text(
                  locale.value.skip,
                  style: boldTextStyle(color: white, size: 14),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            width: Get.width,
            child: Obx(
              () => Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    walkthroughController
                            .walkthroughDetails[
                                walkthroughController.currentPage.value]
                            .title ??
                        "",
                    textAlign: TextAlign.center,
                    style: boldTextStyle(size: 24, color: white),
                  ).paddingSymmetric(horizontal: 54),
                  16.height,
                  Text(
                    walkthroughController
                            .walkthroughDetails[
                                walkthroughController.currentPage.value]
                            .subTitle ??
                        "",
                    textAlign: TextAlign.center,
                    style: secondaryTextStyle(
                        size: 14, color: appScreenGreyBackground),
                  ).paddingSymmetric(horizontal: 54),
                  SizedBox(height: Get.height * 0.042),
                  Obx(
                    () => Column(
                      children: [
                        CircularPercentIndicator(
                          radius: (walkthroughController.skipBtnSize / 2) + 7,
                          lineWidth: 2.0,
                          percent: (walkthroughController.currentPage.value +
                                  1) /
                              walkthroughController.walkthroughDetails.length,
                          progressColor: appColorSecondary,
                          fillColor: transparentColor,
                          backgroundColor: transparentColor,
                          center: Semantics(
                            container: true,
                            button: true,
                            label: walkthroughController.currentPage.value ==
                                    walkthroughController
                                            .walkthroughDetails.length -
                                        1
                                ? locale.value.finish
                                : locale.value.next,
                            child: ExcludeSemantics(
                              child: Tooltip(
                                message:
                                    walkthroughController.currentPage.value ==
                                            walkthroughController
                                                    .walkthroughDetails.length -
                                                1
                                        ? locale.value.finish
                                        : locale.value.next,
                                child: Material(
                                  color: appColorSecondary,
                                  shape: const CircleBorder(),
                                  child: InkWell(
                                    customBorder: const CircleBorder(),
                                    onTap: walkthroughController.handleNext,
                                    child: SizedBox.square(
                                      dimension:
                                          walkthroughController.skipBtnSize,
                                      child: Center(
                                        child: Icon(
                                          Icons.double_arrow_sharp,
                                          color: white,
                                          size: (walkthroughController
                                                      .skipBtnSize /
                                                  2) +
                                              7,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: Get.height * 0.042),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List<Widget>.generate(
                            walkthroughController.walkthroughDetails.length,
                            (index) {
                              final isSelected =
                                  walkthroughController.currentPage.value ==
                                      index;
                              return Semantics(
                                container: true,
                                button: true,
                                selected: isSelected,
                                label: locale.value.pageOf(
                                  index + 1,
                                  walkthroughController
                                      .walkthroughDetails.length,
                                ),
                                child: ExcludeSemantics(
                                  child: InkWell(
                                    onTap: () {
                                      walkthroughController.pageController
                                          .animateToPage(
                                        index,
                                        duration:
                                            const Duration(milliseconds: 300),
                                        curve: Curves.easeOutQuart,
                                      );
                                    },
                                    borderRadius: BorderRadius.circular(20),
                                    child: Container(
                                      height: 8,
                                      width: isSelected ? 35 : 8,
                                      margin: const EdgeInsets.all(5),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(20),
                                        color: isSelected
                                            ? appColorPrimary
                                            : white,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        if (walkthroughController.currentPage.value ==
                            walkthroughController.walkthroughDetails.length -
                                1) ...[
                          12.height,
                          Text(
                            locale.value.notificationPermissionDescription,
                            textAlign: TextAlign.center,
                            style: secondaryTextStyle(
                              size: 12,
                              color: appScreenGreyBackground,
                            ),
                          ).paddingSymmetric(horizontal: 24),
                          TextButton.icon(
                            onPressed: () async {
                              final allowed = await PushNotificationService()
                                  .requestNotificationPermission();
                              if (!allowed) {
                                toast(
                                    locale.value.notificationPermissionDenied);
                              }
                            },
                            icon: const Icon(
                              Icons.notifications_active_outlined,
                              color: white,
                            ),
                            label: Text(
                              locale.value.enableNotifications,
                              style: boldTextStyle(color: white, size: 13),
                            ),
                          ),
                        ],
                      ],
                    ).paddingSymmetric(horizontal: 16),
                  ),
                  SizedBox(height: Get.height * 0.02),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
