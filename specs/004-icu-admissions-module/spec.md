# Feature Specification: ICU Admissions Module

**Feature Branch**: `004-icu-admissions-module`
**Created**: 2026-03-29
**Status**: Implementation Complete
**Input**: User description: "ICU Admissions module integration with hospitals, ICU departments, admission requests, models, UI, themes, and translations"

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Browse Hospitals & ICU Departments (Priority: P1)

A patient (or their family member) needs to find a hospital with
available ICU beds. They open the ICU section, see a list of
hospitals with their type, city, rating, and department count. They
can search by name/city, filter by specialty (cardiac, neurology,
etc.), filter by ventilator availability, and filter by accepted
insurance. They tap a hospital to see its full details including
all ICU departments with bed availability, equipment level, and
daily pricing. They can also browse ICU departments directly with
filters for hospital, specialty, available beds, and ventilator.

**Why this priority**: Finding a suitable hospital is the entry
point for the entire module. Patients cannot submit an admission
request without first identifying where beds are available.

**Independent Test**: Can be tested by opening the ICU section,
browsing hospitals, applying filters, viewing hospital details with
departments, and browsing the department list directly.

**Acceptance Scenarios**:

1. **Given** the patient opens the ICU section, **When** the hospital
   list loads, **Then** hospitals are displayed with name, logo, type
   (private/government/military/university), city, rating,
   departments count, and accepted insurance tags.
2. **Given** the patient searches by name or city, **When** results
   load, **Then** matching hospitals are shown.
3. **Given** the patient filters by specialty "cardiac", **When**
   results load, **Then** only hospitals with cardiac ICU departments
   are shown.
4. **Given** the patient filters by ventilator availability, **When**
   results load, **Then** only hospitals with ventilator-equipped
   departments are shown.
5. **Given** the patient taps a hospital, **When** the detail screen
   loads, **Then** the hospital profile is shown with all ICU
   departments listing: name, specialty, total/available beds,
   ventilator/oxygen indicators, equipment level, daily price.
6. **Given** the patient browses ICU departments directly, **When**
   the department list loads, **Then** departments are shown with
   filters for hospital, specialty, available beds, and ventilator.
7. **Given** no hospitals match the filters, **When** the screen
   loads, **Then** an appropriate empty state is displayed.

---

### User Story 2 - Submit an ICU Admission Request (Priority: P2)

A patient or family member submits an ICU admission request for a
specific hospital. The form is multi-section: patient information
(name, age, gender, national ID, insurance number), case details
(medical condition, diagnosis, case type, urgency, equipment needs,
current location, ambulance need), emergency contact (name, phone,
relationship), payment method (insurance or cash with conditional
insurance fields), and optional medical report file uploads. After
submission, the system generates a request number and shows
confirmation.

**Why this priority**: The admission request is the core
transactional action. This is the most complex form in the app
with conditional validation, file uploads, and multiple sections.

**Independent Test**: Can be tested by selecting a hospital,
filling in all form sections, uploading a report, submitting, and
verifying the confirmation with request number.

**Acceptance Scenarios**:

1. **Given** the patient opens the admission form for a hospital,
   **When** the form loads, **Then** sections for patient info, case
   details, contact, payment, and file upload are displayed.
2. **Given** the patient fills in all required fields and submits,
   **When** the API responds successfully, **Then** a confirmation
   screen shows the request number (ICU-YYYY-NNNN) and summary.
3. **Given** the patient selects "insurance" as payment method,
   **When** the payment section updates, **Then** insurance provider
   and insurance number fields become required.
4. **Given** the patient selects "cash" as payment method, **When**
   the payment section updates, **Then** insurance fields are hidden.
5. **Given** the patient attaches medical report files, **When** they
   select files, **Then** only pdf, jpg, jpeg, png, doc, docx files
   up to 10MB each are accepted.
6. **Given** required fields are empty, **When** the patient taps
   submit, **Then** validation errors highlight each missing field.
7. **Given** the API returns an error, **When** the patient submits,
   **Then** a user-friendly error is shown and form data is preserved.

---

### User Story 3 - View & Track Admission Requests (Priority: P3)

A patient views their list of ICU admission requests and checks the
status of each. They can filter by status (pending, accepted,
rejected, info_requested, cancelled) and tap a request to see full
details including hospital, department, patient info, case details,
contact, payment, admin notes, rejection reason, and attached
medical reports.

**Why this priority**: After submitting a request, patients need
visibility into its progress, especially for urgent ICU cases.

**Independent Test**: Can be tested by viewing the request list,
filtering by status, and tapping a request to verify all fields.

**Acceptance Scenarios**:

1. **Given** the patient opens "My ICU Requests", **When** the list
   loads, **Then** requests are displayed with request number,
   hospital name, status, urgency, case type, and creation date.
2. **Given** the patient selects a status filter, **When** results
   load, **Then** only requests with that status are shown.
3. **Given** the patient taps a request, **When** the detail screen
   loads, **Then** all sections are shown: patient info, case details,
   contact info, hospital/department, payment, admin notes, rejection
   reason (if rejected), medical reports (downloadable), and dates.
4. **Given** the patient has no requests, **When** the list loads,
   **Then** an empty state with a CTA to browse hospitals is shown.

---

### User Story 4 - Cancel an Admission Request (Priority: P4)

A patient decides to cancel a pending admission request. They
provide a cancellation reason and confirm. Only requests in
"pending" status can be cancelled by the patient.

**Why this priority**: Cancellation allows patients to withdraw
requests they no longer need, but is secondary to submitting and
tracking.

**Independent Test**: Can be tested by opening a pending request,
tapping cancel, entering a reason, and confirming.

