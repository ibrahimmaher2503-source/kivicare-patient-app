import 'package:kivicare_patient/locale/languages.dart';

enum NurseStatus { pending, assigned, confirmed, inProgress, completed, cancelled }

extension NurseStatusExtension on NurseStatus {
  static NurseStatus fromString(String? value) {
    switch (value) {
      case 'assigned': return NurseStatus.assigned;
      case 'confirmed': return NurseStatus.confirmed;
      case 'in_progress': return NurseStatus.inProgress;
      case 'completed': return NurseStatus.completed;
      case 'cancelled': return NurseStatus.cancelled;
      default: return NurseStatus.pending;
    }
  }

  String get apiValue {
    if (this == NurseStatus.inProgress) return 'in_progress';
    return name;
  }

  bool get isTerminal => this == NurseStatus.completed || this == NurseStatus.cancelled;

  String displayLabel(BaseLanguage locale) {
    switch (this) {
      case NurseStatus.pending: return locale.nurseStatusPending;
      case NurseStatus.assigned: return locale.nurseStatusAssigned;
      case NurseStatus.confirmed: return locale.nurseStatusConfirmed;
      case NurseStatus.inProgress: return locale.nurseStatusInProgress;
      case NurseStatus.completed: return locale.nurseStatusCompleted;
      case NurseStatus.cancelled: return locale.nurseStatusCancelled;
    }
  }
}
