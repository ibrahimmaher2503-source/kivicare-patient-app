import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kivicare_patient/api/core_apis.dart';
import 'package:kivicare_patient/main.dart';
import 'package:kivicare_patient/network/network_utils.dart';
import 'package:kivicare_patient/utils/app_common.dart';
import 'package:kivicare_patient/utils/common_base.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../utils/constants.dart';
import '../auth/model/login_response.dart';
import '../booking/model/booking_req.dart';
import '../clinic/model/clinic_detail_model.dart';
import '../clinic/model/clinics_res_model.dart';
import '../doctor/model/doctor_list_res.dart';
import '../other_patient/manage_other_patient_controller.dart';
import '../service/model/service_list_model.dart';
import 'components/appointment_summary_comp.dart';

class BookingFormController extends GetxController {
  int _serviceRequestGeneration = 0;
  int _clinicRequestGeneration = 0;
  int _doctorRequestGeneration = 0;
  int _slotRequestGeneration = 0;
  Rx<Future<RxList<String>>> slotsFuture = Future(() => RxList<String>()).obs;
  RxBool isLoading = false.obs;
  RxBool nextBtnVisible = false.obs;
  RxList<String> slots = RxList();
  RxString selectedDate = DateTime.now().formatApiDateYYYYmmdd().obs;
  RxString selectedSlot = "".obs;

  final ManageOtherPatientController manageOtherPatientController =
      ManageOtherPatientController();

  Rx<UserData> selectedMember = UserData().obs;

  RxList<PlatformFile> medicalReportFiles = RxList();

  BookingReq bookingReq = BookingReq();

  RxBool isLastPageService = false.obs;
  RxBool isLastPageClinic = false.obs;
  RxBool isLastPageDoctor = false.obs;
  RxInt servicePage = 1.obs;
  RxInt clinicPage = 1.obs;
  RxInt doctorPage = 1.obs;

  // Snapshot of the globals taken in onInit, so list filtering doesn't read
  // `currentSelected*` at call time (they may be reset or overwritten later).
  int filterCategoryId = -1;
  int filterSystemServiceId = -1;
  int filterClinicId = -1;
  int filterDoctorId = -1;

  //Service
  Rx<ServiceElement> selectedService = ServiceElement().obs;
  RxList<ServiceElement> serviceList = RxList();

  //Error Service
  RxBool hasErrorFetchingService = false.obs;
  RxString errorMessageService = "".obs;

  //Clinic
  Rx<Clinic> selectedClinic = Clinic(clinicSession: ClinicSession()).obs;
  RxList<Clinic> clinicList = RxList();

  //Error Clinic
  RxBool hasErrorFetchingClinic = false.obs;
  RxString errorMessageClinic = "".obs;

  //Doctor
  Rx<Doctor> selectedDoctor = Doctor().obs;
  RxList<Doctor> doctorList = RxList();

  //Error Clinic
  RxBool hasErrorFetchingDoctor = false.obs;
  RxString errorMessageDoctor = "".obs;

  RxString serviceNameText = "".obs;
  RxString clinicNameText = "".obs;
  RxString doctorNameText = "".obs;
  TextEditingController medicalReportCont = TextEditingController();

  bool get isIndependentBooking => selectedDoctor.value.isIndependent;

  @override
  void onInit() {
    final incomingIndependent = currentSelectedDoctor.value.isIndependent;
    filterCategoryId = currentSelectedService.value.categoryId;
    filterSystemServiceId = currentSelectedService.value.systemServiceId;
    filterClinicId = currentSelectedClinic.value.id;
    filterDoctorId = currentSelectedDoctor.value.doctorId;

    if (!incomingIndependent && !currentSelectedService.value.id.isNegative) {
      log('currentSelectedService.value.name==> ${currentSelectedService.value.name}');
      log('currentSelectedService.value.id==> ${currentSelectedService.value.id}');
      selectedService(currentSelectedService.value);
      serviceNameText(currentSelectedService.value.name);
      getClinicList();
    }

    if (!incomingIndependent && !currentSelectedClinic.value.id.isNegative) {
      log('currentSelectedClinic.value.name==> ${currentSelectedClinic.value.name}');
      log('currentSelectedClinic.value.id==> ${currentSelectedClinic.value.id}');
      selectedClinic(currentSelectedClinic.value);
      clinicNameText(currentSelectedClinic.value.name);
      getDoctorList();
    }

    if (!currentSelectedDoctor.value.doctorId.isNegative) {
      log('currentSelectedDoctor.value.name==> ${currentSelectedDoctor.value.fullName}');
      log('currentSelectedDoctor.value.doctorId==> ${currentSelectedDoctor.value.doctorId}');
      selectedDoctor(currentSelectedDoctor.value);
      doctorNameText(currentSelectedDoctor.value.fullName);
      if (selectedDoctor.value.isIndependent) {
        selectedClinic(Clinic(clinicSession: ClinicSession()));
        clinicNameText("");
        getIndependentService();
      } else {
        getTimeSlot();
      }
    }

    if (!selectedDoctor.value.isIndependent) init();
    super.onInit();
  }

