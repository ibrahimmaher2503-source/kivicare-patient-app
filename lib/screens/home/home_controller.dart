import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../api/home_apis.dart';
import '../../utils/app_common.dart';
import 'model/dashboard_res_model.dart';

class HomeController extends GetxController {
  RxBool isLoading = false.obs;
  RxBool isRefresh = false.obs;
  TextEditingController searchCont = TextEditingController();
  Rx<Future<DashboardRes>> getDashboardDetailFuture =
      Future(() => DashboardRes(data: DashboardData())).obs;
  Rx<DashboardData> dashboardData = DashboardData().obs;
  PageController pageController = PageController();
  RxInt currentPage = 0.obs;

  ///Slider
  PageController sliderPageController =
      PageController(keepPage: true, initialPage: 0);
  RxInt sliderCurrentPage = 0.obs;

  @override
  void onReady() {
    init();
    super.onReady();
  }

  void init() {
    getDashboardDetail();
  }

  ///Get ChooseService List
  Future<void> getDashboardDetail({bool isFromSwipeRefresh = false}) async {
    if (!isFromSwipeRefresh) {
      isLoading(true);
    }
    await getDashboardDetailFuture(
      HomeServiceApis.getDashboard(),
    ).then((value) {
      handleDashboardRes(value);
    }).whenComplete(() => isLoading(false));
  }

  void handleDashboardRes(DashboardRes value) {
    dashboardData(value.data);
    unreadNotificationCount(value.data.unReadCount);
    //More Logic....
  }

  @override
  void onClose() {
    searchCont.dispose();
    pageController.dispose();
    sliderPageController.dispose();
    super.onClose();
  }
}
