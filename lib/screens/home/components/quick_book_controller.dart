import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kivicare_patient/screens/booking/model/booking_req.dart';
import 'package:kivicare_patient/screens/clinic/model/clinics_res_model.dart';
import 'package:kivicare_patient/screens/service/model/service_list_model.dart';
import 'package:kivicare_patient/screens/slots/components/appointment_summary_comp.dart';
import 'package:kivicare_patient/utils/app_common.dart';
import 'package:kivicare_patient/utils/common_base.dart';
import 'package:kivicare_patient/utils/constants.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../main.dart';

import '../../../api/core_apis.dart';

class QuickBookController extends GetxController {
  TextEditingController serviceCont = TextEditingController();
  TextEditingController clinicCont = TextEditingController();
  TextEditingController dateCont = TextEditingController();
  TextEditingController timeCont = TextEditingController();
  RxBool isLoading = false.obs;
  RxBool hasErrorFetchingServices = false.obs;
  RxString errorMessageServices = "".obs;
  RxBool hasErrorFetchingClinic = false.obs;
  RxString errorMessageClinic = "".obs;
  RxList<ServiceElement> serviceList = RxList();
  RxString searchService = "".obs;
  RxString searchClinic = "".obs;
  RxInt selectedServiceId = (-1).obs;
  RxInt selectedClinicId = (-1).obs;
  RxInt selectedDoctorId = (-1).obs;
  ServiceElement? serviceData;
  Clinic? selectedClinicData;
  RxString selectedService = "".obs;
  RxString selectedClinic = "".obs;
  RxString doctorName = "".obs;

  RxString selectedDate = DateTime.now().formatApiDateYYYYmmdd().obs;
  RxBool nextBtnVisible = false.obs;

  //get list of services
  Rx<Future<RxList<ServiceElement>>> servicesFuture =
      Future(() => RxList<ServiceElement>()).obs;
  RxList<ServiceElement> servicesList = RxList();

  //get list of clinic
  Rx<Future<RxList<Clinic>>> clinicFuture = Future(() => RxList<Clinic>()).obs;
  RxList<Clinic> clinicList = RxList();

  Rx<Future<RxList<String>>> slotsFuture = Future(() => RxList<String>()).obs;
  RxList<String> slots = RxList();
  RxString selectedSlot = "".obs;
  RxString price = "".obs;
  RxString onboardingHint = "".obs;

  BookingReq bookingReq = BookingReq();
  RxBool hasMoreData = true.obs;
  RxInt currentPage = 1.obs;

  @override
  void onInit() {
    resetFields();
    super.onInit();
  }

  void resetFields() {
    serviceCont.clear();
    clinicCont.clear();
    dateCont.clear();
    timeCont.clear();

    selectedDate.value = '';
    selectedSlot.value = '';
    selectedServiceId.value = -1;
    selectedClinicId.value = -1;
    selectedDoctorId.value = -1;
    selectedService.value = "";
    selectedClinic.value = "";
    doctorName.value = "";
    price.value = "";

    serviceList.clear();
    clinicList.clear();
    slots.clear();

    serviceData = null;
    selectedClinicData = null;

    hasErrorFetchingServices.value = false;
    hasErrorFetchingClinic.value = false;
    isLoading.value = false;
    updateHint();
  }

  int get currentStep {
    if (serviceData == null) return 1;
    if (selectedClinicData == null) return 2;
    if (selectedDate.value.isEmpty) return 3;
    if (selectedSlot.value.isEmpty) return 4;
    return 5;
  }

  bool get canPickClinic => serviceData != null;

  bool get canPickDate => canPickClinic && selectedClinicData != null;

  bool get canPickTime => canPickDate && selectedDate.value.isNotEmpty;

  void updateHint() {
    if (currentStep == 1) {
      onboardingHint(locale.value.selectService);
    } else if (currentStep == 2) {
      onboardingHint(locale.value.selectClinic);
    } else if (currentStep == 3) {
      onboardingHint(locale.value.chooseDate);
    } else if (currentStep == 4) {
      onboardingHint(locale.value.chooseTime);
    } else {
      onboardingHint(locale.value.bookNow);
    }
  }

  void onServiceSelected(ServiceElement service) {
    selectedServiceId.value = service.id;
    serviceCont.text = service.name;
    selectedService.value = serviceCont.text;
    serviceData = service;
    selectedClinicId.value = -1;
    selectedClinicData = null;
    clinicCont.clear();
    selectedDate.value = '';
    dateCont.clear();
    selectedSlot.value = '';
    slots.clear();
    timeCont.clear();
    updateHint();
  }

  void onClinicSelected(Clinic clinic) {
    selectedClinicId.value = clinic.id;
    selectedClinic.value = clinic.name;
    clinicCont.text = clinic.name;
    selectedClinicData = clinic;
    selectedDate.value = '';
    dateCont.clear();
    selectedSlot.value = '';
    slots.clear();
    timeCont.clear();
    updateHint();
  }

  void onDateSelected(DateTime date) {
    selectedDate.value = date.formatApiDateYYYYmmdd();
    dateCont.text = selectedDate.value;
    selectedSlot.value = '';
    slots.clear();
    timeCont.clear();
    updateHint();
  }