  Future<void> getIndependentService() async {
    isLoading(true);
    try {
      final services = await CoreServiceApis.getIndependentServices(
        doctorId: selectedDoctor.value.id,
      );
      serviceList.assignAll(services);
      if (services.isNotEmpty) {
        selectedService(services.first);
        serviceNameText(services.first.name);
        getTimeSlot();
      }
    } catch (e) {
      log('independent services error $e');
    } finally {
      isLoading(false);
    }
  }

  @override
  void onClose() {
    // The pre-fill globals are consumed by this form; reset them so the next
    // booking session doesn't inherit a stale service/clinic/doctor.
    currentSelectedService(ServiceElement());
    currentSelectedClinic(Clinic(clinicSession: ClinicSession()));
    currentSelectedDoctor(Doctor());
    medicalReportCont.dispose();
    super.onClose();
  }

  Future<void> init({bool showLoader = true}) async {
    if (showLoader) {
      isLoading(true);
    }

    getServiceList();
    await manageOtherPatientController.getOtherPatientList();
  }

  Future<void> handleFilesPickerClick() async {
    final pickedFiles = await pickFiles();
    Set<String> filePathsSet = medicalReportFiles
        .map((file) => file.name.trim().toLowerCase())
        .toSet();
    for (var i = 0; i < pickedFiles.length; i++) {
      if (!filePathsSet.contains(pickedFiles[i].name.trim().toLowerCase())) {
        medicalReportFiles.add(pickedFiles[i]);
      }
    }
  }

  ///Get Service List
  Future<void> getServiceList({String searchText = ""}) async {
    final requestGeneration = ++_serviceRequestGeneration;
    final requestedPage = servicePage.value;
    final requestList =
        requestedPage == 1 ? <ServiceElement>[] : serviceList.toList();
    var isLastPage = false;
    isLoading(true);
    try {
      final value = await CoreServiceApis.getServiceList(
        page: requestedPage,
        serviceList: requestList,
        categoryId: filterCategoryId,
        systemServiceId: filterSystemServiceId,
        clinicId: filterClinicId,
        doctorId: filterDoctorId,
        search: searchText.trim(),
        lastPageCallBack: (p) => isLastPage = p,
      );
      if (requestGeneration != _serviceRequestGeneration) return;
      serviceList.assignAll(value);
      isLastPageService(isLastPage);
      hasErrorFetchingService(false);
    } catch (error) {
      if (requestGeneration != _serviceRequestGeneration) return;
      hasErrorFetchingService(true);
      errorMessageService(
          sanitizeBackendMessage(error, locale.value.somethingWentWrong));
    } finally {
      if (requestGeneration == _serviceRequestGeneration) isLoading(false);
    }
  }

  ///Get Clinic List
  Future<void> getClinicList({String searchText = ""}) async {
    final requestGeneration = ++_clinicRequestGeneration;
    final requestedPage = clinicPage.value;
    final requestList = requestedPage == 1 ? <Clinic>[] : clinicList.toList();
    var isLastPage = false;
    isLoading(true);
    try {
      final value = await CoreServiceApis.getClinics(
        page: requestedPage,
        clinics: requestList,
        serviceId: selectedService.value.id,
        search: searchText.trim(),
        lastPageCallBack: (p) => isLastPage = p,
      );
      if (requestGeneration != _clinicRequestGeneration) return;
      clinicList.assignAll(value);
      isLastPageClinic(isLastPage);
      hasErrorFetchingClinic(false);
    } catch (error) {
      if (requestGeneration != _clinicRequestGeneration) return;
      hasErrorFetchingClinic(true);
      errorMessageClinic(
          sanitizeBackendMessage(error, locale.value.somethingWentWrong));
    } finally {
      if (requestGeneration == _clinicRequestGeneration) isLoading(false);
    }
  }

