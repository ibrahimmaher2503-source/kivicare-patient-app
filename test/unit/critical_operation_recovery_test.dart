import 'package:flutter_test/flutter_test.dart';
import 'package:kivicare_patient/api/core_apis.dart';
import 'package:kivicare_patient/api/icu_apis.dart';
import 'package:kivicare_patient/api/labs_radiology_apis.dart';
import 'package:kivicare_patient/network/network_utils.dart';

void main() {
  test('booking malformed success stays ambiguous', () {
    expect(
      () => parseBookingSubmissionResponse('{"status":true}'),
      throwsA(isA<AmbiguousRequestOutcomeException>()),
    );
    expect(
      () => parseBookingSubmissionResponse('not-json'),
      throwsA(isA<AmbiguousRequestOutcomeException>()),
    );
  });

  test('booking explicitly rejected response remains a definite failure', () {
    expect(
      () => parseBookingSubmissionResponse({
        'status': false,
        'message': 'slot unavailable',
      }),
      throwsA(isA<StateError>()),
    );
  });

  test('lab order requires a usable receipt before clearing pending state', () {
    expect(
      () => LabsRadiologyApis.parseCreatedTestOrderResponse({
        'data': {'id': 0, 'reference_number': ''},
      }),
      throwsA(isA<AmbiguousRequestOutcomeException>()),
    );
    expect(
      () => LabsRadiologyApis.parseCreatedTestOrderResponse('accepted'),
      throwsA(isA<AmbiguousRequestOutcomeException>()),
    );
  });

  test('ICU admission requires both id and reference', () {
    expect(
      () => parseIcuAdmissionResponse({
        'data': {'id': 4, 'request_number': ''},
      }),
      throwsA(isA<AmbiguousRequestOutcomeException>()),
    );

    final receipt = parseIcuAdmissionResponse({
      'data': {'id': 4, 'request_number': 'ICU-4'},
    });
    expect(receipt.id, 4);
    expect(receipt.referenceNumber, 'ICU-4');
  });
}
