# Implementation Plan: Labs & Radiology Booking Module

**Branch**: `022-labs-radiology-booking` | **Date**: 2026-04-29 | **Spec**: [spec.md](./spec.md)
**Input**: Feature specification from `/specs/022-labs-radiology-booking/spec.md`

## Summary

Add a Vezeeta-style diagnostic booking module to the Espitalia Patient App covering both **Labs** and **Radiology Centers** as a single unified `Facility` concept (FacilityType enum: `lab` | `radiology`). Patients discover facilities, browse a test catalog by category or search, view facility details, pick a slot, confirm a booking, track orders through a status timeline, cancel while permitted, and download report PDFs when completed.

**Technical approach**: 8 screens under `lib/screens/labs_radiology/` organised by step (hub, categories, tests, facility_detail, slot_selection, booking_confirmation, orders), one API service file `lib/api/labs_radiology_apis.dart` calling the existing Laravel endpoints via `buildHttpResponse()`, GetX controllers (transient — no `permanent: true`), reuse of the existing Location Filter module, design-token styling already in `colors.dart`, and a small `ReportDownloadService` that streams a PDF to `getApplicationDocumentsDirectory()` and opens it. Categories are cached in GetStorage with a 7-day TTL. Booking creation goes through `POST /v1/test-orders`; `POST /v1/facility-bookings` is treated as a fallback only and confirmed with the backend before Phase 4 (see research.md decision R-1).

## Technical Context

