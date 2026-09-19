import 'package:flutter_test/flutter_test.dart';
import 'package:kivicare_patient/screens/labs_radiology/models/booking_payload.dart';
import 'package:kivicare_patient/screens/labs_radiology/models/facility_type.dart';

BookingPayload payload({
  FacilityType type = FacilityType.lab,
  int? labTestId = 4,
  DateTime? date,
  String time = '09:30',
  String? notes,
}) {
  return BookingPayload(
    facilityType: type,
    facilityId: 2,
    labTestId: labTestId,
    slotId: 3,
    preferredDate: date ?? DateTime.now().add(const Duration(days: 2)),
    preferredTime: time,
    patientNotes: notes,
  );
}

void main() {
  test('accepts a valid lab booking', () {
    expect(payload().validate(), isNull);
  });

  test('requires a selected test for lab bookings', () {
    expect(payload(labTestId: null).validate(), 'lab_test_required');
  });

  test('rejects past dates and malformed times', () {
    expect(
      payload(date: DateTime.now().subtract(const Duration(days: 2)))
          .validate(),
      'preferred_date_past',
    );
    expect(payload(time: '9:30 AM').validate(), 'preferred_time_invalid');
  });

  test('rejects patient notes over the API limit', () {
    expect(
      payload(notes: List.filled(1001, 'a').join()).validate(),
      'patient_notes_too_long',
    );
  });
}
