import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../api/core_apis.dart';
import '../../main.dart';
import 'model/nurse_model.dart';
import 'model/nurse_request_model.dart';

class CreateNurseRequestController extends GetxController {
  // Form controllers
  TextEditingController serviceDescriptionCont = TextEditingController();
  TextEditingController preferredDateCont = TextEditingController();
  TextEditingController preferredTimeCont = TextEditingController();
  TextEditingController durationHoursCont = TextEditingController();
  TextEditingController contactNumberCont = TextEditingController();
  TextEditingController patientNotesCont = TextEditingController();
  TextEditingController addressLine1Cont = TextEditingController();
  TextEditingController addressLine2Cont = TextEditingController();
  TextEditingController cityCont = TextEditingController();
  TextEditingController stateCont = TextEditingController();
  TextEditingController countryCont = TextEditingController();
  TextEditingController postalCodeCont = TextEditingController();

  FocusNode serviceDescriptionFocus = FocusNode();
  FocusNode durationHoursFocus = FocusNode();
  FocusNode contactNumberFocus = FocusNode();
  FocusNode patientNotesFocus = FocusNode();
  FocusNode addressLine1Focus = FocusNode();
  FocusNode addressLine2Focus = FocusNode();
  FocusNode cityFocus = FocusNode();
  FocusNode stateFocus = FocusNode();
  FocusNode countryFocus = FocusNode();
  FocusNode postalCodeFocus = FocusNode();

  Rx<Nurse?> selectedNurse = Rx<Nurse?>(null);
  RxBool isLoading = false.obs;

  // Edit mode
  NurseRequest? editRequest;
  bool get isEditMode => editRequest != null;

  void initForEdit(NurseRequest request) {
    editRequest = request;
    serviceDescriptionCont.text = request.serviceDescription;
    preferredDateCont.text = request.preferredDate;
    preferredTimeCont.text = request.preferredTime;
    durationHoursCont.text = request.durationHours > 0 ? request.durationHours.toString() : '';
    contactNumberCont.text = request.contactNumber;
    patientNotesCont.text = request.patientNotes;

    if (request.address != null) {
      addressLine1Cont.text = request.address!.addressLine1;
      addressLine2Cont.text = request.address!.addressLine2;
      cityCont.text = request.address!.city;
      stateCont.text = request.address!.state;
      countryCont.text = request.address!.country;
      postalCodeCont.text = request.address!.postalCode;
    }
  }

  void setNurse(Nurse nurse) {
    selectedNurse(nurse);
  }

  @override
  void dispose() {
    serviceDescriptionCont.dispose();
    preferredDateCont.dispose();
    preferredTimeCont.dispose();
    durationHoursCont.dispose();
    contactNumberCont.dispose();
    patientNotesCont.dispose();
    addressLine1Cont.dispose();
    addressLine2Cont.dispose();
    cityCont.dispose();
    stateCont.dispose();
    countryCont.dispose();
    postalCodeCont.dispose();
    super.dispose();
  }

  Map<String, dynamic> _buildRequestBody() {
    final body = <String, dynamic>{
      'service_description': serviceDescriptionCont.text.trim(),
      'preferred_date': preferredDateCont.text.trim(),
      'preferred_time': preferredTimeCont.text.trim(),
      'contact_number': contactNumberCont.text.trim(),
    };

    if (selectedNurse.value != null) {
      body['nurse_id'] = selectedNurse.value!.id;
    }

    if (durationHoursCont.text.trim().isNotEmpty) {
      body['duration_hours'] = int.tryParse(durationHoursCont.text.trim()) ?? 1;
    }

    if (patientNotesCont.text.trim().isNotEmpty) {
      body['patient_notes'] = patientNotesCont.text.trim();
    }

    // Address
    final address = <String, dynamic>{};
    if (addressLine1Cont.text.trim().isNotEmpty) address['address_line_1'] = addressLine1Cont.text.trim();
    if (addressLine2Cont.text.trim().isNotEmpty) address['address_line_2'] = addressLine2Cont.text.trim();
    if (cityCont.text.trim().isNotEmpty) address['city'] = cityCont.text.trim();
    if (stateCont.text.trim().isNotEmpty) address['state'] = stateCont.text.trim();
    if (countryCont.text.trim().isNotEmpty) address['country'] = countryCont.text.trim();
    if (postalCodeCont.text.trim().isNotEmpty) address['postal_code'] = postalCodeCont.text.trim();

    if (address.isNotEmpty) {
      body['address'] = address;
    }

    return body;
  }

  Future<void> submitRequest() async {
    isLoading(true);
    hideKeyBoardWithoutContext();

    final body = _buildRequestBody();

    await CoreServiceApis.createNurseRequest(request: body).then((value) {
      toast(locale.value.nurseRequestSubmitted);
      isLoading(false);
      Get.back();
    }).catchError((e) {
      isLoading(false);
      toast(e.toString());
      log("submitRequest error: $e");
    });
  }

  Future<void> updateRequest() async {
    if (editRequest == null) return;
    isLoading(true);
    hideKeyBoardWithoutContext();

    final body = _buildRequestBody();

    await CoreServiceApis.updateNurseRequest(requestId: editRequest!.id, request: body).then((value) {
      toast(locale.value.nurseRequestUpdated);
      isLoading(false);
      Get.back();
    }).catchError((e) {
      isLoading(false);
      toast(e.toString());
      log("updateRequest error: $e");
    });
  }
}
