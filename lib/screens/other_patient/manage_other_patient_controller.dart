import 'dart:io';

import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../api/core_apis.dart';
import '../../main.dart';
import '../auth/model/login_response.dart';

class ManageOtherPatientController extends GetxController {
  Rx<Future<RxList<UserData>>> otherPatientListFuture =
      Future(() => RxList<UserData>()).obs;
  RxBool isLoading = false.obs;
  RxBool hasLoadError = false.obs;
  RxBool isLastPage = false.obs;
  RxInt page = 1.obs;

  //region Objects
  Rx<UserData> selectedMember = UserData().obs;

  RxList<UserData> otherPatientList = <UserData>[].obs;

  Rx<File> imageFile = File("").obs;

  @override
  void onInit() {
    super.onInit();
    init();
  }

  Future<void> init({bool showLoader = true}) async {
    await getOtherPatientList(showLoader: showLoader);
  }

  Future<void> onRefresh() async {
    page(1);
    isLastPage(false);
    await init(showLoader: false);
  }

  Future<void> onNextPage() async {
    if (!isLastPage.value && !isLoading.value) {
      final previousPage = page.value;
      page.value++;
      await init();
      if (hasLoadError.value) page(previousPage);
    }
  }

  Future<void> getOtherPatientList({bool showLoader = true}) async {
    if (showLoader) isLoading(true);
    hasLoadError(false);
    final request = CoreServiceApis.otherMemberPatientList(
      page: page.value,
      memberList: otherPatientList,
      lastPageCallBack: (value) => isLastPage(value),
    );
    otherPatientListFuture.value = request;
    try {
      await request;
    } catch (e) {
      hasLoadError(true);
      log('getOtherPatientList failed: ${e.runtimeType}');
      toast(locale.value.somethingWentWrongPleaseTryAgainLater);
    } finally {
      isLoading(false);
    }
  }

  Future<void> handleDeleteMember(int memberId) async {
    if (isLoading.value || memberId <= 0) return;
    isLoading(true);
    try {
      final response = await CoreServiceApis.deleteMember(memberId: memberId);
      if (!response.status) {
        throw StateError(response.message);
      }
      toast(locale.value.recordDeletedSuccessfully);
      await onRefresh();
    } catch (e) {
      log('deleteOtherPatient failed: ${e.runtimeType}');
      toast(e is StateError
          ? e.message
          : locale.value.somethingWentWrongPleaseTryAgainLater);
    } finally {
      isLoading(false);
    }
  }
}
