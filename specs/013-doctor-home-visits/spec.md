# Feature Specification: Doctor Home Visit Requests

**Feature Branch**: `013-doctor-home-visits`
**Created**: 2026-04-06
**Status**: Draft
**Input**: User description: "Patient-facing and admin APIs for requesting and managing doctor home visits, including submission, listing, detail view, admin management, status updates, and doctor assignment."

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Patient Submits a Home Visit Request (Priority: P1)

A patient who is unable to travel to a clinic opens the app and requests a doctor to visit them at home. They describe the reason for the visit, select a preferred date, provide a contact phone number, optionally choose a preferred doctor, and add any additional notes. After submission, they receive a confirmation with a reference number.

**Why this priority**: This is the core value proposition of the feature. Without the ability to submit a visit request, no other functionality is meaningful.

**Independent Test**: Can be fully tested by filling out the visit request form, submitting it, and verifying a reference number is returned with status "pending".

**Acceptance Scenarios**:

1. **Given** a logged-in patient, **When** they fill in all required fields (visit reason, preferred date, contact phone) and submit, **Then** the system creates a visit request with status "pending" and returns a unique reference number (format: VR-YYYY-NNNN).
2. **Given** a logged-in patient, **When** they submit a request with a preferred doctor selected, **Then** the visit request stores the preferred doctor association.
3. **Given** a logged-in patient, **When** they submit a request with a preferred date in the past, **Then** the system rejects the request with a validation error.
4. **Given** a logged-in patient, **When** they leave the visit reason empty, **Then** the system rejects the request with a validation error indicating the field is required.
5. **Given** a logged-in patient, **When** they submit a request with additional notes, **Then** the notes are saved and visible in the request detail.

---

### User Story 2 - Patient Views Their Visit Requests (Priority: P1)

A patient wants to check the status of their visit requests. They navigate to a list of their submitted requests and can tap into any request to see full details including the assigned doctor, status, admin notes, and any cancellation reason.

**Why this priority**: Patients need visibility into their requests immediately after submission. This is essential for the feature to be usable.

**Independent Test**: Can be tested by listing visit requests for a patient and verifying the list is paginated, sorted by most recent first, and each item shows key details.

**Acceptance Scenarios**:

1. **Given** a logged-in patient with multiple visit requests, **When** they open the visit requests list, **Then** they see a paginated list sorted by most recent first.
2. **Given** a logged-in patient, **When** they tap on a specific visit request, **Then** they see full details including reference number, status, visit reason, preferred date, contact phone, additional notes, preferred doctor, assigned doctor, admin notes, cancellation reason, and completion date.
3. **Given** a logged-in patient, **When** they attempt to view a request belonging to another patient, **Then** the system denies access.
4. **Given** a logged-in patient with no visit requests, **When** they open the visit requests list, **Then** they see an appropriate empty state message.

---

### User Story 3 - Admin Lists and Filters Visit Requests (Priority: P2)

An admin, receptionist, or doctor needs to review incoming visit requests. They can see all patient requests with filtering by status, date range, and assigned doctor to manage the queue efficiently.

**Why this priority**: Admin management is required for operational workflow, but patients can still submit and view requests without it.

**Independent Test**: Can be tested by logging in as an admin and verifying the list displays all patient requests with working filters.

**Acceptance Scenarios**:

1. **Given** an admin user, **When** they open the visit requests management screen, **Then** they see a paginated list of all visit requests with patient details.
2. **Given** an admin user, **When** they filter by status "pending", **Then** only pending requests are shown.
3. **Given** an admin user, **When** they filter by a date range, **Then** only requests with preferred dates within that range are shown.
4. **Given** an admin user, **When** they filter by assigned doctor, **Then** only requests assigned to that doctor are shown.
5. **Given** a regular patient user, **When** they attempt to access the admin list, **Then** the system denies access.

---

### User Story 4 - Admin Updates Visit Request Status (Priority: P2)

An admin or receptionist reviews a pending visit request and updates its status to confirmed, cancelled, or completed. They can add notes explaining the status change and, when cancelling, provide a cancellation reason.

**Why this priority**: Status management is the core admin workflow that moves requests through their lifecycle, but patients can still submit and track requests without admin actions.

**Independent Test**: Can be tested by changing a request's status and verifying the update is reflected in both admin and patient views.

**Acceptance Scenarios**:

1. **Given** an admin viewing a pending visit request, **When** they change the status to "confirmed" with a note, **Then** the status updates and the note is recorded in the status history.
2. **Given** an admin viewing a request, **When** they change the status to "cancelled" with a cancellation reason, **Then** the status updates and the cancellation reason is stored.
3. **Given** an admin viewing a confirmed request, **When** they change the status to "completed", **Then** the status updates and a completion timestamp is recorded.
4. **Given** a doctor who is not assigned to the request, **When** they attempt to update its status, **Then** the system denies the action.
5. **Given** an admin, **When** they attempt an invalid status transition (e.g., completed to pending), **Then** the system rejects the update with a validation error.

---

### User Story 5 - Admin Assigns a Doctor to a Visit Request (Priority: P2)

