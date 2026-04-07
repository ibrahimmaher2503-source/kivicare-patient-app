# Implementation Plan: Labs & Radiology Booking System

**Branch**: `012-labs-radiology-bookings` | **Date**: 2026-04-05 | **Spec**: [spec.md](spec.md)
**Input**: Feature specification from `/specs/012-labs-radiology-bookings/spec.md`

**Note**: This template is filled in by the `/speckit.plan` command. See `.specify/templates/plan-template.md` for the execution workflow.

## Summary

Implement a comprehensive lab test ordering and radiology facility booking system for the Espitalia patient app. Patients will browse available lab test categories and individual tests (public endpoints), create multi-item test orders with clinical notes (authenticated), and book facility appointments with date/time slot selection. Role-based access control ensures patients see only their data, doctors see assigned orders, and admins see all. Platform parity across Android, iOS, and Web with GetX state management and Backend contract integration with Laravel REST API.

## Technical Context

**Language/Version**: Dart 3.0+ / Flutter 3.0+ (as per constitution)
**Primary Dependencies**: GetX 4.7.2 (state management), http package (networking), Firebase (auth/messaging), nb_utils, Google Fonts
**Storage**: GetStorage (test preferences, order history caching), platform keychain (sensitive tokens via existing network layer)
**Testing**: Flutter test framework - widget tests for UI, integration tests for order/booking flows, unit tests for business logic
**Target Platform**: Android (API 21+), iOS (Flutter defaults), Web (Chrome) - **PLATFORM PARITY REQUIRED per constitution**
**Project Type**: Mobile + Web application (Flutter) - Espitalia patient app
**Performance Goals**: Test catalog search <1s, order creation <5min, slot availability <500ms, booking completion <3min, 1000 concurrent users, 100 simultaneous bookings
**Constraints**: Double-booking prevention (100% success rate), role-based access control (RBAC) with 403 enforcement, pricing accuracy (zero discrepancies), status workflow validation (no invalid transitions), healthcare data security (HTTPS, Bearer tokens, no sensitive data in logs)
**Scale/Scope**: 35 functional requirements, 7 entity models, 4 public endpoints (test catalog), 18+ authenticated endpoints (orders/bookings), 6 user workflows, ~4000+ lines across models/controllers/screens/services

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

### Applicable Principles

