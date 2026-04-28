import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../api/doctor_visit_apis.dart';
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
    fetchRequests();
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
      final res = await DoctorVisitApis.getRequests(page: 1);
      requests.assignAll(_applyFilter(res.data));
      currentPage.value = 1;
      hasMore.value = res.hasMore;
    } catch (e) {
      error(e.toString());
      toast(e.toString());
    } finally {
      isLoading(false);
    }
  }

  Future<void> loadMore() async {
    if (isLoadingMore.value || !hasMore.value) return;
    isLoadingMore(true);
    try {
      final nextPage = currentPage.value + 1;
      final res = await DoctorVisitApis.getRequests(page: nextPage);
      requests.addAll(_applyFilter(res.data));
      currentPage.value = nextPage;
      hasMore.value = res.hasMore;
    } catch (e) {
      toast(e.toString());
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

  List<VisitRequestModel> _applyFilter(List<VisitRequestModel> source) {
    if (statusFilter.value == null) return source;
    return source.where((r) => r.status == statusFilter.value).toList();
  }

  @override
  void onClose() {
    scrollController.dispose();
    super.onClose();
  }
}
