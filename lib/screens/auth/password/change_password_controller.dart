// ignore_for_file: depend_on_referenced_packages

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';
import '../../../main.dart';
import '../../../utils/app_common.dart';
import '../../../api/auth_apis.dart';
import 'password_set_success.dart';
import '../../../utils/common_base.dart';
import '../../../utils/secure_session_storage.dart';
import '../../../network/network_utils.dart';

class ChangePassController extends GetxController {
  RxBool isLoading = false.obs;
  TextEditingController oldPasswordCont = TextEditingController();
  TextEditingController newpasswordCont = TextEditingController();
  TextEditingController confirmPasswordCont = TextEditingController();

  RxBool hasUppercase = false.obs;
  RxBool hasNumber = false.obs;
  RxBool hasSpecial = false.obs;
  RxBool hasLetter = false.obs;

  RxBool newPasshasFocus = false.obs;

  void checkPasswordRules(String password) {
    hasUppercase.value = RegExp(r'[A-Z]').hasMatch(password);
    hasNumber.value = RegExp(r'[0-9]').hasMatch(password);
    hasSpecial.value = RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password);
    hasLetter.value = RegExp(r'[a-z]').hasMatch(password);
  }

  Future<void> saveForm() async {
    if (isLoading.value) return;
    isLoading(true);
    if (newpasswordCont.text.trim() != confirmPasswordCont.text.trim()) {
      isLoading(false);
      return toast(locale.value.yourNewPasswordDoesnT);
    } else if ((oldPasswordCont.text.trim() == newpasswordCont.text.trim()) &&
        oldPasswordCont.text.trim() == confirmPasswordCont.text.trim()) {
      isLoading(false);
      return toast(locale.value.oldAndNewPassword);
    }

    hideKeyBoardWithoutContext();

    Map<String, dynamic> req = {
      'old_password': oldPasswordCont.text.trim(),
      'new_password': confirmPasswordCont.text.trim(),
    };

    await AuthServiceApis.changePasswordAPI(request: req).then((value) async {
      isLoading(false);
      loginUserData.value.apiToken = value.data.apiToken;
      await SecureSessionStorage.writeUser(loginUserData.value);
      Get.to(() => const PasswordSetSuccess());
    }).catchError((e) {
      isLoading(false);
      toast(sanitizeBackendMessage(e, locale.value.somethingWentWrong),
          print: true);
    });
  }

  @override
  void onClose() {
    oldPasswordCont.dispose();
    newpasswordCont.dispose();
    confirmPasswordCont.dispose();
    super.onClose();
  }
}
