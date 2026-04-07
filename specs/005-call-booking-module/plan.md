# Implementation Plan: Call Booking Module

**Branch**: `005-call-booking-module` | **Date**: 2026-03-29 | **Spec**: [spec.md](spec.md)
**Input**: Feature specification from `/specs/005-call-booking-module/spec.md`

## Summary

Build a new Call Booking module for the Espitalia Patient App allowing
patients to browse doctors offering video/phone consultations, view
call services with pricing, select available time slots, book calls,
and access meeting links. The module connects to 4-5 REST API
endpoints on the Laravel backend.

**Critical finding**: This is a **brand new module** — no existing
code. All files must be created from scratch following patterns from
existing modules (lab_test, nurse, icu).

## Technical Context

**Language/Version**: Dart 3.0+ / Flutter 3.0+
**Primary Dependencies**: GetX 4.7.2+, nb_utils, http, google_fonts, url_launcher
**Storage**: GetStorage (non-sensitive), platform keychain (tokens)
**Testing**: flutter test (recommended, not mandatory per constitution)
**Target Platform**: Android (primary), iOS, Web
**Project Type**: Mobile app (Flutter cross-platform)
**Performance Goals**: Screen load <2s, slot loading <1s
**Constraints**: Must use existing network layer, GetX patterns,
Clinical Elegance design tokens. Meeting links open via url_launcher.
**Scale/Scope**: 4-5 API endpoints, 4 models, ~12-15 new files,
5 language files to extend

## Constitution Check

| Principle | Status | Notes |
|-----------|--------|-------|
| I. Platform Parity | PASS | Flutter widgets, url_launcher for meeting links is cross-platform. |
| II. Patient Data Security | PASS | Auth via Bearer tokens. No sensitive data stored locally. |
| III. GetX Architecture | PASS | Standard patterns: .obs, Obx(), Get.to(), Get.put(). |
| IV. Backend Contract Fidelity | PASS | Endpoints in api_end_points.dart, methods in core_apis.dart. |
| V. Localization-First | PASS | All strings via locale.value. Keys in all 5 files. |
| VI. Testing Discipline | N/A | Not mandatory for this module. |
| VII. Simplicity | PASS | No new packages. url_launcher already in pubspec. |

## Project Structure

### Source Code (NEW — to be created)

```text
lib/
├── api/
│   └── core_apis.dart                         # Add ~5 call booking API methods
├── screens/
│   └── call_booking/                          # NEW DIRECTORY
│       ├── model/
│       │   ├── call_doctor_model.dart         # CallDoctor + CallService models
│       │   ├── time_slot_model.dart           # TimeSlot model
│       │   └── call_booking_model.dart        # CallBooking model
│       ├── components/
│       │   ├── call_doctor_card.dart          # Doctor list card
│       │   ├── call_service_card.dart         # Service card with pricing
│       │   ├── time_slot_chip.dart            # Selectable time slot widget
│       │   └── call_booking_card.dart         # Booking list card
│       ├── call_doctor_list_controller.dart
│       ├── call_doctor_list_screen.dart
│       ├── call_doctor_detail_screen.dart     # Profile + services
│       ├── book_call_controller.dart          # Slot selection + booking
│       ├── book_call_screen.dart              # Date picker + slot grid + confirm
│       ├── call_booking_list_controller.dart
│       ├── call_booking_list_screen.dart
│       └── call_booking_detail_screen.dart    # Booking detail + meeting link
├── utils/
│   ├── api_end_points.dart                   # Add ~5 call endpoints
│   ├── colors.dart                           # Add call type colors
│   └── constants.dart                        # Add call type constants
├── locale/                                    # Extend all 6 locale files
└── screens/home/components/
    └── quick_services_component.dart          # Add call booking entry
```

## Complexity Tracking

No constitution violations. Meeting links use existing url_launcher.
