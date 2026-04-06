# Implementation Plan: Doctor Home Visit Requests

**Branch**: `013-doctor-home-visits` | **Date**: 2026-04-06 | **Spec**: [spec.md](spec.md)
**Input**: Feature specification from `/specs/013-doctor-home-visits/spec.md`

## Summary

Implement a doctor home visit request system for the Espitalia patient app. Patients can submit requests for a doctor to visit them at home, specifying visit reason, preferred date, contact phone, optional preferred doctor, and notes. They can list and view their requests. Admins/receptionists can view all requests with filters, update request status (pending -> confirmed -> completed, or cancelled), and assign doctors. The feature integrates with existing Laravel REST API endpoints, follows GetX state management, and supports localization in English and Arabic.

## Technical Context

**Language/Version**: Dart 3.0+ / Flutter 3.0+ (as per constitution)
**Primary Dependencies**: GetX 4.7.2 (state management), http package (networking via existing network layer), nb_utils, Google Fonts
**Storage**: GetStorage (UI preferences), platform keychain (sensitive tokens via existing network layer)
**Testing**: Flutter test framework - widget tests for form validation, integration tests for request flows, unit tests for model serialization and status transitions
**Target Platform**: Android (API 21+), iOS (Flutter defaults), Web (Chrome) - **PLATFORM PARITY REQUIRED per constitution**
**Project Type**: Mobile + Web application (Flutter) - Espitalia patient app
**Performance Goals**: Request submission <5s, list loading <1s, status updates reflected immediately
**Constraints**: Role-based access control (patient sees own requests only, admin/receptionist/doctor see all), valid status transitions only, healthcare data security (HTTPS, Bearer tokens)
**Scale/Scope**: 19 functional requirements, 4 entity types, 6 API endpoints (3 patient, 3 admin), 5 user workflows, ~2000-2500 lines across models/controllers/screens/components

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

### Applicable Principles

| Principle | Status | Notes |
|-----------|--------|-------|
| **I. Platform Parity** | PASS | Feature is form-based (text inputs, date picker, lists). No platform-specific dependencies. Date picker uses Flutter Material (works across all platforms). |
| **II. Patient Data Security** | PASS | Uses existing HTTPS-only network layer with Bearer token auth. Visit reason and contact phone are patient data — transmitted securely via existing interceptors. No new keys or secrets needed. |
| **III. GetX Architecture** | PASS | All state via .obs observables + Obx() widgets. Controllers extend GetxController. Navigation via Get.to(). No competing patterns. |
| **IV. Backend Contract Fidelity** | PASS | All 6 API endpoints defined in spec input. Register in api_end_points.dart. Follow buildHttpResponse() -> handleResponse() -> model pattern. Automatic token refresh works unchanged. |
| **V. Localization-First** | PASS | All UI strings via locale.value.<key>. Add keys to both language_en.dart and language_ar.dart. RTL support for Arabic. Use intl for date formatting. |
| **VI. Testing Discipline** | PASS | Visit requests involve patient data — recommended to test. Include unit tests for models, widget tests for form validation, integration tests for submit/list flows. |
| **VII. Simplicity & Maintainability** | PASS | No new packages needed. Use existing patterns. Feature is self-contained in one screen directory. No over-engineering — straightforward CRUD with status workflow. |

**GATE RESULT**: **PASS** — All applicable principles satisfied. Design can proceed.

## Project Structure

### Documentation (this feature)

```text
specs/013-doctor-home-visits/
├── plan.md              # This file
├── research.md          # Phase 0 output
├── data-model.md        # Phase 1 output
├── quickstart.md        # Phase 1 output
├── contracts/           # Phase 1 output
│   └── api-contracts.md # REST API endpoint contracts
└── tasks.md             # Phase 2 output (/speckit.tasks command)
```

### Source Code (repository root)

