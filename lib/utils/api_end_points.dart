class APIEndPoints {
  static const String appConfiguration = 'app-configuration';
  static const String aboutPages = 'page-list';

  //Auth & User
  static const String register = 'register';
  static const String socialLogin = 'social-login';
  static const String login = 'login';
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
  static const String getDoctorDetails = 'doctor-details';
  static const String getTimeSlots = 'get-time-slots';
  static const String independentDoctors = 'independent-doctors';
  static const String independentBooking = 'independent-booking';

  //Booking for Other
  static const String addPatient = 'add-patient-member';
  static const String otherMemberPatientList = 'other-members-list';
  static const String deleteOtherMember = 'delete-other_member';

  //booking api-list
  static const String getAppointments = 'appointment-list';
  static const String getEncounterList = 'encounter-list';
  static const String saveBooking = 'save-booking';
  static const String savePayment = 'save-payment';
  static const String idempotencyStatus = 'v1/idempotency/status';
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

  // NURSE REQUEST MODULE — patient-facing endpoints
  static const String getNurseRequests = 'v1/nurse-requests';
  static const String createNurseRequest = 'v1/nurse-requests';
  static const String getNurseRequestDetail =
      'v1/nurse-requests'; // append /{id}

  // Location reference (ensure present)
  static const String governorates = 'governorates';
  static const String cities = 'cities'; // ?governorate_id=

  // ============================================
  // DOCTOR VISIT MODULE
  // ============================================
  static const String doctorVisitRequests = 'v1/doctor-visit/requests';
  static String cancelDoctorVisitRequest(String reference) =>
      'v1/doctor-visit/requests/$reference/cancel';

  // ============================================
  // PHARMACY MODULE
  // ============================================
  static const String pharmacyCategories = 'v1/pharmacy/categories';
  static const String pharmacyProducts = 'v1/pharmacy/products';
  static const String pharmacyBrands = 'v1/pharmacy/filters/brands';
  static const String pharmacyProductTypes =
      'v1/pharmacy/filters/product-types';
  static const String pharmacyCart = 'v1/pharmacy/cart';
  static const String pharmacyCartItems = 'v1/pharmacy/cart/items';
  static const String pharmacyAvailablePharmacies =
      'v1/pharmacy/cart/available-pharmacies';
  static const String pharmacyOrders = 'v1/pharmacy/orders';
  static const String pharmacyPrescriptions = 'v1/pharmacy/prescriptions';
  static const String pharmacyValidateCoupon = 'v1/pharmacy/coupons/validate';
  static const String pharmacyRefunds = 'v1/pharmacy/refunds';
  static const String pharmacyNotifications = 'v1/pharmacy/notifications';
  static const String pharmacyUnreadNotificationsCount =
      'v1/pharmacy/notifications/unread-count';
  static const String pharmacyReadAllNotifications =
      'v1/pharmacy/notifications/read-all';

  // ============================================
  // ICU ADMISSION MODULE
  // ============================================
  static const String icuHospitals = 'v1/hospitals';
  static const String icuDepartments = 'v1/icu-departments';
  static const String icuAdmissionRequests = 'v1/icu-admission-requests';

  static String icuHospitalDetail(int id) => 'v1/hospitals/$id';
  static String icuHospitalDepartments(int id) =>
      'v1/icu-departments?hospital_id=$id';
  static String icuAdmissionRequestDetail(int id) =>
      'v1/icu-admission-requests/$id';
  static String cancelIcuAdmissionRequest(int id) =>
      'v1/icu-admission-requests/$id/cancel';

  // ============================================
  // LABS & RADIOLOGY MODULE
  // ============================================
  static const String labsSearch = 'labs/search';
  static const String radiologySearch = 'radiology/search';
  static const String labTestCategories = 'v1/lab-test-categories';
  static const String labTests = 'v1/lab-tests';
  static const String facilityBookings = 'v1/facility-bookings';
  static const String testOrders = 'v1/test-orders';
}
