import 'package:intl/intl.dart';
import 'facility_type.dart';

class BookingPayload {
  final FacilityType facilityType;
  final int facilityId;
  final int? labTestId;
  final int slotId;
  final DateTime preferredDate;
  final String preferredTime;
  final String? notes;
  final String? patientNotes;

  BookingPayload({
    required this.facilityType,
    required this.facilityId,
    this.labTestId,
    required this.slotId,
    required this.preferredDate,
    required this.preferredTime,
    this.notes,
    this.patientNotes,
  });

  Map<String, dynamic> toJson() {
    final m = <String, dynamic>{
      'facility_type': facilityType.apiValue,
      'facility_id': facilityId,
      'slot_id': slotId,
      'preferred_date': DateFormat('yyyy-MM-dd').format(preferredDate),
      'preferred_time': preferredTime,
    };
    if (labTestId != null) m['lab_test_id'] = labTestId;
    if (notes?.trim().isNotEmpty == true) m['notes'] = notes!.trim();
    if (patientNotes?.trim().isNotEmpty == true) {
      m['patient_notes'] = patientNotes!.trim();
    }
    return m;
  }

  String? validate() {
    if (facilityType == FacilityType.lab && labTestId == null) {
      return 'lab_test_required';
    }
    if (preferredDate
        .isBefore(DateTime.now().subtract(const Duration(days: 1)))) {
      return 'preferred_date_past';
    }
    if (!RegExp(r'^\d{2}:\d{2}$').hasMatch(preferredTime)) {
      return 'preferred_time_invalid';
    }
    if ((patientNotes?.length ?? 0) > 1000) {
      return 'patient_notes_too_long';
    }
    return null;
  }
}
