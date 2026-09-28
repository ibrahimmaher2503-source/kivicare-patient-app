// ignore_for_file: depend_on_referenced_packages

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../api/auth_apis.dart';
import '../../../main.dart';
import '../../../utils/common_base.dart';
import '../../../network/network_utils.dart';

class ForgetPasswordController extends GetxController {
  RxBool isLoading = false.obs;
  final GlobalKey<FormState> forgotPassFormKey = GlobalKey();

  TextEditingController emailCont = TextEditingController();

  Future<void> saveForm() async {
    if (isLoading.value) return;
    isLoading(true);
    hideKeyBoardWithoutContext();

    Map<String, dynamic> req = {
      'email': emailCont.text.trim(),
    };

    await AuthServiceApis.forgotPasswordAPI(request: req).then((value) async {
      isLoading(false);
      toast(sanitizeBackendMessage(
          value.message, locale.value.weHaveEmailedYourPasswordResetLink));
      Get.back();
    }).catchError((e) {
      isLoading(false);
      toast(sanitizeBackendMessage(e, locale.value.somethingWentWrong),
          print: true);
    });
  }

  @override
  void onClose() {
    emailCont.dispose();
    super.onClose();
  }
}
