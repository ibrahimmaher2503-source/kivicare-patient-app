import 'package:flutter_test/flutter_test.dart';
import 'package:kivicare_patient/api/pharmacy_apis.dart';

void main() {
  group('parsePrescriptionUploadResponse', () {
    test('returns the accepted prescription from a nested response', () {
      final prescription = parsePrescriptionUploadResponse({
        'status': true,
        'data': {
          'prescription': {
            'id': 42,
            'status': 'pending',
            'images': ['prescription.jpg'],
          },
        },
      });

      expect(prescription.id, 42);
      expect(prescription.status, 'pending');
    });

    test('rejects an HTTP-success response with a logical failure', () {
      expect(
        () => parsePrescriptionUploadResponse({
          'status': false,
          'message': 'Upload rejected',
        }),
        throwsA(isA<FormatException>()),
      );
    });

    test('rejects a success response without a persisted id', () {
      expect(
        () => parsePrescriptionUploadResponse({
          'status': true,
          'data': {'id': 0, 'status': 'pending'},
        }),
        throwsA(isA<FormatException>()),
      );
    });
  });
}
