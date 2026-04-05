import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:file_picker/file_picker.dart';
import 'package:get/get.dart' hide MultipartFile, Response;
import 'package:http/http.dart';

import 'package:kivicare_patient/screens/other_patient/model/other_patient_list_res.dart';
import 'package:nb_utils/nb_utils.dart';
import '../main.dart';
import '../models/base_response_model.dart';
import '../network/network_utils.dart';
import '../screens/Encounter/model/encounter_list_model.dart';
import '../screens/auth/model/login_response.dart';
import '../screens/booking/model/appointment_detail_res.dart';
import '../screens/booking/model/appointment_invoice_res.dart';
import '../screens/booking/model/appointment_status_model.dart';
import '../screens/booking/model/appointments_res_model.dart';
import '../screens/booking/model/doctor_review_res_model.dart';
import '../screens/booking/model/employee_review_data.dart';
import '../screens/booking/model/encounter_detail_model.dart';
import '../screens/booking/model/save_booking_res.dart';
import '../screens/category/model/category_list_model.dart';
import '../screens/clinic/model/clinic_detail_model.dart';
import '../screens/clinic/model/clinic_gallery_model.dart';
import '../screens/clinic/model/clinics_res_model.dart';
import '../screens/doctor/model/doctor_detail_model.dart';
import '../screens/doctor/model/doctor_list_res.dart';
import '../screens/home/model/system_service_res.dart';
import '../screens/incident_management/model/incident_response_model.dart';
import '../screens/service/model/service_detail_model.dart';
import '../screens/service/model/service_list_model.dart';
import '../screens/slots/appointment_slot_model.dart';
import '../screens/nurse/model/nurse_model.dart';
import '../screens/nurse/model/nurse_request_model.dart';
import '../screens/lab_test/model/lab_test_category_model.dart';
import '../screens/lab_test/model/lab_test_model.dart';
import '../screens/lab_test/model/test_order_model.dart';
import '../screens/request_service/model/request_service_model.dart';
import '../screens/icu/model/hospital_model.dart';
import '../screens/icu/model/icu_admission_model.dart';
import '../screens/call_booking/model/call_doctor_model.dart';
import '../screens/call_booking/model/call_booking_model.dart';
import '../screens/call_booking/model/time_slot_model.dart';
import '../screens/independent_booking/model/independent_doctor_model.dart';
import '../screens/independent_booking/model/independent_booking_model.dart';
import '../screens/radiology/model/radiology_center_model.dart';
import '../models/home_healthcare_provider_model.dart';
import '../screens/lab_test/model/lab_model.dart';
import '../models/governorate_model.dart';
import '../models/city_model.dart';
import '../utils/api_end_points.dart';
import '../utils/app_common.dart';
import '../utils/constants.dart';

class CoreServiceApis {
  static Future<RxList<SystemService>> getSystemService({
    int page = 1,
    int perPage = 10,
    required List<SystemService> systemServiceList,
    Function(bool)? lastPageCallBack,
    int? categoryId,
  }) async {
    String catId = (categoryId != null && categoryId != -1) ? '&category_id=$categoryId' : '';
    final systemServiceListRes = SystemServicesRes.fromJson(await handleResponse(
      await buildHttpResponse("${APIEndPoints.getSystemService}?per_page=$perPage&page=$page$catId", method: HttpMethodType.GET),
    ));
    if (page == 1) systemServiceList.clear();
    systemServiceList.addAll(systemServiceListRes.data);
    lastPageCallBack?.call(systemServiceListRes.data.length != perPage);
    return systemServiceList.obs;
  }

  static Future<RxList<CategoryElement>> getCategoryList({
    int page = 1,
    int perPage = 50,
    required List<CategoryElement> categories,
    Function(bool)? lastPageCallBack,
  }) async {
    final categoryListRes = CategoryListRes.fromJson(await handleResponse(await buildHttpResponse("${APIEndPoints.getCategoryList}?per_page=$perPage&page=$page", method: HttpMethodType.GET)));
    if (page == 1) categories.clear();
    categories.addAll(categoryListRes.data);
    lastPageCallBack?.call(categoryListRes.data.length != perPage);
    return categories.obs;
  }

  static Future<RxList<EncounterElement>> getEncounterList({
    int page = 1,
    int perPage = 10,
    required List<EncounterElement> encounterList,
    Function(bool)? lastPageCallBack,
  }) async {
    final encounterListRes = EncounterListRes.fromJson(await handleResponse(await buildHttpResponse("${APIEndPoints.getEncounterList}?per_page=$perPage&page=$page", method: HttpMethodType.GET)));
    if (page == 1) encounterList.clear();
    encounterList.addAll(encounterListRes.data);
    lastPageCallBack?.call(encounterListRes.data.length != perPage);
    return encounterList.obs;
  }

  static Future<RxList<ServiceElement>> getServiceList({
    int page = 1,
    int perPage = 10,
    required List<ServiceElement> serviceList,
    Function(bool)? lastPageCallBack,
    String search = "",
    String serviceType = "",
    String servicePriceMin = "",
    String servicePriceMax = "",
    int? categoryId,
    int? systemServiceId,
    int? clinicId,
    int? doctorId,
    int isFeatures = -1,
    int isPopulars = -1,
    int enableAdvancePayment = -1,
    String allServices = "",
  }) async {
    String catId = (categoryId != null && categoryId != -1) ? '&category_id=$categoryId' : '';
    String clinicid = (clinicId != null && clinicId != -1) ? '&clinic_id=$clinicId' : '';
    String sysServiceId = (systemServiceId != null && systemServiceId != -1) ? '&system_service_id=$systemServiceId' : '';
    String docId = (doctorId != null && doctorId != -1) ? '&doctor_id=$doctorId' : '';
    String searchService = search.isNotEmpty ? '&search=$search' : '';
    String type = serviceType.isNotEmpty ? '&type=$serviceType' : '';
    String priceMin = servicePriceMin.isNotEmpty ? '&is_price_min=$servicePriceMin' : '';
    String priceMax = servicePriceMax.isNotEmpty ? '&is_price_max=$servicePriceMax' : '';
    String isFeature = isFeatures != -1 ? '&is_features=$isFeatures' : '';
    String isPopular = isPopulars != -1 ? '&is_popular=$isPopulars' : '';
    String isEdvance = enableAdvancePayment != -1 ? '&is_enable_advance_payment=$enableAdvancePayment' : '';
    String totalPage = allServices == 'all' ?'all':perPage.toString();

    final serviceListRes = ServiceListRes.fromJson(await handleResponse(
      await buildHttpResponse("${APIEndPoints.getServiceList}?per_page=$totalPage&page=$page$searchService$catId$sysServiceId$clinicid$docId$isFeature$type$priceMin$priceMax$isEdvance$isPopular", method:
      HttpMethodType.GET),
    ));
    if (page == 1) serviceList.clear();
    serviceList.addAll(serviceListRes.data);
    lastPageCallBack?.call(serviceListRes.data.length != perPage);
    return serviceList.obs;
  }

