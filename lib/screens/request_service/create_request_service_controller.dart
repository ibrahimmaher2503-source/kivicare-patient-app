import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../api/core_apis.dart';
import '../../main.dart';

class CreateRequestServiceController extends GetxController {
  // Form controllers
  TextEditingController nameCont = TextEditingController();
  TextEditingController descriptionCont = TextEditingController();
  TextEditingController typeCont = TextEditingController();

  FocusNode nameFocus = FocusNode();
  FocusNode descriptionFocus = FocusNode();
  FocusNode typeFocus = FocusNode();

  RxBool isLoading = false.obs;

  @override
  void onClose() {
    nameCont.dispose();
    descriptionCont.dispose();
    typeCont.dispose();
    nameFocus.dispose();
    descriptionFocus.dispose();
    typeFocus.dispose();
    super.onClose();
  }

  Map<String, dynamic> _buildRequestBody() {
    final body = <String, dynamic>{
      'name': nameCont.text.trim(),
    };

    if (descriptionCont.text.trim().isNotEmpty) {
      body['description'] = descriptionCont.text.trim();
    }

    if (typeCont.text.trim().isNotEmpty) {
      body['type'] = typeCont.text.trim();
    }

    return body;
  }

  Future<void> submitRequest() async {
    if (nameCont.text.trim().isEmpty) {
      toast(locale.value.serviceName);
      return;
    }

    isLoading(true);
    FocusManager.instance.primaryFocus?.unfocus();

    final body = _buildRequestBody();

    await CoreServiceApis.saveRequestService(request: body).then((value) {
      toast(locale.value.serviceRequestSubmitted);
      isLoading(false);
      Get.back();
    }).catchError((e) {
      isLoading(false);
      toast(e.toString());
      log("submitRequest error: $e");
    });
  }
}