**Language/Version**: Dart 3.0+ / Flutter 3.0+
**Primary Dependencies**: GetX 4.7.2+ (state, DI, navigation), `http` (via `lib/network/network_utils.dart`), `nb_utils` (existing styling helpers), `cached_network_image` (via `cached_image_widget`), `intl` (date/number formatting), `url_launcher` (tap-to-call, open in maps), `path_provider` (already in tree via Firebase), `permission_handler` (already in tree via location services), `open_filex` — verify version, otherwise add (R-2)
**Storage**: GetStorage (non-sensitive: cached test categories, last-selected facility tab); device file system via `getApplicationDocumentsDirectory()` for downloaded reports
**Testing**: `flutter test` for unit tests on models, payload builders, and status-history derivation; manual QA for screens (per Constitution VI — recommended, not mandatory). No live backend in tests.
**Target Platform**: Android (primary, fully configured), iOS (Firebase placeholder — feature must build and run, file download path must work via path_provider's iOS Documents dir), Web (graceful degradation only — file download falls back to browser download or shows "Not available on web" message; see R-3).
**Project Type**: Mobile-first Flutter app (also Web). Single `lib/` tree.
**Performance Goals**: First meaningful paint of hub list under 2s on 4G; slot grid loads under 1s after date tap; debounced search inputs at 400ms (server) / 200ms (client) per spec.
**Constraints**: Zero new `flutter analyze` warnings; no new state-management library; one test per booking (no cart); no admin endpoints; all strings via `locale.value.<key>`; RTL parity for calendar strip and slot grid.
**Scale/Scope**: 8 patient-facing screens + 1 booking-success screen + 1 test-detail bottom sheet; ~14 reusable components; 13 data models; 12 API methods; ~80 new locale keys × 2 languages.

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

| Principle | Status | Notes |
|-----------|--------|-------|
| **I. Platform Parity** | ✅ Pass | Plan accounts for Android (primary), iOS (Documents dir + permissions), Web (graceful degradation for download — explicitly mentioned, not a runtime crash). All three platforms must build. Open-in-Maps and tap-to-call use `url_launcher` which has cross-platform support. |
| **II. Patient Data Security** | ✅ Pass | All endpoints under `https://espitalia.net/api/`. Bearer token via existing `buildHeaderTokens()`. No URL-embedded tokens. No new credentials introduced. Patient notes (max 1000 chars) are not classified as sensitive secrets but are PII — they ride existing TLS and the existing storage stack; no plain-text persistence of patient notes outside in-memory controller state. |
| **III. GetX Architecture Consistency** | ✅ Pass | `.obs` + `Obx()` only. `Get.put()` / `Get.lazyPut(fenix: false)` for transient lifecycle. `Get.to()` / `Get.off()` / `Get.bottomSheet()` per spec routing section. `isDarkMode` accessed from `app_common.dart`. No `setState`. No competing libraries. |
| **IV. Backend Contract Fidelity** | ✅ Pass | All endpoints added to `lib/utils/api_end_points.dart` (no hardcoded URLs). Existing `buildHttpResponse()` → `handleResponse()` → model deserialization pattern. `reGenerateToken()` not modified. Server-controlled fields (`status`, `total_amount`, `payment_status`, `report_url`, `confirmed_at`, `cancelled_at`, `completed_at`, `admin_notes`, commission/earnings) are explicitly never sent. Errors surface via `toast()`. Backend POST endpoint ambiguity (`/v1/test-orders` vs `/v1/facility-bookings`) is resolved in research R-1 before Phase 4. |
| **V. Localization-First** | ✅ Pass | ~80 keys added to BOTH `language_en.dart` and `language_ar.dart`. All UI text via `locale.value.<key>`. Calendar strip and slot grid verified RTL. Dates/times via `intl` (no manual string formatting). |
| **VI. Testing Discipline** | ✅ Pass | Booking is a high-risk path; unit tests for `BookingPayload.toJson()` (verifies forbidden fields are not sent), `TestOrderStatus.isCancellable` / `isTerminal`, `SlotsResponse.slotsFor()`, and report-eligibility helpers. Tests use mock responses. |
| **VII. Simplicity & Maintainability** | ✅ Pass | No new state-management library. No new payment abstraction. No wrapper classes around `http` or `path_provider`. Reuses existing components (`app_scaffold`, `cached_image_widget`, `loader_widget`, `empty_error_state_widget`, `filter_count_badge`, Location Filter). Each screen is a single responsibility. Folder layout mirrors existing modules (`incident_management`, `nurse_request`). One new dependency (`open_filex`) — added only if not already present (R-2). |

**Result**: All gates pass. No violations. No entries needed in Complexity Tracking.

## Project Structure

### Documentation (this feature)

```text
specs/022-labs-radiology-booking/
├── plan.md                  # This file
├── research.md              # Phase 0 output — resolves R-1, R-2, R-3
├── data-model.md            # Phase 1 — 13 entities + state transitions
├── quickstart.md            # Phase 1 — manual smoke-test walkthrough
├── contracts/
│   ├── README.md            # Index of contracts
│   ├── api-endpoints.md     # 12 patient endpoints (paths, params, bodies, responses)
│   ├── api-forbidden-fields.md  # Server-controlled fields the app must never send
│   ├── routing-contract.md  # Get.to / Get.off / Get.bottomSheet entry points
│   └── localization-keys.md # All keys to be added to language_en.dart and language_ar.dart
├── checklists/
│   └── requirements.md      # From /speckit.specify (already present)
└── tasks.md                 # Created by /speckit.tasks (NOT this command)
```

### Source Code (repository root)

This is a **mobile-first Flutter app**, single project. The feature lives under `lib/` mirroring existing module patterns (`incident_management`, `nurse_request`).

```text
lib/
├── api/
│   └── labs_radiology_apis.dart                 # NEW — 12 methods
├── screens/
│   └── labs_radiology/                          # NEW — feature root
│       ├── hub/
│       │   ├── labs_radiology_hub_screen.dart
│       │   ├── labs_radiology_hub_controller.dart
│       │   └── components/
│       │       ├── facility_type_tabs.dart
│       │       ├── facility_search_bar.dart
│       │       ├── location_filter_chip.dart
│       │       ├── lab_card.dart
│       │       ├── radiology_center_card.dart
│       │       ├── service_badge.dart
│       │       └── empty_facilities_widget.dart
│       ├── categories/
│       │   ├── test_categories_screen.dart
│       │   ├── test_categories_controller.dart
│       │   └── components/
│       │       ├── category_grid_tile.dart
│       │       └── category_search_bar.dart
│       ├── tests/
│       │   ├── lab_tests_list_screen.dart
│       │   ├── lab_tests_list_controller.dart
│       │   ├── lab_test_detail_sheet.dart
│       │   └── components/
│       │       ├── lab_test_tile.dart
│       │       ├── price_pill.dart
│       │       └── prep_instructions_chip.dart
│       ├── facility_detail/
│       │   ├── facility_detail_screen.dart
│       │   ├── facility_detail_controller.dart
│       │   └── components/
│       │       ├── facility_hero_header.dart
│       │       ├── facility_services_section.dart
│       │       ├── facility_tests_section.dart
│       │       ├── facility_address_card.dart
│       │       └── book_appointment_sticky_bar.dart
│       ├── slot_selection/
│       │   ├── slot_selection_screen.dart
│       │   ├── slot_selection_controller.dart
│       │   └── components/
│       │       ├── slot_calendar_strip.dart
│       │       ├── slot_grid.dart
│       │       └── slot_chip.dart
│       ├── booking_confirmation/
│       │   ├── booking_confirmation_screen.dart
│       │   ├── booking_confirmation_controller.dart
│       │   ├── booking_success_screen.dart
│       │   └── components/
│       │       ├── booking_summary_card.dart
│       │       ├── price_summary_section.dart
│       │       └── confirmation_notes_field.dart
│       ├── orders/
│       │   ├── test_orders_list_screen.dart
│       │   ├── test_orders_list_controller.dart
│       │   ├── test_order_detail_screen.dart
│       │   ├── test_order_detail_controller.dart
│       │   └── components/
│       │       ├── test_order_card.dart
│       │       ├── test_order_status_chip.dart
│       │       ├── test_order_status_timeline.dart
│       │       ├── download_report_button.dart
│       │       └── cancel_order_dialog.dart
│       ├── shared/
│       │   ├── components/
│       │   │   ├── facility_rating_badge.dart
│       │   │   ├── distance_badge.dart
│       │   │   └── facility_type_badge.dart
│       │   └── service/
│       │       └── report_download_service.dart
│       └── models/
│           ├── facility_type.dart
│           ├── facility_model.dart
│           ├── facility_list_response.dart
│           ├── lab_test_model.dart
│           ├── lab_test_category_model.dart
│           ├── lab_test_list_response.dart
│           ├── slot_model.dart
│           ├── slots_response.dart
│           ├── test_order_model.dart
│           ├── test_order_list_response.dart
│           ├── test_order_status.dart
│           ├── test_order_status_history_model.dart
│           └── booking_payload.dart
├── utils/
│   └── api_end_points.dart                      # MODIFIED — add labs/radiology constants
├── locale/
│   ├── language_en.dart                         # MODIFIED — add ~80 keys
│   └── language_ar.dart                         # MODIFIED — add ~80 keys
└── screens/dashboard/                           # MODIFIED — add entry tile

test/
└── screens/
    └── labs_radiology/
        ├── booking_payload_test.dart            # NEW — verifies forbidden fields
        ├── test_order_status_test.dart          # NEW — isCancellable/isTerminal
        ├── slots_response_test.dart             # NEW — slotsFor(date) helper
        └── test_order_model_test.dart           # NEW — hasReport / canCancel
```

**Structure Decision**: Single Flutter project, mobile-first. Module placed under `lib/screens/labs_radiology/` mirroring `lib/screens/incident_management/` and `lib/screens/nurse_request/`. API service in `lib/api/`. No separate backend tree (the Laravel API is external). No new top-level packages.

## Post-Design Constitution Re-Check

After completing Phase 0 (`research.md`) and Phase 1 (`data-model.md`, `contracts/`, `quickstart.md`), all seven principles still pass:

- **I. Platform Parity**: Web download path explicitly handled in R-3 via blob fallback. Android/iOS handled via `path_provider` + `open_filex`.
- **II. Patient Data Security**: All endpoints HTTPS. Forbidden-fields contract makes server-controlled data exfiltration via the request body impossible by construction.
- **III. GetX Architecture Consistency**: All controllers in `data-model.md` and `contracts/routing-contract.md` use `.obs` / `Get.to` / `Get.lazyPut`. No competing patterns introduced.
- **IV. Backend Contract Fidelity**: `contracts/api-endpoints.md` pins paths, params, bodies, and responses. R-1 tracks the only real ambiguity with a clear pre-Phase-4 confirmation step.
- **V. Localization-First**: `contracts/localization-keys.md` enumerates every key for both languages.
- **VI. Testing Discipline**: 4 unit tests scoped (booking payload, status enum, slots response, order helpers). All target high-risk logic, none requires live backend.
- **VII. Simplicity & Maintainability**: One new dependency (`open_filex`) explicitly justified in R-2 against three alternatives. No new abstractions over `http`. `ReportDownloadService` is the only new service and is justified.

**Result**: Phase 1 design introduces no new violations. Ready for `/speckit.tasks`.

## Complexity Tracking

> *No Constitution Check violations. Section intentionally empty.*

The module reuses every applicable shared component and stays within established patterns. The only new infrastructure is `ReportDownloadService`, a thin wrapper required because no existing service downloads binary files to disk and re-opens them. It is justified by the fact that report download is a distinct capability (file I/O + permissions + open-in-viewer) that would otherwise be inlined into a controller — violating Constitution VII (controllers should not own file I/O).