  static Future<RxList<ServiceElement>> getDoctorServiceList({
    int page = 1,
    int perPage = 10,
    required List<ServiceElement> serviceList,
    Function(bool)? lastPageCallBack,
    int? doctorId,
    String search = "",
  }) async {
    String docId = (doctorId != null && doctorId != -1) ? '&doctor_id=$doctorId' : '';
    String searchService = search.isNotEmpty ? '&search=$search' : '';
    final doctorServiceListRes = ServiceListRes.fromJson(await handleResponse(await buildHttpResponse("${APIEndPoints.getServiceList}?per_page=$perPage&page=$page$docId$searchService", method: HttpMethodType.GET)));
    if (page == 1) serviceList.clear();
    serviceList.addAll(doctorServiceListRes.data);
    lastPageCallBack?.call(doctorServiceListRes.data.length != perPage);
    return serviceList.obs;
  }

  static Future<ServiceDetailModel> getServiceDetail({required int serviceId}) async {
    return ServiceDetailModel.fromJson(await handleResponse(await buildHttpResponse('${APIEndPoints.getServiceDetails}?service_id=$serviceId', method: HttpMethodType.GET)));
  }

  /// Fetch all governorates (no pagination — 27 items max)
  static Future<List<Governorate>> getGovernorates() async {
    final res = GovernorateListResponse.fromJson(await handleResponse(
      await buildHttpResponse(APIEndPoints.governorates, method: HttpMethodType.GET),
    ));
    return res.data;
  }

  /// Fetch cities for a governorate (no pagination — ~50 items max)
  static Future<List<City>> getCities({required int governorateId}) async {
    final res = CityListResponse.fromJson(await handleResponse(
      await buildHttpResponse(
        '${APIEndPoints.cities}?governorate_id=$governorateId',
        method: HttpMethodType.GET,
      ),
    ));
    return res.data;
  }

  static Future<ClinicDetailModel> getClinicDetails({required int clinicId}) async {
    return ClinicDetailModel.fromJson(await handleResponse(await buildHttpResponse('${APIEndPoints.getClinicDetails}?clinic_id=$clinicId', method: HttpMethodType.GET)));
  }

  static Future<DoctorDetailModel> getDoctorDetails({required int doctorId}) async {
    return DoctorDetailModel.fromJson(await handleResponse(await buildHttpResponse('${APIEndPoints.getDoctorDetails}?doctor_id=$doctorId', method: HttpMethodType.GET)));
  }

  static Future<RxList<Clinic>> getClinics({
    int page = 1,
    int perPage = 10,
    required List<Clinic> clinics,
    Function(bool)? lastPageCallBack,
    String servicePriceMin = "",
    String servicePriceMax = "",
    String search = '',
    int? serviceId,
    int? isPopulars = -1,
    int? clinicId,
  }) async {
    String servId = (serviceId != null && serviceId != -1) ? '&service_id=$serviceId' : '';
    String searchClinic = search.isNotEmpty ? '&search=$search' : '';
    String isPopular = isPopulars != -1 ? '&is_popular=$isPopulars' : '';
    String priceMin = servicePriceMin.isNotEmpty ? '&is_price_min=$servicePriceMin' : '';
    String priceMax = servicePriceMax.isNotEmpty ? '&is_price_max=$servicePriceMax' : '';
    String clinicid = (clinicId != null && clinicId != -1) ? '&clinic_id=$clinicId' : '';
    final clinicsRes = ClinicsRes.fromJson(await handleResponse(await buildHttpResponse("${APIEndPoints.getClinicList}?per_page=$perPage&page=$page$servId$searchClinic$priceMin$priceMax$clinicid$isPopular", method: HttpMethodType.GET)));
    if (page == 1) clinics.clear();
    clinics.addAll(clinicsRes.data);
    lastPageCallBack?.call(clinicsRes.data.length != perPage);
    return clinics.obs;
  }

  /// New search method using the new backend clinics/search endpoint.
  static Future<RxList<Clinic>> searchClinics({
    int page = 1,
    int perPage = 20,
    required List<Clinic> clinicList,
    Function(bool)? lastPageCallBack,
    String name = '',
    int? governorateId,
    int? cityId,
    int? specialtyId,
  }) async {
    String nameParam = name.isNotEmpty ? '&name=${Uri.encodeQueryComponent(name)}' : '';
    String govParam = governorateId != null ? '&governorate_id=$governorateId' : '';
    String cityParam = cityId != null ? '&city_id=$cityId' : '';
    String specParam = specialtyId != null ? '&specialty_id=$specialtyId' : '';

    final res = ClinicSearchListResponse.fromJson(await handleResponse(
      await buildHttpResponse(
        '${APIEndPoints.clinicsSearch}?per_page=$perPage&page=$page$nameParam$govParam$cityParam$specParam',
        method: HttpMethodType.GET,
      ),
    ));

    if (page == 1) clinicList.clear();
    clinicList.addAll(res.data);
    lastPageCallBack?.call(res.currentPage >= res.lastPage);

    return clinicList.obs;
  }

  static Future<RxList<GalleryData>> getClinicGalleryList({
    int page = 1,
    int perPage = 10,
    required List<GalleryData> galleryList,
    Function(bool)? lastPageCallBack,
    int clinicId = -1,
  }) async {
    String clncId = clinicId != -1 ? '&clinic_id=$clinicId' : '';
    final galleryListRes = ClinicGalleryModel.fromJson(await handleResponse(await buildHttpResponse("${APIEndPoints.getClinicGallery}?per_page=$perPage&page=$page$clncId", method: HttpMethodType.GET)));
    if (page == 1) galleryList.clear();
    galleryList.addAll(galleryListRes.data);
    lastPageCallBack?.call(galleryListRes.data.length != perPage);
    return galleryList.obs;
  }