  void clearDoctorSelection() {
    doctorNameText("");

    /// Clear selected doctor in doctor name field
    selectedDoctor(Doctor());
  }

  ///Get Doctor List
  Future<void> getDoctorList({String searchText = ""}) async {
    final requestGeneration = ++_doctorRequestGeneration;
    final requestedPage = doctorPage.value;
    final requestList = requestedPage == 1 ? <Doctor>[] : doctorList.toList();
    var isLastPage = false;
    isLoading(true);
    try {
      final value = await CoreServiceApis.getDoctors(
        page: requestedPage,
        doctors: requestList,
        clinicId: selectedClinic.value.id,
        serviceId: selectedService.value.id,
        search: searchText.trim(),
        lastPageCallBack: (p) => isLastPage = p,
      );
      if (requestGeneration != _doctorRequestGeneration) return;
      doctorList.assignAll(value);
      isLastPageDoctor(isLastPage);
      hasErrorFetchingDoctor(false);
    } catch (error) {
      if (requestGeneration != _doctorRequestGeneration) return;
      hasErrorFetchingDoctor(true);
      errorMessageDoctor(
          sanitizeBackendMessage(error, locale.value.somethingWentWrong));
    } finally {
      if (requestGeneration == _doctorRequestGeneration) isLoading(false);
    }
  }

  Future<void> getTimeSlot({bool showLoader = true}) async {
    final requestGeneration = ++_slotRequestGeneration;
    final requestSlots = <String>[].obs;
    if (showLoader) {
      isLoading(true);
    }

    /// Get Time Slots Api Call
    await slotsFuture(
      isIndependentBooking
          ? CoreServiceApis.getIndependentTimeSlots(
              slots: requestSlots,
              date: selectedDate.value,
              serviceId: selectedService.value.id,
              doctorId: selectedDoctor.value.id,
            )
          : CoreServiceApis.getTimeSlots(
              slots: requestSlots,
              date: selectedDate.value,
              serviceId: selectedService.value.id,
              clinicId: selectedClinic.value.id,
              doctorId: selectedDoctor.value.doctorId,
            ),
    ).then((value) {
      if (requestGeneration != _slotRequestGeneration) return;
      slots.assignAll(value);
      log('value.length ==> ${value.length}');
    }).catchError((e) {
      isLoading(false);
      log("getTimeSlots error $e");
    }).whenComplete(() {
      if (requestGeneration == _slotRequestGeneration) isLoading(false);
    });
  }

  void selectService(
    ServiceElement service, {
    bool fetchClinics = true,
  }) {
    if (isIndependentBooking) {
      _slotRequestGeneration++;
      selectedService(service);
      serviceNameText(service.name);
      selectedSlot("");
      slots.clear();
      nextBtnVisible(false);
      getTimeSlot();
      return;
    }
    _clinicRequestGeneration++;
    _doctorRequestGeneration++;
    _slotRequestGeneration++;
    selectedService(service);
    serviceNameText(service.name);
    selectedClinic(Clinic(clinicSession: ClinicSession()));
    clinicNameText("");
    clinicList.clear();
    clinicPage(1);
    isLastPageClinic(false);
    selectedDoctor(Doctor());
    doctorNameText("");
    doctorList.clear();
    doctorPage(1);
    isLastPageDoctor(false);
    selectedSlot("");
    slots.clear();
    nextBtnVisible(false);
    if (fetchClinics) getClinicList();
  }

  void selectClinic(
    Clinic clinic, {
    bool fetchDoctors = true,
  }) {
    _doctorRequestGeneration++;
    _slotRequestGeneration++;
    selectedClinic(clinic);
    clinicNameText(clinic.name);
    selectedDoctor(Doctor());
    doctorNameText("");
    doctorList.clear();
    doctorPage(1);
    isLastPageDoctor(false);
    selectedSlot("");
    slots.clear();
    nextBtnVisible(false);
    if (fetchDoctors) getDoctorList();
  }

  void selectDoctor(
    Doctor doctor, {
    bool fetchSlots = true,
  }) {
    _slotRequestGeneration++;
    selectedDoctor(doctor);
    doctorNameText(doctor.fullName);
    selectedSlot("");
    slots.clear();
    nextBtnVisible(false);
    if (fetchSlots) {
      if (doctor.isIndependent) {
        getIndependentService();
      } else {
        getTimeSlot();
      }
    }
  }