```text
lib/
├── screens/
│   └── doctor_visit/                              # Doctor home visit feature
│       ├── doctor_visit_request_screen.dart        # Submit new visit request form
│       ├── doctor_visit_request_controller.dart    # Form state + submission logic
│       ├── doctor_visit_list_screen.dart           # Patient's visit request list
│       ├── doctor_visit_list_controller.dart       # List loading + pagination
│       ├── doctor_visit_detail_screen.dart         # Visit request detail view
│       ├── doctor_visit_detail_controller.dart     # Detail loading + actions
│       ├── model/
│       │   └── doctor_visit_request_model.dart     # Visit request model + list response
│       └── components/
│           ├── doctor_visit_card.dart              # List item card widget
│           └── doctor_visit_status_badge.dart      # Status badge (pending/confirmed/cancelled/completed)
│
├── utils/
│   └── api_end_points.dart                        # (updated with new endpoints)
│
└── locale/
    ├── languages.dart                              # (updated with new abstract keys)
    ├── language_en.dart                            # (updated with English strings)
    └── language_ar.dart                            # (updated with Arabic strings)

test/
├── unit/
│   └── models/
│       └── doctor_visit_request_model_test.dart   # Model serialization tests
└── integration/
    └── doctor_visit_request_flow_test.dart         # End-to-end request submission
```

**Structure Decision**: Single Flutter project using Espitalia's existing pattern. Doctor visit feature in `lib/screens/doctor_visit/` with co-located models and components. This is a patient-facing feature — admin screens are not included since this is a patient app (admin endpoints are used for data that doctors/receptionists access through the same app with role-based visibility).

## Complexity Tracking

> No constitution violations. Table intentionally left empty.

## Phase 0: Research & Unknowns

**Prerequisites**: Specification complete (passed)
**Gate**: Constitution Check passed (no violations)

### Technical Unknowns Resolved

All technical decisions are well-defined by the Espitalia constitution and existing codebase. No external research needed:

1. **State Management**: GetX 4.7.2 (established architecture)
2. **Networking**: http package + buildHttpResponse() pattern (existing)
3. **UI Framework**: Flutter Material + nb_utils + Google Fonts (established)
4. **Authentication**: Bearer tokens + Sanctum (existing)
5. **Localization**: BaseLanguage + locale observables (established)
6. **Date Picker**: Flutter Material DatePicker (cross-platform, no new dependency)
7. **Form Validation**: Client-side validation matching API contract (max lengths, required fields, date >= today)
8. **Status Workflow**: pending -> confirmed -> completed, pending -> cancelled, confirmed -> cancelled (defined in spec)
9. **Role Detection**: Use existing `loginUserData.value` role field for RBAC in UI

**Outcome**: No NEEDS CLARIFICATION markers. Design can proceed to Phase 1.

---

## Phase 1: Design & Contracts

**Prerequisites**: Phase 0 complete (all unknowns resolved)

### Phase 1A: Data Model

See [data-model.md](data-model.md)

**Key Entities**:
- **DoctorVisitRequest** (id, reference_number, visit_type, visit_reason, preferred_date, contact_phone, additional_notes, status, preferred_doctor, assigned_doctor, admin_notes, cancellation_reason, completed_at, created_at)
- **DoctorSummary** (id, name) — lightweight doctor reference embedded in visit request
- **DoctorVisitRequestListResponse** — paginated list wrapper with meta (current_page, last_page, per_page, total)

### Phase 1B: API Contracts

See [contracts/api-contracts.md](contracts/api-contracts.md)

**Patient Endpoints** (authenticated, role: user):
- POST /v1/doctor-visit/requests (submit new request)
- GET /v1/doctor-visit/requests (list my requests, paginated)
- GET /v1/doctor-visit/requests/{reference} (view single request detail)

**Admin Endpoints** (authenticated, role: admin/receptionist/doctor):
- GET /v1/admin/doctor-visit/requests (list all, filterable by status/date/doctor)
- PUT /v1/admin/doctor-visit/requests/{reference}/status (update status)
- PUT /v1/admin/doctor-visit/requests/{reference}/assign-doctor (assign doctor)

**Error Responses**: 422 validation, 403 permission denied, 404 not found.

### Phase 1C: QuickStart Integration

See [quickstart.md](quickstart.md)

