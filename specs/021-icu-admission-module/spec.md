# Feature Specification: ICU Admission (Intensive Care) Module

**Feature Branch**: `021-icu-admission-module`
**Created**: 2026-04-28
**Status**: Draft
**Input**: User description: "ICU Admission (Intensive Care) Module — patients can browse partner hospitals with ICU capabilities, view ICU department types, submit admission requests with urgency and medical context, and track request status through a full lifecycle."

## User Scenarios & Testing *(mandatory)*

### User Story 1 — Submit ICU Admission Request (Priority: P1)

A patient or family member in an urgent medical situation can fill out an ICU admission request form with all necessary patient details, medical context, and urgency level, then submit it to a specific hospital and ICU department. They receive a reference number confirming the request was received.

**Why this priority**: This is the core transaction of the entire module. Without the ability to submit a request, none of the other flows have value. It also carries the highest risk — a failed or lost request in a critical care scenario has life-safety implications.

**Independent Test**: Can be fully tested by selecting a hospital, completing the patient form, and submitting — the user receives a reference number and the request appears in their request list.

**Acceptance Scenarios**:

1. **Given** a logged-in user on the request form with a hospital pre-selected, **When** they fill all required fields and tap Submit, **Then** the request is submitted, a unique reference number is displayed, and the request appears as "Pending" in their request list.
2. **Given** a user on the form with required fields empty, **When** they tap Submit, **Then** each missing required field displays an inline error message and submission does not proceed.
3. **Given** a user who selects "Critical" urgency, **When** that selection is made, **Then** a non-blocking alert appears offering the option to call the emergency hotline before continuing the form.
4. **Given** a user who selects Hospital A, **When** they later switch to Hospital B, **Then** the previously selected ICU department is cleared and only Hospital B's departments are shown.
5. **Given** a user who successfully submits a request, **When** the app is closed and reopened, **Then** the reference number from their last submission is recoverable from the system.

---

### User Story 2 — Browse Hospitals and Find ICU Availability (Priority: P1)

A patient or family member can browse a list of partner hospitals, search by name, filter by location (governorate) and ICU department type, view individual hospital details including ICU departments offered and contact information, and initiate an admission request directly from the hospital detail page.

**Why this priority**: Finding the right hospital is the prerequisite for submitting a request. Without discoverability, users cannot complete the P1 flow without already knowing which hospital they want.

**Independent Test**: Can be fully tested by opening the hospital list, searching or filtering, tapping a hospital card, and verifying that the detail page shows ICU department information and a request initiation action.

**Acceptance Scenarios**:

1. **Given** a user on the hospital list, **When** they type a hospital name in the search bar, **Then** the list filters within a second to show matching results only.
2. **Given** a user on the hospital list, **When** they apply a governorate filter, **Then** only hospitals in that governorate appear.
3. **Given** a user on the hospital list, **When** they apply an ICU department type filter, **Then** only hospitals offering that department appear.
4. **Given** a user scrolls to the bottom of a long hospital list, **When** more results exist, **Then** the next page loads automatically without user action.
5. **Given** a user on the hospital detail page, **When** they tap "Request ICU Admission Here", **Then** the admission form opens with that hospital pre-filled.
6. **Given** a hospital with emergency phone listed, **When** a user taps the emergency call button, **Then** the device dialer opens with the hospital's emergency number.

---

### User Story 3 — Track and Manage Admission Requests (Priority: P2)

A patient or family member can view all their past and active ICU admission requests in a list, filtered by status. They can tap into any request to see the full detail — status timeline, patient info, assigned hospital and room (once admitted), and accompanying contact — and can cancel a pending or under-review request.

**Why this priority**: Users need visibility and control after submitting. Without tracking, they have no way to know what is happening with their request, and cancellation prevents abandonment of stale requests.

**Independent Test**: Can be fully tested by viewing the request list, filtering by status, opening a request detail, viewing the status timeline, and (for pending requests) cancelling with an optional reason.

**Acceptance Scenarios**:

1. **Given** a user with multiple requests, **When** they open "My Admission Requests", **Then** all their requests are listed newest-first with status chip, urgency badge, hospital name, and patient name visible.
2. **Given** a user on the request list, **When** they apply a status filter (e.g., "Pending"), **Then** only requests with that status are shown.
3. **Given** a user opens a request in "Admitted" status, **When** the detail page loads, **Then** an admission assignment card shows the assigned room, bed, and admitted date.
4. **Given** a user opens a request in "Pending" status, **When** they tap "Cancel Request", **Then** a confirmation dialog appears with an optional reason field, and confirming the cancellation updates the request status to "Cancelled".
5. **Given** a user opens a request in "Admitted" status, **When** they view the page, **Then** no cancel button is shown.
6. **Given** a request is "Discharged", **When** a user views the detail, **Then** discharge info is shown and the status timeline shows all completed steps.
7. **Given** a request is "Rejected" or "Cancelled", **When** a user views the detail, **Then** a highlighted banner shows the reason.

