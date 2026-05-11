// ignore_for_file: depend_on_referenced_packages
import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:stream_transform/stream_transform.dart';

import '../../api/core_apis.dart';
import '../booking/model/employee_review_data.dart';
import '../service/model/service_list_model.dart';
import 'model/doctor_detail_model.dart';
import 'model/doctor_list_res.dart';

class DoctorDetailController extends GetxController {
  RxBool isLoading = false.obs;

  Rx<Future<DoctorDetailModel>> getDoctorDetail =
      Future(() => DoctorDetailModel(data: Doctor())).obs;
  Rx<Doctor> doctorData = Doctor().obs;

  //Services
  Rx<Future<RxList<ServiceElement>>> serviceListFuture =
      Future(() => RxList<ServiceElement>()).obs;
  RxBool isServicesLoading = false.obs;
  RxList<ServiceElement> serviceList = RxList();
  RxBool isServicesLastPage = false.obs;
  RxInt servicesPage = 1.obs;

  //Reviews (inline)
  RxList<DoctorReviewData> inlineReviewList = RxList();
  RxBool isReviewsLastPage = false.obs;
  RxBool isReviewsLoading = false.obs;
  RxInt reviewsPage = 1.obs;

  ///Search
  TextEditingController searchCont = TextEditingController();
  RxBool isSearchText = false.obs;
  StreamController<String> searchStream = StreamController<String>();
  final _scrollController = ScrollController();

  @override
  void onInit() {
    _scrollController.addListener(
        () => Get.context != null ? hideKeyboard(Get.context) : null);
    searchStream.stream.debounce(const Duration(seconds: 1)).listen((s) {
      getServiceList();
    });
    if (Get.arguments is Doctor) {
      doctorData(Get.arguments);
    }
    init(showLoader: false);
    super.onInit();
  }

  ///Get Doctor Detail
  Future<void> init({bool showLoader = true}) async {
    if (showLoader) {
      isLoading(true);
    }
    final doctorId = doctorData.value.doctorId.isNegative
        ? doctorData.value.id
        : doctorData.value.doctorId;

    if (doctorId.isNegative) {
      isLoading(false);
      log('DoctorDetail skipped: invalid doctor id. id=${doctorData.value.id}, doctorId=${doctorData.value.doctorId}');
      return;
    }

    await getDoctorDetail(
      CoreServiceApis.getDoctorDetails(doctorId: doctorId),
    ).then((value) {
      doctorData(value.data);
      _initServiceList();
      _initInlineReviews();
      isLoading(false);
    }).catchError((e) {
      isLoading(false);
      log('DoctorDetail getDoctorDetail err ==> $e');
    }).whenComplete(() => isLoading(false));
  }

  void _initServiceList() {
    serviceList.assignAll(doctorData.value.services);
    servicesPage(1);
    isServicesLastPage(
      doctorData.value.totalServices == 0 ||
          doctorData.value.services.length >= doctorData.value.totalServices,
    );
  }

  void _initInlineReviews() {
    inlineReviewList.assignAll(doctorData.value.reviews);
    reviewsPage(1);
    isReviewsLastPage(
      doctorData.value.totalReviews == 0 ||
          doctorData.value.reviews.length >= doctorData.value.totalReviews,
    );
  }

  Future<void> loadMoreReviews() async {
    if (isReviewsLoading.value || isReviewsLastPage.value) return;
    isReviewsLoading(true);
    final nextPage = reviewsPage.value + 1;
    final docId = doctorData.value.doctorId.isNegative
        ? doctorData.value.id
        : doctorData.value.doctorId;
    await CoreServiceApis.getDoctorReviews(
      page: nextPage,
      reviewList: inlineReviewList,
      doctorId: docId,
      lastPageCallBack: (isLast) => isReviewsLastPage(isLast),
    ).then((_) {
      reviewsPage(nextPage);
    }).catchError((e) {
      log('loadMoreReviews err ==> $e');
    }).whenComplete(() => isReviewsLoading(false));
  }

  Future<void> getServiceList({bool showLoader = true}) async {
    if (showLoader) {
      isServicesLoading(true);
    }
    await serviceListFuture(
      CoreServiceApis.getDoctorServiceList(
        page: servicesPage.value,
        serviceList: serviceList,
        doctorId: doctorData.value.doctorId,
        search: searchCont.text.trim(),
        lastPageCallBack: (p0) {
          isServicesLastPage(p0);
        },
      ),
    ).then((value) {
      log('value.length ==> ${value.length}');
    }).catchError((e) {
      isServicesLoading(false);
      log('doctor detail getServiceList err ==> $e');
    }).whenComplete(() => isServicesLoading(false));
  }

  @override
  void onClose() {
    searchStream.close();
    if (Get.context != null) {
      _scrollController.removeListener(() => hideKeyboard(Get.context));
    }
    super.onClose();
  }
}
