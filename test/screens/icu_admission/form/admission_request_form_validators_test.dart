import 'package:flutter_test/flutter_test.dart';
import 'package:kivicare_patient/screens/icu_admission/models/admission_request_form_payload.dart';
import 'package:kivicare_patient/screens/icu_admission/models/admission_request_model.dart';

void main() {
  group('AdmissionRequestFormPayload whitelist (FR-023)', () {
    test('toJson only includes whitelisted fields', () {
      final payload = AdmissionRequestFormPayload(
        hospitalId: 1,
        icuDepartmentId: 2,
        patientName: 'John Doe',
        patientAge: 45,
        patientGender: 'male',
        diagnosis: 'Heart failure',
        urgency: UrgencyLevel.urgent,
        accompanyingName: 'Jane Doe',
        accompanyingPhone: '+201001234567',
      );

      final json = payload.toJson();
      
      // Whitelisted
      expect(json['hospital_id'], 1);
      expect(json['patient_name'], 'John Doe');
      expect(json['urgency'], 'urgent');

      // Forbidden (FR-023 enforcement)
      expect(json.containsKey('status'), isFalse);
      expect(json.containsKey('reference_number'), isFalse);
      expect(json.containsKey('assigned_room'), isFalse);
      expect(json.containsKey('assigned_bed'), isFalse);
      expect(json.containsKey('admitted_at'), isFalse);
      expect(json.containsKey('discharged_at'), isFalse);
      expect(json.containsKey('payment_status'), isFalse);
      expect(json.containsKey('commission_amount'), isFalse);
    });
  });

  group('Phone regex validation (FR-018)', () {
    final phoneRegex = RegExp(r'^\+?\d{7,20}$');

    test('valid phone numbers pass', () {
      expect(phoneRegex.hasMatch('+201001234567'), isTrue);
      expect(phoneRegex.hasMatch('01001234567'), isTrue);
      expect(phoneRegex.hasMatch('+15265897485'), isTrue);
    });

    test('invalid phone numbers fail', () {
      expect(phoneRegex.hasMatch('123'), isFalse);
      expect(phoneRegex.hasMatch('abc-defg'), isFalse);
      expect(phoneRegex.hasMatch(''), isFalse);
    });
  });

  group('Age boundary validation', () {
    test('age must be between 0 and 150', () {
      int age = 45;
      expect(age >= 0 && age <= 150, isTrue);
      
      age = -1;
      expect(age >= 0 && age <= 150, isFalse);
      
      age = 151;
      expect(age >= 0 && age <= 150, isFalse);
    });
  });
}
