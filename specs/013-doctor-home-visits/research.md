# Research: Doctor Home Visit Requests

**Feature**: 013-doctor-home-visits
**Date**: 2026-04-06

## Summary

No significant technical unknowns required external research. All decisions are well-defined by the existing Espitalia codebase patterns and the constitution.

## Decisions

### 1. State Management Approach

- **Decision**: GetX 4.7.2 with .obs reactive variables and Obx() widgets
- **Rationale**: Mandated by constitution principle III. Entire codebase uses this pattern.
- **Alternatives considered**: None — GetX is non-negotiable per constitution.

### 2. Networking Pattern

- **Decision**: Use existing buildHttpResponse() -> handleResponse() -> model.fromJson() chain
- **Rationale**: All 145 lines of api_end_points.dart follow this pattern. Provides automatic token refresh, error handling, and header injection.
- **Alternatives considered**: None — established and proven pattern.

### 3. Form Validation Strategy

- **Decision**: Client-side validation matching API contract, with server-side validation as fallback
- **Rationale**: Reduces unnecessary API calls. API returns 422 with field-level errors as a safety net.
- **Alternatives considered**: Server-only validation — rejected because it adds latency and poor UX for obvious validation (empty required fields, date in past).

### 4. Date Picker Implementation

- **Decision**: Flutter Material `showDatePicker()` with `firstDate: DateTime.now()` constraint
- **Rationale**: Cross-platform, no additional packages needed. Enforces "after_or_equal:today" validation at the UI level.
- **Alternatives considered**: Custom calendar widget — rejected per constitution VII. Simplicity.

### 5. Preferred Doctor Selection

- **Decision**: Reuse existing `getDoctorList` API endpoint for doctor picker dropdown
- **Rationale**: Doctor data already available via existing API. No new endpoint needed.
- **Alternatives considered**: Dedicated doctor-visit-eligible endpoint — rejected because the API spec doesn't define one, and the existing doctor list serves the purpose.

### 6. Status Display Strategy

- **Decision**: Color-coded status badge widget (reuse pattern from test_order_status_badge.dart)
- **Rationale**: Existing lab test feature uses the same pattern. Provides clear visual status indicator.
- **Alternatives considered**: Text-only status — rejected because badge pattern is already established and provides better UX.

### 7. Role-Based UI Visibility

- **Decision**: Check `loginUserData.value.userRole` to show/hide admin features
- **Rationale**: Existing pattern in the app for role-gated screens (nurse requests, ICU admissions). Backend enforces RBAC via API — UI just controls visibility.
- **Alternatives considered**: Separate app builds per role — rejected as existing app already supports multi-role.

### 8. Reference Number Usage

- **Decision**: Use reference_number (e.g., VR-2026-0042) as the primary identifier in navigation and API calls for detail/status endpoints
- **Rationale**: API spec uses {reference} as URL parameter, not {id}. This is a human-readable identifier suitable for display and sharing.
- **Alternatives considered**: Use numeric id — rejected because API contract uses reference string.
