import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../api/core_apis.dart';
import '../../utils/app_common.dart';
import 'model/doctor_visit_request_model.dart';

class DoctorVisitListController extends GetxController {
  final RxList<DoctorVisitRequest> requests = RxList<DoctorVisitRequest>();
  final RxBool isLoading = false.obs;
  final RxBool isLastPage = false.obs;
  int page = 1;

  // Admin mode
  bool get isAdminMode {
    final roles = loginUserData.value.userRole;
    return roles.contains('admin') || roles.contains('receptionist') || roles.contains('doctor');
  }

  // Admin filters
  final RxnString selectedStatus = RxnString();
  final Rx<DateTime?> dateFrom = Rx<DateTime?>(null);
  final Rx<DateTime?> dateTo = Rx<DateTime?>(null);
  final RxnInt assignedDoctorId = RxnInt();

  int get activeFilterCount {
    int count = 0;
    if (selectedStatus.value != null) count++;
    if (dateFrom.value != null) count++;
    if (dateTo.value != null) count++;
    if (assignedDoctorId.value != null) count++;
    return count;
  }

  @override
  void onInit() {
    super.onInit();
    loadRequests();
  }

  Future<void> loadRequests() async {
    isLoading(true);

    try {
      DoctorVisitRequestListResponse response;

      if (isAdminMode) {
        String? dateFromStr;
        String? dateToStr;
        if (dateFrom.value != null) {
          dateFromStr = '${dateFrom.value!.year}-${dateFrom.value!.month.toString().padLeft(2, '0')}-${dateFrom.value!.day.toString().padLeft(2, '0')}';
        }
        if (dateTo.value != null) {
          dateToStr = '${dateTo.value!.year}-${dateTo.value!.month.toString().padLeft(2, '0')}-${dateTo.value!.day.toString().padLeft(2, '0')}';
        }

        response = await CoreServiceApis.getAdminDoctorVisitRequests(
          page: page,
          status: selectedStatus.value,
          dateFrom: dateFromStr,
          dateTo: dateToStr,
          assignedDoctorId: assignedDoctorId.value,
        );
      } else {
        response = await CoreServiceApis.getDoctorVisitRequests(page: page);
      }

      if (page == 1) requests.clear();
      requests.addAll(response.data);
      isLastPage.value = response.data.length < response.perPage;
    } catch (e) {
      toast(e.toString());
    } finally {
      isLoading(false);
    }
  }

  Future<void> refreshRequests() async {
    page = 1;
    isLastPage.value = false;
    await loadRequests();
  }

  Future<void> loadNextPage() async {
    if (isLastPage.value || isLoading.value) return;
    page++;
    await loadRequests();
  }

  void applyFilters() {
    page = 1;
    isLastPage.value = false;
    loadRequests();
  }

  void clearFilters() {
    selectedStatus.value = null;
    dateFrom.value = null;
    dateTo.value = null;
    assignedDoctorId.value = null;
    applyFilters();
  }
}