  static Future<RxList<Doctor>> getDoctors({
    int page = 1,
    int perPage = 10,
    required List<Doctor> doctors,
    Function(bool)? lastPageCallBack,
    String? doctorRatingMin = '',
    String? doctorRatingMax = '',
    String search = "",
    int clinicId = -1,
    int? serviceId,
    int? isPopulars = -1,
  }) async {

    String clncId = clinicId != -1 ? '&clinic_id=$clinicId' : '';
    String doctorMinRating = doctorRatingMin != '' ? '&is_rating_min=$doctorRatingMin' : '';
    String doctorMaxRating = doctorRatingMax != '' ? '&is_rating_max=$doctorRatingMax' : '';
    String servId = serviceId != null ? '&service_id=$serviceId' : '';
    String searchDoctor = search.isNotEmpty ? '&search=$search' : '';
    String isPopular = isPopulars != -1 ? '&is_popular=$isPopulars' : '';
    final doctorListRes = DoctorListRes.fromJson(await handleResponse(await buildHttpResponse("${APIEndPoints.getDoctorList}?per_page=$perPage&page=$page$clncId$servId$searchDoctor$isPopular$doctorMinRating$doctorMaxRating", method: HttpMethodType.GET)));
    if (page == 1) doctors.clear();
    doctors.addAll(doctorListRes.data);
    lastPageCallBack?.call(doctorListRes.data.length != perPage);
    return doctors.obs;
  }

  /// New search method using the new backend doctors/search endpoint.
  static Future<RxList<Doctor>> searchDoctors({
    int page = 1,
    int perPage = 20,
    required List<Doctor> doctorList,
    Function(bool)? lastPageCallBack,
    String name = '',
    int? governorateId,
    int? cityId,
    int? specialtyId,
    String gender = '',
    double? minPrice,
    double? maxPrice,
  }) async {
    String nameParam = name.isNotEmpty ? '&name=${Uri.encodeQueryComponent(name)}' : '';
    String govParam = governorateId != null ? '&governorate_id=$governorateId' : '';
    String cityParam = cityId != null ? '&city_id=$cityId' : '';
    String specParam = specialtyId != null ? '&specialty_id=$specialtyId' : '';
    String genderParam = gender.isNotEmpty ? '&gender=${Uri.encodeQueryComponent(gender)}' : '';
    String minPriceParam = minPrice != null ? '&min_price=$minPrice' : '';
    String maxPriceParam = maxPrice != null ? '&max_price=$maxPrice' : '';

    final res = DoctorSearchListResponse.fromJson(await handleResponse(
      await buildHttpResponse(
        '${APIEndPoints.doctorsSearch}?per_page=$perPage&page=$page$nameParam$govParam$cityParam$specParam$genderParam$minPriceParam$maxPriceParam',
        method: HttpMethodType.GET,
      ),
    ));

    if (page == 1) doctorList.clear();
    doctorList.addAll(res.data);
    lastPageCallBack?.call(res.currentPage >= res.lastPage);

    return doctorList.obs;
  }

  static Future<RxList<String>> getTimeSlots({
    required RxList<String> slots,
    required String date,
    required int clinicId,
    required int doctorId,
    required int serviceId,
  }) async {
    final timeSlotsRes = TimeSlotsRes.fromJson(await handleResponse(await buildHttpResponse("${APIEndPoints.getTimeSlots}?appointment_date=$date&doctor_id=$doctorId&clinic_id=$clinicId&service_id=$serviceId", method: HttpMethodType.GET)));
    slots(timeSlotsRes.slots);
    return slots;
  }

  static Future<void> bookServiceApi({required Map<String, dynamic> request, List<PlatformFile>? files, required VoidCallback onSuccess, required VoidCallback loaderOff}) async {
    var multiPartRequest = await getMultiPartRequest(APIEndPoints.saveBooking);
    multiPartRequest.fields.addAll(await getMultipartFields(val: request));

    if (files.validate().isNotEmpty) {
      multiPartRequest.files.addAll(await getMultipartImages(files: files.validate(), name: 'file_url'));
    }

    log("Multipart ${jsonEncode(multiPartRequest.fields)}");
    log("Multipart Files ${multiPartRequest.files.map((e) => e.filename)}");
    log("Multipart Extension ${multiPartRequest.files.map((e) => e.filename!.split(".").last)}");
    multiPartRequest.headers.addAll(buildHeaderTokens());

    await sendMultiPartRequest(multiPartRequest, onSuccess: (temp) async {
      log("Response: ${jsonDecode(temp)}");
      // toast(baseResponseModel.message, print: true);
      try {
        saveBookingRes(SaveBookingRes.fromJson(jsonDecode(temp)));
      } catch (e) {
        log('SaveBookingRes.fromJson E: $e');
      }
      onSuccess.call();
    }, onError: (error) {
      toast(error.toString(), print: true);
      loaderOff.call();
    });
  }

  static Future<RxList<AppointmentData>> getAppointmentList({
    String filterByStatus = '',
    String filterByService = '',
    int page = 1,
    String search = '',
    int perPage = Constants.perPageItem,
    required List<AppointmentData> appointments,
    Function(bool)? lastPageCallBack,
  }) async {
    String searchBooking = search.isNotEmpty ? '&search=$search' : '';
    String statusFilter = '';
    if (filterByStatus.isNotEmpty) {
      if (filterByStatus == AppointmentStatus.all.name) {
        statusFilter = '';
      } else if (filterByStatus == AppointmentStatus.upcoming.name) {
        String status = '${filterByStatus}_appointment';
        statusFilter = '&$status';
      } else if (filterByStatus == AppointmentStatus.completed.name) {
        statusFilter = '&status=checkout';
      }
    } else {
      statusFilter = '';
    }
    String serviceFilter = filterByService.isNotEmpty ? '&system_service_name=$filterByService' : '';
    final bookingRes = AppointmentListRes.fromJson(await handleResponse(await buildHttpResponse("${APIEndPoints.getAppointments}?page=$page&per_page=$perPage$statusFilter$serviceFilter$searchBooking", method: HttpMethodType.GET)));
    if (page == 1) appointments.clear();
    appointments.addAll(bookingRes.data.validate());

    lastPageCallBack?.call(bookingRes.data.validate().length != perPage);

    return appointments.obs;
  }

  static Future<AppointmentDetailRes> getAppointmentDetail({
    required int appointmentId,
    String notifyId = "",
  }) async {
    String notificationId = notifyId.trim().isNotEmpty ? '&notification_id=$notifyId' : '';
    return AppointmentDetailRes.fromJson(await handleResponse(await buildHttpResponse("${APIEndPoints.getAppointmentDetail}?appointment_id=$appointmentId$notificationId", method: HttpMethodType.GET)));
  }

  static Future<Rx<AppointmentInvoiceResp>> appointmentInvoice(int appointmentId) async {
    final res = AppointmentInvoiceResp.fromJson(await handleResponse(await buildHttpResponse("${APIEndPoints.downloadInvoice}?id=$appointmentId", method: HttpMethodType.GET)));
    return res.obs;
  }

