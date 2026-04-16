import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kivicare_patient/api/auth_apis.dart';
import 'package:kivicare_patient/main.dart';
import 'package:kivicare_patient/screens/auth/model/login_response.dart';
import 'package:kivicare_patient/utils/constants.dart';
import 'package:kivicare_patient/utils/local_storage.dart';
import 'package:nb_utils/nb_utils.dart';
import '../../utils/app_common.dart';
import '../../utils/colors.dart';
import '../../utils/common_base.dart';
import '../booking/appointments_controller.dart';
import '../home/home_controller.dart';
import 'components/btm_nav_item.dart';
import 'dashboard_controller.dart';
import 'components/menu.dart';

class DashboardScreen extends StatelessWidget {
  DashboardScreen({super.key});
  final DashboardController dashboardController = Get.put(DashboardController());

  @override
  Widget build(BuildContext context) {
    return DoublePressBackWidget(
      message: locale.value.pressBackAgainToExitApp,
      child: Scaffold(
        body: Stack(
          children: [
            Obx(() => dashboardController.screen[dashboardController.currentIndex.value]),
            Obx(
              () => Align(
                alignment: Alignment.bottomCenter,
                child: ClipRRect(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        // Frosted glass background
                        color: isDarkMode.value
                            ? Colors.black.withValues(alpha: 0.4)
                            : Colors.white.withValues(alpha: 0.75),
                        // Subtle top border
                        border: Border(
                          top: BorderSide(
                            color: isDarkMode.value
                                ? Colors.white.withValues(alpha: 0.1)
                                : appColorPrimary.withValues(alpha: 0.08),
                            width: 0.5,
                          ),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: isDarkMode.value
                                ? Colors.black.withValues(alpha: 0.3)
                                : appColorPrimary.withValues(alpha: 0.08),
                            offset: const Offset(0, -4),
                            blurRadius: 16,
                            spreadRadius: 0,
                          ),
                        ],
                      ),
                      padding: EdgeInsets.only(
                        top: 10,
                        bottom: MediaQuery.of(context).padding.bottom + 10,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        mainAxisSize: MainAxisSize.max,
                        children: List.generate(
                          bottomNavItems.length,
                          (index) {
                            BottomBarItem navBar = bottomNavItems[index];
                            return Obx(
                              () => BtmNavItem(
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
                                selectedNav:
                                    dashboardController.selectedBottomNav.value,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
        extendBody: true,
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
        AuthServiceApis.viewProfile().then((data) {
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
          setValueToLocal(SharedPreferenceConst.USER_DATA, loginUserData.toJson());
        }).catchError((e) {
          toast(e.toString());
        });
      }
    } catch (e) {
      log('onItemSelected Err: $e');
    }
  }
}
