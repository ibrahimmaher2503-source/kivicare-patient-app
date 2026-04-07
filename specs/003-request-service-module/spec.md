# Feature Specification: Request Service Module

**Feature Branch**: `003-request-service-module`
**Created**: 2026-03-29
**Status**: Implementation Complete
**Input**: User description: "Request Service module (custom catalog requests) with models, UI, themes, and translations"

## User Scenarios & Testing *(mandatory)*

### User Story 1 - View My Service Requests (Priority: P1)

A patient wants to see all their custom service requests and check
the status of each. They open the Request Service section, see a
paginated list of their requests with name, type, description,
status (pending, accepted, rejected), and creation date. They can
search by name/description and filter by status.

**Why this priority**: Viewing existing requests is the most common
action. Patients need to track what they've submitted and its
approval status. This read-only view is the foundation.

**Independent Test**: Can be fully tested by opening the Request
Service section, viewing the list, searching, and filtering by
status. Delivers visibility even without create capability.

**Acceptance Scenarios**:

1. **Given** the patient opens "My Service Requests", **When** the
   list loads, **Then** requests are displayed with name, type icon,
   description preview, status badge (pending/accepted/rejected),
   and creation date.
2. **Given** the patient types a search term, **When** results load,
   **Then** only requests matching the name or description are shown.
3. **Given** the patient selects the "Pending" status filter, **When**
   results load, **Then** only pending requests are displayed.
4. **Given** the patient has no requests, **When** the list loads,
   **Then** an empty state with a call-to-action to create a request
   is displayed.
5. **Given** the API returns an error, **When** the screen loads,
   **Then** an appropriate error message is displayed.

---

### User Story 2 - Create a Service Request (Priority: P2)

A patient wants to request a custom service not available in the
standard catalog. They fill in the service name (required), an
optional description, and an optional type classification. After
submission, the request is saved with "pending" status and the
patient receives confirmation.

**Why this priority**: Creating requests is the core action of the
module. Without it, the module has no input mechanism. This is a
simple form with minimal required fields.

**Independent Test**: Can be tested by filling in the form, submitting,
and verifying the request appears in the list with "pending" status.

**Acceptance Scenarios**:

1. **Given** the patient opens the create form, **When** the screen
   loads, **Then** fields for service name (required), description
   (optional), and type (optional) are displayed.
2. **Given** the patient fills in the name and submits, **When** the
   API responds successfully, **Then** a success message is shown and
   the patient is navigated back to the list.
3. **Given** the patient leaves the name field empty, **When** they
   tap submit, **Then** a validation error is shown.
4. **Given** the API returns an error, **When** the patient submits,
   **Then** a user-friendly error message is displayed and form data
   is preserved.

---

### Edge Cases

- What happens when the patient's auth token expires? The existing
  token regeneration flow handles this transparently.
- What if the request list is very long? Pagination handles this
  with scroll-to-load-more.
- How does the card display different service types? Icons are
  mapped by type keyword (nurse, lab, home, emergency, default).

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: Authenticated users MUST be able to view a paginated
  list of their service requests with name, type, description,
  status, and creation date.
- **FR-002**: Users MUST be able to search requests by name or
  description.
- **FR-003**: Users MUST be able to filter requests by status
  (pending, accepted, rejected).
- **FR-004**: Authenticated users MUST be able to create a service
  request with a required name, optional description (max 500
  characters), and optional type.
- **FR-005**: Request creation MUST validate that the name field is
  not empty.
- **FR-006**: The request list MUST display type-appropriate icons
  based on the service type (nurse, lab, home, emergency).
- **FR-007**: Status badges MUST be color-coded: pending=amber,
  accepted=green, rejected=red.
- **FR-008**: All user-facing text MUST be localized in all five
  supported languages (EN, AR, DE, FR, HI).
- **FR-009**: All screens MUST support both light and dark themes
  using the existing design token system.
- **FR-010**: All screens MUST follow the Clinical Elegance design
  system (16px card radius, 12px input radius, 24px padding,
  navy-tinted shadows).

### Key Entities

- **Request Service**: A patient's custom service request. Attributes:
  name, description, type (laboratory/nurse/home/emergency), status
  (active/inactive), approval status (pending/accept/reject),
  created by, timestamps.

### Assumptions

- The patient app only needs the `user` (patient) role perspective.
- This is a simple request-and-track module — no editing or
  cancellation of submitted requests.
- The admin reviews and accepts/rejects requests server-side.
- The `type` field is a free-text hint for categorization, not a
  strict enum. Icons are mapped by keyword matching.
- Only 2 API endpoints: POST to create, GET to list with filters.
- No detail screen needed — the list card shows all relevant info.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Users can view their service requests within 2 taps
  from the home screen.
- **SC-002**: Users can create a new service request in under 1
  minute.
- **SC-003**: Request list loads within 2 seconds on a standard
  mobile connection.
- **SC-004**: Both user stories are functional in light and dark
  themes without visual defects.
- **SC-005**: All user-facing text appears correctly in all five
  supported languages, including RTL layout for Arabic.