  static Future<EncounterDetailModel> getEncounterDetail({required int encounterId}) async {
    return EncounterDetailModel.fromJson(await handleResponse(await buildHttpResponse("${APIEndPoints.encounterDashboardDetail}?encounter_id=$encounterId", method: HttpMethodType.GET)));
  }

  static Future<BaseResponseModel> updateStatus({required Map request, required int appointmentId}) async {
    return BaseResponseModel.fromJson(await handleResponse(await buildHttpResponse('${APIEndPoints.updateStatus}/$appointmentId', request: request, method: HttpMethodType.POST)));
  }

  static Future<BaseResponseModel> rescheduleBooking({required Map request}) async {
    return BaseResponseModel.fromJson(await handleResponse(await buildHttpResponse(APIEndPoints.rescheduleBooking, request: request, method: HttpMethodType.POST)));
  }


  static Future<BaseResponseModel> updateReview({required Map request}) async {
    return BaseResponseModel.fromJson(await handleResponse(await buildHttpResponse(APIEndPoints.saveRating, request: request, method: HttpMethodType.POST)));
  }

  static Future<BaseResponseModel> deleteReview({required int id}) async {
    return BaseResponseModel.fromJson(await handleResponse(await buildHttpResponse(APIEndPoints.deleteRating, request: {"id": id}, method: HttpMethodType.POST)));
  }

  static Future<RxList<DoctorReviewData>> getDoctorReviews({
    int page = 1,
    int perPage = Constants.perPageItem,
    required List<DoctorReviewData> reviewList,
    Function(bool)? lastPageCallBack,
    int doctorId = -1,
  }) async {
    String docId = doctorId != -1 ? '&doctor_id=$doctorId' : '';
    final reviewRes = DoctorReviewRes.fromJson(await handleResponse(await buildHttpResponse("${APIEndPoints.getRating}?per_page=$perPage&page=$page$docId", method: HttpMethodType.GET)));
    if (page == 1) reviewList.clear();
    reviewList.addAll(reviewRes.reviewData);
    lastPageCallBack?.call(reviewRes.reviewData.length != perPage);
    return reviewList.obs;
  }

  //Payment
  static Future<BaseResponseModel> savePayment({required Map request}) async {
    return BaseResponseModel.fromJson(await handleResponse(await buildHttpResponse(APIEndPoints.savePayment, request: request, method: HttpMethodType.POST)));
  }

  //Incident

  static Future<RxList<Incident>> getIncidentList({
    required int page,
    int perPage = 10,
    required List<Incident> incidents,
    Function(bool)? lastPageCallBack,
  }) async {
    final res = IncidentResponse.fromJson(await handleResponse(
      await buildHttpResponse("${APIEndPoints.incidenceList}?per_page=$perPage&page=$page", method: HttpMethodType.GET),
    ));

    if (page == 1) incidents.clear();
    incidents.addAll(res.data!.incidents);

    lastPageCallBack?.call(res.data!.incidents.length < perPage);
    return incidents.obs;
  }

  static Future<dynamic> addIncident({
    required String title,
    required String description,
    required String phoneCode,
    required String mobileNumber,
    required String email,
    File? imageFile,
    Function(dynamic)? onSuccess,
  }) async {
    MultipartRequest multiPartRequest = await getMultiPartRequest(APIEndPoints.incidenceSave);

    // Add form fields
    multiPartRequest.fields['title'] = title;
    multiPartRequest.fields['description'] = description;
    multiPartRequest.fields['country_code'] = '+$phoneCode';
    multiPartRequest.fields['phone'] = mobileNumber;
    multiPartRequest.fields['email'] = email;

    // Attach image if present
    if (imageFile != null && imageFile.existsSync()) {
      multiPartRequest.files.add(await MultipartFile.fromPath('file_url', imageFile.path));
    }

    // Add headers
    multiPartRequest.headers.addAll(buildHeaderTokens());

    // Send multipart request
    await sendMultiPartRequest(
      multiPartRequest,
      onSuccess: (data) async {
        onSuccess?.call(data);
        toast(locale.value.successfullyAdded);
      },
      onError: (error) {
        throw error;
      },
    ).catchError((error) {
      throw error;
    });
  }

  static Future<BaseResponseModel> updateIncidentStatus({
    required int incidentId,
    required Map<String, dynamic> request,
  }) async {
    return BaseResponseModel.fromJson(
      await handleResponse(
        await buildHttpResponse(
          "${APIEndPoints.updateIncidentStatus}/$incidentId",
          request: request,
          method: HttpMethodType.POST,
        ),
      ),
    );
  }

  /// Fetch Other Patient List
  static Future<RxList<UserData>> otherMemberPatientList({
    int page = 1,
    int perPage = 10,
    required List<UserData> memberList,
    Function(bool)? lastPageCallBack,
  }) async {
    OtherPatientListRes memberListRes = OtherPatientListRes.fromJson(await handleResponse(await buildHttpResponse(
      "${APIEndPoints.otherMemberPatientList}?per_page=$perPage&page=$page",
      method: HttpMethodType.GET,
    )));
    if (page == 1) memberList.clear();
    memberList.addAll(memberListRes.data);
    lastPageCallBack?.call(memberListRes.data.length != perPage);
    return memberList.obs;
  }

  /// Add/Update Other Patient List
  static Future<BaseResponseModel> addUpdateOtherPatientApi({
    required Map<String, dynamic> request,
    File? profileImage,
  }) async {
    return BaseResponseModel.fromJson(
      await buildMultiPartResponse(
        endPoint: APIEndPoints.addPatient,
        request: request,
        fileKey: UserKeys.profileImage,
        files: profileImage != null ? [profileImage] : [],
      ),
    );
  }

  static Future<BaseResponseModel> deleteMember({required int memberId}) async {
    return BaseResponseModel.fromJson(
      await handleResponse(await buildHttpResponse(
        '${APIEndPoints.deleteOtherMember}/$memberId',
        method: HttpMethodType.POST,
      )),
    );
  }

  // ===== NURSE MODULE =====

