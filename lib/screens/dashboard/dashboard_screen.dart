import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kivicare_patient/api/auth_apis.dart';
import 'package:kivicare_patient/main.dart';
import 'package:kivicare_patient/screens/auth/model/login_response.dart';
import 'package:kivicare_patient/utils/constants.dart';
import 'package:kivicare_patient/utils/local_storage.dart';
import 'package:kivicare_patient/utils/secure_session_storage.dart';
import 'package:nb_utils/nb_utils.dart';
import '../../utils/app_common.dart';
import '../../utils/colors.dart';
import '../../utils/common_base.dart';
import '../../network/network_utils.dart';
import '../booking/appointments_controller.dart';
import '../home/home_controller.dart';
import 'components/btm_nav_item.dart';
import 'dashboard_controller.dart';
import 'components/menu.dart';

class DashboardScreen extends StatelessWidget {
  DashboardScreen({super.key});
  final DashboardController dashboardController =
      Get.put(DashboardController());

  @override
  Widget build(BuildContext context) {
    return DoublePressBackWidget(
      message: locale.value.pressBackAgainToExitApp,
      child: Scaffold(
        body: Obx(() =>
            dashboardController.screen[dashboardController.currentIndex.value]),
        bottomNavigationBar: Obx(
          () => Container(
            decoration: BoxDecoration(
              color: isDarkMode.value ? surfaceElevatedDark : surfaceElevated,
              border: Border(
                top: BorderSide(
                  color: isDarkMode.value ? borderColorDark : gray200,
                  width: 1,
                ),
              ),
              boxShadow: isDarkMode.value
                  ? const []
                  : [
                      BoxShadow(
                        color: softShadowColorMedium,
                        offset: const Offset(0, -2),
                        blurRadius: 16,
                        spreadRadius: 0,
                      ),
                    ],
            ),
            child: SafeArea(
              top: false,
              child: Row(
                children: List.generate(
                  bottomNavItems.length,
                  (index) {
                    final BottomBarItem navBar = bottomNavItems[index];
                    return BtmNavItem(
                      navBar: navBar,
                      isFirst: index == 0,
                      isLast: index == bottomNavItems.length - 1,
                      press: () {
                        if (!isLoggedIn.value && index == 1) {
                          doIfLoggedIn(() {
                            handleChangeTabIndex(index);
                          });
                        } else {
                          handleChangeTabIndex(index);
                        }
                      },
                      selectedNav: dashboardController.selectedBottomNav.value,
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void handleChangeTabIndex(int index) {
    dashboardController.selectedBottomNav(bottomNavItems[index]);
    dashboardController.currentIndex(index);
    try {
      if (index == 0 || (index == 2 && isLoggedIn.value)) {
        HomeController hCont = Get.find();
        hCont.getDashboardDetail(isFromSwipeRefresh: true);
      } else if (isLoggedIn.value && index == 1) {
        AppointmentsController aCont = Get.find();
        aCont.getAppointmentList(showLoader: false);
      }
      if (index == 2 && isLoggedIn.value) {
        AuthServiceApis.viewProfile().then((data) async {
          loginUserData(UserData(
            id: loginUserData.value.id,
            firstName: data.userData.firstName,
            lastName: data.userData.lastName,
            userName: "${data.userData.firstName} ${data.userData.lastName}",
            mobile: data.userData.mobile,
            email: data.userData.email,
            userRole: loginUserData.value.userRole,
            gender: data.userData.gender,
            dateOfBirth: data.userData.dateOfBirth,
            address: data.userData.address,
            apiToken: loginUserData.value.apiToken,
            profileImage: data.userData.profileImage,
            loginType: loginUserData.value.loginType,
          ));
          await SecureSessionStorage.writeUser(loginUserData.value);
          removeValueFromLocal(SharedPreferenceConst.USER_DATA);
        }).catchError((e) {
          toast(sanitizeBackendMessage(
              e, locale.value.somethingWentWrongPleaseTryAgainLater));
        });
      }
    } catch (e) {
      log('onItemSelected Err: $e');
    }
  }
}
