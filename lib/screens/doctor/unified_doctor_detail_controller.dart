import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../api/core_apis.dart';
import '../../utils/constants.dart';
import '../call_booking/model/call_doctor_model.dart';
import '../call_booking/model/time_slot_model.dart';
import '../independent_booking/model/independent_doctor_model.dart';
import 'model/doctor_list_res.dart';
import 'model/unified_doctor_model.dart';

/// Loads booking capabilities from 3 parallel API endpoints on init.
/// Uses individual try-catch so a missing endpoint never blocks the UI.
/// Also holds per-capability form state for the Book tab.
class UnifiedDoctorDetailController extends GetxController {
  final UnifiedDoctor doctor;

  UnifiedDoctorDetailController({required this.doctor});

  final RxBool isLoading = true.obs;
  final RxList<BookingCapability> capabilities = <BookingCapability>[].obs;

  /// Full doctor detail loaded in parallel with capabilities (About/Reviews/Qualifications tabs).
  final Rx<Doctor?> fullDoctorData = Rx<Doctor?>(null);
  final RxBool isLoadingDetails = false.obs;

  // Per-capability form state — pre-initialised for all 4 BookingTypes in onInit().
  final Map<BookingType, Rx<ServiceInfo?>> selectedService = {};
  final Map<BookingType, Rx<DateTime?>> selectedDate = {};
  final Map<BookingType, Rx<TimeSlot?>> selectedSlot = {};
  final Map<BookingType, RxList<TimeSlot>> slots = {};
  final Map<BookingType, RxBool> isLoadingSlots = {};
  final Map<BookingType, RxBool> isSectionExpanded = {};

  @override
  void onInit() {
    super.onInit();
    for (final t in BookingType.values) {
      selectedService[t] = Rx<ServiceInfo?>(null);
      selectedDate[t] = Rx<DateTime?>(null);
      selectedSlot[t] = Rx<TimeSlot?>(null);
      slots[t] = <TimeSlot>[].obs;
      isLoadingSlots[t] = false.obs;
      isSectionExpanded[t] = false.obs;
    }
    _loadCapabilities();
    _loadDoctorDetails();
  }

  Future<void> _loadDoctorDetails() async {
    isLoadingDetails(true);
    try {
      final detail = await CoreServiceApis.getDoctorDetails(doctorId: doctor.doctorId);
      fullDoctorData.value = detail.data;
    } catch (_) {}
    isLoadingDetails(false);
  }

  Future<void> _loadCapabilities() async {
    isLoading(true);
    final resolved = List<BookingCapability>.from(doctor.bookingCapabilities);

    // Fire both requests in parallel before awaiting
    final callFuture = CoreServiceApis.getCallDoctorServices(doctorId: doctor.doctorId);
    final indFuture = CoreServiceApis.getIndependentDoctorServices(doctorId: doctor.doctorId);

    List<CallService> callServices = [];
    List<IndependentService> indServices = [];

    try {
      callServices = await callFuture;
    } catch (_) {}
    try {
      indServices = await indFuture;
    } catch (_) {}

    // Merge call capabilities
    final videoServices = callServices
        .where((s) => s.callType == 'video')
        .map(ServiceInfo.fromCallService)
        .toList();
    final phoneServices = callServices
        .where((s) => s.callType != 'video')
        .map(ServiceInfo.fromCallService)
        .toList();

    if (videoServices.isNotEmpty && !resolved.any((c) => c.type == BookingType.videoCall)) {
      final prices = videoServices.map((s) => s.finalPrice);
      resolved.add(BookingCapability(
        type: BookingType.videoCall,
        isAvailable: true,
        startingPrice: prices.reduce((a, b) => a < b ? a : b),
        services: videoServices,
      ));
    }
    if (phoneServices.isNotEmpty && !resolved.any((c) => c.type == BookingType.phoneCall)) {
      final prices = phoneServices.map((s) => s.finalPrice);
      resolved.add(BookingCapability(
        type: BookingType.phoneCall,
        isAvailable: true,
        startingPrice: prices.reduce((a, b) => a < b ? a : b),
        services: phoneServices,
      ));
    }

    // Merge independent capability
    if (indServices.isNotEmpty && !resolved.any((c) => c.type == BookingType.inPerson)) {
      final services = indServices.map(ServiceInfo.fromIndependentService).toList();
      final prices = services.map((s) => s.charges);
      resolved.add(BookingCapability(
        type: BookingType.inPerson,
        isAvailable: true,
        startingPrice: prices.reduce((a, b) => a < b ? a : b),
        services: services,
      ));
    }

    capabilities.assignAll(resolved);
    isLoading(false);
  }

  void reloadCapabilities() => _loadCapabilities();

  void toggleSection(BookingType type) => isSectionExpanded[type]!.toggle();

  void setService(BookingType type, ServiceInfo? service) {
    selectedService[type]!.value = service;
    selectedDate[type]!.value = null;
    selectedSlot[type]!.value = null;
    slots[type]!.clear();
  }

  void setDate(BookingType type, DateTime date) {
    selectedDate[type]!.value = date;
    selectedSlot[type]!.value = null;
    loadSlots(type);
  }

  void setSlot(BookingType type, TimeSlot slot) {
    selectedSlot[type]!.value = slot;
  }

  /// Returns true when all required fields for the given booking type are filled.
  bool canBook(BookingType type) {
    if (type == BookingType.clinic) {
      return selectedService[type]!.value != null;
    }
    return selectedService[type]!.value != null &&
        selectedDate[type]!.value != null &&
        selectedSlot[type]!.value != null;
  }

  /// Loads available time slots for [type] using the current selectedService and selectedDate.
  Future<void> loadSlots(BookingType type) async {
    final service = selectedService[type]?.value;
    final date = selectedDate[type]?.value;
    if (service == null || date == null) return;

    isLoadingSlots[type]!(true);
    slots[type]!.clear();

    final dateStr = DateFormat(DateFormatConst.yyyy_MM_dd).format(date);

    try {
      if (type == BookingType.videoCall || type == BookingType.phoneCall) {
        final result = await CoreServiceApis.getCallSlots(
          doctorId: doctor.doctorId,
          request: {'date': dateStr, 'call_service_id': service.id},
        );
        slots[type]!.addAll(result);
      } else if (type == BookingType.inPerson) {
        final result = await CoreServiceApis.getIndependentSlots(
          doctorId: doctor.doctorId,
          request: {'date': dateStr, 'independent_service_id': service.id},
        );
        slots[type]!.addAll(result);
      }
      // BookingType.clinic: slots are handled inside BookingFormScreen
    } catch (_) {}

    isLoadingSlots[type]!(false);
  }
}