  static Future<RxList<Nurse>> getNurseList({
    int page = 1,
    int perPage = 20,
    required List<Nurse> nurseList,
    Function(bool)? lastPageCallBack,
    String search = "",
    String availabilityStatus = "",
    String serviceArea = "",
    String specialization = "",
  }) async {
    String searchParam = search.isNotEmpty ? '&search=${Uri.encodeQueryComponent(search)}' : '';
    String statusParam = availabilityStatus.isNotEmpty ? '&availability_status=${Uri.encodeQueryComponent(availabilityStatus)}' : '';
    String areaParam = serviceArea.isNotEmpty ? '&service_area=${Uri.encodeQueryComponent(serviceArea)}' : '';
    String specParam = specialization.isNotEmpty ? '&specialization=${Uri.encodeQueryComponent(specialization)}' : '';

    final res = NurseListResponse.fromJson(await handleResponse(
      await buildHttpResponse("${APIEndPoints.getNurses}?per_page=$perPage&page=$page$searchParam$statusParam$areaParam$specParam", method: HttpMethodType.GET),
    ));
    if (page == 1) nurseList.clear();
    nurseList.addAll(res.data);
    lastPageCallBack?.call(res.currentPage >= res.lastPage);
    return nurseList.obs;
  }

  /// New search method using the new backend search endpoint.
  /// Keep getNurseList() for backward compatibility.
  static Future<RxList<Nurse>> searchNurses({
    int page = 1,
    int perPage = 20,
    required List<Nurse> nurseList,
    Function(bool)? lastPageCallBack,
    String search = '',
    int? governorateId,
    int? cityId,
    String specialty = '',
    String gender = '',
    String availability = '',
  }) async {
    String searchParam = search.isNotEmpty ? '&search=${Uri.encodeQueryComponent(search)}' : '';
    String govParam = governorateId != null ? '&governorate_id=$governorateId' : '';
    String cityParam = cityId != null ? '&city_id=$cityId' : '';
    String specParam = specialty.isNotEmpty ? '&specialty=${Uri.encodeQueryComponent(specialty)}' : '';
    String genderParam = gender.isNotEmpty ? '&gender=${Uri.encodeQueryComponent(gender)}' : '';
    String availParam = availability.isNotEmpty ? '&availability=${Uri.encodeQueryComponent(availability)}' : '';

    final res = NurseListResponse.fromJson(await handleResponse(
      await buildHttpResponse(
        '${APIEndPoints.nursesSearch}?per_page=$perPage&page=$page$searchParam$govParam$cityParam$specParam$genderParam$availParam',
        method: HttpMethodType.GET,
      ),
    ));

    if (page == 1) nurseList.clear();
    nurseList.addAll(res.data);
    lastPageCallBack?.call(res.currentPage >= res.lastPage);

    return nurseList.obs;
  }

  static Future<Nurse> getNurseDetail({required int nurseId}) async {
    final json = await handleResponse(await buildHttpResponse('${APIEndPoints.getNurseDetail}/$nurseId', method: HttpMethodType.GET));
    return Nurse.fromJson(json["data"] is Map<String, dynamic> ? json["data"] : json);
  }

  static Future<RxList<NurseRequest>> getNurseRequestList({
    int page = 1,
    int perPage = 20,
    required List<NurseRequest> requestList,
    Function(bool)? lastPageCallBack,
    String status = "",
    String search = "",
  }) async {
    String statusParam = status.isNotEmpty ? '&status=${Uri.encodeQueryComponent(status)}' : '';
    String searchParam = search.isNotEmpty ? '&search=${Uri.encodeQueryComponent(search)}' : '';

    final res = NurseRequestListResponse.fromJson(await handleResponse(
      await buildHttpResponse("${APIEndPoints.getNurseRequests}?per_page=$perPage&page=$page$statusParam$searchParam", method: HttpMethodType.GET),
    ));
    if (page == 1) requestList.clear();
    requestList.addAll(res.data);
    lastPageCallBack?.call(res.currentPage >= res.lastPage);
    return requestList.obs;
  }

  static Future<NurseRequest> createNurseRequest({required Map<String, dynamic> request}) async {
    final json = await handleResponse(await buildHttpResponse(APIEndPoints.createNurseRequest, method: HttpMethodType.POST, request: request));
    return NurseRequest.fromJson(json["data"] is Map<String, dynamic> ? json["data"] : json);
  }

  static Future<NurseRequest> getNurseRequestDetail({required int requestId}) async {
    final json = await handleResponse(await buildHttpResponse('${APIEndPoints.getNurseRequestDetail}/$requestId', method: HttpMethodType.GET));
    return NurseRequest.fromJson(json["data"] is Map<String, dynamic> ? json["data"] : json);
  }

  static Future<NurseRequest> updateNurseRequest({required int requestId, required Map<String, dynamic> request}) async {
    final json = await handleResponse(await buildHttpResponse('${APIEndPoints.updateNurseRequest}/$requestId', method: HttpMethodType.PUT, request: request));
    return NurseRequest.fromJson(json["data"] is Map<String, dynamic> ? json["data"] : json);
  }

  static Future<BaseResponseModel> cancelNurseRequest({required int requestId, required Map<String, dynamic> request}) async {
    return BaseResponseModel.fromJson(await handleResponse(await buildHttpResponse('${APIEndPoints.cancelNurseRequest}/$requestId/cancel', method: HttpMethodType.POST, request: request)));
  }

  // ===== LAB TEST MODULE =====

  static Future<List<LabTestCategory>> getLabTestCategories() async {
    final res = LabTestCategoryListResponse.fromJson(await handleResponse(
      await buildHttpResponse(APIEndPoints.labTestCategories, method: HttpMethodType.GET),
    ));
    return res.data;
  }

  static Future<RxList<LabTest>> getLabTestList({
    int page = 1,
    int perPage = 20,
    required List<LabTest> labTestList,
    Function(bool)? lastPageCallBack,
    int? categoryId,
    String department = "",
    String search = "",
  }) async {
    String catParam = (categoryId != null && categoryId != -1) ? '&category_id=$categoryId' : '';
    String deptParam = department.isNotEmpty ? '&department=${Uri.encodeQueryComponent(department)}' : '';
    String searchParam = search.isNotEmpty ? '&search=${Uri.encodeQueryComponent(search)}' : '';

    final res = LabTestListResponse.fromJson(await handleResponse(
      await buildHttpResponse("${APIEndPoints.labTests}?per_page=$perPage&page=$page$catParam$deptParam$searchParam", method: HttpMethodType.GET),
    ));
    if (page == 1) labTestList.clear();
    labTestList.addAll(res.data);
    lastPageCallBack?.call(res.currentPage >= res.lastPage);
    return labTestList.obs;
  }

