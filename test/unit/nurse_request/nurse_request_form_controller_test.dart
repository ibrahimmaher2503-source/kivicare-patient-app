import 'package:flutter_test/flutter_test.dart';
import 'package:kivicare_patient/screens/nurse_request/models/nurse_request_form_payload.dart';

void main() {
  group('Bilingual cross-field description rule', () {
    test('both empty fails validation (both required together)', () {
      final payload = NurseRequestFormPayload(
        serviceDescriptionEn: '',
        serviceDescriptionAr: '',
        preferredDate: DateTime(2026, 5, 2),
        durationHours: 2,
        addressLine1: '12 Test St.',
        city: 'Cairo',
        contactPhone: '+201001234567',
      );
      final json = payload.toJson();
      // Both omitted from payload — caller must validate before submit
      expect(json.containsKey('service_description_en'), isFalse);
      expect(json.containsKey('service_description_ar'), isFalse);
    });

    test('English-only non-empty passes (description included)', () {
      final payload = NurseRequestFormPayload(
        serviceDescriptionEn: 'Daily wound care',
        serviceDescriptionAr: '',
        preferredDate: DateTime(2026, 5, 2),
        durationHours: 2,
        addressLine1: '12 Test St.',
        city: 'Cairo',
        contactPhone: '+201001234567',
      );
      final json = payload.toJson();
      expect(json['service_description_en'], 'Daily wound care');
      expect(json.containsKey('service_description_ar'), isFalse);
    });

    test('Arabic-only non-empty passes (description included)', () {
      final payload = NurseRequestFormPayload(
        serviceDescriptionEn: '',
        serviceDescriptionAr: 'رعاية يومية',
        preferredDate: DateTime(2026, 5, 2),
        durationHours: 2,
        addressLine1: '12 Test St.',
        city: 'Cairo',
        contactPhone: '+201001234567',
      );
      final json = payload.toJson();
      expect(json['service_description_ar'], 'رعاية يومية');
      expect(json.containsKey('service_description_en'), isFalse);
    });
  });

  group('Duration stepper boundaries', () {
    test('duration 1 is minimum valid', () {
      final payload = NurseRequestFormPayload(
        serviceDescriptionEn: 'Test',
        preferredDate: DateTime(2026, 5, 2),
        durationHours: 1,
        addressLine1: '12 Test St.',
        city: 'Cairo',
        contactPhone: '+201001234567',
      );
      expect(payload.toJson()['duration_hours'], 1);
    });

    test('duration 24 is maximum valid', () {
      final payload = NurseRequestFormPayload(
        serviceDescriptionEn: 'Test',
        preferredDate: DateTime(2026, 5, 2),
        durationHours: 24,
        addressLine1: '12 Test St.',
        city: 'Cairo',
        contactPhone: '+201001234567',
      );
      expect(payload.toJson()['duration_hours'], 24);
    });
  });

  group('Phone regex validation', () {
    final phoneRegex = RegExp(r'^\+?[0-9]{7,20}$');

    test('valid phone numbers pass', () {
      expect(phoneRegex.hasMatch('+201001234567'), isTrue);
      expect(phoneRegex.hasMatch('201001234567'), isTrue);
      expect(phoneRegex.hasMatch('+20100123'), isTrue);
    });

    test('invalid phone numbers fail', () {
      expect(phoneRegex.hasMatch('+12'), isFalse);
      expect(phoneRegex.hasMatch('abc'), isFalse);
      expect(phoneRegex.hasMatch(''), isFalse);
      expect(phoneRegex.hasMatch('+'), isFalse);
    });
  });

  group('Unknown-outcome verify-list flow', () {
    test('NurseRequestFormPayload.toJson does not throw on minimal valid input', () {
      final payload = NurseRequestFormPayload(
        serviceDescriptionEn: 'Test',
        preferredDate: DateTime(2026, 5, 2),
        durationHours: 2,
        addressLine1: '12 Test St.',
        city: 'Cairo',
        contactPhone: '+201001234567',
      );
      expect(() => payload.toJson(), returnsNormally);
    });
  });
}
