# Feature Specification: Nurse Request Module

**Feature Branch**: `002-nurse-request-module`
**Created**: 2026-03-29
**Status**: Implementation Complete
**Input**: User description: "Nurse Request module integration with 7 API endpoints, models, UI screens with existing theme, and translations"

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Browse Available Nurses (Priority: P1)

A patient wants to find a nurse for home care. They open the Nurse
section, see a list of available nurses with their specialization,
experience, hourly rate, and service area. They can search by name
or specialization, filter by availability status and service area,
and tap a nurse to view their full profile including about text,
contact details, and profile image.

**Why this priority**: Browsing nurses is the entry point for the
entire module. Patients cannot request a nurse without first
discovering who is available. This read-only foundation enables all
other stories.

**Independent Test**: Can be fully tested by opening the Nurse
section, browsing the nurse list, applying filters, searching by
name, and viewing a nurse's profile. Delivers discovery value even
without request capability.

**Acceptance Scenarios**:

1. **Given** the patient opens the Nurse section, **When** the list
   loads, **Then** available nurses are displayed with name, profile
   image, specialization, experience, hourly rate, availability
   status, and service area.
2. **Given** the patient types a search term, **When** results load,
   **Then** nurses matching the name, specialization, or service area
   are shown.
3. **Given** the patient filters by "available" status, **When**
   results load, **Then** only available nurses are displayed.
4. **Given** the patient filters by service area, **When** results
   load, **Then** only nurses serving that area are shown.
5. **Given** the patient taps a nurse, **When** the detail screen
   loads, **Then** the nurse's full profile is displayed: name, photo,
   specialization, experience, about, hourly rate, availability,
   service area, email, and mobile.
6. **Given** no nurses match the filters or the API returns an error,
   **When** the screen loads, **Then** an appropriate empty state or
   error message is displayed.

---

### User Story 2 - Create a Nurse Request (Priority: P2)

A patient selects a nurse (or requests without specifying one) and
creates a home care request. They fill in the service description,
preferred date and time, duration in hours, their address, contact
number, and optional notes. The system calculates the total amount
based on the nurse's hourly rate and the duration. After submission,
a confirmation is shown with the request details.

**Why this priority**: Creating a request is the core transactional
action. Without it, the module is informational only. This converts
browsing intent into a trackable service request.

**Independent Test**: Can be tested by filling in the request form,
submitting it, and verifying the confirmation screen shows the
request details and calculated total.

**Acceptance Scenarios**:

1. **Given** the patient opens the request form (optionally with a
   pre-selected nurse), **When** the form loads, **Then** fields
   for service description, preferred date, preferred time, duration,
   address, contact number, and notes are displayed.
2. **Given** the patient fills in all required fields and submits,
   **When** the API responds successfully, **Then** a confirmation
   screen displays the request details including calculated total
   amount.
3. **Given** a nurse is selected with an hourly rate of 50 and
   duration is 4 hours, **When** the form displays the summary,
   **Then** the total shows 200.
4. **Given** the patient enters a preferred date in the past, **When**
   they attempt to submit, **Then** a validation error indicates the
   date must be today or later.
5. **Given** the patient leaves required fields empty (service
   description, preferred date, duration, address line 1, city,
   contact number), **When** they tap submit, **Then** validation
   errors are shown for each missing field.
6. **Given** the API returns an error, **When** the patient submits,
   **Then** a user-friendly error message is displayed and form data
   is preserved.

---

### User Story 3 - View & Track Nurse Requests (Priority: P3)

A patient views their list of nurse requests and checks the status
of each. They can filter by status (pending, confirmed, in_progress,
completed, cancelled) and tap a request to see full details
including nurse assignment, address, amounts, and notes.

**Why this priority**: After creating a request, patients need
visibility into its progress. This completes the core request
lifecycle from the patient's perspective.

**Independent Test**: Can be tested by viewing the request list,
filtering by status, tapping a request, and verifying all detail
fields display correctly.

**Acceptance Scenarios**:

1. **Given** the patient opens "My Nurse Requests", **When** the list
   loads, **Then** requests are displayed with service description,
   preferred date, status, nurse name (if assigned), and total amount.
2. **Given** the patient selects a status filter, **When** results
   load, **Then** only requests with that status are shown.
3. **Given** the patient taps a request, **When** the detail screen
   loads, **Then** all details are shown: service description, nurse
   info, preferred date/time, duration, full address, contact number,
   status, payment status, total amount, patient notes, admin notes,
   and timestamps.
4. **Given** the patient has no requests, **When** the list loads,
   **Then** an empty state with a call-to-action to browse nurses is
   displayed.

---

### User Story 4 - Edit a Pending Request (Priority: P4)

A patient realizes they need to change details on a request that
has not yet been confirmed. They open the pending request, tap edit,
modify the fields, and save. Only requests in "pending" status can
be edited.

**Why this priority**: Editing allows patients to correct mistakes
before a nurse is assigned. It's secondary to creating and tracking
but important for user autonomy.

**Independent Test**: Can be tested by opening a pending request,
tapping edit, changing fields, saving, and verifying the updates
are reflected.

**Acceptance Scenarios**:

1. **Given** the patient views a request with status "pending",
   **When** they tap "Edit", **Then** the edit form opens pre-filled
   with current values.
2. **Given** the patient modifies fields and saves, **When** the API
   responds successfully, **Then** the detail screen shows updated
   values and a success message is displayed.
3. **Given** the patient views a request with status other than
   "pending", **When** they view the detail, **Then** the edit option
   is not available.
4. **Given** the patient clears a required field and saves, **When**
   they tap save, **Then** validation errors are shown.

---

### User Story 5 - Cancel a Request (Priority: P5)