---

### User Story 4 — Browse ICU Department Types (Priority: P3)

A patient or family member can view all types of ICU departments available across partner hospitals (General ICU, Cardiac ICU, Neonatal ICU, etc.) with a description of each, and can tap a department type to see all hospitals that offer it.

**Why this priority**: Helpful for users who know the type of care needed but not a specific hospital. Lower priority as it is a discovery aid that can also be accomplished via the hospital filter.

**Independent Test**: Can be fully tested by opening the ICU departments list, viewing department types with descriptions, tapping one, and verifying the hospital list opens filtered to that department type.

**Acceptance Scenarios**:

1. **Given** a user opens "Browse ICU Departments", **When** the page loads, **Then** all available department types are displayed with icon and description.
2. **Given** a user taps a department type, **When** navigation completes, **Then** the hospital list opens filtered to hospitals offering that department.

---

### Edge Cases

- What happens when a hospital has no ICU departments listed? The form's department selector should show an empty state and prevent submission until a valid department is selected.
- What happens when the user's network connection fails during form submission? The submit button shows an error, the user is not navigated away, and the form data is preserved so they can retry.
- What happens when a request's status is updated by the hospital while the user is viewing the detail? On pull-to-refresh, the latest status is shown.
- What happens when a hospital's available bed count is zero for all ICU departments? The hospital still appears in the list but "No beds available" is shown; users can still submit a request (admin may accommodate).
- What if the user enters a 2000-character diagnosis and tries to add more? A character counter is visible and the field stops accepting input at the limit.
- What if the user selects a date beyond 30 days? The date picker does not allow selection beyond today + 30 days.
- What happens if the user's session expires mid-form? The system transparently refreshes the session token; if refresh fails, the user is prompted to log in and their form data is preserved where possible.

---

## Requirements *(mandatory)*

### Functional Requirements

**Hospital Discovery**

- **FR-001**: Users MUST be able to search hospitals by name with results appearing within a second of stopping typing.
- **FR-002**: Users MUST be able to filter hospitals by geographic area (governorate and city).
- **FR-003**: Users MUST be able to filter hospitals by ICU department type.
- **FR-004**: Users MUST be able to filter to hospitals with currently available beds.
- **FR-005**: Hospital lists MUST load additional results automatically as users scroll, without requiring a manual action.
- **FR-006**: Users MUST be able to refresh hospital lists by pulling down on the screen.

**Hospital Detail**

- **FR-007**: Each hospital detail page MUST show available ICU departments with bed availability (where provided).
- **FR-008**: Each hospital detail MUST provide a direct action to call the hospital phone and the emergency phone separately.
- **FR-009**: Each hospital detail MUST offer a one-tap action to begin an admission request for that hospital.
- **FR-010**: Hospital detail pages MUST show address information and, if coordinates are available, a link to open the location in a maps application.

**Admission Request Form**

- **FR-011**: Users MUST be able to specify patient name, age, gender, diagnosis, urgency level, and accompanying person contact as required fields.
- **FR-012**: The form MUST allow optional input for national ID, current condition, attending doctor, medical history, current medications, allergies, preferred date/time, and additional notes.
- **FR-013**: Diagnosis, medical history, current medications, allergies, current condition, and additional notes fields MUST enforce a 2,000-character maximum with a visible counter.
- **FR-014**: Urgency level MUST have three options — Routine, Urgent, and Critical — with visual differentiation between them.
- **FR-015**: Selecting Critical urgency MUST display a non-blocking alert offering the option to call the emergency hotline before continuing.
- **FR-016**: Hospital selection MUST cascade to department selection — changing the hospital clears the selected department and loads only the new hospital's departments.
- **FR-017**: When navigating to the form from a hospital detail page, the hospital field MUST be pre-populated and visually locked; the user may change it via an explicit action.
- **FR-018**: The accompanying person phone field MUST validate that the number contains 7 to 20 digits, optionally preceded by a `+`.
- **FR-019**: The preferred admission date MUST be limited to today through 30 days from today.

**Submission & Confirmation**

- **FR-020**: On successful submission, the system MUST display a unique reference number in `ICU-YYYY-NNNN` format.
- **FR-021**: The reference number MUST be copyable to the device clipboard with a single action.
- **FR-022**: The most recently submitted reference number MUST be persisted on the device so it can be recovered if the user closes the app before seeing the confirmation screen.
- **FR-023**: The system MUST NOT transmit status, room assignment, bed assignment, admission timestamps, payment fields, or commission-related fields from the patient app.

