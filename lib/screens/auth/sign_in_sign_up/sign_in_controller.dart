// ignore_for_file: depend_on_referenced_packages

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';
import '../../../main.dart';
import '../../../utils/push_notification_service.dart';
import '../../dashboard/dashboard_controller.dart';
import '../../dashboard/dashboard_screen.dart';
import '../../home/home_controller.dart';
import '../model/login_response.dart';
import '../../../api/auth_apis.dart';
import '../../../utils/app_common.dart';
import '../../../utils/common_base.dart';
import '../../../utils/constants.dart';
import '../../../utils/local_storage.dart';
import '../../../network/network_utils.dart';
import '../../../utils/secure_session_storage.dart';
import '../services/social_logins.dart';

class SignInController extends GetxController {
  RxBool isNavigateToDashboard = false.obs;
  final GlobalKey<FormState> signInformKey = GlobalKey();

  RxBool isRememberMe = true.obs;
  RxBool isLoading = false.obs;
  RxString userName = "".obs;

  TextEditingController emailCont = TextEditingController();
  TextEditingController passwordCont = TextEditingController();

  FocusNode emailFocus = FocusNode();
  FocusNode passwordFocus = FocusNode();

  void toggleSwitch() {
    isRememberMe.value = !isRememberMe.value;
  }

  @override
  void onInit() {
    emailCont.text = '';
    passwordCont.text = '';
    isRememberMe.value = false;
    if (Get.arguments is bool) {
      isNavigateToDashboard(Get.arguments == true);
    }
    final userIsRemeberMe =
        getValueFromLocal(SharedPreferenceConst.IS_REMEMBER_ME);
    final userNameFromLocal =
        getValueFromLocal(SharedPreferenceConst.USER_NAME);
    if (userNameFromLocal is String) {
      userName(userNameFromLocal);
    }
    if (userIsRemeberMe == true) {
      final userEmail = getValueFromLocal(SharedPreferenceConst.USER_EMAIL);
      if (userEmail is String) {
        emailCont.text = userEmail;
      }
    }
    super.onInit();
  }

  Future<void> saveForm() async {
    if (isLoading.value) return;
    isLoading(true);
    hideKeyBoardWithoutContext();

    Map<String, dynamic> req = {
      'email': emailCont.text.trim(),
      'password': passwordCont.text.trim(),
      'user_type': 'user',
    };

    await AuthServiceApis.loginUser(request: req).then((value) async {
      if (value.status != true) {
        isLoading(false);
        toast(value.message.trim().isNotEmpty
            ? value.message
            : locale.value.signInFailed);
        return;
      }

      if (isRememberMe.value) {
        setValueToLocal(
            SharedPreferenceConst.USER_EMAIL, emailCont.text.trim());
        setValueToLocal(SharedPreferenceConst.USER_NAME, userName.value);
      } else {
        setValueToLocal(SharedPreferenceConst.USER_EMAIL, "");
        setValueToLocal(SharedPreferenceConst.USER_NAME, "");
      }
      await handleLoginResponse(loginResponse: value);
      setValueToLocal(SharedPreferenceConst.LOGIN_SUCCESSFULL, true);
    }).catchError((e) {
      isLoading(false);
      log('Sign-in failed: ${e.runtimeType}');
      toast(sanitizeBackendMessage(e is NetworkRequestException ? e.message : e,
          locale.value.somethingWentWrong));
    });
  }

