import 'dart:io';

import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kivicare_patient/utils/common_base.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../api/core_apis.dart';
import '../../app_theme.dart';
import '../../main.dart';
import '../../utils/app_common.dart';
import '../../utils/colors.dart';
import '../../utils/constants.dart';
import '../auth/model/common_model.dart';
import '../auth/model/login_response.dart';

class AddOtherPatientController extends GetxController {
  final GlobalKey<FormState> addMemberFormKey = GlobalKey();

  RxBool isLoading = false.obs;
  RxBool isEdit = false.obs;

  Rx<File> imageFile = File("").obs;
  XFile? pickedFile;

  TextEditingController fNameCont = TextEditingController();
  TextEditingController lNameCont = TextEditingController();
  TextEditingController phoneCodeCont = TextEditingController();
  TextEditingController mobileCont = TextEditingController();
  TextEditingController dateOfBirthCont = TextEditingController();

  FocusNode fNameFocus = FocusNode();
  FocusNode lNameFocus = FocusNode();
  FocusNode phoneCodeFocus = FocusNode();
  FocusNode mobileFocus = FocusNode();
  FocusNode dateOfBirthFocus = FocusNode();

  Rx<Country> pickedPhoneCode = defaultCountry.obs;

  Rx<CMNModel> selectedGender = CMNModel().obs;
  Rx<CMNModel> selectedRelation = CMNModel().obs;

  @override
  void onInit() {
    if (Get.arguments is UserData) {
      init(argument: Get.arguments as UserData);
      isEdit(true);
    } else {
      selectedGender.value = genders.first;
      selectedRelation.value = relation.first;
      isEdit(false);
    }

    super.onInit();
  }

  Future<void> init({
    bool showLoader = true,
    required UserData argument,
  }) async {
    isLoading(showLoader);
    fNameCont.text = argument.firstName;
    lNameCont.text = argument.lastName;

    try {
      mobileCont.text = argument.contactNumber.extractPhoneCodeAndNumber.$2;
    } catch (e) {
      mobileCont.text = argument.contactNumber.trim();
      log('CountryParser Mobile Number Err: $e');
    }

    try {
      pickedPhoneCode(CountryParser.parsePhoneCode(
          argument.contactNumber.extractPhoneCodeAndNumber.$1));
    } catch (e) {
      pickedPhoneCode(Country.from(json: defaultCountry.toJson()));
      log('CountryParser.parsePhoneCode Err: $e');
    }

    selectedGender(
      genders.firstWhere(
        (element) =>
            element.slug.toString().toLowerCase() ==
            argument.gender.toLowerCase(),
        orElse: () => CMNModel(
          id: 3,
          name: RelationConstant.others.capitalizeFirstLetter(),
          slug: RelationConstant.others,
        ),
      ),
    );

    dateOfBirthCont.text = argument.birthDate;
    selectedRelation(
      relation.firstWhere(
        (element) =>
            element.slug.toString().toLowerCase() ==
            argument.relation.toLowerCase(),
        orElse: () => CMNModel(
          id: 5,
          name: RelationConstant.others.capitalizeFirstLetter(),
          slug: RelationConstant.others,
        ),
      ),
    );
    isLoading(false);
  }

  Future<void> pickDate(BuildContext context) async {
    DateTime now = DateTime.now();
    DateTime? pickedDate = await showDatePicker(
      context: context,
      fieldHintText: DateTime.now().formatDateYYYYmmdd(),
      initialDate: dateOfBirthCont.text.isNotEmpty
          ? DateTime.parse(dateOfBirthCont.text)
          : null,
      firstDate: DateTime(1900),
      lastDate: now,
      confirmText: locale.value.confirm,
      cancelText: locale.value.cancel,
      helpText: locale.value.selectBirthdate,
      locale: Locale(selectedLanguageDataModel?.languageCode ??
          getStringAsync(SELECTED_LANGUAGE_CODE)),
      builder: (_, child) {
        return Theme(
          data: isDarkMode.value ? AppTheme.darkTheme : AppTheme.lightTheme,
          child: child!,
        );
      },
    );

    if (pickedDate != null) {
      dateOfBirthCont.text = pickedDate.formatDateYYYYmmdd();
      hideKeyboard(getContext);
    } else {
      log("Date is not selected");
    }
  }

  void _getFromGallery() async {
    pickedFile = await ImagePicker().pickImage(
        source: ImageSource.gallery, maxWidth: 1800, maxHeight: 1800);
    if (pickedFile != null) {
      imageFile(File(pickedFile!.path));
    }
  }

  Future<void> _getFromCamera() async {
    pickedFile = await ImagePicker()
        .pickImage(source: ImageSource.camera, maxWidth: 1800, maxHeight: 1800);
    if (pickedFile != null) {
      imageFile(File(pickedFile!.path));
    }
  }

  void showBottomSheet(BuildContext context) {
    showModalBottomSheet<void>(
      backgroundColor: context.cardColor,
      context: context,
      builder: (BuildContext context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            SettingItemWidget(
              title: locale.value.gallery,
              leading: const Icon(Icons.image, color: appColorPrimary),
              onTap: () async {
                _getFromGallery();
                finish(context);
              },
            ),
            SettingItemWidget(
              title: locale.value.camera,
              leading: const Icon(Icons.camera, color: appColorPrimary),
              onTap: () {
                _getFromCamera();
                finish(context);
              },
              hoverColor: Colors.transparent,
              highlightColor: Colors.transparent,
              splashColor: Colors.transparent,
            ),
          ],
        ).paddingAll(16.0);
      },
    );
  }

  Future<void> addMember() async {
    if (isLoading.value) return;
    isLoading(true);

    Map<String, dynamic> memberData = {
      UserKeys.firstName: fNameCont.text,
      UserKeys.lastName: lNameCont.text,
      OtherPatientConst.relation: selectedRelation.value.name,
      OtherPatientConst.dob: dateOfBirthCont.text,
      OtherPatientConst.contactNumber:
          '+${mobileCont.text.trim().formatPhoneNumber(pickedPhoneCode.value.phoneCode)}',
      UserKeys.gender: selectedGender.value.name,
      UserKeys.userId: loginUserData.value.id,
    };

    if ((Get.arguments is UserData)) {
      memberData.putIfAbsent(
          OtherPatientConst.idKey, () => (Get.arguments as UserData).id);
    }

    try {
      final response = await CoreServiceApis.addUpdateOtherPatientApi(
        request: memberData,
        profileImage: imageFile.value,
      );
      if (!response.status) {
        throw StateError(response.message);
      }
      toast(isEdit.value
          ? locale.value.patientUpdatedSuccessfully
          : locale.value.patientAddedSuccessfully);
      Get.back(result: true);
    } catch (e) {
      log('addOtherPatient failed: ${e.runtimeType}');
      toast(e is StateError
          ? e.message
          : locale.value.somethingWentWrongPleaseTryAgainLater);
    } finally {
      isLoading(false);
    }
  }

  Future<void> handleAddOtherPatient() async {
    if (isLoading.value) return;
    final form = addMemberFormKey.currentState;
    if (form != null && form.validate()) {
      form.save();
      await addMember();
    }
  }

  @override
  void onClose() {
    fNameCont.dispose();
    lNameCont.dispose();
    phoneCodeCont.dispose();
    mobileCont.dispose();
    dateOfBirthCont.dispose();
    fNameFocus.dispose();
    lNameFocus.dispose();
    phoneCodeFocus.dispose();
    mobileFocus.dispose();
    dateOfBirthFocus.dispose();
    super.onClose();
  }
}
