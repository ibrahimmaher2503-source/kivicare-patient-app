# Implementation Plan: Nurse Request (Home Nursing) Module

**Branch**: `020-nurse-request-module` | **Date**: 2026-04-28 | **Spec**: [spec.md](./spec.md)
**Input**: Feature specification from `/specs/020-nurse-request-module/spec.md`

## Summary

Patient-facing module that lets a logged-in patient submit a home-nursing request, browse their previous requests, and track each request's lifecycle (pending → assigned → confirmed → in_progress → completed, or terminal cancelled) on a detail screen that reveals the assigned nurse and final price once admin acts. The patient never selects a nurse from the app.

Technical approach: a new Flutter module under `lib/screens/nurse_request/` that mirrors the established `lib/screens/doctor_visit/` pattern (model + controller + screen layers, GetX state, `buildHttpResponse()` API service), three patient endpoints under the un-prefixed `nurse-requests` path (per commit `173ae10` and the canonical Postman collection — *not* `v1/nurse-requests` as the spec input draft suggested), and a self-contained governorate/city picker inside the module (the previous shared picker was removed on this branch, so the governorate/city UX ships as a per-module component with fail-open free-text fallback). All user-visible strings flow through `locale.value.<key>`; both light and dark themes plus Arabic RTL must work on every screen of the flow.

The five spec clarifications are absorbed into this plan as concrete constraints:
- **Self-only filing** → no dependent picker; payload carries no `patient_id`/`patient_for`.
- **Duplicate-submit safety** → submit button disabled in-flight; on unknown outcomes, route to list with verify banner; no auto-retry; in-memory draft preserved during the verify roundtrip.
- **Draft persistence** → in-memory only on the form route; nothing on disk; relaunch starts empty.
- **Status filter persistence** → session-scoped (alive across detail back-nav, resets on module re-entry).
- **Time zone** → `preferred_date` and `preferred_time` are clinic-wall-clock in `Africa/Cairo`, including the today / +90-day boundary check.

## Technical Context

**Language/Version**: Dart 3.0+ / Flutter 3.0+ (matches project SDK; package id `com.espitalia.patient`).
**Primary Dependencies**: `get: ^4.7.2` (state, routing, DI), `nb_utils` (boldTextStyle / boxDecorationDefault / toast), `google_fonts` (Plus Jakarta Sans body, Outfit display), `intl: ^0.20.2` (date formatting + Arabic plural rules + `Africa/Cairo` boundary), `url_launcher: ^6.3.1` (tap-to-call `tel:`), `lottie: ^3.3.1` (success animation), `flutter/services.dart` Clipboard (reference copy), `http` via `lib/network/network_utils.dart` (`buildHttpResponse` + `handleResponse` + transparent token refresh).
**Storage**: None on disk. Drafts live in `TextEditingController` + `Rx*` state on the controller and are discarded when the form route is popped or the app is killed (constraint from clarification 3). `GetStorage` is **not** used by this module.
**Testing**: `flutter test` for two unit suites (request body builder respects "omit empty optional" and "trim whitespace" + the bilingual cross-field rule; status enum `fromString`/`isTerminal`/`apiValue` round-trip) and one widget smoke suite for `NurseStatusChip` and `NurseStatusTimeline` rendering across the six statuses in light/dark. Mocked HTTP responses; no live backend.
**Target Platform**: Android (compile/target SDK 35), iOS (Flutter default min), and Web (Chromium-based) — required by Constitution Principle I.
**Project Type**: Flutter mobile app feature module added under `lib/screens/`. No new top-level project.
**Performance Goals**: Submit flow visibly responsive; list pagination loads next page in under 2 s on a healthy network (SC-010); detail and list use lighter inline shimmer (no full-screen blocker) per FR-048.
**Constraints**: Zero new `flutter analyze` warnings (Constitution + SC-012). All strings through `locale.value.<key>` (Constitution V + SC-004). GetX-only state — no `setState`, no Provider/Riverpod/Bloc (Constitution III). All endpoints declared in `lib/utils/api_end_points.dart`, never hardcoded (Constitution IV). Bearer token auth via existing pipeline; no new credential paths (Constitution II). Dark mode and Arabic RTL parity on every screen (FR-043 to FR-046). The form must never transmit `nurse_id`, `coupon_code`, `status`, `total_amount`, or `payment_status` (FR-022 + SC-009).
**Scale/Scope**: Single new module: 5 models (`NurseRequestModel`, `AssignedNurseModel`, `StatusHistoryEntry`, `NurseRequestListResponse`, `NurseRequestFormPayload`), 1 API service file (3 methods), 3 GetX controllers, 4 screens (list / form / success / detail) + ~12 components, 1 dashboard entry hook, ~55 localization keys × 2 languages, and 5 endpoint constants (`getNurseRequests`/`createNurseRequest`/`getNurseRequestDetail` for this module + `governorates` and `cities` reused for the location picker). Estimated ~25 new files, no modifications to other modules besides the dashboard quick-service registration, `api_end_points.dart`, `language_*.dart`, and the push-notification dispatcher.

## Constitution Check

