import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nb_utils/nb_utils.dart';
import '../../../utils/constants.dart';
import 'package:country_picker/country_picker.dart';

import '../../api/core_apis.dart';
import '../../components/operation_verification_screen.dart';
import '../../main.dart';
import '../../network/critical_operation.dart';
import '../../network/network_utils.dart';
import '../../utils/common_base.dart';
import 'model/incident_response_model.dart';
import 'model/incident_status_model.dart';
import 'package:path/path.dart' as path;

class IncidentManagement extends GetxController {
  // Form controllers
  TextEditingController titleCont = TextEditingController();
  TextEditingController desCont = TextEditingController();
  TextEditingController emailCont = TextEditingController();
  TextEditingController phoneCodeCont = TextEditingController();
  TextEditingController mobileCont = TextEditingController();
  TextEditingController imageTitleCont = TextEditingController();

  FocusNode titleFocus = FocusNode();
  FocusNode desFocus = FocusNode();
  FocusNode emailFocus = FocusNode();
  FocusNode phoneCodeFocus = FocusNode();
  FocusNode mobileFocus = FocusNode();
  FocusNode imageTitleFocus = FocusNode();

  RxBool isLoading = false.obs;
  Rx<Country> pickedPhoneCode = defaultCountry.obs;
  Rx<File> imageFile = File("").obs;
  XFile? pickedFile;

  // Incident list state
  Rx<Future<RxList<Incident>>> incidenceFuture =
      Future(() => RxList<Incident>()).obs;
  RxList<Incident> incidents = RxList<Incident>();
  RxBool isIncidenceLastPage = false.obs;
  RxInt incidencePage = 1.obs;

  RxBool isExpanded = false.obs;

  // Filters
  RxSet<String> selectedStatus = RxSet();
  RxSet<String> selectedService = RxSet();

  // Tabs
  RxList<IncidentStatusModel> filterStatus = RxList();
  Rx<IncidentStatusModel> selectedTab = IncidentStatusModel().obs;

  @override
  void onInit() {
    filterStatus = [
      IncidentStatusModel(type: IncidentStatus.all, name: locale.value.all),
      IncidentStatusModel(type: IncidentStatus.open, name: locale.value.open),
      IncidentStatusModel(
          type: IncidentStatus.closed,
          name: locale.value.closed.toLowerCase().capitalizeFirstLetter()),
    ].obs;

    if (filterStatus.isNotEmpty) {
      selectedTab(filterStatus.first);
    }

    getIncidents(); // Initial call
    super.onInit();
  }

  @override
  void dispose() {
    clearTextFields();
    super.dispose();
  }

  void clearTextFields() {
    titleCont.clear();
    desCont.clear();
    emailCont.clear();
    phoneCodeCont.clear();
    mobileCont.clear();
    imageTitleCont.clear();
  }

  Future<void> getIncidents({bool showLoader = true}) async {
    if (showLoader) {
      isLoading(true);
    }

    await incidenceFuture(
      CoreServiceApis.getIncidentList(
        page: incidencePage.value,
        perPage: 10,
        incidents: incidents,
        lastPageCallBack: (isLast) => isIncidenceLastPage(isLast),
      ),
    ).then((value) {
      log('Incidents fetched: ${value.length}');
    }).catchError((e) {
      log("getIncidents error $e");
    }).whenComplete(() => isLoading(false));
  }

  void pickImage() async {
    pickedFile = await ImagePicker().pickImage(
        source: ImageSource.gallery, maxWidth: 1800, maxHeight: 1800);
    if (pickedFile != null) {
      imageFile(File(pickedFile!.path));
      imageTitleCont.text = path.basename(pickedFile!.path);
    }
  }

  Future<bool> submitAPI({
    required String title,
    required String description,
    required String phoneCode,
    required String mobileNumber,
    required String email,
    required File imageFile,
  }) async {
    if (isLoading.value) return false;
    isLoading(true);
    hideKeyBoardWithoutContext();
    final fingerprint = criticalOperationFingerprint({
      'title': title,
      'description': description,
      'phone_code': phoneCode,
      'mobile_number': mobileNumber,
      'email': email,
      'has_attachment': imageFile.existsSync(),
    });
    String? operationKey;
    try {
      operationKey = await CriticalOperationStore.begin(
        CriticalOperationType.incident,
        scope: fingerprint,
        requestFingerprint: fingerprint,
      );
      final response = await CoreServiceApis.addIncident(
        title: title,
        description: description,
        email: email,
        mobileNumber: mobileNumber,
        phoneCode: phoneCode,
        imageFile: imageFile,
        idempotencyKey: operationKey,
      );
      await CriticalOperationStore.complete(
        CriticalOperationType.incident,
        scope: fingerprint,
      );
      toast(response.message.isNotEmpty
          ? sanitizeBackendMessage(
              response.message, locale.value.successfullyAdded)
          : locale.value.successfullyAdded);
      return true;
    } catch (error) {
      log('Incident submission failed: $error');
      if (error is AmbiguousRequestOutcomeException && operationKey != null) {
        Get.to(() => OperationVerificationScreen(
              operationType: CriticalOperationType.incident,
              operationKey: operationKey!,
            ));
      }
      toast(locale.value.somethingWentWrong);
      return false;
    } finally {
      isLoading(false);
    }
  }

  @override
  void onClose() {
    titleCont.dispose();
    desCont.dispose();
    emailCont.dispose();
    phoneCodeCont.dispose();
    mobileCont.dispose();
    imageTitleCont.dispose();
    titleFocus.dispose();
    desFocus.dispose();
    emailFocus.dispose();
    phoneCodeFocus.dispose();
    mobileFocus.dispose();
    imageTitleFocus.dispose();
    super.onClose();
  }
}
