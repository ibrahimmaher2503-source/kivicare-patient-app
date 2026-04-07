/// Form Validation Utilities
/// Provides validation methods for labs/radiology booking forms

class FormValidators {
  /// Validate booking date (must be today or future, Y-m-d format)
  /// Returns error message if invalid, null if valid
  static String? validateBookingDate(String? value) {
    if (value == null || value.isEmpty) {
      return 'Booking date is required';
    }

    try {
      final date = DateTime.parse(value);
      final today = DateTime.now();
      final todayOnly = DateTime(today.year, today.month, today.day);

      if (date.isBefore(todayOnly)) {
        return 'Booking date must be today or in the future';
      }
      return null;
    } catch (e) {
      return 'Invalid date format (use YYYY-MM-DD)';
    }
  }

  /// Validate future date (must be after today, Y-m-d format)
  /// Returns error message if invalid, null if valid
  static String? validateFutureDate(String? value) {
    if (value == null || value.isEmpty) {
      return 'Date is required';
    }

    try {
      final date = DateTime.parse(value);
      final tomorrow = DateTime.now().add(const Duration(days: 1));
      final tomorrowOnly = DateTime(tomorrow.year, tomorrow.month, tomorrow.day);

      if (!date.isAfter(tomorrowOnly)) {
        return 'Date must be in the future';
      }
      return null;
    } catch (e) {
      return 'Invalid date format (use YYYY-MM-DD)';
    }
  }

  /// Validate time format (H:i format, e.g., "09:30" or "9:30")
  /// Returns error message if invalid, null if valid
  static String? validateTime(String? value) {
    if (value == null || value.isEmpty) {
      return 'Time is required';
    }

    final timeRegex = RegExp(r'^([0-1]?[0-9]|2[0-3]):([0-5][0-9])$');
    if (!timeRegex.hasMatch(value)) {
      return 'Invalid time format (use HH:MM)';
    }

    try {
      final parts = value.split(':');
      final hour = int.parse(parts[0]);
      final minute = int.parse(parts[1]);

      if (hour < 0 || hour > 23 || minute < 0 || minute > 59) {
        return 'Invalid time values';
      }
      return null;
    } catch (e) {
      return 'Invalid time format';
    }
  }

  /// Validate patient name (non-empty, 2-255 characters, alphanumeric with spaces)
  /// Returns error message if invalid, null if valid
  static String? validatePatientName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Patient name is required';
    }

    final trimmed = value.trim();
    if (trimmed.length < 2) {
      return 'Patient name must be at least 2 characters';
    }

    if (trimmed.length > 255) {
      return 'Patient name cannot exceed 255 characters';
    }

    // Allow letters, spaces, hyphens, and apostrophes
    final nameRegex = RegExp(r"^[a-zA-Z\s\-']+$");
    if (!nameRegex.hasMatch(trimmed)) {
      return 'Patient name can only contain letters, spaces, hyphens, and apostrophes';
    }

    return null;
  }

  /// Validate phone number (international format, 10-50 characters)
  /// Returns error message if invalid, null if valid
  static String? validatePhoneNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Phone number is required';
    }

    final trimmed = value.trim();
    if (trimmed.length < 10) {
      return 'Phone number must be at least 10 digits';
    }

    if (trimmed.length > 50) {
      return 'Phone number cannot exceed 50 characters';
    }

    // Allow digits, +, -, spaces, parentheses
    final phoneRegex = RegExp(r'^[\d\s\-\+\(\)]+$');
    if (!phoneRegex.hasMatch(trimmed)) {
      return 'Phone number contains invalid characters';
    }

    return null;
  }

  /// Validate clinical notes (optional, max 2000 characters)
  /// Returns error message if invalid, null if valid
  static String? validateClinicalNotes(String? value) {
    if (value == null || value.isEmpty) {
      return null; // Optional field
    }

    if (value.length > 2000) {
      return 'Clinical notes cannot exceed 2000 characters';
    }

    return null;
  }

  /// Validate booking notes (optional, max 1000 characters)
  /// Returns error message if invalid, null if valid
  static String? validateBookingNotes(String? value) {
    if (value == null || value.isEmpty) {
      return null; // Optional field
    }

    if (value.length > 1000) {
      return 'Notes cannot exceed 1000 characters';
    }

    return null;
  }

  /// Validate cancellation reason (required, max 500 characters)
  /// Returns error message if invalid, null if valid
  static String? validateCancellationReason(String? value) {
    if (value == null || value.isEmpty) {
      return 'Cancellation reason is required';
    }

    if (value.length > 500) {
      return 'Cancellation reason cannot exceed 500 characters';
    }

    return null;
  }

  /// Validate test selection (at least 1 test selected)
  /// Returns error message if invalid, null if valid
  static String? validateTestSelection(List? tests) {
    if (tests == null || tests.isEmpty) {
      return 'Please select at least one test';
    }

    return null;
  }

  /// Validate slot selection (slot must be selected)
  /// Returns error message if invalid, null if valid
  static String? validateSlotSelection(String? slotTime) {
    if (slotTime == null || slotTime.isEmpty) {
      return 'Please select an available slot';
    }

    return null;
  }

  /// Validate facility selection (facility must be selected)
  /// Returns error message if invalid, null if valid
  static String? validateFacilitySelection(int? facilityId) {
    if (facilityId == null || facilityId <= 0) {
      return 'Please select a facility';
    }

    return null;
  }

  /// Validate priority selection (must be valid priority)
  /// Returns error message if invalid, null if valid
  static String? validatePriority(String? priority) {
    if (priority == null || priority.isEmpty) {
      return 'Please select a priority level';
    }

    final validPriorities = ['routine', 'urgent', 'stat'];
    if (!validPriorities.contains(priority)) {
      return 'Invalid priority level';
    }

    return null;
  }

  /// Validate booking status (must be valid status)
  /// Returns error message if invalid, null if valid
  static String? validateBookingStatus(String? status) {
    if (status == null || status.isEmpty) {
      return 'Invalid booking status';
    }

    final validStatuses = ['pending', 'confirmed', 'cancelled', 'completed', 'no_show'];
    if (!validStatuses.contains(status)) {
      return 'Invalid booking status';
    }

    return null;
  }

  /// Check if date is in valid range (not too far in future)
  /// Default: 90 days from now
  static String? validateDateRange(String? dateString, {int maxDaysFromNow = 90}) {
    if (dateString == null || dateString.isEmpty) {
      return 'Date is required';
    }

    try {
      final date = DateTime.parse(dateString);
      final today = DateTime.now();
      final maxDate = today.add(Duration(days: maxDaysFromNow));

      if (date.isAfter(maxDate)) {
        return 'Booking cannot be made more than $maxDaysFromNow days in advance';
      }

      return null;
    } catch (e) {
      return 'Invalid date format';
    }
  }

  /// Get character count for notes (for display)
  static int getCharacterCount(String? value) {
    return value?.length ?? 0;
  }

  /// Check if character count exceeds maximum
  static bool isCharCountExceeded(String? value, int maxChars) {
    return (value?.length ?? 0) > maxChars;
  }
}
