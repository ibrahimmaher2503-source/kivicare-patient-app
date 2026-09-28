import 'package:flutter_test/flutter_test.dart';
import 'package:kivicare_patient/screens/labs_radiology/models/facility_list_response.dart';
import 'package:kivicare_patient/screens/labs_radiology/models/facility_type.dart';

void main() {
  group('FacilityListResponse', () {
    test('parses wrapped items and pagination response', () {
      final response = FacilityListResponse.fromJson(
        {
          'status': true,
          'data': {
            'items': [
              {
                'id': 1,
                'name': 'Nile Radiology Center',
                'scan_type': 'x-ray',
                'governorate': {'id': 1, 'name': 'Cairo'},
                'city': {'id': 1, 'name': 'Nasr City'},
                'branch': null,
              },
            ],
            'pagination': {
              'current_page': 1,
              'last_page': 2,
              'per_page': 15,
              'total': 16,
            },
          },
          'message': '',
        },
        fallbackType: FacilityType.radiology,
      );

      expect(response.data, hasLength(1));
      expect(response.data.first.id, 1);
      expect(response.data.first.name, 'Nile Radiology Center');
      expect(response.data.first.type, FacilityType.radiology);
      expect(response.data.first.governorate, 'Cairo');
      expect(response.data.first.city, 'Nasr City');
      expect(response.currentPage, 1);
      expect(response.lastPage, 2);
      expect(response.total, 16);
      expect(response.hasMore, isTrue);
    });

    test('still parses flat paginator response', () {
      final response = FacilityListResponse.fromJson(
        {
          'data': [
            {
              'id': 2,
              'name': 'Central Lab',
              'facility_type': 'lab',
            },
          ],
          'current_page': '2',
          'last_page': 3,
          'total': '30',
        },
        fallbackType: FacilityType.radiology,
      );

      expect(response.data, hasLength(1));
      expect(response.data.first.type, FacilityType.lab);
      expect(response.currentPage, 2);
      expect(response.lastPage, 3);
      expect(response.total, 30);
      expect(response.hasMore, isTrue);
    });
  });
}
