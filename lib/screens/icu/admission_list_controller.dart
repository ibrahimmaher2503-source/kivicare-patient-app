import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../api/core_apis.dart';
import '../../main.dart';
import '../../utils/constants.dart';
import 'model/icu_admission_model.dart';

class AdmissionListController extends GetxController {
  // List state
  Rx<Future<RxList<IcuAdmissionRequest>>> admissionFuture = Future(() => RxList<IcuAdmissionRequest>()).obs;
  RxList<IcuAdmissionRequest> admissions = RxList<IcuAdmissionRequest>();
  RxBool isLoading = false.obs;
  RxBool isLastPage = false.obs;
  RxInt page = 1.obs;

  // Filter tabs
  RxString selectedStatus = ''.obs;
  RxList<Map<String, String>> statusFilters = RxList();

  @override
  void onInit() {
    statusFilters = [
      {'key': '', 'label': locale.value.all},
      {'key': IcuAdmissionStatusConst.pending, 'label': locale.value.pending},
      {'key': IcuAdmissionStatusConst.accepted, 'label': locale.value.acceptedLabel},
      {'key': IcuAdmissionStatusConst.rejected, 'label': locale.value.rejectedLabel},
      {'key': IcuAdmissionStatusConst.infoRequested, 'label': locale.value.infoRequestedLabel},
      {'key': IcuAdmissionStatusConst.cancelled, 'label': locale.value.cancelled},
    ].obs;

    getAdmissions();
    super.onInit();
  }

  Future<void> getAdmissions({bool showLoader = true}) async {
    if (showLoader) {
      isLoading(true);
    }

    await admissionFuture(
      CoreServiceApis.getIcuAdmissionList(
        page: page.value,
        perPage: Constants.perPageItem,
        admissionList: admissions,
        status: selectedStatus.value,
        lastPageCallBack: (isLast) => isLastPage(isLast),
      ),
    ).then((value) {
      log('ICU admissions fetched: ${value.length}');
    }).catchError((e) {
      log("getAdmissions error $e");
    }).whenComplete(() => isLoading(false));
  }

  void onFilterChanged(String status) {
    selectedStatus(status);
    page(1);
    getAdmissions();
  }
}
