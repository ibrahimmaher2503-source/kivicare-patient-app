// ignore_for_file: depend_on_referenced_packages

import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';
import '../../../utils/app_common.dart';
import '../../../api/auth_apis.dart';
import '../../../network/network_utils.dart';
import '../../../main.dart';
import 'logout_flow.dart';

class ProfileController extends GetxController {
  RxBool isLoading = false.obs;
  RxBool isWalletLoading = false.obs;
  @override
  void onInit() {
    init();
    super.onInit();
  }

  void init() {
    getAboutPageData();
    isWalletLoading(true);
    AuthServiceApis.getUserWallet().whenComplete(() => isWalletLoading(false));
  }

  Future<void> handleLogout() async {
    if (isLoading.value) return;
    await runLogoutFlow(
      sendLogout: () async => AuthServiceApis.logoutApi(),
      clearLocalSession: AuthServiceApis.clearData,
      navigateToSignedOutHome: navigateToSignedOutHome,
      setLoading: (loading) => isLoading(loading),
      onRemoteFailure: (error) => toast(sanitizeBackendMessage(
          error, locale.value.somethingWentWrongPleaseTryAgainLater)),
    );
  }

  ///Get About Pages
  void getAboutPageData({bool isFromSwipeRefresh = false}) {
    if (!isFromSwipeRefresh) {
      isLoading(true);
    }
    isLoading(true);
    AuthServiceApis.getAboutPageData().then((value) {
      isLoading(false);
      aboutPages(value.data);
    }).onError((error, stackTrace) {
      isLoading(false);
      toast(sanitizeBackendMessage(
          error, locale.value.somethingWentWrongPleaseTryAgainLater));
    });
  }
}
