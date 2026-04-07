import 'package:kivicare_patient/screens/call_booking/model/call_doctor_model.dart';
import 'package:kivicare_patient/screens/doctor/model/doctor_list_res.dart';
import 'package:kivicare_patient/screens/independent_booking/model/independent_doctor_model.dart';
import 'package:kivicare_patient/screens/service/model/service_list_model.dart';

enum BookingType { clinic, videoCall, phoneCall, inPerson }

class ServiceInfo {
  final int id;
  final String name;
  final int durationMin;
  final double charges;
  final double finalPrice;
  final BookingType bookingType;
  final dynamic rawService;

  ServiceInfo({
    required this.id,
    required this.name,
    required this.durationMin,
    required this.charges,
    required this.finalPrice,
    required this.bookingType,
    required this.rawService,
  });

  factory ServiceInfo.fromClinicService(ServiceElement s) => ServiceInfo(
        id: s.id,
        name: s.name,
        durationMin: s.duration,
        charges: s.charges.toDouble(),
        finalPrice: s.payableAmount.toDouble(),
        bookingType: BookingType.clinic,
        rawService: s,
      );

  factory ServiceInfo.fromCallService(CallService s) => ServiceInfo(
        id: s.id,
        name: s.name,
        durationMin: s.durationMin,
        charges: s.charges,
        finalPrice: s.finalPrice,
        bookingType: s.callType == 'video' ? BookingType.videoCall : BookingType.phoneCall,
        rawService: s,
      );

  factory ServiceInfo.fromIndependentService(IndependentService s) => ServiceInfo(
        id: s.id,
        name: s.name,
        durationMin: s.durationMin,
        charges: s.charges,
        finalPrice: s.charges,
        bookingType: BookingType.inPerson,
        rawService: s,
      );
}

class BookingCapability {
  final BookingType type;
  final bool isAvailable;
  final double startingPrice;
  final List<ServiceInfo> services;

  BookingCapability({
    required this.type,
    required this.isAvailable,
    required this.startingPrice,
    required this.services,
  });
}

class UnifiedDoctor {
  final int id;
  final int doctorId;
  final String firstName;
  final String lastName;
  final String fullName;
  final String email;
  final String mobile;
  final String gender;
  final String expert;
  final String profileImage;
  final double averageRating;
  final int totalReviews;
  final String experience;
  List<BookingCapability> bookingCapabilities;

  UnifiedDoctor({
    required this.id,
    required this.doctorId,
    required this.firstName,
    required this.lastName,
    required this.fullName,
    required this.email,
    required this.mobile,
    required this.gender,
    required this.expert,
    required this.profileImage,
    required this.averageRating,
    required this.totalReviews,
    required this.experience,
    required this.bookingCapabilities,
  });

  factory UnifiedDoctor.fromDoctor(Doctor d) {
    final clinicServices = d.services.map(ServiceInfo.fromClinicService).toList();
    final capabilities = <BookingCapability>[];
    if (clinicServices.isNotEmpty) {
      final prices = clinicServices.map((s) => s.finalPrice);
      capabilities.add(BookingCapability(
        type: BookingType.clinic,
        isAvailable: true,
        startingPrice: prices.reduce((a, b) => a < b ? a : b),
        services: clinicServices,
      ));
    }
    return UnifiedDoctor(
      id: d.id,
      doctorId: d.doctorId,
      firstName: d.firstName,
      lastName: d.lastName,
      fullName: d.fullName,
      email: d.email,
      mobile: d.mobile,
      gender: d.gender,
      expert: d.expert,
      profileImage: d.profileImage,
      averageRating: d.averageRating.toDouble(),
      totalReviews: d.totalReviews,
      experience: d.experience,
      bookingCapabilities: capabilities,
    );
  }

