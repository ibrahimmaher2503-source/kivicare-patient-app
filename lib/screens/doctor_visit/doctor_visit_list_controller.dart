import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../api/doctor_visit_apis.dart';
import '../../main.dart';
import '../../screens/auth/sign_in_sign_up/signin_screen.dart';
import '../../utils/app_common.dart';
import '../../network/network_utils.dart';
import 'models/visit_request_model.dart';
import 'models/visit_status.dart';

class DoctorVisitListController extends GetxController {
  final RxList<VisitRequestModel> requests = <VisitRequestModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isLoadingMore = false.obs;
  final RxInt currentPage = 1.obs;
  final RxBool hasMore = true.obs;
  final RxString error = ''.obs;
  final Rx<VisitStatus?> statusFilter = Rx<VisitStatus?>(null);

  late ScrollController scrollController;

  @override
  void onInit() {
    super.onInit();
    scrollController = ScrollController()..addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (isLoggedIn.value) {
        fetchRequests();
      } else {
        final loggedIn = await Get.to(() => SignInScreen()) ?? false;
        if (loggedIn) {
          fetchRequests();
        } else {
          Get.back();
        }
      }
    });
  }

  void _onScroll() {
    if (scrollController.position.pixels >=
            scrollController.position.maxScrollExtent - 200 &&
        !isLoadingMore.value &&
        hasMore.value) {
      loadMore();
    }
  }

  Future<void> fetchRequests() async {
    isLoading(true);
    error('');
    try {
      final res = await DoctorVisitApis.getRequests(
        page: 1,
        status: statusFilter.value,
      );
      requests.assignAll(res.data);
      currentPage.value = 1;
      hasMore.value = res.hasMore;
    } catch (e) {
      final message =
          sanitizeBackendMessage(e, locale.value.somethingWentWrong);
      error(message);
      toast(message);
    } finally {
      isLoading(false);
    }
  }

  Future<void> loadMore() async {
    if (isLoadingMore.value || !hasMore.value) return;
    isLoadingMore(true);
    try {
      final nextPage = currentPage.value + 1;
      final res = await DoctorVisitApis.getRequests(
        page: nextPage,
        status: statusFilter.value,
      );
      requests.addAll(res.data);
      currentPage.value = nextPage;
      hasMore.value = res.hasMore;
    } catch (e) {
      toast(sanitizeBackendMessage(e, locale.value.somethingWentWrong));
    } finally {
      isLoadingMore(false);
    }
  }

  @override
  Future<void> refresh() => fetchRequests();

  void setFilter(VisitStatus? status) {
    statusFilter.value = status;
    fetchRequests();
  }

  @override
  void onClose() {
    scrollController.dispose();
    super.onClose();
  }
}
