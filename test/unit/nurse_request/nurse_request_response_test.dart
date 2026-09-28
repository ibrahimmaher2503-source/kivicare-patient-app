import 'package:flutter_test/flutter_test.dart';
import 'package:kivicare_patient/screens/nurse_request/models/nurse_request_list_response.dart';

void main() {
  test('parses Laravel nurse request pagination and its legacy nested fields',
      () {
    final response = NurseRequestListResponse.fromJson({
      'data': [
        {
          'id': 7,
          'service_description_en': 'Daily care',
          'preferred_date': '2026-08-27',
          'duration_hours': '2.00',
          'address': {'address_line_1': '12 Test St', 'city': 'Cairo'},
          'contact_number': '+201001234567',
          'payment_status': true,
          'created_at': '2026-08-26T10:00:00Z',
          'updated_at': '2026-08-26T10:00:00Z',
        },
      ],
      'meta': {'current_page': 1, 'last_page': 1, 'per_page': 15, 'total': 1},
    });

    final request = response.data.single;
    expect(request.referenceNumber, 'NR-000007');
    expect(request.durationHours, 2);
    expect(request.addressLine1, '12 Test St');
    expect(request.contactPhone, '+201001234567');
    expect(request.paymentStatus, 'paid');
  });

  test('parses an empty Laravel nurse request page', () {
    final response = NurseRequestListResponse.fromJson({
      'data': [],
      'meta': {'current_page': 1, 'last_page': 1, 'per_page': 15, 'total': 0},
    });

    expect(response.data, isEmpty);
    expect(response.hasMore, isFalse);
  });
}