  /// New search method using the new backend labs/search endpoint.
  static Future<RxList<LabTest>> searchLabs({
    int page = 1,
    int perPage = 20,
    required List<LabTest> labTestList,
    Function(bool)? lastPageCallBack,
    String testName = '',
    int? governorateId,
    int? cityId,
    String department = '',
    int? categoryId,
  }) async {
    String nameParam = testName.isNotEmpty ? '&test_name=${Uri.encodeQueryComponent(testName)}' : '';
    String govParam = governorateId != null ? '&governorate_id=$governorateId' : '';
    String cityParam = cityId != null ? '&city_id=$cityId' : '';
    String deptParam = department.isNotEmpty ? '&department=${Uri.encodeQueryComponent(department)}' : '';
    String catParam = categoryId != null ? '&category_id=$categoryId' : '';

    final res = LabTestListResponse.fromJson(await handleResponse(
      await buildHttpResponse(
        '${APIEndPoints.labsSearch}?per_page=$perPage&page=$page$nameParam$govParam$cityParam$deptParam$catParam',
        method: HttpMethodType.GET,
      ),
    ));

    if (page == 1) labTestList.clear();
    labTestList.addAll(res.data);
    lastPageCallBack?.call(res.currentPage >= res.lastPage);

    return labTestList.obs;
  }

  static Future<LabTest> getLabTestDetail({required int testId}) async {
    final json = await handleResponse(await buildHttpResponse(APIEndPoints.labTestDetail(testId), method: HttpMethodType.GET));
    return LabTest.fromJson(json["data"] is Map<String, dynamic> ? json["data"] : json);
  }

  static Future<RxList<TestOrder>> getTestOrderList({
    int page = 1,
    int perPage = 20,
    required List<TestOrder> orderList,
    Function(bool)? lastPageCallBack,
    String status = "",
  }) async {
    String statusParam = status.isNotEmpty ? '&status=${Uri.encodeQueryComponent(status)}' : '';

    final res = TestOrderListResponse.fromJson(await handleResponse(
      await buildHttpResponse("${APIEndPoints.testOrders}?per_page=$perPage&page=$page$statusParam", method: HttpMethodType.GET),
    ));
    if (page == 1) orderList.clear();
    orderList.addAll(res.data);
    lastPageCallBack?.call(res.currentPage >= res.lastPage);
    return orderList.obs;
  }

  static Future<TestOrder> createTestOrder({required Map<String, dynamic> request}) async {
    final json = await handleResponse(await buildHttpResponse(APIEndPoints.testOrders, method: HttpMethodType.POST, request: request));
    return TestOrder.fromJson(json["data"] is Map<String, dynamic> ? json["data"] : json);
  }

  static Future<TestOrder> getTestOrderDetail({required int orderId}) async {
    final json = await handleResponse(await buildHttpResponse(APIEndPoints.testOrderDetail(orderId), method: HttpMethodType.GET));
    return TestOrder.fromJson(json["data"] is Map<String, dynamic> ? json["data"] : json);
  }

  static Future<BaseResponseModel> cancelTestOrder({required int orderId, required Map<String, dynamic> request}) async {
    return BaseResponseModel.fromJson(await handleResponse(await buildHttpResponse(APIEndPoints.testOrderCancel(orderId), method: HttpMethodType.POST, request: request)));
  }

  static Future<Response> downloadTestReport({required int orderId}) async {
    return await buildHttpResponse(APIEndPoints.testOrderReportDownload(orderId), method: HttpMethodType.GET);
  }

  // ===== LABS BROWSE =====

  static Future<RxList<Lab>> searchLabFacilities({
    int page = 1,
    int perPage = 15,
    required List<Lab> labList,
    Function(bool)? lastPageCallBack,
    String testName = '',
    int? governorateId,
    int? cityId,
  }) async {
    String nameParam = testName.isNotEmpty ? '&test_name=${Uri.encodeQueryComponent(testName)}' : '';
    String govParam = governorateId != null ? '&governorate_id=$governorateId' : '';
    String cityParam = cityId != null ? '&city_id=$cityId' : '';

    final res = LabListResponse.fromJson(await handleResponse(
      await buildHttpResponse(
        '${APIEndPoints.labsSearch}?per_page=$perPage&page=$page$nameParam$govParam$cityParam',
        method: HttpMethodType.GET,
      ),
    ));

    if (page == 1) labList.clear();
    labList.addAll(res.data);
    lastPageCallBack?.call(res.currentPage >= res.lastPage);

    return labList.obs;
  }

  // ===== RADIOLOGY CENTERS BROWSE =====

  static Future<RxList<RadiologyCenter>> searchRadiologyCenters({
    int page = 1,
    int perPage = 15,
    required List<RadiologyCenter> centerList,
    Function(bool)? lastPageCallBack,
    String scanType = '',
    int? governorateId,
    int? cityId,
  }) async {
    String scanParam = scanType.isNotEmpty ? '&scan_type=${Uri.encodeQueryComponent(scanType)}' : '';
    String govParam = governorateId != null ? '&governorate_id=$governorateId' : '';
    String cityParam = cityId != null ? '&city_id=$cityId' : '';

    final res = RadiologyCenterListResponse.fromJson(await handleResponse(
      await buildHttpResponse(
        '${APIEndPoints.radiologySearch}?per_page=$perPage&page=$page$scanParam$govParam$cityParam',
        method: HttpMethodType.GET,
      ),
    ));

    if (page == 1) centerList.clear();
    centerList.addAll(res.data);
    lastPageCallBack?.call(res.currentPage >= res.lastPage);

    return centerList.obs;
  }

  // ===== REQUEST SERVICE MODULE =====

  static Future<RequestService> saveRequestService({required Map<String, dynamic> request}) async {
    final json = await handleResponse(await buildHttpResponse(APIEndPoints.saveRequestService, method: HttpMethodType.POST, request: request));
    return RequestService.fromJson(json["data"] is Map<String, dynamic> ? json["data"] : json);
  }

  static Future<RxList<RequestService>> getRequestServiceList({
    int page = 1,
    int perPage = 20,
    required List<RequestService> serviceList,
    Function(bool)? lastPageCallBack,
    String isStatus = "",
    String search = "",
  }) async {
    String statusParam = isStatus.isNotEmpty ? '&is_status=${Uri.encodeQueryComponent(isStatus)}' : '';
    String searchParam = search.isNotEmpty ? '&search=${Uri.encodeQueryComponent(search)}' : '';

    final res = RequestServiceListResponse.fromJson(await handleResponse(
      await buildHttpResponse("${APIEndPoints.getRequestService}?per_page=$perPage&page=$page$statusParam$searchParam", method: HttpMethodType.GET),
    ));
    if (page == 1) serviceList.clear();
    serviceList.addAll(res.data);
    lastPageCallBack?.call(res.currentPage >= res.lastPage);
    return serviceList.obs;
  }

  // ===== ICU ADMISSIONS MODULE =====