  void onSlotSelected(String slot) {
    selectedSlot(slot);
    timeCont.text = slot;
    onDateTimeChange();
    updateHint();
  }

  Future<void> getServiceList({bool showLoader = true}) async {
    if (showLoader) {
      isLoading(true);
    }
    await servicesFuture(
      CoreServiceApis.getServiceList(
        serviceList: serviceList,
        page: currentPage.value,
        search: searchService.value,
        enableAdvancePayment: 0,
        lastPageCallBack: (value) {
          hasMoreData.value = value;
        },
      ),
    ).then((value) {
      isLoading(false);
    }).catchError((e) {
      isLoading(false);
    }).whenComplete(() => isLoading(false));
  }

  Future<void> getClinicList({bool showLoader = true}) async {
    if (showLoader) {
      isLoading(true);
    }
    await clinicFuture(CoreServiceApis.getClinics(
            clinics: clinicList,
            search: searchClinic.value,
            serviceId: selectedServiceId.value))
        .then((value) {
      clinicList(value);
      isLoading(false);
    }).catchError((e) {
      isLoading(false);
    }).whenComplete(() => isLoading(false));
  }

  Future<void> getTimeSlot({bool showLoader = true}) async {
    if (serviceData == null) return;
    if (showLoader) isLoading(true);
    try {
      final doctor = serviceData!.assignDoctor.firstWhereOrNull(
        (element) => element.clinicId == selectedClinicId.value,
      );

      if (doctor == null) {
        // No doctor assigned to the selected clinic — don't fall back to a
        // doctor from another clinic or fetch slots with doctor_id = -1.
        selectedDoctorId.value = -1;
        doctorName.value = "";
        price.value = "";
        slots.clear();
        await slotsFuture(Future(() => slots));
        return;
      }

      selectedDoctorId.value = doctor.doctorId;
      doctorName.value = doctor.doctorName;
      price.value = doctor.priceDetail.totalAmount.toString();

      final timeSlots = await slotsFuture(
        CoreServiceApis.getTimeSlots(
          slots: slots,
          date: selectedDate.value,
          serviceId: selectedServiceId.value,
          clinicId: selectedClinicId.value,
          doctorId: selectedDoctorId.value,
        ),
      );

      log('Fetched ${timeSlots.length} time slots');
    } catch (e) {
      log("getTimeSlots error: $e");
    } finally {
      if (showLoader) isLoading(false);
    }
  }

  void onDateTimeChange() {
    final appointmentDateTime = "${selectedDate.value} ${selectedSlot.value}";
    if (appointmentDateTime.isValidDateTime) {
      nextBtnVisible(true);
    } else {
      nextBtnVisible(false);
    }
  }

  void bookAppointment() {
    if (serviceData == null) {
      toast(locale.value.selectService);
      return;
    }
    if (selectedClinicData == null) {
      toast(locale.value.selectClinic);
      return;
    }
    if (selectedDate.value.isEmpty || selectedSlot.value.isEmpty) {
      toast(locale.value.chooseTime);
      return;
    }
    if (selectedDoctorId.value <= 0 || price.value.isEmpty) {
      toast(locale.value.noDoctorsAvailable);
      return;
    }
    //BookingReq
    bookingReq.clinicId = selectedClinicId.value.toString();
    bookingReq.serviceId = selectedServiceId.value.toString();
    bookingReq.appointmentDate = selectedDate.value;
    bookingReq.userId = loginUserData.value.id.toString();
    bookingReq.status = StatusConst.pending;
    bookingReq.doctorId = selectedDoctorId.value.toString();
    bookingReq.appointmentTime = selectedSlot.value;
    //
    bookingReq.serviceName = serviceData!.name.toString();
    bookingReq.doctorName = doctorName.value;
    bookingReq.clinicName = selectedClinicData!.name.toString();
    bookingReq.location = selectedClinicData!.address.toString();
    bookingReq.totalAmount = price.value.toDouble();
    bookingReq.isEnableAdvancePayment = serviceData!.isEnableAdvancePayment;
    // advancePaymentAmount is a percentage of the total, not an amount.
    bookingReq.advancePayableAmount =
        (bookingReq.totalAmount * serviceData!.advancePaymentAmount) / 100;
    bookingReq.isOnlineService =
        serviceData!.type.toLowerCase() == ServiceTypeConst.online;

    showInDialog(
      Get.context!,
      contentPadding: EdgeInsets.zero,
      builder: (_) {
        return AppointmentSummaryWidget(
          bookingData: bookingReq,
          isQuickBook: true,
        );
      },
    ).then((value) {
      // Proceed pops the summary with `true`; reset the draft only then so
      // cancelling keeps the user's selections editable. Never call dispose()
      // manually — GetX owns this controller's lifecycle.
      if (value == true) {
        resetFields();
      }
    });
  }

  @override
  void onClose() {
    serviceCont.dispose();
    clinicCont.dispose();
    dateCont.dispose();
    timeCont.dispose();
    super.onClose();
  }
}