An admin or receptionist assigns an available doctor to a pending or confirmed visit request. This may differ from the patient's preferred doctor based on availability.

**Why this priority**: Doctor assignment is essential for operational fulfillment but depends on the core request and status management being in place.

**Independent Test**: Can be tested by assigning a doctor to a request and verifying the assignment is reflected in the request detail.

**Acceptance Scenarios**:

1. **Given** an admin viewing a visit request without an assigned doctor, **When** they assign a doctor, **Then** the assigned doctor is stored and visible in the request detail.
2. **Given** an admin, **When** they assign a doctor who does not exist, **Then** the system rejects the assignment with a validation error.
3. **Given** a doctor user, **When** they attempt to assign a doctor to a request, **Then** the system denies the action (only admin/receptionist can assign).
4. **Given** an admin, **When** they reassign a different doctor to an existing request, **Then** the assigned doctor is updated.

---

### Edge Cases

- What happens when a patient submits a request for today's date (boundary of "after_or_equal:today")?
- How does the system handle a request where the preferred doctor is later deactivated or removed?
- What happens when an admin tries to cancel an already completed request?
- How does the system behave when paginating with zero results matching the filters?
- What happens if the patient's contact phone format varies (international vs. local)?
- How does the system handle concurrent status updates on the same request?

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: System MUST allow authenticated patients to submit a home visit request with visit reason, preferred date, and contact phone as required fields.
- **FR-002**: System MUST validate that preferred date is today or a future date.
- **FR-003**: System MUST generate a unique reference number (format: VR-YYYY-NNNN) for each visit request upon creation.
- **FR-004**: System MUST set the initial status of every new visit request to "pending".
- **FR-005**: System MUST allow patients to optionally specify a preferred doctor and additional notes when submitting a request.
- **FR-006**: System MUST enforce field length limits: visit reason (1000 chars), contact phone (20 chars), additional notes (2000 chars).
- **FR-007**: System MUST provide a paginated list of the authenticated patient's own visit requests, sorted by most recent first.
- **FR-008**: System MUST allow patients to view full details of their own visit requests, including assigned doctor, admin notes, cancellation reason, and completion timestamp.
- **FR-009**: System MUST prevent patients from viewing visit requests belonging to other patients.
- **FR-010**: System MUST allow admin, receptionist, and doctor roles to view a paginated list of all visit requests with patient details.
- **FR-011**: System MUST support filtering the admin visit request list by status, date range (from/to), and assigned doctor.
- **FR-012**: System MUST allow admin and receptionist roles to update a visit request's status to confirmed, cancelled, or completed.
- **FR-013**: System MUST allow a doctor to update status only on requests assigned to them.
- **FR-014**: System MUST validate status transitions and reject invalid ones (e.g., completed to pending).
- **FR-015**: System MUST store a cancellation reason when status is changed to "cancelled".
- **FR-016**: System MUST record notes with status changes as part of the request's status history.
- **FR-017**: System MUST allow admin and receptionist roles to assign a doctor to a visit request.
- **FR-018**: System MUST validate that the assigned doctor exists in the system.
- **FR-019**: System MUST prevent doctor role from assigning doctors to requests (admin/receptionist only).

### Key Entities

- **Visit Request**: Represents a patient's request for a doctor home visit. Key attributes: reference number, visit type (home_visit), visit reason, preferred date, contact phone, additional notes, status (pending/confirmed/cancelled/completed), cancellation reason, completion timestamp, creation timestamp. Belongs to a patient. May reference a preferred doctor and an assigned doctor.
- **Patient**: The user who submits and owns visit requests. Identified by their authenticated account.
- **Doctor**: A healthcare provider who can be preferred by the patient or assigned by admin. Referenced by both preferred_doctor and assigned_doctor on a visit request.
- **Status History**: A record of status changes on a visit request, including the new status, notes, and timestamp of each change.

## Assumptions

- The visit type is always "home_visit" for this feature (no other visit types in scope).
- Valid status transitions follow: pending -> confirmed, pending -> cancelled, confirmed -> completed, confirmed -> cancelled. No backwards transitions allowed.
- Reference number format VR-YYYY-NNNN uses the year of creation and a sequential number.
- Pagination defaults to 15 items per page, with page 1 as default.
- The patient's contact phone on the visit request may differ from their profile phone (e.g., a caregiver's number).
- Push notifications for status changes are out of scope for this feature (can be added later).
- The admin list endpoint is accessible to admin, receptionist, and doctor roles; the assign-doctor action is restricted to admin and receptionist only.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Patients can submit a home visit request in under 2 minutes from opening the request form.
- **SC-002**: Patients can view their visit request history and check status within 3 taps from the main dashboard.
- **SC-003**: 95% of visit request submissions succeed on the first attempt (no validation errors for correctly filled forms).
- **SC-004**: Admins can filter and find a specific visit request within 15 seconds using status, date, or doctor filters.
- **SC-005**: Visit request status updates are reflected immediately in both admin and patient views.
- **SC-006**: The system correctly prevents unauthorized access in 100% of cross-patient and role-restricted scenarios.
