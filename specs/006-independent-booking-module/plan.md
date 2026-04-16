# Implementation Plan: Independent Doctor Booking Module

**Branch**: `006-independent-booking-module` | **Date**: 2026-03-29 | **Spec**: [spec.md](spec.md)
**Input**: Feature specification from `/specs/006-independent-booking-module/spec.md`

## Summary

Build a new Independent Doctor Booking module allowing patients to
book in-person appointments directly with doctors outside clinic
scheduling. The flow mirrors Call Booking (doctor list → services →
date → slots → book) but for in-person consultations with finer slot
intervals (10 min default), inclusive tax display, and no meeting
links. Connects to 4 REST API endpoints.

**Critical finding**: Brand new module — no existing code. Structure
mirrors `lib/screens/call_booking/` closely. Can reuse TimeSlot model
and time_slot_chip.dart component from Call Booking.

## Technical Context

**Language/Version**: Dart 3.0+ / Flutter 3.0+
**Primary Dependencies**: GetX 4.7.2+, nb_utils, http, google_fonts
**Storage**: GetStorage (non-sensitive), platform keychain (tokens)
**Target Platform**: Android (primary), iOS, Web
**Project Type**: Mobile app (Flutter cross-platform)
**Scale/Scope**: 4 API endpoints, 3 models (reuse TimeSlot), ~12 new files

## Constitution Check

| Principle | Status | Notes |
|-----------|--------|-------|
| I. Platform Parity | PASS | Flutter widgets only. |
| II. Patient Data Security | PASS | Auth via Bearer tokens. |
| III. GetX Architecture | PASS | Standard patterns. |
| IV. Backend Contract Fidelity | PASS | Endpoints in api_end_points.dart. |
| V. Localization-First | PASS | All strings via locale.value. |
| VI. Testing Discipline | N/A | Not mandatory. |
| VII. Simplicity | PASS | No new packages. Reuses TimeSlot + chip from Call Booking. |

## Project Structure

### Source Code (NEW)

```text
lib/
├── api/
│   └── core_apis.dart                              # Add ~4 API methods
├── screens/
│   └── independent_booking/                        # NEW DIRECTORY
│       ├── model/
│       │   ├── independent_doctor_model.dart       # Doctor + Service models
│       │   └── independent_booking_model.dart      # Booking model
│       ├── components/
│       │   ├── independent_doctor_card.dart         # Doctor list card
│       │   ├── independent_service_card.dart        # Service with tax display
│       │   └── independent_booking_card.dart        # Booking list card
│       ├── independent_doctor_list_controller.dart
│       ├── independent_doctor_list_screen.dart
│       ├── independent_doctor_detail_screen.dart
│       ├── book_independent_controller.dart         # Slot + booking
│       ├── book_independent_screen.dart
│       ├── independent_booking_list_controller.dart
│       ├── independent_booking_list_screen.dart
│       └── independent_booking_detail_screen.dart
├── utils/
│   ├── api_end_points.dart                         # Add 4 endpoints
│   └── colors.dart                                 # Add booking colors (if needed)
├── locale/                                          # Extend all 6 locale files
└── screens/home/components/
    └── quick_services_component.dart               # Add entry points
```

**Reuse from Call Booking**:
- `lib/screens/call_booking/model/time_slot_model.dart` (TimeSlot)
- `lib/screens/call_booking/components/time_slot_chip.dart` (TimeSlotChip)

## Complexity Tracking

No constitution violations. Reuses existing components.
