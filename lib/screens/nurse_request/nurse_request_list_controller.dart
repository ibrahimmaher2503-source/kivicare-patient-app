import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kivicare_patient/api/nurse_request_apis.dart';
import 'package:kivicare_patient/main.dart';
import 'package:kivicare_patient/screens/auth/sign_in_sign_up/signin_screen.dart';
import 'package:kivicare_patient/utils/app_common.dart';
import 'package:kivicare_patient/network/network_utils.dart';
import 'package:nb_utils/nb_utils.dart';

import 'models/nurse_request_model.dart';
import 'models/nurse_status.dart';

// This controller is registered via Get.lazyPut(permanent: false) so the filter
// (selectedStatus) survives detail-back-to-list navigation within the same module
// session, but resets when the module is re-entered from the dashboard (clarification C4).
class NurseRequestListController extends GetxController {
  final RxList<NurseRequestModel> items = <NurseRequestModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isLoadingMore = false.obs;
  final RxnString error = RxnString();
  final RxInt currentPage = 1.obs;
  final RxBool hasMore = true.obs;
  final Rxn<NurseStatus> selectedStatus = Rxn<NurseStatus>();
  final ScrollController scrollController = ScrollController();

  @override
  void onInit() {
    super.onInit();
    scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (isLoggedIn.value) {
        fetchFirstPage();
      } else {
        final loggedIn = await Get.to(() => SignInScreen()) ?? false;
        if (loggedIn) {
          fetchFirstPage();
        } else {
          Get.back();
        }
      }
    });
  }

  @override
  void onClose() {
    scrollController.dispose();
    super.onClose();
  }

  void _onScroll() {
    if (scrollController.position.pixels >=
        scrollController.position.maxScrollExtent - 200) {
      if (hasMore.value && !isLoadingMore.value) {
        loadMore();
      }
    }
  }

  Future<void> fetchFirstPage() async {
    isLoading(true);
    error.value = null;
    currentPage.value = 1;
    try {
      final res = await NurseRequestApis.list(
        page: 1,
        perPage: 15,
        status: selectedStatus.value?.apiValue,
      );
      items.assignAll(res.data);
      hasMore.value = res.hasMore;
      currentPage.value = res.currentPage;
    } catch (e) {
      final message =
          sanitizeBackendMessage(e, locale.value.somethingWentWrong);
      if (items.isEmpty) {
        error.value = message;
      } else {
        toast(message);
      }
    } finally {
      isLoading(false);
    }
  }

  Future<void> loadMore() async {
    if (!hasMore.value || isLoadingMore.value) return;
    isLoadingMore(true);
    try {
      final nextPage = currentPage.value + 1;
      final res = await NurseRequestApis.list(
        page: nextPage,
        perPage: 15,
        status: selectedStatus.value?.apiValue,
      );
      items.addAll(res.data);
      hasMore.value = res.hasMore;
      currentPage.value = res.currentPage;
    } catch (e) {
      toast(sanitizeBackendMessage(e, locale.value.somethingWentWrong));
    } finally {
      isLoadingMore(false);
    }
  }

  @override
  Future<void> refresh() async {
    await fetchFirstPage();
  }

  void applyStatusFilter(NurseStatus? status) {
    selectedStatus.value = status;
    fetchFirstPage();
  }
}