  void onDateTimeChange() {
    final appointmentDateTime =
        DateTime.tryParse("${selectedDate.value} ${selectedSlot.value}");
    nextBtnVisible(appointmentDateTime?.isAfter(DateTime.now()) ?? false);
  }

  void handleNextClick(BuildContext context) {
    //BookingReq
    bookingReq.files = medicalReportFiles;
    bookingReq.clinicId = selectedClinic.value.id.toString();
    bookingReq.serviceId = selectedService.value.id.toString();
    bookingReq.isIndependent = isIndependentBooking;
    bookingReq.independentServiceId =
        isIndependentBooking ? selectedService.value.id.toString() : "";
    bookingReq.appointmentDate = selectedDate.value;
    bookingReq.userId = loginUserData.value.id.toString();
    bookingReq.status = StatusConst.pending;
    bookingReq.doctorId = (isIndependentBooking
            ? selectedDoctor.value.id
            : selectedDoctor.value.doctorId)
        .toString();
    bookingReq.appointmentTime = selectedSlot.value;
    bookingReq.description = medicalReportCont.text;
    //
    bookingReq.serviceName = selectedService.value.name;
    bookingReq.doctorName = selectedDoctor.value.fullName;
    bookingReq.clinicName =
        isIndependentBooking ? "" : selectedClinic.value.name;
    bookingReq.location =
        isIndependentBooking ? "" : selectedClinic.value.address;
    bookingReq.totalAmount = totalAmount.toStringAsFixed(2).toDouble();
    bookingReq.isEnableAdvancePayment =
        selectedService.value.isEnableAdvancePayment;
    bookingReq.advancePayableAmount = advancePayableAmount;
    bookingReq.isOnlineService =
        selectedService.value.type.toLowerCase() == ServiceTypeConst.online;
    if (selectedMember.value.id > 0) {
      bookingReq.otherPatientId = selectedMember.value.id.toString();
    } else {
      // bookingReq is reused across Next clicks — clear a previously selected
      // family member so the booking is made for the logged-in user.
      bookingReq.otherPatientId = "";
    }
    showInDialog(
      context,
      contentPadding: EdgeInsets.zero,
      builder: (_) {
        return AppointmentSummaryWidget(bookingData: bookingReq);
      },
    );
  }

  //----------------------------------------Price Calculation-----------------------------------
  AssignDoctor get finalAssignDoctor =>
      selectedService.value.assignDoctor.firstWhere(
        (element) => element.doctorId == selectedDoctor.value.doctorId,
        orElse: () => AssignDoctor(
          priceDetail: PriceDetail(
            servicePrice: selectedService.value.charges,
            serviceAmount: selectedService.value.charges,
            discountAmount: selectedService.value.discountAmount,
            discountType: selectedService.value.discountType,
            discountValue: selectedService.value.discountValue,
            totalAmount: selectedService.value.payableAmount,
            duration: selectedService.value.duration,
          ),
        ),
      );

  double get fixedExclusiveTaxAmount => appConfigs.value.taxData
      .where((element) =>
          (element.taxScope == TaxType.exclusiveTax) &&
          (element.type.toLowerCase().contains(TaxType.FIXED.toLowerCase())))
      .sumByDouble((p0) => p0.value.validate());

  double get percentExclusiveTaxAmount =>
      appConfigs.value.taxData.where((element) {
        return (element.taxScope == TaxType.exclusiveTax) &&
            (element.type
                .toLowerCase()
                .contains(TaxType.PERCENT.toLowerCase()));
      }).sumByDouble((p0) {
        return ((selectedService.value.assignDoctor.isNotEmpty
                ? finalAssignDoctor.priceDetail.serviceAmount *
                    p0.value.validate()
                : selectedService.value.payableAmount * p0.value.validate()) /
            100);
      });

  num get totalExclusiveTax =>
      (fixedExclusiveTaxAmount + percentExclusiveTaxAmount)
          .toStringAsFixed(Constants.DECIMAL_POINT)
          .toDouble();

  num get totalAmount => (selectedService.value.assignDoctor.isNotEmpty
      ? (finalAssignDoctor.priceDetail.totalAmount)
      : (selectedService.value.payableAmount + totalExclusiveTax));

  num get advancePayableAmount =>
      (totalAmount * selectedService.value.advancePaymentAmount) / 100;

  num get remainingAmountAfterService => totalAmount - advancePayableAmount;
}