| # | Principle | Status | Notes |
|---|-----------|--------|-------|
| I | Platform Parity | PASS | Pure Flutter widgets; no platform-conditional code. `url_launcher` (tap-to-call) and `Clipboard` (copy reference) are cross-platform. Verify Android + at least one of iOS/Web during acceptance. |
| II | Patient Data Security | PASS | Reuses `buildHttpResponse` (HTTPS only, Bearer in header). Drafts kept in memory — no PII written to disk per clarification 3. No new secrets, no Crashlytics changes. |
| III | GetX Architecture Consistency | PASS | `RxList`, `RxBool`, `RxnString`, `Rxn<T>` for state; `Get.put`/`Get.lazyPut` for DI; `Get.to`/`Get.off`/`Get.back` for navigation. No `setState`, no parallel state libs. `isDarkMode` consumed from `lib/utils/app_common.dart`. |
| IV | Backend Contract Fidelity | PASS | New endpoint constants added to `lib/utils/api_end_points.dart` only. Service file follows `buildHttpResponse → handleResponse → Model.fromJson` exactly as `lib/api/doctor_visit_apis.dart`. No changes to `reGenerateToken()`. |
| V | Localization-First | PASS | All ~55 keys added to both `language_en.dart` and `language_ar.dart`. Per-field RTL/LTR override on the bilingual description fields uses `Directionality` widgets, not hardcoded text. Date/number formatting uses `intl`. |
| VI | Testing Discipline | RECOMMENDED — will include | API request builder + status enum unit tests (low effort, high value). Widget smoke for status chip + timeline. No live-backend dependency. |
| VII | Simplicity & Maintainability | PASS | No new packages introduced. Module mirrors the doctor_visit pattern — no new abstractions. Screen files kept under 500 lines by extracting form sections and detail cards into `components/`. The governorate/city picker is module-local until a second consumer appears; if the booking module re-introduces a shared picker later, this one can be replaced without churning the API surface. |

**Gate result**: PASS. No constitution violations require justification.

## Project Structure

### Documentation (this feature)

```text
specs/020-nurse-request-module/
├── plan.md                              # this file
├── spec.md                              # already written + clarifications session
├── research.md                          # Phase 0 output
├── data-model.md                        # Phase 1 output
├── quickstart.md                        # Phase 1 output
├── contracts/
│   └── api-endpoints.md                 # Phase 1 output (HTTP contract for the 3 patient endpoints + governorates/cities)
├── checklists/
│   └── requirements.md                  # already written by /speckit.specify
└── tasks.md                             # produced later by /speckit.tasks
```

### Source Code (repository root)

The module mirrors `lib/screens/doctor_visit/` (already in-tree) for the screens layer. Touchpoints in other directories are minimal and itemised below.

```text
lib/
├── api/
│   └── nurse_request_apis.dart                    # NEW — three patient endpoints
├── locale/
│   ├── language_en.dart                           # MODIFIED — add ~55 nurse_request_* keys
│   ├── language_ar.dart                           # MODIFIED — add ~55 nurse_request_* keys
│   └── languages.dart                             # MODIFIED only if BaseLanguage abstract requires new getters
├── screens/
│   ├── home/components/
│   │   └── quick_service_card.dart                # MODIFIED — add Home Nursing entry (replace `isComingSoon` for Home Care, or add a dedicated entry)
│   └── nurse_request/                             # NEW MODULE
│       ├── nurse_request_list_screen.dart
│       ├── nurse_request_list_controller.dart
│       ├── components/
│       │   ├── nurse_request_card.dart
│       │   ├── nurse_status_chip.dart
│       │   ├── nurse_status_timeline.dart
│       │   ├── nurse_status_history_tile.dart
│       │   ├── assigned_nurse_card.dart
│       │   ├── pricing_card.dart
│       │   ├── address_summary_card.dart
│       │   ├── schedule_summary_card.dart
│       │   ├── nurse_request_filter_chips.dart    # session-scoped status filter
│       │   └── empty_nurse_requests_widget.dart
│       ├── request_form/
│       │   ├── nurse_request_form_screen.dart
│       │   ├── nurse_request_form_controller.dart
│       │   └── components/
│       │       ├── service_description_section.dart   # bilingual EN+AR with per-field Directionality
│       │       ├── schedule_section.dart               # date + time + duration; Africa/Cairo today boundary
│       │       ├── address_section.dart                # line1/line2 + governorate dropdown + city (dropdown OR free-text) + collapsible state/country/postal
│       │       ├── contact_section.dart                # phone with +20 default
│       │       ├── notes_field.dart
│       │       ├── duration_stepper.dart               # 1–24 with 44pt tap targets
│       │       └── governorate_city_picker.dart        # module-local picker w/ free-text fallback
│       ├── detail/
│       │   ├── nurse_request_detail_screen.dart
│       │   └── nurse_request_detail_controller.dart
│       ├── success/
│       │   └── nurse_request_success_screen.dart       # Lottie + reference + copy + 2 actions
│       └── model/
│           ├── nurse_request_model.dart                # full request entity
│           ├── nurse_request_list_response.dart        # paginated wrapper
│           ├── nurse_request_form_payload.dart         # typed allow-list builder for the POST body
│           ├── status_history_entry.dart               # per-transition entry; actor identity hidden
│           ├── assigned_nurse_model.dart               # patient-visible nurse subset
│           └── nurse_status.dart                       # 6-value enum w/ fromString / apiValue / isTerminal / displayLabel
└── utils/
    └── api_end_points.dart                        # MODIFIED — add 3 new constants

test/
└── unit/nurse_request/
    ├── nurse_request_apis_test.dart               # request body shape, omit-empty, trim, NEVER include forbidden fields
    ├── nurse_status_test.dart                     # enum round-trip + isTerminal
    └── nurse_request_form_controller_test.dart    # bilingual cross-field rule + duration boundaries
```

**Structure Decision**: Adopt the `doctor_visit` pattern verbatim (1 API service file, models in `models/`, screens grouped by sub-flow with `components/` for widgets, controllers next to their screens). This keeps the module self-contained, matches an existing reference the project already uses, and respects Constitution VII (no new abstractions). The only structural deviation is the per-module `governorate_city_picker.dart`, which is justified in `research.md` because the previously shared picker was deleted on this branch and we need the form to work today — a re-shared component can be extracted later when a second consumer appears.

## Complexity Tracking

> No constitution violations to justify. Section intentionally empty.