| Principle | Status | Notes |
|-----------|--------|-------|
| **I. Platform Parity** | ✅ PASS | Feature must work on Android, iOS, Web. Use platform checks for facility-specific features (e.g., date picker native vs web). All 4 list screens must be tested on 2+ platforms. |
| **II. Patient Data Security** | ✅ PASS | Healthcare + payment data. Use HTTPS only (existing network layer enforces this). Bearer token auth via existing interceptors. No hardcoded API keys. Sanitize logs for Crashlytics. |
| **III. GetX Architecture** | ✅ PASS | All state via .obs observables + Obx() widgets. Use Get.put() for controller injection. Navigation via Get.to(). No setState() or competing patterns. |
| **IV. Backend Contract Fidelity** | ✅ PASS | Integrate with Laravel API endpoints in lib/utils/api_end_points.dart. Follow existing pattern: buildHttpResponse() → handleResponse() → model. Automatic token refresh via network_utils.dart works for both password & social logins. |
| **V. Localization-First** | ✅ PASS | All UI strings via locale.value.<key>. Add keys to both language_en.dart and language_ar.dart. RTL layout support for Arabic. Use intl package for dates/numbers. |
| **VI. Testing Discipline** | ✅ PASS | Order & booking flows are high-risk (healthcare + payments). Include widget tests for UI, integration tests for happy path + error cases, unit tests for price calc + RBAC. Mock API responses. |
| **VII. Simplicity & Maintainability** | ✅ PASS | Use existing packages (no new dependencies beyond what's required). Keep screens <500 lines (extract components only if 2+ reuses). Pay attention to slot availability optimization (may need indexing strategy). |

**GATE RESULT**: ✅ **PASS** — All applicable principles satisfied. Design can proceed.

## Project Structure

### Documentation (this feature)

```text
specs/[###-feature]/
├── plan.md              # This file (/speckit.plan command output)
├── research.md          # Phase 0 output (/speckit.plan command)
├── data-model.md        # Phase 1 output (/speckit.plan command)
├── quickstart.md        # Phase 1 output (/speckit.plan command)
├── contracts/           # Phase 1 output (/speckit.plan command)
└── tasks.md             # Phase 2 output (/speckit.tasks command - NOT created by /speckit.plan)
```

### Source Code (repository root)

**Option**: Single Flutter project (existing Espitalia structure applies)

```text
lib/
├── screens/
│   ├── lab_test/                              # Lab test catalog & ordering
│   │   ├── lab_test_categories_screen.dart
│   │   ├── lab_test_categories_controller.dart
│   │   ├── lab_test_detail_screen.dart
│   │   ├── create_test_order_screen.dart
│   │   ├── create_test_order_controller.dart
│   │   ├── test_order_list_screen.dart
│   │   ├── test_order_list_controller.dart
│   │   ├── test_order_detail_screen.dart
│   │   ├── model/
│   │   │   ├── test_order_model.dart
│   │   │   └── lab_test_model.dart
│   │   └── components/
│   │       ├── lab_test_category_card.dart
│   │       ├── lab_test_card.dart
│   │       ├── test_order_card.dart
│   │       └── test_order_status_badge.dart
│   │
│   └── facility_booking/                      # Facility booking (labs & radiology)
│       ├── facility_booking_screen.dart
│       ├── facility_booking_controller.dart
│       ├── facility_slots_screen.dart
│       ├── facility_slots_controller.dart
│       ├── my_bookings_screen.dart
│       ├── my_bookings_controller.dart
│       ├── booking_detail_screen.dart
│       ├── model/
│       │   ├── facility_booking_model.dart
│       │   ├── facility_model.dart
│       │   └── booking_slot_model.dart
│       └── components/
│           ├── facility_booking_card.dart
│           ├── facility_slot_calendar.dart
│           └── booking_status_badge.dart
│
├── api/
│   ├── lab_test_apis.dart                    # API calls for test catalog & orders
│   └── facility_booking_apis.dart            # API calls for facility bookings
│
├── models/
│   ├── lab_test_category_model.dart
│   ├── lab_test_model.dart
│   ├── test_order_model.dart
│   ├── test_order_item_model.dart
│   ├── facility_booking_model.dart
│   ├── facility_model.dart
│   ├── radiology_center_model.dart
│   └── booking_slot_model.dart
│
└── utils/
    └── api_end_points.dart                   # (updated with new endpoints)

test/
├── unit/
│   ├── models/
│   │   ├── lab_test_model_test.dart
│   │   ├── test_order_model_test.dart
│   │   └── facility_booking_model_test.dart
│   └── services/
│       ├── test_order_pricing_test.dart      # Price calculation logic
│       └── booking_slot_validation_test.dart # Slot availability logic
│
└── integration/
    ├── lab_test_order_flow_test.dart         # End-to-end ordering
    └── facility_booking_flow_test.dart       # End-to-end booking
```

**Structure Decision**: Single Flutter project using Espitalia's existing pattern. Lab test and facility booking features grouped in separate screen directories under lib/screens/. Models, API services, and components follow established patterns (models in lib/models/, APIs in lib/api/, component files co-located with screens). Tests mirror source structure in test/ directory.

## Complexity Tracking

> **Fill ONLY if Constitution Check has violations that must be justified**

| Violation | Why Needed | Simpler Alternative Rejected Because |
|-----------|------------|-------------------------------------|
| [e.g., 4th project] | [current need] | [why 3 projects insufficient] |
| [e.g., Repository pattern] | [specific problem] | [why direct DB access insufficient] |

## Phase 0: Research & Unknowns

**Prerequisites**: Specification complete (✅ passed)
**Gate**: Constitution Check passed (✅ no violations)

### Technical Unknowns Resolved

All technical decisions are well-defined by the Espitalia constitution and existing codebase. No external research needed:

1. ✅ **State Management**: GetX 4.7.2 (established architecture)
2. ✅ **Networking**: http package + buildHttpResponse() pattern (existing)
3. ✅ **UI Framework**: Flutter Material + nb_utils + Google Fonts (established)
4. ✅ **Authentication**: Bearer tokens + Sanctum (existing)
5. ✅ **Localization**: BaseLanguage + locale observables (established)
6. ✅ **Payment Integration**: Existing payment_gateways pattern (for order payment_status)
7. ✅ **Firebase**: Messaging for notifications (existing)
8. ✅ **Database**: Laravel backend handles persistence (no local DB needed)

**Outcome**: No NEEDS CLARIFICATION markers. Design can proceed to Phase 1.

---

## Phase 1: Design & Contracts

**Prerequisites**: Phase 0 complete (✅ all unknowns resolved)

### Phase 1A: Data Model

See `data-model.md` (to be generated)

**Key Entities**:
- **LabTestCategory** (id, name, slug, description, icon, display_order, test_count)
- **LabTest** (id, name, code, category_id, department, sample_type, price, turnaround_time)
- **TestOrder** (id, order_number, patient_id, doctor_id, items[], status, total_amount, payment_status)
- **TestOrderItem** (id, test_id, order_id, price, status, result_date)
- **FacilityBooking** (id, booking_number, facility_id, type, booking_date, booking_time, status)
- **Lab** (id, name, is_active, is_holiday)
- **RadiologyCenter** (id, name, is_active, is_holiday)

### Phase 1B: API Contracts

See `contracts/` directory (to be generated)

**Public Endpoints** (unauthenticated):
- GET /v1/lab-test-categories
- GET /v1/lab-tests (filterable by category, department, searchable)
- GET /v1/lab-tests/{id}
- GET /v1/facility-bookings/labs/{labId}/slots?date=YYYY-MM-DD
- GET /v1/facility-bookings/radiology-centers/{centerId}/slots?date=YYYY-MM-DD

**Authenticated Endpoints** (Bearer token):
- POST /v1/test-orders (create order)
- GET /v1/test-orders (list with role-based filtering)
- GET /v1/test-orders/{id} (view single)
- POST /v1/test-orders/{id}/cancel
- GET /v1/test-orders/{id}/report/download
- POST /v1/facility-bookings (create booking)
- GET /v1/facility-bookings (list my bookings)
- GET /v1/facility-bookings/{id} (view single)
- POST /v1/facility-bookings/{id}/cancel

**Error Responses**: All endpoints return 422 for validation errors, 403 for permission denied, 404 for not found.

### Phase 1C: QuickStart Integration

See `quickstart.md` (to be generated)

**Integration Points**:
- Existing authentication flow (no new auth required)
- Existing notification system (Firebase Cloud Messaging)
- Existing payment gateway system (for order payment status)
- Existing localization system (add ~25 new keys)
- Existing navigation (Get.to / Get.back patterns)
- Existing error handling (toast + error UI patterns)

---

## Implementation Roadmap

### Task Groups (for Phase 2 `/speckit.tasks`)

1. **Setup**: API endpoint definitions, models, utility extensions
2. **Core APIs**: Lab test catalog APIs, facility slot checking
3. **Test Orders**: Order creation, RBAC filtering, cancellation
4. **Facility Bookings**: Slot calendar, double-booking prevention, booking management
5. **UI Screens**: Test catalog browsing, order creation, booking calendar
6. **Localization**: Add English and Arabic strings
7. **Testing**: Unit tests (pricing, RBAC), integration tests (flows)
8. **Polish**: Performance optimization, accessibility, error handling

### Performance Considerations

- **Test Search** (<1s): Implement client-side pagination/caching of catalog
- **Slot Availability** (<500ms): Consider server-side indexing for facility availability
- **Concurrent Users** (1000+): Rely on Laravel backend scaling; app is primarily client-heavy
- **Double-booking Prevention**: Use optimistic locking or transaction handling in backend

---

## Architecture Decision Records

### Database & Storage Strategy

**Decision**: Use existing Laravel backend for all persistence. No local SQL database needed.
- **Rationale**: Espitalia uses Laravel REST API exclusively. Introducing local databases adds complexity without benefit.
- **Storage in Flutter**: GetStorage for UI state (test filters, sort preferences), platform keychain for sensitive tokens (existing)

### State Management Strategy

**Decision**: GetX-only, following existing patterns.
- **Reactive Variables**: Use `.obs` for all mutable state (selected filters, order draft, booking draft)
- **Controllers**: One per screen (can be in screen file or separate, choose one approach per directory)
- **Global State**: Access existing global state (isLoggedIn, loginUserData) from common_base.dart

### API Contract Strategy

**Decision**: RESTful endpoints with role-based filtering on backend.
- **Rationale**: Backend enforces access control (patient/doctor/admin isolation). Client respects 403 errors and displays appropriate UI.
- **Consistency**: Follow existing pattern — all endpoints return standardized JSON response shape

### Testing Strategy

**Decision**: Focus tests on high-risk paths (ordering + booking) and business logic (pricing, RBAC).
- **Unit Tests**: Pricing calculations, booking slot validation, RBAC filtering
- **Integration Tests**: Happy path order creation, facility booking with payment status
- **Widget Tests**: List screens, detail screens, form validations
- **Mocking**: Mock API responses; do not hit live backend during tests

---
