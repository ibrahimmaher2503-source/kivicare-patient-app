import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../api/core_apis.dart';
import '../../main.dart';
import '../../utils/app_common.dart';

class DoctorVisitRequestController extends GetxController {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final TextEditingController visitReasonCont = TextEditingController();
  final TextEditingController contactPhoneCont = TextEditingController();
  final TextEditingController additionalNotesCont = TextEditingController();

  final Rx<DateTime?> preferredDate = Rx<DateTime?>(null);
  final RxnInt preferredDoctorId = RxnInt();
  final RxString preferredDoctorName = ''.obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    contactPhoneCont.text = loginUserData.value.mobile;
  }

  @override
  void onClose() {
    visitReasonCont.dispose();
    contactPhoneCont.dispose();
    additionalNotesCont.dispose();
    super.onClose();
  }

  Future<void> pickDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: preferredDate.value ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 90)),
    );
    if (picked != null) {
      preferredDate.value = picked;
    }
  }

  String? validateVisitReason(String? value) {
    if (value == null || value.trim().isEmpty) return locale.value.thisFieldIsRequired;
    if (value.length > 1000) return '${locale.value.visitReason} max 1000';
    return null;
  }

  String? validateContactPhone(String? value) {
    if (value == null || value.trim().isEmpty) return locale.value.thisFieldIsRequired;
    if (value.length > 20) return '${locale.value.contactPhone} max 20';
    return null;
  }

  Future<void> submitRequest() async {
    if (!formKey.currentState!.validate()) return;
    if (preferredDate.value == null) {
      toast(locale.value.dateIsNotSelected);
      return;
    }

    isLoading(true);

    final request = <String, dynamic>{
      'visit_reason': visitReasonCont.text.trim(),
      'preferred_date': '${preferredDate.value!.year}-${preferredDate.value!.month.toString().padLeft(2, '0')}-${preferredDate.value!.day.toString().padLeft(2, '0')}',
      'contact_phone': contactPhoneCont.text.trim(),
    };

    if (preferredDoctorId.value != null) {
      request['preferred_doctor_id'] = preferredDoctorId.value;
    }
    if (additionalNotesCont.text.trim().isNotEmpty) {
      request['additional_notes'] = additionalNotesCont.text.trim();
    }

    await CoreServiceApis.submitDoctorVisitRequest(request: request).then((value) {
      toast(locale.value.visitRequestSubmitted);
      Get.back(result: true);
    }).catchError((e) {
      toast(e.toString());
    }).whenComplete(() {
      isLoading(false);
    });
  }
}
