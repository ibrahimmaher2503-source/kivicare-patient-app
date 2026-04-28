import 'package:flutter_test/flutter_test.dart';
import 'package:kivicare_patient/screens/nurse_request/models/nurse_status.dart';

void main() {
  group('NurseStatus', () {
    test('fromString round-trips all values', () {
      expect(NurseStatusExtension.fromString('pending'), NurseStatus.pending);
      expect(NurseStatusExtension.fromString('assigned'), NurseStatus.assigned);
      expect(NurseStatusExtension.fromString('confirmed'), NurseStatus.confirmed);
      expect(NurseStatusExtension.fromString('in_progress'), NurseStatus.inProgress);
      expect(NurseStatusExtension.fromString('completed'), NurseStatus.completed);
      expect(NurseStatusExtension.fromString('cancelled'), NurseStatus.cancelled);
    });

    test('fromString defaults to pending on unknown input', () {
      expect(NurseStatusExtension.fromString(null), NurseStatus.pending);
      expect(NurseStatusExtension.fromString(''), NurseStatus.pending);
      expect(NurseStatusExtension.fromString('bogus'), NurseStatus.pending);
    });

    test('apiValue returns correct wire values', () {
      expect(NurseStatus.pending.apiValue, 'pending');
      expect(NurseStatus.assigned.apiValue, 'assigned');
      expect(NurseStatus.confirmed.apiValue, 'confirmed');
      expect(NurseStatus.inProgress.apiValue, 'in_progress');
      expect(NurseStatus.completed.apiValue, 'completed');
      expect(NurseStatus.cancelled.apiValue, 'cancelled');
    });

    test('isTerminal is true only for completed and cancelled', () {
      expect(NurseStatus.pending.isTerminal, isFalse);
      expect(NurseStatus.assigned.isTerminal, isFalse);
      expect(NurseStatus.confirmed.isTerminal, isFalse);
      expect(NurseStatus.inProgress.isTerminal, isFalse);
      expect(NurseStatus.completed.isTerminal, isTrue);
      expect(NurseStatus.cancelled.isTerminal, isTrue);
    });
  });
}