**Request Tracking**

- **FR-024**: Users MUST be able to view all their admission requests in a list ordered newest-first, with status chip, urgency badge, hospital name, patient name, and preferred date visible on each card.
- **FR-025**: Users MUST be able to filter their request list by status (All, Pending, Under Review, Approved, Admitted, Discharged, Rejected, Cancelled).
- **FR-026**: The request detail MUST show a visual timeline reflecting the progression through statuses with timestamps for each transition.
- **FR-027**: Admission assignment details (room, bed, admitted date) MUST only appear on the detail page when the request status is "Admitted" or "Discharged".
- **FR-028**: Discharge information MUST only appear when the request status is "Discharged".
- **FR-029**: A cancellation/rejection reason banner MUST appear on the detail page when the status is "Cancelled" or "Rejected".
- **FR-030**: A "Cancel Request" action MUST be visible and functional only when the request status is "Pending" or "Under Review".
- **FR-031**: Cancellation MUST require a confirmation step with an optional free-text reason field (max 500 characters).

**Emergency Hotline**

- **FR-032**: A prominent emergency call-to-action MUST remain visible throughout the ICU module home, admission detail, and submission confirmation screens.
- **FR-033**: Tapping any emergency call action MUST open the device dialer with the configured emergency hotline number.
- **FR-034**: The emergency banner MUST NOT be dismissible.

**Localization & Accessibility**

- **FR-035**: All user-facing text MUST support both English and Arabic, with Arabic layout rendering right-to-left.
- **FR-036**: The module MUST render correctly in both light and dark display modes.

### Key Entities

- **Hospital**: A partner healthcare facility that offers ICU services. Has a name, contact information (including an emergency number), location, list of ICU departments, and optionally a description and amenities list.
- **ICU Department**: A category of intensive care unit (e.g., General ICU, Cardiac ICU, Neonatal ICU). Belongs to a hospital and may report available bed count.
- **Admission Request**: A patient-initiated request for an ICU bed. Carries patient identification, medical context, urgency level, preferred scheduling, and an accompanying person contact. Progresses through a defined status lifecycle. Has a unique reference number.
- **Status History**: An ordered record of all status transitions on an admission request, with timestamps and optional notes.
- **Admission Status**: An enumerated state of a request — Pending, Under Review, Approved, Admitted, Discharged, Rejected, or Cancelled. Patient can only trigger the Cancelled transition (from Pending or Under Review). All other transitions are server-controlled.
- **Urgency Level**: A classification of the admission urgency — Routine, Urgent, or Critical — with distinct visual treatment throughout the module.

---

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: A patient or family member can complete and submit an ICU admission request in under 5 minutes from the moment they open the form.
- **SC-002**: Users can locate a specific hospital by name or governorate within 3 taps and 10 seconds from the ICU home screen.
- **SC-003**: 100% of submitted admission requests generate a unique reference number that the user can copy within 10 seconds of submission.
- **SC-004**: The reference number from the user's last submitted request is recoverable within 5 seconds of opening the app, even after force-close.
- **SC-005**: The request status timeline accurately reflects all historical status transitions at the moment the detail screen is loaded.
- **SC-006**: The emergency hotline call action is reachable in 2 taps or fewer from the ICU home screen, the submission confirmation, and any request detail screen.
- **SC-007**: All required form fields produce an inline validation error when left empty — no submission proceeds silently with incomplete data.
- **SC-008**: Users can cancel an eligible admission request (Pending or Under Review) within 3 taps from the request list.
- **SC-009**: The module renders correctly with full right-to-left layout when the app language is set to Arabic, with no truncated or overlapping text.
- **SC-010**: The module introduces zero new static analysis warnings compared to the codebase baseline.

---

## Assumptions

- The backend API for hospitals, ICU departments, and admission requests exists at the documented endpoints and returns the documented response shapes. Where the API is unavailable, empty states with retry actions are shown.
- "Available beds" is data provided by the backend per ICU department — the app displays what it receives without real-time polling.
- The emergency hotline number is configured in the app's configuration file and does not change per request or per hospital context.
- Pagination follows the standard 15-items-per-page response envelope already used by other modules in this app.
- The admission request status lifecycle is managed entirely by the backend. The app only triggers the Cancel transition; all other transitions are server-initiated.
- Users are already authenticated before accessing the ICU module. Authentication and session refresh follow the existing app pattern and are transparent to the user.
- Push notifications for ICU status changes follow the existing notification infrastructure. A notification payload containing `type: icu_admission_status_changed` and a `request_id` routes directly to the relevant request detail screen.