**Integration Points**:
- Existing authentication flow (no new auth required)
- Existing notification system (out of scope per assumptions, but infrastructure ready)
- Existing localization system (add ~20 new keys)
- Existing navigation (Get.to / Get.back patterns)
- Existing error handling (toast + error UI patterns)
- Existing doctor list data (for preferred doctor picker, reuse getDoctorList endpoint)

---

## Implementation Roadmap

### Task Groups (for Phase 2 `/speckit.tasks`)

1. **Setup**: API endpoint definitions, model classes, localization keys
2. **Core APIs**: Doctor visit request API service methods (submit, list, detail)
3. **Patient Screens**: Request form, list screen, detail screen with controllers
4. **Admin Features**: Admin list with filters, status update, doctor assignment (role-gated in same app)
5. **Components**: Visit card, status badge, form validation
6. **Localization**: Add English and Arabic strings
7. **Testing**: Unit tests (model serialization), integration tests (request flow)
8. **Dashboard Integration**: Add entry point from home screen

### Performance Considerations

- **Request List** (<1s): Server-side pagination with 15 items per page
- **Form Submission** (<5s): Single POST request, no complex processing
- **Status Updates**: Immediate reflection via reactive GetX state
- **Doctor Picker**: Reuse existing getDoctorList API for preferred doctor selection

---

## Architecture Decision Records

### Feature Directory Structure

**Decision**: Create `lib/screens/doctor_visit/` as a self-contained feature directory.
- **Rationale**: Follows the lab_test and facility_booking patterns. Co-locates controllers, models, and components with screens for easy navigation.
- **Alternative rejected**: Placing in existing `lib/screens/booking/` — rejected because doctor visits are a distinct workflow from clinic appointments.

### API Service Location

**Decision**: Add doctor visit API methods to `lib/api/core_apis.dart` rather than creating a new API file.
- **Rationale**: The feature has only 3 patient-facing API calls. Existing features like nurse requests use core_apis.dart. Creating a separate file for 3 methods would be over-engineering.
- **Alternative rejected**: New `lib/api/doctor_visit_apis.dart` — rejected per VII. Simplicity; extract only when the file becomes large.

### Admin Screens in Patient App

**Decision**: Include admin-facing screens (list all requests, update status, assign doctor) within the same app, gated by role checks.
- **Rationale**: The existing app already serves admin/receptionist/doctor roles (see nurse requests, ICU admissions). Role-based UI visibility is established practice.
- **Alternative rejected**: Separate admin portal — rejected because it would duplicate the app and fragment the codebase.

### Model Placement

**Decision**: Place DoctorVisitRequest model in `lib/screens/doctor_visit/model/` (feature-local) rather than `lib/models/`.
- **Rationale**: The model is only used within the doctor visit feature. Follows the lab_test pattern where feature-specific models live in the feature directory. Only shared/cross-feature models go in `lib/models/`.

### State Management Strategy

**Decision**: GetX-only, one controller per screen.
- **Reactive Variables**: Use `.obs` for all mutable state (form fields, list data, loading states)
- **Controllers**: Separate controller files paired with each screen
- **Global State**: Access existing global state (isLoggedIn, loginUserData) from common_base.dart

---

## Constitution Re-Check (Post Phase 1)

| Principle | Status | Notes |
|-----------|--------|-------|
| **I. Platform Parity** | PASS | All UI components are standard Flutter Material. DatePicker works cross-platform. No platform-specific code. |
| **II. Patient Data Security** | PASS | Visit reason and phone data transmitted via existing HTTPS + Bearer token layer. No new sensitive storage. |
| **III. GetX Architecture** | PASS | All controllers extend GetxController. All navigation uses Get.to(). No competing patterns. |
| **IV. Backend Contract Fidelity** | PASS | 6 endpoints registered in api_end_points.dart. Follow existing buildHttpResponse() pattern. Response shapes match API spec. |
| **V. Localization-First** | PASS | ~20 new locale keys added to both en/ar. RTL layout via existing framework. |
| **VI. Testing Discipline** | PASS | Unit tests for model serialization, integration test for request flow. |
| **VII. Simplicity & Maintainability** | PASS | No new packages. ~2000-2500 lines. Feature self-contained in one directory. |

**POST-DESIGN GATE**: **PASS** — Design remains aligned with all constitution principles.
