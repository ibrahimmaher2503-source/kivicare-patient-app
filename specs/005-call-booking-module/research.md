# Research: Call Booking Module

**Branch**: `005-call-booking-module` | **Date**: 2026-03-29

## Key Finding: Brand New Module

No existing code for call booking. All files must be built from
scratch following established patterns.

## Decisions

### D1: Time Slot UI Pattern
- **Decision**: Grid of selectable chips (like appointment slot
  pickers in other healthcare apps). Selected slot highlighted
  with gradient.
- **Rationale**: Familiar pattern, easy to scan available times.

### D2: Meeting Link Handling
- **Decision**: Use `url_launcher` (already in pubspec) to open
  meeting links in the device browser. Show "Join Call" button
  only for video bookings with a meeting link.
- **Rationale**: Jitsi works in browser. No need for in-app
  WebView — simpler and cross-platform.

### D3: Booking List vs Existing Appointments
- **Decision**: Dedicated "My Call Bookings" section separate from
  regular appointments. Uses the existing appointments API filtered
  by booking_type="call" or a dedicated endpoint.
- **Rationale**: Clearer separation of call bookings from in-person
  visits. Matches the module-per-feature pattern.

### D4: Payment Method
- **Decision**: Default to "cash" with dropdown for other methods.
  Don't implement full payment flow in this module — just pass
  the transaction_type to the API.
- **Rationale**: Existing payment gateway integrations handle the
  actual payment processing. This module just selects the method.

### D5: No New Dependencies
- **Decision**: No new packages needed.
- **Rationale**: url_launcher already in pubspec for meeting links.
