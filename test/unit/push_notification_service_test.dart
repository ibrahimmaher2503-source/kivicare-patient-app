import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:kivicare_patient/utils/push_notification_service.dart';

void main() {
  test('Android 13 notification permission is declared before it is requested', () {
    final manifest = File('android/app/src/main/AndroidManifest.xml')
        .readAsStringSync();
    final source =
        File('lib/utils/push_notification_service.dart').readAsStringSync();

    expect(manifest, contains('android.permission.POST_NOTIFICATIONS'));
    expect(source, contains('FirebaseMessaging.instance.requestPermission('));
  });

  test('pending refreshed token is preferred and only cleared after sync', () {
    final source =
        File('lib/utils/push_notification_service.dart').readAsStringSync();

    expect(
      RegExp(
        r'final token\s*=\s*_pendingRefreshedToken\s*\?\?\s*'
        r'await\s+FirebaseMessaging\.instance\.getToken\(\);',
      ).hasMatch(source),
      isTrue,
    );

    final updateIndex =
        source.indexOf('await AuthServiceApis.updateProfile(playerId: token);');
    final clearIndex =
        source.indexOf('_pendingRefreshedToken = null;', updateIndex);
    expect(updateIndex, greaterThanOrEqualTo(0));
    expect(clearIndex, greaterThan(updateIndex));
  });

  group('notification payload route classification', () {
    test(
        'covers appointment, nurse, ICU, pharmacy, labs, doctor visit, incident, and encounter',
        () {
      expect(
        PushNotificationService.classifyNotificationRoute(
          {'type': 'new_appointment', 'id': 10},
        ),
        PushNotificationRoute.appointment,
      );
      expect(
        PushNotificationService.classifyNotificationRoute(
          {'type': 'nurse_request_status_changed', 'request_id': '11'},
        ),
        PushNotificationRoute.nurseRequest,
      );
      expect(
        PushNotificationService.classifyNotificationRoute(
          {'type': 'icu_admission_status_changed', 'request_id': 12},
        ),
        PushNotificationRoute.icuAdmission,
      );
      expect(
        PushNotificationService.classifyNotificationRoute(
          {'type': 'pharmacy_order_status_changed', 'order_id': 13},
        ),
        PushNotificationRoute.pharmacyOrder,
      );
      expect(
        PushNotificationService.classifyNotificationRoute(
          {'type': 'lab_order_status_changed', 'test_order_id': 14},
        ),
        PushNotificationRoute.labOrder,
      );
      expect(
        PushNotificationService.classifyNotificationRoute(
          {'type': 'doctor_visit_status_changed', 'reference_number': 'V-15'},
        ),
        PushNotificationRoute.doctorVisit,
      );
      expect(
        PushNotificationService.classifyNotificationRoute(
          {'type': 'incident_status_changed'},
        ),
        PushNotificationRoute.incident,
      );
      expect(
        PushNotificationService.classifyNotificationRoute(
          {'type': 'encounter_update', 'encounter_id': 16},
        ),
        PushNotificationRoute.encounter,
      );
    });

    test('normalizes nested JSON additional_data before classification', () {
      expect(
        PushNotificationService.classifyNotificationRoute({
          'additional_data':
              '{"type":"nurse_request_status_changed","request_id":"17"}',
        }),
        PushNotificationRoute.nurseRequest,
      );
    });

    test('accepts backend order_id for test orders', () {
      final payload = {'type': 'test_order_status_changed', 'order_id': 42};

      expect(
        PushNotificationService.classifyNotificationRoute(payload),
        PushNotificationRoute.labOrder,
      );
      expect(
        PushNotificationService.testOrderIdFromNotification(payload),
        42,
      );
    });

    test('falls back safely for malformed additional_data and unknown payloads',
        () {
      expect(
        PushNotificationService.classifyNotificationRoute({
          'additional_data': '{not-json',
          'type': 'unknown_status',
        }),
        PushNotificationRoute.notifications,
      );
      expect(
        PushNotificationService.classifyNotificationRoute({
          'type': 'new_appointment',
          'id': 'not-an-id',
        }),
        PushNotificationRoute.notifications,
      );
    });
  });
}