**Acceptance Scenarios**:

1. **Given** the patient views a request with status "pending",
   **When** they tap "Cancel Request", **Then** a dialog prompts
   for a cancellation reason.
2. **Given** the patient enters a reason and confirms, **When** the
   API responds successfully, **Then** the status updates to
   "cancelled" and a success message is shown.
3. **Given** the patient views a request with status other than
   "pending", **When** they view the detail, **Then** the cancel
   option is not available.
4. **Given** the patient enters a reason exceeding 500 characters,
   **When** they attempt to confirm, **Then** a validation error
   is shown.

---

### Edge Cases

- What happens when bed availability changes between browsing and
  submitting? The server validates availability; the client displays
  the server error.
- How does the app handle hospitals with no ICU departments? Display
  a "No departments" message in the hospital detail.
- What if the patient selects insurance but doesn't fill insurance
  fields? Client-side conditional validation catches this before
  submission.
- What if a file exceeds 10MB? Show a localized error before upload.
- What if the patient uploads an unsupported file type? Only allow
  pdf, jpg, jpeg, png, doc, docx via file picker filter.
- How does the app handle the "info_requested" status? Display it
  as a status badge with an informational message; no patient action
  required (admin handles).

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: Authenticated users MUST be able to view a paginated
  list of hospitals with name, logo, type, city, rating, departments
  count, and accepted insurance.
- **FR-002**: Users MUST be able to search hospitals by name, city,
  address, or description.
- **FR-003**: Users MUST be able to filter hospitals by specialty,
  ventilator availability, and accepted insurance.
- **FR-004**: Users MUST be able to view hospital details with all
  ICU departments showing name, specialty, bed counts (total/
  available), ventilator/oxygen indicators, equipment level, daily
  price, and description.
- **FR-005**: Users MUST be able to browse ICU departments with
  filters for hospital, specialty, available beds, and ventilator.
- **FR-006**: Authenticated users MUST be able to create an ICU
  admission request with: hospital (required), department (optional),
  patient info (name, age, gender required; national ID, insurance
  number conditional), case details (medical condition, case type,
  urgency required; diagnosis, equipment needs, location, ambulance
  optional), contact (name, phone required; relationship optional),
  payment method (required; insurance fields conditional), and
  medical report uploads (optional, pdf/jpg/png/doc, max 10MB each).
- **FR-007**: Request creation MUST validate all required fields with
  appropriate max lengths. Insurance fields MUST be required when
  payment method is "insurance".
- **FR-008**: System MUST auto-generate request numbers in
  ICU-YYYY-NNNN format (server-side).
- **FR-009**: Authenticated users MUST be able to view their own
  admission requests in a paginated list filtered by status.
- **FR-010**: Users MUST be able to view full request details
  including all sections, admin notes, rejection reason, and
  downloadable medical reports.
- **FR-011**: Users MUST be able to cancel requests in "pending"
  status with a mandatory cancellation reason (max 500 characters).
- **FR-012**: All user-facing text MUST be localized in all five
  supported languages (EN, AR, DE, FR, HI).
- **FR-013**: All screens MUST support both light and dark themes.
- **FR-014**: All screens MUST follow the Clinical Elegance design
  system.

### Key Entities

- **Hospital**: A healthcare facility with ICU departments.
  Attributes: name, slug, description, hospital type, address, city,
  state, country, lat/lng, phone, email, website, license number,
  accepted insurance (list), rating, logo, status, departments list.
- **ICU Department**: A department within a hospital. Attributes:
  name, hospital, specialty type, total beds, available beds,
  has ventilator, has oxygen, equipment level (basic/advanced/full),
  daily price, description, status.
- **ICU Admission Request**: A patient's request for ICU admission.
  Attributes: request number, patient (nested), patient info (nested:
  name, age, gender, national ID, insurance number), case details
  (nested: condition, diagnosis, case type, urgency, ventilator/
  oxygen/ambulance needs, location), contact (nested: name, phone,
  relationship), hospital, department, status, urgency, payment
  method, insurance provider, admin notes, rejection reason,
  response date, medical reports (list of files), timestamps.

### Assumptions

- The patient app only needs the `user` (patient) role perspective.
- The truncated endpoint 4.6 is "Get Admission Request Details"
  (GET /v1/icu-admission-requests/{id}) returning a single resource.
- A cancel endpoint exists (POST /v1/icu-admission-requests/{id}/cancel)
  with cancellation_reason field, consistent with other modules.
- File uploads use multipart/form-data via the existing network
  layer's `buildMultiPartResponse()`.
- Status flow: pending -> accepted/rejected/info_requested/cancelled.
  Only "pending" can be cancelled by patient.
- Urgency levels: critical (red), urgent (orange), standard (blue).
- The "info_requested" status means the hospital needs more info —
  displayed as informational, no patient action in app.
- Hospital types: government, private, military, university.
- Case types: stroke, cardiac, post_operative, ventilator, neonatal,
  pediatric, burns, general.
- Equipment levels: basic, advanced, full.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Users can find hospitals with available ICU beds
  within 3 taps from the home screen.
- **SC-002**: Users can complete an admission request form in under
  5 minutes despite its multi-section complexity.
- **SC-003**: Hospital and request list screens load within 2 seconds
  on a standard mobile connection.
- **SC-004**: All four user stories are functional in both light and
  dark themes without visual defects.
- **SC-005**: All user-facing text appears correctly in all five
  supported languages, including RTL layout for Arabic.
- **SC-006**: 85% of users can complete their first admission request
  without assistance or errors.
- **SC-007**: File uploads complete successfully for supported formats
  up to 10MB per file.
