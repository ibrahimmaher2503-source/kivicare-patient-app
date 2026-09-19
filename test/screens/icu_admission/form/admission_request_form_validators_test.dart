import 'package:flutter_test/flutter_test.dart';
import 'package:kivicare_patient/screens/icu_admission/models/admission_request_form_payload.dart';
import 'package:kivicare_patient/screens/icu_admission/models/admission_request_model.dart';
import 'package:kivicare_patient/screens/icu_admission/form/admission_request_form_validators.dart';

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
        languageCode: 'en',
        attendingDoctor: 'Dr Salem',
        medicalHistory: 'Hypertension',
        currentMedications: 'Medication A',
        allergies: 'Penicillin',
        additionalNotes: 'Monitor closely',
        urgency: UrgencyLevel.urgent,
        accompanyingName: 'Jane Doe',
        accompanyingPhone: '+201001234567',
      );

      final json = payload.toJson();

      // Whitelisted
      expect(json['hospital_id'], 1);
      expect(json['patient_name'], 'John Doe');
      expect(json['urgency'], 'urgent');
      expect(json['diagnosis_en'], 'Heart failure');
      expect(json.containsKey('diagnosis_ar'), isFalse);
      expect(json['attending_doctor'], 'Dr Salem');
      expect(json['medical_history'], 'Hypertension');
      expect(json['current_medications'], 'Medication A');
      expect(json['allergies'], 'Penicillin');
      expect(json['additional_notes'], 'Monitor closely');

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
    test('valid phone numbers pass', () {
      expect(
        AdmissionRequestFormValidators.phone(
          '+201001234567',
          requiredMessage: 'required',
          invalidMessage: 'invalid',
        ),
        isNull,
      );
      expect(
        AdmissionRequestFormValidators.phone(
          '+20 100-123-4567',
          requiredMessage: 'required',
          invalidMessage: 'invalid',
        ),
        isNull,
      );
    });

    test('invalid phone numbers fail', () {
      expect(
        AdmissionRequestFormValidators.phone(
          '123',
          requiredMessage: 'required',
          invalidMessage: 'invalid',
        ),
        'invalid',
      );
      expect(
        AdmissionRequestFormValidators.phone(
          '',
          requiredMessage: 'required',
          invalidMessage: 'invalid',
        ),
        'required',
      );
    });
  });

  group('Age boundary validation', () {
    test('age must be between 0 and 150', () {
      expect(
        AdmissionRequestFormValidators.age(
          '45',
          requiredMessage: 'required',
          invalidMessage: 'invalid',
        ),
        isNull,
      );
      expect(
        AdmissionRequestFormValidators.age(
          '-1',
          requiredMessage: 'required',
          invalidMessage: 'invalid',
        ),
        'invalid',
      );
      expect(
        AdmissionRequestFormValidators.age(
          '151',
          requiredMessage: 'required',
          invalidMessage: 'invalid',
        ),
        'invalid',
      );
    });
  });
}
