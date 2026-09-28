import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:file_picker/file_picker.dart';
import 'package:get/get.dart' hide MultipartFile;
import 'package:http/http.dart';

import 'package:kivicare_patient/screens/other_patient/model/other_patient_list_res.dart';
import 'package:nb_utils/nb_utils.dart';
import '../models/base_response_model.dart';
import '../network/network_utils.dart';
import '../network/critical_operation.dart';
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
    String catId = (categoryId != null && categoryId != -1)
        ? '&category_id=$categoryId'
        : '';
    final systemServiceListRes =
        SystemServicesRes.fromJson(await handleResponse(
      await buildHttpResponse(
          "${APIEndPoints.getSystemService}?per_page=$perPage&page=$page$catId",
          method: HttpMethodType.GET),
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
    String search = "",
  }) async {
    final endpoint = endpointWithQuery(APIEndPoints.getCategoryList, {
      'per_page': perPage,
      'page': page,
      'search': search.isEmpty ? null : search,
    });
    final categoryListRes = CategoryListRes.fromJson(await handleResponse(
        await buildHttpResponse(endpoint, method: HttpMethodType.GET)));
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
    final encounterListRes = EncounterListRes.fromJson(await handleResponse(
        await buildHttpResponse(
            "${APIEndPoints.getEncounterList}?per_page=$perPage&page=$page",
            method: HttpMethodType.GET)));
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
    int? governorateId,
    int? cityId,
    int isFeatures = -1,
    int isPopulars = -1,
    int enableAdvancePayment = -1,
    String allServices = "",
  }) async {
    String totalPage = allServices == 'all' ? 'all' : perPage.toString();
    final endpoint = endpointWithQuery(APIEndPoints.getServiceList, {
      'per_page': totalPage,
      'page': page,
      'search': search.isEmpty ? null : search,
      'category_id': categoryId != null && categoryId != -1 ? categoryId : null,
      'system_service_id': systemServiceId != null && systemServiceId != -1
          ? systemServiceId
          : null,
      'clinic_id': clinicId != null && clinicId != -1 ? clinicId : null,
      'doctor_id': doctorId != null && doctorId != -1 ? doctorId : null,
      'governorate_id': governorateId,
      'city_id': cityId,
      'is_featured': isFeatures != -1 ? isFeatures : null,
      'type': serviceType.isEmpty ? null : serviceType,
      'is_price_min': servicePriceMin.isEmpty ? null : servicePriceMin,
      'is_price_max': servicePriceMax.isEmpty ? null : servicePriceMax,
      'is_enable_advance_payment':
          enableAdvancePayment != -1 ? enableAdvancePayment : null,
      'is_popular': isPopulars != -1 ? isPopulars : null,
    });

    final serviceListRes = ServiceListRes.fromJson(await handleResponse(
      await buildHttpResponse(endpoint, method: HttpMethodType.GET),
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
    String docId =
        (doctorId != null && doctorId != -1) ? '&doctor_id=$doctorId' : '';
    String searchService = search.isNotEmpty ? '&search=$search' : '';
    final doctorServiceListRes = ServiceListRes.fromJson(await handleResponse(
        await buildHttpResponse(
            "${APIEndPoints.getServiceList}?per_page=$perPage&page=$page$docId$searchService",
            method: HttpMethodType.GET)));
    if (page == 1) serviceList.clear();
    serviceList.addAll(doctorServiceListRes.data);
    lastPageCallBack?.call(doctorServiceListRes.data.length != perPage);
    return serviceList.obs;
  }

  static Future<ServiceDetailModel> getServiceDetail(
      {required int serviceId}) async {
    return ServiceDetailModel.fromJson(await handleResponse(
        await buildHttpResponse(
            '${APIEndPoints.getServiceDetails}?service_id=$serviceId',
            method: HttpMethodType.GET)));
  }

  static Future<ClinicDetailModel> getClinicDetails(
      {required int clinicId}) async {
    return ClinicDetailModel.fromJson(await handleResponse(
        await buildHttpResponse(
            '${APIEndPoints.getClinicDetails}?clinic_id=$clinicId',
            method: HttpMethodType.GET)));
  }

  static Future<DoctorDetailModel> getDoctorDetails(
      {required int doctorId}) async {
    return DoctorDetailModel.fromJson(await handleResponse(
        await buildHttpResponse('${APIEndPoints.getDoctorDetails}/$doctorId',
            method: HttpMethodType.GET)));
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
    int? governorateId,
    int? cityId,
  }) async {
    final endpoint = endpointWithQuery(APIEndPoints.getClinicList, {
      'per_page': perPage,
      'page': page,
      'service_id': serviceId != null && serviceId != -1 ? serviceId : null,
      'search': search.isEmpty ? null : search,
      'is_popular': isPopulars != -1 ? isPopulars : null,
      'is_price_min': servicePriceMin.isEmpty ? null : servicePriceMin,
      'is_price_max': servicePriceMax.isEmpty ? null : servicePriceMax,
      'clinic_id': clinicId != null && clinicId != -1 ? clinicId : null,
      'governorate_id': governorateId,
      'city_id': cityId,
    });
    final clinicsRes = ClinicsRes.fromJson(await handleResponse(
      await buildHttpResponse(endpoint, method: HttpMethodType.GET),
    ));
    if (page == 1) clinics.clear();
    clinics.addAll(clinicsRes.data);
    lastPageCallBack?.call(clinicsRes.data.length != perPage);
    return clinics.obs;
  }

  static Future<RxList<GalleryData>> getClinicGalleryList({
    int page = 1,
    int perPage = 10,
    required List<GalleryData> galleryList,
    Function(bool)? lastPageCallBack,
    int clinicId = -1,
  }) async {
    String clncId = clinicId != -1 ? '&clinic_id=$clinicId' : '';
    final galleryListRes = ClinicGalleryModel.fromJson(await handleResponse(
        await buildHttpResponse(
            "${APIEndPoints.getClinicGallery}?per_page=$perPage&page=$page$clncId",
            method: HttpMethodType.GET)));
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
    int? governorateId,
    int? cityId,
  }) async {
    final endpoint = endpointWithQuery(APIEndPoints.getDoctorList, {
      'per_page': perPage,
      'page': page,
      'clinic_id': clinicId != -1 ? clinicId : null,
      'service_id': serviceId,
      'search': search.isEmpty ? null : search,
      'is_popular': isPopulars != -1 ? isPopulars : null,
      'is_rating_min':
          doctorRatingMin?.isNotEmpty == true ? doctorRatingMin : null,
      'is_rating_max':
          doctorRatingMax?.isNotEmpty == true ? doctorRatingMax : null,
      'governorate_id': governorateId,
      'city_id': cityId,
    });
    final doctorListRes = DoctorListRes.fromJson(await handleResponse(
      await buildHttpResponse(endpoint, method: HttpMethodType.GET),
    ));
    if (page == 1) doctors.clear();
    doctors.addAll(doctorListRes.data);
    lastPageCallBack?.call(doctorListRes.data.length != perPage);
    return doctors.obs;
  }

  static Future<RxList<String>> getTimeSlots({
    required RxList<String> slots,
    required String date,
    required int clinicId,
    required int doctorId,
    required int serviceId,
  }) async {
    final timeSlotsRes = TimeSlotsRes.fromJson(await handleResponse(
        await buildHttpResponse(
            "${APIEndPoints.getTimeSlots}?appointment_date=$date&doctor_id=$doctorId&clinic_id=$clinicId&service_id=$serviceId",
            method: HttpMethodType.GET)));
    slots(timeSlotsRes.slots);
    return slots;
  }

  static Future<RxList<ServiceElement>> getIndependentServices({
    required int doctorId,
  }) async {
    final response = await buildHttpResponse(
      '${APIEndPoints.independentDoctors}/$doctorId/services',
      method: HttpMethodType.GET,
    );
    final parsed = ServiceListRes.fromJson(await handleResponse(response));
    return parsed.data.obs;
  }

  static Future<RxList<String>> getIndependentTimeSlots({
    required RxList<String> slots,
    required int doctorId,
    required int serviceId,
    required String date,
  }) async {
    final response = await buildHttpResponse(
      '${APIEndPoints.independentDoctors}/$doctorId/slots',
      method: HttpMethodType.POST,
      request: {
        'appointment_date': date,
        'independent_service_id': serviceId,
      },
    );
    final json = await handleResponse(response);
    final data = json is Map<String, dynamic> ? json['data'] : null;
    slots.assignAll(data is List
        ? data
            .map((value) => value is Map ? '${value['value'] ?? ''}' : '$value')
            .where((value) => value.isNotEmpty)
        : const <String>[]);
    return slots;
  }

  static Future<void> bookServiceApi(
      {required Map<String, dynamic> request,
      List<PlatformFile>? files,
      required String idempotencyKey,
      required VoidCallback onSuccess,
      required VoidCallback loaderOff}) async {
    var multiPartRequest = await getMultiPartRequest(APIEndPoints.saveBooking);
    multiPartRequest.fields.addAll(await getMultipartFields(val: request));

    if (files.validate().isNotEmpty) {
      multiPartRequest.files.addAll(
          await getMultipartImages(files: files.validate(), name: 'file_url'));
    }

    multiPartRequest.headers.addAll({
      ...buildHeaderTokens(),
      ...criticalOperationHeaders(idempotencyKey),
    });

    Object? submissionError;
    await sendMultiPartRequest(multiPartRequest, onSuccess: (temp) async {
      try {
        final booking = parseBookingSubmissionResponse(temp);
        saveBookingRes(booking);
        onSuccess.call();
      } on Object {
        rethrow;
      }
    }, onError: (error) {
      submissionError = error;
    });
    if (submissionError != null) throw submissionError!;
  }

  static Future<SaveBookingRes> bookIndependentService({
    required Map<String, dynamic> request,
    required String idempotencyKey,
  }) async {
    final response = await buildHttpResponse(
      APIEndPoints.independentBooking,
      method: HttpMethodType.POST,
      request: request,
      header: {
        ...buildHeaderTokens(),
        ...criticalOperationHeaders(idempotencyKey),
      },
    );
    return parseBookingSubmissionResponse(await handleResponse(response));
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
    String serviceFilter = filterByService.isNotEmpty
        ? '&system_service_name=$filterByService'
        : '';
    final bookingRes = AppointmentListRes.fromJson(await handleResponse(
        await buildHttpResponse(
            "${APIEndPoints.getAppointments}?page=$page&per_page=$perPage$statusFilter$serviceFilter$searchBooking",
            method: HttpMethodType.GET)));
    if (page == 1) appointments.clear();
    appointments.addAll(bookingRes.data.validate());

    lastPageCallBack?.call(bookingRes.data.validate().length != perPage);

    return appointments.obs;
  }

  static Future<AppointmentDetailRes> getAppointmentDetail({
    required int appointmentId,
    String notifyId = "",
  }) async {
    String notificationId =
        notifyId.trim().isNotEmpty ? '&notification_id=$notifyId' : '';
    return AppointmentDetailRes.fromJson(await handleResponse(
        await buildHttpResponse(
            "${APIEndPoints.getAppointmentDetail}?appointment_id=$appointmentId$notificationId",
            method: HttpMethodType.GET)));
  }

  static Future<Rx<AppointmentInvoiceResp>> appointmentInvoice(
      int appointmentId) async {
    final res = AppointmentInvoiceResp.fromJson(await handleResponse(
        await buildHttpResponse(
            "${APIEndPoints.downloadInvoice}?id=$appointmentId",
            method: HttpMethodType.GET)));
    return res.obs;
  }

  static Future<EncounterDetailModel> getEncounterDetail(
      {required int encounterId}) async {
    return EncounterDetailModel.fromJson(await handleResponse(
        await buildHttpResponse(
            "${APIEndPoints.encounterDashboardDetail}?encounter_id=$encounterId",
            method: HttpMethodType.GET)));
  }

  static Future<BaseResponseModel> updateStatus(
      {required Map request, required int appointmentId}) async {
    return BaseResponseModel.fromJson(await handleResponse(
        await buildHttpResponse('${APIEndPoints.updateStatus}/$appointmentId',
            request: request, method: HttpMethodType.POST)));
  }

  static Future<BaseResponseModel> rescheduleBooking(
      {required Map request, String? idempotencyKey}) async {
    return BaseResponseModel.fromJson(await handleResponse(
        await buildHttpResponse(APIEndPoints.rescheduleBooking,
            request: request,
            header: idempotencyKey == null
                ? null
                : {...buildHeaderTokens(), ...criticalOperationHeaders(idempotencyKey)},
            method: HttpMethodType.POST)));
  }

  static Future<BaseResponseModel> updateReview({required Map request}) async {
    return BaseResponseModel.fromJson(await handleResponse(
        await buildHttpResponse(APIEndPoints.saveRating,
            request: request, method: HttpMethodType.POST)));
  }

  static Future<BaseResponseModel> deleteReview({required int id}) async {
    return BaseResponseModel.fromJson(await handleResponse(
        await buildHttpResponse(APIEndPoints.deleteRating,
            request: {"id": id}, method: HttpMethodType.POST)));
  }

  static Future<RxList<DoctorReviewData>> getDoctorReviews({
    int page = 1,
    int perPage = Constants.perPageItem,
    required List<DoctorReviewData> reviewList,
    Function(bool)? lastPageCallBack,
    int doctorId = -1,
  }) async {
    String docId = doctorId != -1 ? '&doctor_id=$doctorId' : '';
    final reviewRes = DoctorReviewRes.fromJson(await handleResponse(
        await buildHttpResponse(
            "${APIEndPoints.getRating}?per_page=$perPage&page=$page$docId",
            method: HttpMethodType.GET)));
    if (page == 1) reviewList.clear();
    reviewList.addAll(reviewRes.reviewData);
    lastPageCallBack?.call(reviewRes.reviewData.length != perPage);
    return reviewList.obs;
  }

  //Payment
  static Future<BaseResponseModel> savePayment({
    required Map request,
    required String idempotencyKey,
  }) async {
    return BaseResponseModel.fromJson(
        await handleResponse(await buildHttpResponse(APIEndPoints.savePayment,
            request: request,
            header: {
              ...buildHeaderTokens(),
              ...criticalOperationHeaders(idempotencyKey),
            },
            method: HttpMethodType.POST)));
  }

  //Incident

  static Future<RxList<Incident>> getIncidentList({
    required int page,
    int perPage = 10,
    required List<Incident> incidents,
    Function(bool)? lastPageCallBack,
  }) async {
    final res = IncidentResponse.fromJson(await handleResponse(
      await buildHttpResponse(
          "${APIEndPoints.incidenceList}?per_page=$perPage&page=$page",
          method: HttpMethodType.GET),
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
    required String idempotencyKey,
    Function(dynamic)? onSuccess,
  }) async {
    MultipartRequest multiPartRequest =
        await getMultiPartRequest(APIEndPoints.incidenceSave);

    // Add form fields
    multiPartRequest.fields['title'] = title;
    multiPartRequest.fields['description'] = description;
    multiPartRequest.fields['country_code'] = '+$phoneCode';
    multiPartRequest.fields['phone'] = mobileNumber;
    multiPartRequest.fields['email'] = email;

    // Attach image if present
    if (imageFile != null && imageFile.existsSync()) {
      multiPartRequest.files
          .add(await MultipartFile.fromPath('file_url', imageFile.path));
    }

    // Add headers
    multiPartRequest.headers.addAll({
      ...buildHeaderTokens(),
      ...criticalOperationHeaders(idempotencyKey),
    });

    BaseResponseModel result = BaseResponseModel();
    await sendMultiPartRequest(
      multiPartRequest,
      onSuccess: (data) async {
        final decoded = data is String ? jsonDecode(data) : data;
        if (decoded is Map) {
          result = BaseResponseModel.fromJson(decoded.cast<String, dynamic>());
        }
        onSuccess?.call(data);
      },
      onError: (error) {
        throw error;
      },
    ).catchError((error) {
      throw error;
    });
    return result;
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
    OtherPatientListRes memberListRes = OtherPatientListRes.fromJson(
        await handleResponse(await buildHttpResponse(
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
}

/// Parses the create-booking response without treating an incomplete success
/// body as a safe-to-retry rejection. The server may already have committed it.
SaveBookingRes parseBookingSubmissionResponse(dynamic raw) {
  late final dynamic decoded;
  try {
    decoded = raw is String ? jsonDecode(raw) : raw;
  } on Object {
    throw const AmbiguousRequestOutcomeException(
      'The server accepted the booking but returned an invalid confirmation. Verify its status before retrying.',
    );
  }
  if (decoded is! Map || decoded['status'] is! bool) {
    throw const AmbiguousRequestOutcomeException(
      'The server accepted the booking but returned an invalid confirmation. Verify its status before retrying.',
    );
  }

  late final SaveBookingRes booking;
  try {
    booking = SaveBookingRes.fromJson(decoded.cast<String, dynamic>());
  } on Object {
    throw const AmbiguousRequestOutcomeException(
      'The server accepted the booking but returned an invalid confirmation. Verify its status before retrying.',
    );
  }
  if (!booking.status) {
    throw StateError(
      booking.message.trim().isNotEmpty
          ? booking.message
          : 'The booking could not be confirmed.',
    );
  }
  if (booking.saveBookingResData.id <= 0) {
    throw const AmbiguousRequestOutcomeException(
      'The server accepted the booking but returned an invalid confirmation. Verify its status before retrying.',
    );
  }
  return booking;
}