  static Future<RxList<Hospital>> getHospitalList({
    int page = 1,
    int perPage = 20,
    required List<Hospital> hospitalList,
    Function(bool)? lastPageCallBack,
    String city = "",
    String specialty = "",
    String ventilator = "",
    String insurance = "",
    String search = "",
  }) async {
    String cityParam = city.isNotEmpty ? '&city=${Uri.encodeQueryComponent(city)}' : '';
    String specParam = specialty.isNotEmpty ? '&specialty=${Uri.encodeQueryComponent(specialty)}' : '';
    String ventParam = ventilator.isNotEmpty ? '&ventilator=${Uri.encodeQueryComponent(ventilator)}' : '';
    String insParam = insurance.isNotEmpty ? '&insurance=${Uri.encodeQueryComponent(insurance)}' : '';
    String searchParam = search.isNotEmpty ? '&search=${Uri.encodeQueryComponent(search)}' : '';

    final res = HospitalListResponse.fromJson(await handleResponse(
      await buildHttpResponse("${APIEndPoints.getHospitals}?per_page=$perPage&page=$page$cityParam$specParam$ventParam$insParam$searchParam", method: HttpMethodType.GET),
    ));
    if (page == 1) hospitalList.clear();
    hospitalList.addAll(res.data);
    lastPageCallBack?.call(res.currentPage >= res.lastPage);
    return hospitalList.obs;
  }

  static Future<Hospital> getHospitalDetail({required int hospitalId}) async {
    final json = await handleResponse(await buildHttpResponse('${APIEndPoints.getHospitalDetail}/$hospitalId', method: HttpMethodType.GET));
    return Hospital.fromJson(json["data"] is Map<String, dynamic> ? json["data"] : json);
  }

  static Future<RxList<IcuDepartment>> getIcuDepartmentList({
    int page = 1,
    int perPage = 20,
    required List<IcuDepartment> departmentList,
    Function(bool)? lastPageCallBack,
    int? hospitalId,
    String specialty = "",
    String available = "",
    String ventilator = "",
  }) async {
    String hospParam = (hospitalId != null && hospitalId != -1) ? '&hospital_id=$hospitalId' : '';
    String specParam = specialty.isNotEmpty ? '&specialty=${Uri.encodeQueryComponent(specialty)}' : '';
    String availParam = available.isNotEmpty ? '&available=${Uri.encodeQueryComponent(available)}' : '';
    String ventParam = ventilator.isNotEmpty ? '&ventilator=${Uri.encodeQueryComponent(ventilator)}' : '';

    final res = IcuDepartmentListResponse.fromJson(await handleResponse(
      await buildHttpResponse("${APIEndPoints.getIcuDepartments}?per_page=$perPage&page=$page$hospParam$specParam$availParam$ventParam", method: HttpMethodType.GET),
    ));
    if (page == 1) departmentList.clear();
    departmentList.addAll(res.data);
    lastPageCallBack?.call(res.currentPage >= res.lastPage);
    return departmentList.obs;
  }

  static Future<RxList<IcuAdmissionRequest>> getIcuAdmissionList({
    int page = 1,
    int perPage = 20,
    required List<IcuAdmissionRequest> admissionList,
    Function(bool)? lastPageCallBack,
    String status = "",
  }) async {
    String statusParam = status.isNotEmpty ? '&status=${Uri.encodeQueryComponent(status)}' : '';

    final res = IcuAdmissionListResponse.fromJson(await handleResponse(
      await buildHttpResponse("${APIEndPoints.getIcuAdmissionRequests}?per_page=$perPage&page=$page$statusParam", method: HttpMethodType.GET),
    ));
    if (page == 1) admissionList.clear();
    admissionList.addAll(res.data);
    lastPageCallBack?.call(res.currentPage >= res.lastPage);
    return admissionList.obs;
  }

  static Future<IcuAdmissionRequest> createIcuAdmission({
    required Map<String, dynamic> request,
    List<File>? medicalReports,
  }) async {
    var multiPartRequest = await getMultiPartRequest(APIEndPoints.createIcuAdmissionRequest);
    multiPartRequest.headers.addAll(buildHeaderTokens());
    multiPartRequest.fields.addAll(await getMultipartFields(val: request));

    if (medicalReports != null && medicalReports.isNotEmpty) {
      for (int i = 0; i < medicalReports.length; i++) {
        if (medicalReports[i].path.isNotEmpty) {
          multiPartRequest.files.add(await MultipartFile.fromPath('medical_reports[$i]', medicalReports[i].path));
        }
      }
    }

    Response response = await Response.fromStream(await multiPartRequest.send());

    apiPrint(
      url: multiPartRequest.url.toString(),
      headers: jsonEncode(multiPartRequest.headers),
      request: jsonEncode(multiPartRequest.fields),
      hasRequest: true,
      statusCode: response.statusCode,
      responseBody: response.body,
      methodtype: "MultiPart",
    );

    final json = await handleResponse(response);
    return IcuAdmissionRequest.fromJson(json["data"] is Map<String, dynamic> ? json["data"] : json);
  }

  static Future<IcuAdmissionRequest> getIcuAdmissionDetail({required int admissionId}) async {
    final json = await handleResponse(await buildHttpResponse('${APIEndPoints.getIcuAdmissionRequestDetail}/$admissionId', method: HttpMethodType.GET));
    return IcuAdmissionRequest.fromJson(json["data"] is Map<String, dynamic> ? json["data"] : json);
  }

  static Future<BaseResponseModel> cancelIcuAdmission({required int admissionId, required Map<String, dynamic> request}) async {
    return BaseResponseModel.fromJson(await handleResponse(await buildHttpResponse('${APIEndPoints.cancelIcuAdmissionRequest}/$admissionId/cancel', method: HttpMethodType.POST, request: request)));
  }

  // ===== CALL BOOKING MODULE =====

  static Future<RxList<CallDoctor>> getCallDoctorList({
    int page = 1,
    int perPage = 20,
    required List<CallDoctor> doctorList,
    Function(bool)? lastPageCallBack,
    String search = "",
  }) async {
    String searchParam = search.isNotEmpty ? '&search=${Uri.encodeQueryComponent(search)}' : '';

    final res = CallDoctorListResponse.fromJson(await handleResponse(
      await buildHttpResponse("${APIEndPoints.getCallDoctors}?per_page=$perPage&page=$page$searchParam", method: HttpMethodType.GET),
    ));
    if (page == 1) doctorList.clear();
    doctorList.addAll(res.data);
    lastPageCallBack?.call(res.currentPage >= res.lastPage);
    return doctorList.obs;
  }

  static Future<List<CallService>> getCallDoctorServices({required int doctorId}) async {
    final json = await handleResponse(await buildHttpResponse('${APIEndPoints.getCallDoctorServices}/$doctorId/services', method: HttpMethodType.GET));
    if (json["data"] is List) {
      return List<CallService>.from(json["data"].map((x) => CallService.fromJson(x)));
    }
    return [];
  }

