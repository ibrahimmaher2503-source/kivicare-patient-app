import 'package:flutter_test/flutter_test.dart';
import 'package:kivicare_patient/screens/nurse_request/models/nurse_request_form_payload.dart';

void main() {
  group('NurseRequestFormPayload.toJson()', () {
    final minimalDate = DateTime(2026, 5, 2);

    test('includes all required fields', () {
      final payload = NurseRequestFormPayload(
        serviceDescriptionEn: 'Daily dressing change',
        preferredDate: minimalDate,
        durationHours: 2,
        addressLine1: '12 Test St.',
        city: 'Cairo',
        contactPhone: '+201001234567',
      );
      final json = payload.toJson();
      expect(json['service_description_en'], 'Daily dressing change');
      expect(json['preferred_date'], '2026-05-02');
      expect(json['duration_hours'], 2);
      expect(json['address_line_1'], '12 Test St.');
      expect(json['city'], 'Cairo');
      expect(json['contact_number'], '+201001234567');
    });

    test('trims whitespace from all string fields', () {
      final payload = NurseRequestFormPayload(
        serviceDescriptionEn: '  spaced description  ',
        preferredDate: minimalDate,
        durationHours: 1,
        addressLine1: '  12 Test St.  ',
        city: '  Cairo  ',
        contactPhone: '  +201001234567  ',
      );
      final json = payload.toJson();
      expect(json['service_description_en'], 'spaced description');
      expect(json['address_line_1'], '12 Test St.');
      expect(json['city'], 'Cairo');
      expect(json['contact_number'], '+201001234567');
    });

    test('omits empty optional fields', () {
      final payload = NurseRequestFormPayload(
        serviceDescriptionEn: 'Test',
        preferredDate: minimalDate,
        durationHours: 1,
        addressLine1: '12 Test St.',
        city: 'Cairo',
        contactPhone: '+201001234567',
        serviceDescriptionAr: '',
        addressLine2: '',
        patientNotes: '',
        state: '',
        country: '',
        postalCode: '',
        preferredTime: '',
      );
      final json = payload.toJson();
      expect(json.containsKey('service_description_ar'), isFalse);
      expect(json.containsKey('address_line_2'), isFalse);
      expect(json.containsKey('patient_notes'), isFalse);
      expect(json.containsKey('state'), isFalse);
      expect(json.containsKey('country'), isFalse);
      expect(json.containsKey('postal_code'), isFalse);
      expect(json.containsKey('preferred_time'), isFalse);
    });

    test('NEVER includes forbidden server-controlled fields', () {
      final payload = NurseRequestFormPayload(
        serviceDescriptionEn: 'Test',
        preferredDate: minimalDate,
        durationHours: 1,
        addressLine1: '12 Test St.',
        city: 'Cairo',
        contactPhone: '+201001234567',
      );
      final json = payload.toJson();
      final forbidden = [
        'id',
        'reference_number',
        'status',
        'assigned_nurse',
        'total_amount',
        'currency',
        'payment_status',
        'cancellation_reason',
        'completed_at',
        'created_at',
        'updated_at',
        'status_history',
        'nurse_id',
        'coupon_code',
        'patient_id',
        'patient_for',
      ];
      for (final key in forbidden) {
        expect(json.containsKey(key), isFalse,
            reason: 'payload must not contain $key');
      }
    });

    test('formats preferred_date as yyyy-MM-dd', () {
      final payload = NurseRequestFormPayload(
        serviceDescriptionEn: 'Test',
        preferredDate: DateTime(2026, 12, 31),
        durationHours: 1,
        addressLine1: '12 Test St.',
        city: 'Cairo',
        contactPhone: '+201001234567',
      );
      expect(payload.toJson()['preferred_date'], '2026-12-31');
    });

    test('sends governorate_id and city_id only when set', () {
      final withoutIds = NurseRequestFormPayload(
        serviceDescriptionEn: 'Test',
        preferredDate: minimalDate,
        durationHours: 1,
        addressLine1: '12 Test St.',
        city: 'Cairo',
        contactPhone: '+201001234567',
      );
      expect(withoutIds.toJson().containsKey('governorate_id'), isFalse);
      expect(withoutIds.toJson().containsKey('city_id'), isFalse);

      final withIds = NurseRequestFormPayload(
        serviceDescriptionEn: 'Test',
        preferredDate: minimalDate,
        durationHours: 1,
        addressLine1: '12 Test St.',
        city: 'Cairo',
        contactPhone: '+201001234567',
        governorateId: 11,
        cityId: 47,
      );
      expect(withIds.toJson()['governorate_id'], 11);
      expect(withIds.toJson()['city_id'], 47);
    });

    test('always sends city free-text even when city_id is set', () {
      final payload = NurseRequestFormPayload(
        serviceDescriptionEn: 'Test',
        preferredDate: minimalDate,
        durationHours: 1,
        addressLine1: '12 Test St.',
        city: 'Maadi',
        contactPhone: '+201001234567',
        cityId: 47,
      );
      final json = payload.toJson();
      expect(json.containsKey('city'), isTrue);
      expect(json['city'], 'Maadi');
    });
  });
}
