// ignore_for_file: depend_on_referenced_packages

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kivicare_patient/main.dart';
import 'package:kivicare_patient/screens/auth/other/welcome_screen.dart';
import '../../generated/assets.dart';
import 'model/walkthrough_model.dart';
import '../../utils/constants.dart';
import '../../utils/local_storage.dart';

class WalkthroughController extends GetxController {
  PageController pageController = PageController();

  RxInt currentPage = 0.obs;
  double skipBtnSize = 54;

  List<WalkThroughElementModel> walkthroughDetails = [
    WalkThroughElementModel(
        image: Assets.walkthroughImagesWalkImage1,
        title: locale.value.personalizedHealthPlansForYourJourney,
        subTitle: locale.value.customizeHealthPlansForATailoredApproachAlign),
    WalkThroughElementModel(
        image: Assets.walkthroughImagesWalkImage2,
        title: locale.value.stayOnTrackAndSetPersonalGoals,
        subTitle: locale.value.focusOnYourPathSetClearGoalsAndStrideForwardW),
    WalkThroughElementModel(
        image: Assets.walkthroughImagesWalkImage3,
        title: locale.value.discoverAndGetSupportWithin24Hours,
        subTitle: locale.value.exploreFindSolutionsAndReceiveAssistanceSwift),
  ];

  void handleNext() {
    if (currentPage.value == (walkthroughDetails.length - 1)) {
      setValueToLocal(SharedPreferenceConst.FIRST_TIME, true);
      Get.offAll(() => WelcomeScreen());
      return;
    }
    pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutQuart,
    );
  }

  void handleSkip() {
    setValueToLocal(SharedPreferenceConst.FIRST_TIME, true);
    Get.offAll(() => WelcomeScreen());
  }

  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }
}