  static Future<List<TimeSlot>> getCallSlots({required int doctorId, required Map<String, dynamic> request}) async {
    final json = await handleResponse(await buildHttpResponse('${APIEndPoints.getCallSlots}/$doctorId/slots', method: HttpMethodType.POST, request: request));
    if (json["data"] is List) {
      return List<TimeSlot>.from(json["data"].map((x) => TimeSlot.fromJson(x)));
    }
    return [];
  }

  static Future<CallBooking> createCallBooking({required Map<String, dynamic> request}) async {
    final json = await handleResponse(await buildHttpResponse(APIEndPoints.createCallBooking, method: HttpMethodType.POST, request: request));
    final bookingData = json["data"] is Map<String, dynamic> ? Map<String, dynamic>.from(json["data"]) : <String, dynamic>{};

    // Extract root-level fields into booking data if present
    if (json["meeting_link"] is String) bookingData["meeting_link"] = json["meeting_link"];
    if (json["call_type"] is String) bookingData["call_type"] = json["call_type"];
    if (json["service_name"] is String) bookingData["service_name"] = json["service_name"];
    if (json["duration"] is int) bookingData["duration"] = json["duration"];
    if (json["total_amount"] is num) bookingData["total_amount"] = json["total_amount"];

    return CallBooking.fromJson(bookingData.isNotEmpty ? bookingData : json);
  }

  static Future<RxList<CallBooking>> getCallBookingList({
    int page = 1,
    int perPage = 20,
    required List<CallBooking> bookingList,
    Function(bool)? lastPageCallBack,
    String status = "",
  }) async {
    String statusParam = status.isNotEmpty ? '&status=${Uri.encodeQueryComponent(status)}' : '';

    final res = CallBookingListResponse.fromJson(await handleResponse(
      await buildHttpResponse("${APIEndPoints.getCallBookings}?per_page=$perPage&page=$page$statusParam", method: HttpMethodType.GET),
    ));
    if (page == 1) bookingList.clear();
    bookingList.addAll(res.data);
    lastPageCallBack?.call(res.currentPage >= res.lastPage);
    return bookingList.obs;
  }

  // ===== INDEPENDENT DOCTOR BOOKING MODULE =====

  static Future<RxList<IndependentDoctor>> getIndependentDoctorList({
    int page = 1,
    int perPage = 20,
    required List<IndependentDoctor> doctorList,
    Function(bool)? lastPageCallBack,
    String search = "",
  }) async {
    String searchParam = search.isNotEmpty ? '&search=${Uri.encodeQueryComponent(search)}' : '';

    final res = IndependentDoctorListResponse.fromJson(await handleResponse(
      await buildHttpResponse("${APIEndPoints.getIndependentDoctors}?per_page=$perPage&page=$page$searchParam", method: HttpMethodType.GET),
    ));
    if (page == 1) doctorList.clear();
    doctorList.addAll(res.data);
    lastPageCallBack?.call(res.currentPage >= res.lastPage);
    return doctorList.obs;
  }

  static Future<List<IndependentService>> getIndependentDoctorServices({required int doctorId}) async {
    final json = await handleResponse(await buildHttpResponse('${APIEndPoints.getIndependentDoctorServices}/$doctorId/services', method: HttpMethodType.GET));
    if (json["data"] is List) {
      return List<IndependentService>.from(json["data"].map((x) => IndependentService.fromJson(x)));
    }
    return [];
  }

  static Future<List<TimeSlot>> getIndependentSlots({required int doctorId, required Map<String, dynamic> request}) async {
    final json = await handleResponse(await buildHttpResponse('${APIEndPoints.getIndependentSlots}/$doctorId/slots', method: HttpMethodType.POST, request: request));
    if (json["data"] is List) {
      return List<TimeSlot>.from(json["data"].map((x) => TimeSlot.fromJson(x)));
    }
    return [];
  }

  static Future<IndependentBooking> createIndependentBooking({required Map<String, dynamic> request}) async {
    final json = await handleResponse(await buildHttpResponse(APIEndPoints.createIndependentBooking, method: HttpMethodType.POST, request: request));
    final bookingData = json["data"] is Map<String, dynamic> ? Map<String, dynamic>.from(json["data"]) : <String, dynamic>{};

    // Extract root-level fields into booking data if present
    if (json["service_name"] is String) bookingData["service_name"] = json["service_name"];
    if (json["duration"] is int) bookingData["duration"] = json["duration"];
    if (json["total_amount"] is num) bookingData["total_amount"] = json["total_amount"];

    return IndependentBooking.fromJson(bookingData.isNotEmpty ? bookingData : json);
  }

  static Future<RxList<IndependentBooking>> getIndependentBookingList({
    int page = 1,
    int perPage = 20,
    required List<IndependentBooking> bookingList,
    Function(bool)? lastPageCallBack,
    String status = "",
  }) async {
    String statusParam = status.isNotEmpty ? '&status=${Uri.encodeQueryComponent(status)}' : '';

    final res = IndependentBookingListResponse.fromJson(await handleResponse(
      await buildHttpResponse("${APIEndPoints.getIndependentBookings}?per_page=$perPage&page=$page$statusParam", method: HttpMethodType.GET),
    ));
    if (page == 1) bookingList.clear();
    bookingList.addAll(res.data);
    lastPageCallBack?.call(res.currentPage >= res.lastPage);
    return bookingList.obs;
  }

  // ===== HOME HEALTHCARE MODULE =====

  static Future<RxList<HomeHealthcareProvider>> searchHomeHealthcare({
    int page = 1,
    int perPage = 15,
    required List<HomeHealthcareProvider> providerList,
    Function(bool)? lastPageCallBack,
    int? governorateId,
    int? cityId,
    String serviceType = '',
  }) async {
    String govParam = governorateId != null ? '&governorate_id=$governorateId' : '';
    String cityParam = cityId != null ? '&city_id=$cityId' : '';
    String typeParam = serviceType.isNotEmpty ? '&service_type=${Uri.encodeQueryComponent(serviceType)}' : '';

    final res = HomeHealthcareListResponse.fromJson(await handleResponse(
      await buildHttpResponse(
        '${APIEndPoints.homeHealthcareSearch}?per_page=$perPage&page=$page$govParam$cityParam$typeParam',
        method: HttpMethodType.GET,
      ),
    ));

    if (page == 1) providerList.clear();
    providerList.addAll(res.data);
    lastPageCallBack?.call(res.currentPage >= res.lastPage);

    return providerList.obs;
  }
}