A patient decides to cancel a request that is in "pending" or
"confirmed" status. They provide a cancellation reason and confirm
the action.

**Why this priority**: Cancellation is important for patient autonomy
but secondary to creating, tracking, and editing requests.

**Independent Test**: Can be tested by opening a pending/confirmed
request, tapping cancel, entering a reason, confirming, and
verifying the status changes to cancelled.

**Acceptance Scenarios**:

1. **Given** the patient views a request with status "pending" or
   "confirmed", **When** they tap "Cancel Request", **Then** a dialog
   prompts for a cancellation reason.
2. **Given** the patient enters a reason and confirms, **When** the
   API responds successfully, **Then** the request status updates to
   "cancelled" and a success message is shown.
3. **Given** the patient views a request with status "in_progress" or
   "completed", **When** they view the detail, **Then** the cancel
   option is not available.
4. **Given** the patient enters a cancellation reason exceeding 500
   characters, **When** they attempt to confirm, **Then** a validation
   error is shown.
5. **Given** the patient dismisses the cancellation dialog, **When**
   the dialog closes, **Then** the request remains unchanged.

---

### Edge Cases

- What happens when the patient's auth token expires mid-request
  creation? The existing token regeneration flow handles this
  transparently.
- How does the system handle a nurse becoming unavailable after being
  selected for a request? The server validates nurse existence on
  submit; the client displays the server error.
- What if the patient enters duration_hours as 0 or negative? Client
  validation enforces min:1, max:24.
- How does the app handle a nurse with no profile image? Display a
  default avatar placeholder.
- What if the calculated total is 0 (no nurse selected)? Display
  "To be determined" instead of a zero amount.
- What happens when the patient edits a request that was confirmed
  between loading and saving? The server rejects the update; the
  client shows an error and refreshes the detail.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: Authenticated users MUST be able to view a paginated
  list of nurses with name, profile image, specialization, experience,
  hourly rate, availability status, and service area.
- **FR-002**: Users MUST be able to search nurses by name,
  specialization, or service area.
- **FR-003**: Users MUST be able to filter nurses by availability
  status (available/unavailable).
- **FR-004**: Users MUST be able to filter nurses by service area.
- **FR-005**: Users MUST be able to view a nurse's full profile
  including about text, email, mobile, and profile image.
- **FR-006**: Authenticated users MUST be able to create a nurse
  request with service description, preferred date, preferred time,
  duration, address, contact number, and optional patient notes.
- **FR-007**: Request creation MUST validate: service description
  required (max 1000 chars), preferred date required (today or later),
  duration required (1-24 hours), address line 1 required (max 255),
  city required (max 100), contact number required (max 20).
- **FR-008**: If a nurse is selected, the system MUST display the
  calculated total (hourly rate x duration) before submission.
- **FR-009**: Authenticated users MUST be able to view their own
  nurse requests in a paginated list.
- **FR-010**: Users MUST be able to filter requests by status
  (pending, confirmed, in_progress, completed, cancelled).
- **FR-011**: Users MUST be able to view full request details
  including nurse info, address, amounts, notes, and timestamps.
- **FR-012**: Users MUST be able to edit their own requests that
  are in "pending" status only. All create fields are editable.
- **FR-013**: Users MUST be able to cancel requests that are in
  "pending" or "confirmed" status only, with a mandatory
  cancellation reason (max 500 characters).
- **FR-014**: All user-facing text MUST be localized in all five
  supported languages (EN, AR, DE, FR, HI).
- **FR-015**: All screens MUST support both light and dark themes
  using the existing design token system.
- **FR-016**: All screens MUST follow the Clinical Elegance design
  system (16px card radius, 12px input radius, 24px padding,
  navy-tinted shadows).

### Key Entities

- **Nurse**: A healthcare professional available for home care.
  Attributes: name, first/last name, email, mobile, specialization,
  experience, about, hourly rate, availability status (available/
  unavailable), service area, profile image, status.
- **Nurse Request**: A patient's request for nurse home care.
  Attributes: patient (nested), nurse (nested, optional), service
  description, request date, preferred date, preferred time,
  duration hours, address (nested with line 1/2, city, state,
  country, postal code, lat/lng, full address), contact number,
  status, payment status, total amount, patient notes, admin notes,
  cancelled by, cancellation reason, timestamps.

### Assumptions

- The patient app only needs the `user` (patient) role perspective.
  Nurse and admin views are not in scope.
- `patient_id` is automatically set to the authenticated user on
  request creation.
- `total_amount` is calculated server-side as nurse.hourly_rate x
  duration_hours when a nurse is selected. The client displays the
  estimated total but does not set it.
- A request without a nurse_id means the patient wants any available
  nurse — the admin assigns one later.
- The `nurse_id` in the API refers to the User ID of the nurse, not
  the Nurse model ID.
- Status badge colors follow the same pattern as lab tests: pending=
  amber, confirmed=blue, in_progress=indigo, completed=green,
  cancelled=red.
- The existing `buildHttpResponse()` network layer and token
  management handles authentication and error responses.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Users can browse available nurses and view profiles
  within 3 taps from the home screen.
- **SC-002**: Users can complete a nurse request (fill form, submit)
  in under 3 minutes.
- **SC-003**: Request list and detail screens load and display data
  within 2 seconds on a standard mobile connection.
- **SC-004**: All five user stories are functional in both light and
  dark themes without visual defects.
- **SC-005**: All user-facing text appears correctly in all five
  supported languages, including RTL layout for Arabic.
- **SC-006**: 90% of users can complete their first nurse request
  without assistance or errors.
- **SC-007**: Users can edit a pending request and see updates
  reflected immediately after saving.
