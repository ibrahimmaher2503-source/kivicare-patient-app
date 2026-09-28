import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/services.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart';
import 'package:kivicare_patient/network/network_utils.dart';
import 'package:kivicare_patient/network/critical_operation.dart';
import 'package:kivicare_patient/screens/booking/filter/model/filter_params.dart';
import 'package:kivicare_patient/screens/booking/filter/filter_controller.dart';
import 'package:kivicare_patient/screens/clinic/model/clinic_detail_model.dart';
import 'package:kivicare_patient/screens/clinic/model/clinics_res_model.dart';
import 'package:kivicare_patient/screens/doctor/model/doctor_list_res.dart';
import 'package:kivicare_patient/screens/icu_admission/models/hospital_model.dart';
import 'package:kivicare_patient/screens/nurse_request/components/cairo_time.dart';
import 'package:kivicare_patient/screens/nurse_request/models/nurse_status.dart';
import 'package:kivicare_patient/screens/doctor_visit/models/visit_status.dart';
import 'package:kivicare_patient/screens/service/model/service_list_model.dart';
import 'package:kivicare_patient/screens/slots/booking_form_controller.dart';
import 'package:kivicare_patient/utils/local_storage.dart';
import 'package:timezone/data/latest.dart' as tz;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(tz.initializeTimeZones);

  group('Cairo wall clock', () {
    test('uses Egypt daylight-saving offset in summer', () {
      final cairo =
          cairoDateTimeFromUtc(DateTime.utc(2026, DateTime.july, 1, 12));

      expect(cairo.hour, 15);
      expect(cairo.timeZoneOffset, const Duration(hours: 3));
    });

    test('uses standard offset in winter', () {
      final cairo =
          cairoDateTimeFromUtc(DateTime.utc(2026, DateTime.january, 1, 12));

      expect(cairo.hour, 14);
      expect(cairo.timeZoneOffset, const Duration(hours: 2));
    });
  });

  group('HTTP response parsing', () {
    test('accepts an empty successful response', () async {
      expect(await handleResponse(Response('', 204)), <String, dynamic>{});
    });

    test('returns successful non-JSON response text', () async {
      expect(await handleResponse(Response('accepted', 200)), 'accepted');
    });

    test('uses a safe fallback for a non-JSON server error', () async {
      expect(
        () => handleResponse(Response('<html>failure</html>', 500)),
        throwsA(isA<String>()),
      );
    });
  });

  test('critical create requests use the same idempotency and request ID', () {
    final headers = criticalOperationHeaders('operation-123');

    expect(headers['Idempotency-Key'], 'operation-123');
    expect(headers['X-Request-ID'], 'operation-123');
  });

  test('server failures after a mutation stay in reconciliation mode', () {
    for (final status in [408, 500, 502, 503, 504]) {
      expect(isAmbiguousMutatingStatus(status), isTrue,
          reason: 'status $status');
    }
    for (final status in [400, 401, 403, 404, 409, 422, 429]) {
      expect(isAmbiguousMutatingStatus(status), isFalse,
          reason: 'status $status is a deterministic response');
    }
  });

  test('patient cancellation eligibility is fail-closed by state', () {
    expect(NurseStatus.pending.isTerminal, isFalse);
    expect(NurseStatus.assigned.isTerminal, isFalse);
    expect(NurseStatus.completed.isTerminal, isTrue);
    expect(NurseStatus.cancelled.isTerminal, isTrue);
    expect(VisitStatus.pending.isTerminal, isFalse);
    expect(VisitStatus.confirmed.isTerminal, isFalse);
    expect(VisitStatus.completed.isTerminal, isTrue);
    expect(VisitStatus.cancelled.isTerminal, isTrue);
  });

  group('critical operation persistence', () {
    setUpAll(() async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        const MethodChannel('plugins.flutter.io/path_provider'),
        (call) async => Directory.systemTemp.path,
      );
      localStorage = GetStorage(
        'critical-operation-tests',
        Directory.systemTemp.path,
      );
      await localStorage.initStorage;
      await localStorage.erase();
    });

    test('fingerprints are deterministic and map order independent', () {
      expect(
        criticalOperationFingerprint({
          'b': 2,
          'a': [true, 'x']
        }),
        criticalOperationFingerprint({
          'a': [true, 'x'],
          'b': 2
        }),
      );
      expect(
        criticalOperationFingerprint({'value': 1}),
        isNot(criticalOperationFingerprint({'value': 2})),
      );
    });

    test('same pending scope reuses its key, but a changed payload is rejected',
        () async {
      final scope = 'test-${DateTime.now().microsecondsSinceEpoch}';
      final first = await CriticalOperationStore.begin(
        CriticalOperationType.appointment,
        scope: scope,
        requestFingerprint: criticalOperationFingerprint({'slot': 1}),
      );
      final retry = await CriticalOperationStore.begin(
        CriticalOperationType.appointment,
        scope: scope,
        requestFingerprint: criticalOperationFingerprint({'slot': 1}),
      );

      expect(retry, first);
      await expectLater(
        CriticalOperationStore.begin(
          CriticalOperationType.appointment,
          scope: scope,
          requestFingerprint: criticalOperationFingerprint({'slot': 2}),
        ),
        throwsA(isA<PendingCriticalOperationException>()),
      );
      await CriticalOperationStore.complete(
        CriticalOperationType.appointment,
        scope: scope,
      );
    });

    test('concurrent callers for one scope receive one persisted key',
        () async {
      final scope = 'concurrent-${DateTime.now().microsecondsSinceEpoch}';
      final fingerprint = criticalOperationFingerprint({'order': 7});
      final keys = await Future.wait([
        CriticalOperationStore.begin(
          CriticalOperationType.pharmacyOrder,
          scope: scope,
          requestFingerprint: fingerprint,
        ),
        CriticalOperationStore.begin(
          CriticalOperationType.pharmacyOrder,
          scope: scope,
          requestFingerprint: fingerprint,
        ),
      ]);

      expect(keys[0], keys[1]);
      expect(
        CriticalOperationStore.pendingKey(
          CriticalOperationType.pharmacyOrder,
          scope: scope,
        ),
        keys[0],
      );
      await CriticalOperationStore.complete(
        CriticalOperationType.pharmacyOrder,
        scope: scope,
      );
    });
  });

  test('FilterParams has typed, safe defaults', () {
    const params = FilterParams(moduleType: 'doctor');

    expect(params.clinicId, -1);
    expect(params.categoryId, -1);
    expect(params.governorateId, isNull);
    expect(params.ratingMin, isEmpty);
  });

  group('filter regressions', () {
    test('default ranges do not create a phantom active filter', () {
      final controller = FilterController();

      expect(
          controller.maximumPrice.value, FilterController.defaultMaximumPrice);
      expect(controller.maximumRating.value,
          FilterController.defaultMaximumRating);
      expect(controller.activeFilterCount, 0);
    });

    test('tapping an already selected item clears the applied value', () {
      final controller = FilterController();
      final service = ServiceElement(id: 7);

      controller.selectedServiceDataFunc(service);
      controller.selectedServiceDataFunc(service);

      expect(controller.selectedServiceData.value.id, isNegative);
      expect(controller.activeFilterCount, 0);
    });
  });

  group('booking cascade regressions', () {
    test('changing service clears clinic, doctor, slot, and paged lists', () {
      final controller = BookingFormController()
        ..selectedClinic(Clinic(id: 2, clinicSession: ClinicSession()))
        ..selectedDoctor(Doctor(doctorId: 3))
        ..selectedSlot('10:00')
        ..clinicList.add(Clinic(id: 2, clinicSession: ClinicSession()))
        ..doctorList.add(Doctor(doctorId: 3))
        ..clinicPage(4)
        ..doctorPage(5);

      controller.selectService(ServiceElement(id: 9, name: 'Cardiology'),
          fetchClinics: false);

      expect(controller.selectedClinic.value.id, isNegative);
      expect(controller.selectedDoctor.value.doctorId, isNegative);
      expect(controller.selectedSlot.value, isEmpty);
      expect(controller.clinicList, isEmpty);
      expect(controller.doctorList, isEmpty);
      expect(controller.clinicPage.value, 1);
      expect(controller.doctorPage.value, 1);
    });

    test('changing clinic clears doctor and slot state', () {
      final controller = BookingFormController()
        ..selectedDoctor(Doctor(doctorId: 3))
        ..selectedSlot('10:00')
        ..doctorList.add(Doctor(doctorId: 3))
        ..doctorPage(5);

      controller.selectClinic(
        Clinic(id: 8, name: 'Main clinic', clinicSession: ClinicSession()),
        fetchDoctors: false,
      );

      expect(controller.selectedDoctor.value.doctorId, isNegative);
      expect(controller.selectedSlot.value, isEmpty);
      expect(controller.doctorList, isEmpty);
      expect(controller.doctorPage.value, 1);
    });
  });

  group('ICU location formatting', () {
    test('does not render an orphan comma for missing location fields', () {
      expect(Hospital(id: 1, name: 'A').formattedLocation, isEmpty);
      expect(
        Hospital(id: 1, name: 'A', cityName: 'Cairo').formattedLocation,
        'Cairo',
      );
      expect(
        Hospital(
          id: 1,
          name: 'A',
          cityName: 'Nasr City',
          governorateName: 'Cairo',
        ).formattedLocation,
        'Nasr City, Cairo',
      );
    });
  });
}
