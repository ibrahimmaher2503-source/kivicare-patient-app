/// Lab Test & Radiology Booking Constants
/// Enums and constants for sample types, departments, priorities, statuses, and payment states

enum SampleType {
  blood('blood'),
  urine('urine'),
  stool('stool'),
  tissue('tissue'),
  imaging('imaging'),
  swab('swab'),
  other('other');

  final String value;
  const SampleType(this.value);

  /// Parse string value to enum
  static SampleType? fromString(String? value) {
    try {
      return SampleType.values.firstWhere((e) => e.value == value);
    } catch (e) {
      return null;
    }
  }
}

enum Department {
  laboratory('laboratory'),
  radiology('radiology');

  final String value;
  const Department(this.value);

  /// Parse string value to enum
  static Department? fromString(String? value) {
    try {
      return Department.values.firstWhere((e) => e.value == value);
    } catch (e) {
      return null;
    }
  }
}

enum Priority {
  routine('routine'),
  urgent('urgent'),
  stat('stat');

  final String value;
  const Priority(this.value);

  /// Parse string value to enum
  static Priority? fromString(String? value) {
    try {
      return Priority.values.firstWhere((e) => e.value == value);
    } catch (e) {
      return null;
    }
  }
}

enum OrderStatus {
  pending('pending'),
  confirmed('confirmed'),
  sampleCollected('sample_collected'),
  processing('processing'),
  completed('completed'),
  delivered('delivered'),
  cancelled('cancelled');

  final String value;
  const OrderStatus(this.value);

  /// Parse string value to enum
  static OrderStatus? fromString(String? value) {
    try {
      return OrderStatus.values.firstWhere((e) => e.value == value);
    } catch (e) {
      return null;
    }
  }

  /// Get localization key for status display
  String getLocaleKey() {
    switch (this) {
      case OrderStatus.pending:
        return 'pending';
      case OrderStatus.confirmed:
        return 'confirmed';
      case OrderStatus.sampleCollected:
        return 'sampleCollected';
      case OrderStatus.processing:
        return 'processing';
      case OrderStatus.completed:
        return 'completed';
      case OrderStatus.delivered:
        return 'delivered';
      case OrderStatus.cancelled:
        return 'cancelled';
    }
  }
}

enum PaymentStatus {
  unpaid('unpaid'),
  partial('partial'),
  paid('paid');

  final String value;
  const PaymentStatus(this.value);

  /// Parse string value to enum
  static PaymentStatus? fromString(String? value) {
    try {
      return PaymentStatus.values.firstWhere((e) => e.value == value);
    } catch (e) {
      return null;
    }
  }
}

enum BookingStatus {
  pending('pending'),
  confirmed('confirmed'),
  cancelled('cancelled'),
  completed('completed'),
  noShow('no_show');

  final String value;
  const BookingStatus(this.value);

  /// Parse string value to enum
  static BookingStatus? fromString(String? value) {
    try {
      return BookingStatus.values.firstWhere((e) => e.value == value);
    } catch (e) {
      return null;
    }
  }

  /// Get localization key for status display
  String getLocaleKey() {
    switch (this) {
      case BookingStatus.pending:
        return 'pending';
      case BookingStatus.confirmed:
        return 'confirmed';
      case BookingStatus.cancelled:
        return 'cancelled';
      case BookingStatus.completed:
        return 'completed';
      case BookingStatus.noShow:
        return 'noShow';
    }
  }
}

/// Facility Type Constants
class FacilityType {
  static const String lab = 'lab';
  static const String radiology = 'radiology';

  static const List<String> all = [lab, radiology];
}

/// Slot Time Configuration
class SlotConfig {
  static const int slotIntervalMinutes = 30;
  static const String slotTimeFormat = 'H:i';
  static const String dateFormat = 'Y-m-d';
}

/// API Response Pagination
class PaginationConfig {
  static const int defaultPerPage = 15;
  static const int maxPerPage = 100;
}
