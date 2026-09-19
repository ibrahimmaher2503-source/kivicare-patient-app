import 'package:intl/intl.dart';

class NurseRequestFormPayload {
  final String? serviceDescriptionEn;
  final String? serviceDescriptionAr;
  final DateTime preferredDate;
  final String? preferredTime;
  final int durationHours;
  final String addressLine1;
  final String? addressLine2;
  final int? governorateId;
  final int? cityId;
  final String city;
  final String? state;
  final String? country;
  final String? postalCode;
  final String contactPhone;
  final String? patientNotes;

  const NurseRequestFormPayload({
    this.serviceDescriptionEn,
    this.serviceDescriptionAr,
    required this.preferredDate,
    this.preferredTime,
    required this.durationHours,
    required this.addressLine1,
    this.addressLine2,
    this.governorateId,
    this.cityId,
    required this.city,
    this.state,
    this.country,
    this.postalCode,
    required this.contactPhone,
    this.patientNotes,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};

    final enDesc = serviceDescriptionEn?.trim() ?? '';
    final arDesc = serviceDescriptionAr?.trim() ?? '';
    if (enDesc.isNotEmpty) map['service_description_en'] = enDesc;
    if (arDesc.isNotEmpty) map['service_description_ar'] = arDesc;

    map['preferred_date'] = DateFormat('yyyy-MM-dd').format(preferredDate);

    final time = preferredTime?.trim() ?? '';
    if (time.isNotEmpty) map['preferred_time'] = time;

    map['duration_hours'] = durationHours;
    map['address_line_1'] = addressLine1.trim();

    final line2 = addressLine2?.trim() ?? '';
    if (line2.isNotEmpty) map['address_line_2'] = line2;

    if (governorateId != null) map['governorate_id'] = governorateId;
    if (cityId != null) map['city_id'] = cityId;

    map['city'] = city.trim();

    final stateVal = state?.trim() ?? '';
    if (stateVal.isNotEmpty) map['state'] = stateVal;

    final countryVal = country?.trim() ?? '';
    if (countryVal.isNotEmpty) map['country'] = countryVal;

    final postalVal = postalCode?.trim() ?? '';
    if (postalVal.isNotEmpty) map['postal_code'] = postalVal;

    map['contact_number'] = contactPhone.trim();

    final notes = patientNotes?.trim() ?? '';
    if (notes.isNotEmpty) map['patient_notes'] = notes;

    return map;
  }
}
