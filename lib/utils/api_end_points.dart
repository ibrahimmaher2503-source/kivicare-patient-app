class APIEndPoints {
  static const String appConfiguration = 'app-configuration';
  static const String aboutPages = 'page-list';

  //Auth & User
  static const String register = 'register';
  static const String socialLogin = 'social-login';
  static const String login = 'login';
  static const String verify = 'verify';
  static const String logout = 'logout';
  static const String changePassword = 'change-password';
  static const String forgotPassword = 'forgot-password';
  static const String userDetail = 'user-detail';
  static const String updateProfile = 'update-profile';
  static const String deleteUserAccount = 'delete-account';
  static const String getNotification = 'notification-list';
  static const String removeNotification = 'notification-remove';
  static const String clearAllNotification = 'notification-deleteall';
  static const String getPatientWallet = 'get-patient-wallet';
  static const String getWalletHistory = 'get-wallet-history';

  //home choose service api
  static const String getDashboard = 'dashboard-detail';
  static const String getSystemService = 'get-system-service';
  static const String getCategoryList = 'get-category-list';
  static const String getServiceList = 'get-service-list';
  static const String getServiceDetails = 'get-service-details';
  static const String getClinicList = 'get-clinic-list';
  static const String getClinicDetails = 'get-clinic-details';
  static const String getClinicGallery = 'get-clinic-gallery';
  static const String getDoctorList = 'get-doctor-list';
  static const String getDoctorDetails = 'get-doctor-details';
  static const String getTimeSlots = 'get-time-slots';

  //Booking for Other
  static const String addPatient = 'add-patient-member';
  static const String otherMemberPatientList = 'other-members-list';
  static const String deleteOtherMember = 'delete-other_member';

  //booking api-list
  static const String getAppointments = 'appointment-list';
  static const String getEncounterList = 'encounter-list';
  static const String saveBooking = 'save-booking';
  static const String savePayment = 'save-payment';
  static const String updateStatus = 'update-status';
  static const String rescheduleBooking = 'reschedule-booking';

  //booking detail-api
  static const String getAppointmentDetail = 'appointment-detail';
  static const String downloadInvoice = 'download_invoice';

  //booking encounter detail
  static const String encounterDashboardDetail = 'encounter-dashboard-detail';

  //Review
  static const String saveRating = 'save-rating';
  static const String getRating = 'get-rating';
  static const String deleteRating = 'delete-rating';

  //Vendor
  static const String updateService = 'update-service';
  static const String addServiceTraining = 'service-training';
  static const String serviceList = 'service-list';
  static const String deleteService = 'delete-service';
  static const String getCategory = 'category-list';
  static const String addService = 'service';

  //Indicent
  static const String incidenceList = 'incidence-list';
  static const String incidenceSave = 'incidence-save';
  static const String updateIncidentStatus = 'update-incident-status';

  //Nurse
  static const String getNurses = 'v1/nurses';
  static const String getNurseDetail = 'v1/nurses'; // append /{id}
  static const String getNurseRequests = 'v1/nurse-requests';
  static const String createNurseRequest = 'v1/nurse-requests';
  static const String getNurseRequestDetail = 'v1/nurse-requests'; // append /{id}
  static const String updateNurseRequest = 'v1/nurse-requests'; // append /{id}
  static const String cancelNurseRequest = 'v1/nurse-requests'; // append /{id}/cancel

  //Location
  static const String governorates = 'governorates';
  static const String cities = 'cities'; // ?governorate_id=

  // New search endpoints (additive — existing endpoints remain)
  static const String doctorsSearch = 'doctors/search';
  static const String clinicsSearch = 'clinics/search';
  static const String nursesSearch = 'nurses/search';
  static const String labsSearch = 'labs/search';

  // Home Healthcare
  static const String homeHealthcareSearch = 'home-healthcare/search';
  static const String homeHealthcareDetail = 'home-healthcare';    // append /{id}
  static const String homeHealthcareRequests = 'v1/home-healthcare-requests';
  static const String homeHealthcareRequestDetail = 'v1/home-healthcare-requests'; // append /{id}
  static const String homeHealthcareRequestCancel = 'v1/home-healthcare-requests'; // append /{id}/cancel

  // Radiology
  static const String radiologySearch = 'radiology/search';
  static const String radiologyDetail = 'radiology'; // append /{id}

  //Lab Tests
  static const String labTestCategories = 'v1/lab-test-categories';
  static const String labTests = 'v1/lab-tests';
  static String labTestDetail(int id) => '$labTests/$id';
  static const String testOrders = 'v1/test-orders';
  static String testOrderDetail(int id) => '$testOrders/$id';
  static String testOrderCancel(int id) => '$testOrders/$id/cancel';
  static String testOrderReportDownload(int id) => '$testOrders/$id/report/download';

  // Facility Bookings
  static const String facilityBookings = 'v1/facility-bookings';
  static String facilityBookingDetail(int id) => '$facilityBookings/$id';
  static String facilityBookingCancel(int id) => '$facilityBookings/$id/cancel';
  static String labSlots(int labId) => '$facilityBookings/labs/$labId/slots';
  static String radiologyCenterSlots(int centerId) => '$facilityBookings/radiology-centers/$centerId/slots';

  //Request Service
  static const String saveRequestService = 'v1/save-request-service';
  static const String getRequestService = 'v1/get-request-service';

  //ICU Admissions
  static const String getHospitals = 'v1/hospitals';
  static const String getHospitalDetail = 'v1/hospitals'; // append /{id}
  static const String getIcuDepartments = 'v1/icu-departments';
  static const String getIcuAdmissionRequests = 'v1/icu-admission-requests';
  static const String createIcuAdmissionRequest = 'v1/icu-admission-requests';
  static const String getIcuAdmissionRequestDetail = 'v1/icu-admission-requests'; // append /{id}
  static const String cancelIcuAdmissionRequest = 'v1/icu-admission-requests'; // append /{id}/cancel

  //Call Booking
  static const String getCallDoctors = 'v1/call-doctors';
  static const String getCallDoctorServices = 'v1/call-doctors'; // append /{id}/services
  static const String getCallSlots = 'v1/call-doctors'; // append /{id}/slots
  static const String createCallBooking = 'v1/call-booking';
  static const String getCallBookings = 'v1/call-booking';

  //Independent Doctor Booking
  static const String getIndependentDoctors = 'v1/independent-doctors';
  static const String getIndependentDoctorServices = 'v1/independent-doctors'; // append /{id}/services
  static const String getIndependentSlots = 'v1/independent-doctors'; // append /{id}/slots
  static const String createIndependentBooking = 'v1/independent-booking';
  static const String getIndependentBookings = 'v1/independent-booking';

  // Doctor Home Visit
  static const String doctorVisitRequests = 'v1/doctor-visit/requests';
  static String doctorVisitRequestDetail(String reference) => '$doctorVisitRequests/$reference';
  static const String adminDoctorVisitRequests = 'v1/admin/doctor-visit/requests';
  static String adminDoctorVisitRequestStatus(String reference) => '$adminDoctorVisitRequests/$reference/status';
  static String adminDoctorVisitRequestAssignDoctor(String reference) => '$adminDoctorVisitRequests/$reference/assign-doctor';

  // Pharmacy Marketplace
  static const String pharmacyCategories = 'v1/pharmacy/categories';
  static String pharmacyCategoryChildren(int id) => '$pharmacyCategories/$id/children';
  static const String pharmacyProducts = 'v1/pharmacy/products';
  static String pharmacyProductDetail(int id) => '$pharmacyProducts/$id';
  static const String pharmacyFilterBrands = 'v1/pharmacy/filters/brands';
  static const String pharmacyFilterProductTypes = 'v1/pharmacy/filters/product-types';
  static const String pharmacyCart = 'v1/pharmacy/cart';
  static const String pharmacyCartItems = 'v1/pharmacy/cart/items';
  static String pharmacyCartItemDetail(int id) => '$pharmacyCartItems/$id';
  static const String pharmacyAvailablePharmacies = 'v1/pharmacy/cart/available-pharmacies';
  static const String pharmacyOrders = 'v1/pharmacy/orders';
  static String pharmacyOrderDetail(int id) => '$pharmacyOrders/$id';
  static String pharmacyOrderCancel(int id) => '$pharmacyOrders/$id/cancel';
}
