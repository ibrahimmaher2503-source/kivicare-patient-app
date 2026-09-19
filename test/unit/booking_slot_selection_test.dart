import 'package:flutter_test/flutter_test.dart';
import 'package:kivicare_patient/screens/slots/booking_form_controller.dart';
import 'package:kivicare_patient/utils/common_base.dart';

void main() {
  test('booking confirmation requires a future selected slot', () {
    final controller = BookingFormController()
      ..selectedDate(DateTime.now()
          .subtract(const Duration(days: 1))
          .toIso8601String()
          .substring(0, 10))
      ..selectedSlot('23:59');

    controller.onDateTimeChange();

    expect(controller.nextBtnVisible.value, isFalse);
  });

  test('booking API dates stay ASCII under Arabic locale', () {
    final date = DateTime(2026, 8, 28);
    expect(date.formatApiDateYYYYmmdd(), '2026-08-28');
  });
}