  factory UnifiedDoctor.fromCallDoctor(CallDoctor d) {
    final videoServices = d.callServices
        .where((s) => s.callType == 'video')
        .map(ServiceInfo.fromCallService)
        .toList();
    final phoneServices = d.callServices
        .where((s) => s.callType != 'video')
        .map(ServiceInfo.fromCallService)
        .toList();

    final capabilities = <BookingCapability>[];
    if (d.hasVideoCall) {
      final prices = videoServices.map((s) => s.finalPrice);
      capabilities.add(BookingCapability(
        type: BookingType.videoCall,
        isAvailable: true,
        startingPrice: prices.isNotEmpty ? prices.reduce((a, b) => a < b ? a : b) : d.callStartingPrice,
        services: videoServices,
      ));
    }
    if (d.hasPhoneCall) {
      final prices = phoneServices.map((s) => s.finalPrice);
      capabilities.add(BookingCapability(
        type: BookingType.phoneCall,
        isAvailable: true,
        startingPrice: prices.isNotEmpty ? prices.reduce((a, b) => a < b ? a : b) : d.callStartingPrice,
        services: phoneServices,
      ));
    }

    return UnifiedDoctor(
      id: d.id,
      doctorId: d.doctorId,
      firstName: d.firstName,
      lastName: d.lastName,
      fullName: d.fullName,
      email: d.email,
      mobile: d.mobile,
      gender: d.gender,
      expert: d.expert,
      profileImage: d.profileImage,
      averageRating: d.averageRating,
      totalReviews: d.totalReviews,
      experience: d.experience,
      bookingCapabilities: capabilities,
    );
  }

  factory UnifiedDoctor.fromIndependentDoctor(IndependentDoctor d) {
    final services = d.services.map(ServiceInfo.fromIndependentService).toList();
    final prices = services.map((s) => s.charges);
    final capability = BookingCapability(
      type: BookingType.inPerson,
      isAvailable: true,
      startingPrice: prices.isNotEmpty ? prices.reduce((a, b) => a < b ? a : b) : 0.0,
      services: services,
    );

    return UnifiedDoctor(
      id: d.id,
      doctorId: d.doctorId,
      firstName: d.firstName,
      lastName: d.lastName,
      fullName: d.fullName,
      email: d.email,
      mobile: d.mobile,
      gender: d.gender,
      expert: d.expert,
      profileImage: d.profileImage,
      averageRating: d.averageRating,
      totalReviews: d.totalReviews,
      experience: d.experience,
      bookingCapabilities: [capability],
    );
  }

  /// Reconstructs a minimal [CallDoctor] for use as a navigation argument.
  CallDoctor toCallDoctor() => CallDoctor(
        id: id,
        doctorId: doctorId,
        firstName: firstName,
        lastName: lastName,
        fullName: fullName,
        email: email,
        mobile: mobile,
        gender: gender,
        expert: expert,
        experience: experience,
        profileImage: profileImage,
        averageRating: averageRating,
        totalReviews: totalReviews,
      );

  /// Reconstructs a minimal [IndependentDoctor] for use as a navigation argument.
  IndependentDoctor toIndependentDoctor() => IndependentDoctor(
        id: id,
        doctorId: doctorId,
        firstName: firstName,
        lastName: lastName,
        fullName: fullName,
        email: email,
        mobile: mobile,
        gender: gender,
        expert: expert,
        experience: experience,
        profileImage: profileImage,
        averageRating: averageRating,
        totalReviews: totalReviews,
      );

  /// Reconstructs a minimal [Doctor] for use as a navigation argument.
  Doctor toDoctor() => Doctor(
        id: id,
        doctorId: doctorId,
        firstName: firstName,
        lastName: lastName,
        fullName: fullName,
        email: email,
        mobile: mobile,
        gender: gender,
        expert: expert,
        experience: experience,
        profileImage: profileImage,
        averageRating: averageRating,
        totalReviews: totalReviews,
        services: bookingCapabilities
            .where((c) => c.type == BookingType.clinic)
            .expand((c) => c.services)
            .map((s) => s.rawService as ServiceElement)
            .toList(),
      );

  /// Merges capabilities from [other] into this doctor (same [doctorId] only).
  void mergeWith(UnifiedDoctor other) {
    if (other.doctorId != doctorId) return;
    for (final cap in other.bookingCapabilities) {
      final alreadyHas = bookingCapabilities.any((c) => c.type == cap.type);
      if (!alreadyHas) bookingCapabilities.add(cap);
    }
  }
}

/// Deduplicates a list of [UnifiedDoctor] by [doctorId], merging capabilities.
List<UnifiedDoctor> deduplicateDoctors(List<UnifiedDoctor> doctors) {
  final map = <int, UnifiedDoctor>{};
  for (final doc in doctors) {
    if (map.containsKey(doc.doctorId)) {
      map[doc.doctorId]!.mergeWith(doc);
    } else {
      map[doc.doctorId] = doc;
    }
  }
  return map.values.toList();
}
