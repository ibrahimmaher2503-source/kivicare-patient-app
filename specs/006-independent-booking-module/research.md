# Research: Independent Doctor Booking Module

**Branch**: `006-independent-booking-module` | **Date**: 2026-03-29

## Key Finding: Mirrors Call Booking

Structure is nearly identical to Call Booking but for in-person
appointments. Key differences: no meeting links, no call types,
10-min default slots (vs 15), inclusive tax display, booking_type
= "independent".

## Reuse Opportunities

- **TimeSlot model**: Reuse from `lib/screens/call_booking/model/time_slot_model.dart`
- **TimeSlotChip widget**: Reuse from `lib/screens/call_booking/components/time_slot_chip.dart`
- **Slot fetching pattern**: Same POST-for-slots approach
- **Booking confirmation pattern**: Same dialog pattern (minus meeting link)

## Decisions

### D1: Separate Module vs Extending Call Booking
- **Decision**: Separate module at `lib/screens/independent_booking/`
- **Rationale**: Different API endpoints, different service model
  fields (inclusive tax), different booking_type. Keeping separate
  follows the per-feature directory convention. Share via imports.

### D2: Tax Display
- **Decision**: Parse inclusive_tax JSON and display tax breakdown
  in service cards and booking detail. Show: charges, discount,
  tax items, and final total.
- **Rationale**: API provides inclusive_tax as JSON string with
  title, type, and value. Client can parse and display.

### D3: No New Dependencies
- **Decision**: No new packages.
