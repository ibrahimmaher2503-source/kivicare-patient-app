import 'package:flutter_test/flutter_test.dart';
import 'package:kivicare_patient/screens/auth/profile/profile_update_payload.dart';

void main() {
  group('profile date-of-birth update payload', () {
    test('omits date of birth for a photo-only update', () {
      final result = profileDateOfBirthForUpdate(
        photoOnly: true,
        selectedDate: DateTime(2026, 7, 17),
      );

      expect(result, isEmpty);
    });

    test('omits date of birth when the profile has no valid date', () {
      final result = profileDateOfBirthForUpdate(
        photoOnly: false,
        selectedDate: null,
      );

      expect(result, isEmpty);
    });

    test('formats an explicitly selected date for a full update', () {
      final result = profileDateOfBirthForUpdate(
        photoOnly: false,
        selectedDate: DateTime(1990, 2, 3),
      );

      expect(result, '1990-02-03');
    });
  });
}