  Future<void> googleSignIn() async {
    if (isLoading.value) return;
    isLoading(true);
    await GoogleSignInAuthService.signInWithGoogle().then((value) async {
      Map request = {
        UserKeys.contactNumber: value.mobile,
        UserKeys.email: value.email,
        UserKeys.firstName: value.firstName,
        UserKeys.lastName: value.lastName,
        UserKeys.username: value.userName,
        UserKeys.profileImage: value.profileImage,
        'user_type': 'user',
        UserKeys.loginType: LoginTypeConst.LOGIN_TYPE_GOOGLE,
        UserKeys.idToken: value.identityToken,
      };

      /// Social Login Api
      await AuthServiceApis.loginUser(request: request, isSocialLogin: true)
          .then((value) async {
        await handleLoginResponse(loginResponse: value, isSocialLogin: true);
      }).catchError((e) {
        isLoading(false);
        log('Google sign-in failed: ${e.runtimeType}');
        toast(sanitizeBackendMessage(
            e is NetworkRequestException ? e.message : e,
            locale.value.somethingWentWrong));
      });
    }).catchError((e) {
      isLoading(false);
      log('Google sign-in failed: ${e.runtimeType}');
      toast(sanitizeBackendMessage(e is NetworkRequestException ? e.message : e,
          locale.value.somethingWentWrong));
    });
  }

  Future<void> appleSignIn() async {
    if (isLoading.value) return;
    isLoading(true);
    await GoogleSignInAuthService.signInWithApple().then((value) async {
      Map request = {
        UserKeys.contactNumber: value.mobile,
        UserKeys.email: value.email,
        UserKeys.firstName: value.firstName,
        UserKeys.lastName: value.lastName,
        UserKeys.username: value.userName,
        UserKeys.profileImage: value.profileImage,
        'user_type': 'user',
        UserKeys.loginType: LoginTypeConst.LOGIN_TYPE_APPLE,
        UserKeys.idToken: value.identityToken,
      };

      /// Social Login Api
      await AuthServiceApis.loginUser(request: request, isSocialLogin: true)
          .then((value) async {
        await handleLoginResponse(loginResponse: value, isSocialLogin: true);
        setValueToLocal(SharedPreferenceConst.LOGIN_SUCCESSFULL, true);
      }).catchError((e) {
        isLoading(false);
        log('Apple sign-in failed: ${e.runtimeType}');
        toast(sanitizeBackendMessage(
            e is NetworkRequestException ? e.message : e,
            locale.value.somethingWentWrong));
      });
    }).catchError((e) {
      isLoading(false);
      log('Apple sign-in failed: ${e.runtimeType}');
      toast(sanitizeBackendMessage(e is NetworkRequestException ? e.message : e,
          locale.value.somethingWentWrong));
    });
  }

  Future<void> handleLoginResponse(
      {required UserResponse loginResponse, bool isSocialLogin = false}) async {
    if (loginResponse.userData.userRole
        .contains(LoginTypeConst.LOGIN_TYPE_USER)) {
      loginUserData(loginResponse.userData);
      loginUserData.value.isSocialLogin = isSocialLogin;
      await SecureSessionStorage.writeUser(loginUserData.value);
      removeValueFromLocal(SharedPreferenceConst.USER_DATA);
      removeValueFromLocal(SharedPreferenceConst.USER_PASSWORD);
      isLoggedIn(true);
      setValueToLocal(SharedPreferenceConst.IS_LOGGED_IN, true);
      setValueToLocal(SharedPreferenceConst.IS_REMEMBER_ME, isRememberMe.value);

      isLoading(false);

      PushNotificationService().registerFCMAndTopics();

      if (isNavigateToDashboard.value) {
        Get.offAll(() => DashboardScreen(), binding: BindingsBuilder(() {
          Get.put(HomeController());
        }));
      } else {
        try {
          DashboardController dashboardController = Get.find();
          dashboardController.reloadBottomTabs();
        } catch (e) {
          log('dashboardController Get.find E: $e');
        }
        try {
          HomeController homeScreenController = Get.find();
          homeScreenController.init();
        } catch (e) {
          log('homeScreenController Get.find E: $e');
        }
        Get.back(result: true);
      }
    } else {
      isLoading(false);
      toast(loginResponse.message.trim().isEmpty
          ? locale.value.sorryUserCannotSignin
          : loginResponse.message);
    }
  }

  @override
  void onClose() {
    emailCont.dispose();
    passwordCont.dispose();
    emailFocus.dispose();
    passwordFocus.dispose();
    super.onClose();
  }
}
