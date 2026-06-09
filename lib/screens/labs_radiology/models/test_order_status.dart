import '../../../locale/languages.dart';

enum TestOrderStatus {
  pending,
  confirmed,
  sampleCollected,
  inProgress,
  completed,
  cancelled,
  rejected;

  static TestOrderStatus fromString(String? s) {
    switch (s?.toLowerCase()) {
      case 'confirmed':
        return TestOrderStatus.confirmed;
      case 'sample_collected':
        return TestOrderStatus.sampleCollected;
      case 'in_progress':
        return TestOrderStatus.inProgress;
      case 'completed':
        return TestOrderStatus.completed;
      case 'cancelled':
        return TestOrderStatus.cancelled;
      case 'rejected':
        return TestOrderStatus.rejected;
      case 'pending':
      default:
        return TestOrderStatus.pending;
    }
  }

  String get apiValue {
    switch (this) {
      case TestOrderStatus.sampleCollected:
        return 'sample_collected';
      case TestOrderStatus.inProgress:
        return 'in_progress';
      default:
        return name;
    }
  }

  bool get isTerminal =>
      this == TestOrderStatus.completed ||
      this == TestOrderStatus.cancelled ||
      this == TestOrderStatus.rejected;

  bool get isCancellable =>
      this == TestOrderStatus.pending || this == TestOrderStatus.confirmed;

  // Note: These getters will be wired to locale keys added in T021/T022
  String displayLabel(BaseLanguage l) {
    switch (this) {
      case TestOrderStatus.pending:
        return l.statusPending;
      case TestOrderStatus.confirmed:
        return l.statusConfirmed;
      case TestOrderStatus.sampleCollected:
        return l.statusSampleCollected;
      case TestOrderStatus.inProgress:
        return l.statusInProgress;
      case TestOrderStatus.completed:
        return l.statusCompleted;
      case TestOrderStatus.cancelled:
        return l.statusCancelled;
      case TestOrderStatus.rejected:
        return l.statusRejected;
    }
  }
}

enum PaymentStatus {
  unpaid,
  paid,
  refunded;

  static PaymentStatus fromString(String? s) {
    switch (s?.toLowerCase()) {
      case 'paid':
        return PaymentStatus.paid;
      case 'refunded':
        return PaymentStatus.refunded;
      case 'unpaid':
      default:
        return PaymentStatus.unpaid;
    }
  }

  String get apiValue => name;

  String displayLabel(BaseLanguage l) {
    switch (this) {
      case PaymentStatus.unpaid:
        return 'Unpaid';
      case PaymentStatus.paid:
        return l.paid;
      case PaymentStatus.refunded:
        return l.refunded;
    }
  }
}
