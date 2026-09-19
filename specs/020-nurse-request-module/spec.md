# Feature Specification: Nurse Request (Home Nursing) Module

**Feature Branch**: `020-nurse-request-module`
**Created**: 2026-04-28
**Status**: Draft
**Input**: User description: Build a Nurse Request module enabling patients to submit home-nursing requests. The patient submits a form (service description in EN/AR, date/time, duration, address, contact info); admin assigns the nurse and calculates the price afterward. The patient never browses or chooses a nurse. Patients view their requests, track lifecycle (pending → assigned → confirmed → in_progress → completed, or cancelled), and see the assigned nurse and final price once admin completes the assignment.

## Clarifications

### Session 2026-04-28

- Q: Can a patient file a nurse request on behalf of a dependent (existing "Other Patients" feature) or only for themselves? → A: Self-only — the request is always filed for the logged-in patient; no dependent picker in v1.
- Q: How should the form prevent duplicate submissions when the network drops mid-request and the response is lost? → A: Disable the submit control while in-flight; on unknown/timeout failures, route the patient to the request list with a banner asking them to verify the request was created before retrying.
- Q: Should a partially-filled form persist across app interruptions (background, kill, relaunch)? → A: In-memory only — the draft is preserved while the form route is alive, but a fresh app launch starts an empty form. No PII is written to disk for drafts.
- Q: Should the list's status filter persist across visits to the list? → A: Session-scoped — the filter survives back-navigation from a request detail to the list, but resets to "All" when the patient leaves the module and re-enters from the dashboard or elsewhere.
- Q: How are `preferred_date` and `preferred_time` interpreted with respect to time zones? → A: Clinic-fixed wall-clock in Africa/Cairo — both values always mean clinic-local time, and the "today through +90 days" boundary check uses Africa/Cairo's current date regardless of the patient's device time zone.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Submit a home-nursing request (Priority: P1)

A patient who needs in-home nursing care opens the Home Nursing module from the dashboard, taps "New Request", fills a single sectioned form describing what they need, when they need it, and where they are, then submits. They receive a confirmation with a unique reference number and a clear notice that the clinic team will assign a nurse and confirm pricing shortly.

**Why this priority**: This is the core value of the module. Without it, no other feature has meaning. It must work end-to-end on its own — a patient submitting a request and getting a tracked reference number is already a viable MVP.

**Independent Test**: A logged-in patient can navigate from the dashboard to the form, fill in the minimum required fields (service description in either English or Arabic, preferred date, duration, address line 1, city, contact number), submit, and see a success screen with a reference number formatted `NR-YYYY-NNNN`. No nurse selection step is involved.

**Acceptance Scenarios**:

1. **Given** the patient is on the dashboard, **When** they tap the Home Nursing card and then "New Request", **Then** the request form opens with all sections visible.
2. **Given** the patient has filled the required fields and tapped Submit, **When** the request succeeds, **Then** they see a success screen with the reference number, a copy-to-clipboard control, and a clear notice that a nurse will be assigned by the clinic.
3. **Given** the patient leaves both the English and Arabic service descriptions empty, **When** they tap Submit, **Then** the form blocks submission and shows a single inline error explaining at least one description is required.
4. **Given** the patient enters a phone number that does not match the accepted format, **When** they tap Submit, **Then** the form shows an inline error on the phone field and does not submit.
5. **Given** the patient picked a preferred date earlier than today or more than 90 days in the future, **When** they open the date picker, **Then** those dates are visibly disabled and not selectable.
6. **Given** the duration stepper is at 1 hour, **When** the patient taps the decrement button, **Then** nothing happens and the button appears disabled. The same applies at 24 hours for the increment button.
7. **Given** the patient submits a request and the server returns field-specific validation errors, **When** the response is received, **Then** each errored field displays its server-provided message inline; no toast-only failure is shown.

---

### User Story 2 - View the list of my nurse requests with their status (Priority: P1)

After submitting one or more requests, the patient returns to the Home Nursing entry point and sees a list of all their past and active requests, newest first, each card showing the reference number, current status (color-coded), service description in the user's current language, the scheduled date/duration, the address summary, and — once the admin has acted — the assigned nurse name and the final price.

**Why this priority**: A patient cannot meaningfully use the module without being able to find their submitted requests and see what state they are in. This is the read-side counterpart to Story 1 and is essential for trust.

**Independent Test**: With at least one existing request on the account, the patient opens Home Nursing and sees a paginated list ordered newest-first. Pull-to-refresh updates the list. Tapping any card opens the detail view.

**Acceptance Scenarios**:

1. **Given** the patient has submitted multiple requests, **When** they open the Home Nursing list, **Then** the most recent request appears at the top and older requests follow in descending order.
2. **Given** the patient pulls down on the list, **When** the gesture completes, **Then** the list re-fetches and reflects any server-side changes (status updates, newly assigned nurse, newly calculated price).
3. **Given** the patient scrolls to the bottom of the list, **When** more pages are available, **Then** the next page loads automatically without manual pagination controls.
4. **Given** the patient has no requests yet, **When** they open the list, **Then** an empty-state illustration appears with a friendly message and a primary "Request Home Nursing" call-to-action.
5. **Given** the list view selects a status filter (e.g., "Pending"), **When** the filter is applied, **Then** only requests in that status are shown and pagination resets.
6. **Given** a request has been assigned a nurse and priced by the admin, **When** the patient views its card in the list, **Then** the assigned nurse's name and the final amount are visible on the card.

---

### User Story 3 - Track a request's full lifecycle on the detail screen (Priority: P2)

Tapping a request opens a detailed view showing the reference number, a vertical status timeline reflecting the current step (pending → assigned → confirmed → in progress → completed, or terminal cancelled), the full service description in the patient's current language, the schedule, the full address, the contact number, any patient notes, the assigned nurse card (when assigned), the pricing card (when calculated), the cancellation reason banner (when cancelled), and a chronological status history. The patient can refresh the view at any time and tap to call the contact phone or the assigned nurse's phone.

**Why this priority**: After submitting and listing, patients need a clear, single-screen view that answers "what's happening with my request right now?". Without this, status changes are opaque and the assigned nurse and price reveal feels disconnected from the request.

**Independent Test**: Open any existing request from the list. Verify the timeline highlights the current step, the assigned nurse and pricing cards appear if and only if the data is present, the cancellation banner appears only on cancelled requests, and tapping the contact phone opens the device dialer.

**Acceptance Scenarios**:

1. **Given** a pending request has just been submitted, **When** the patient opens its detail screen, **Then** only the "Pending" step on the timeline is visually marked active and no assigned nurse or pricing card is shown.
2. **Given** the admin has assigned a nurse but not yet calculated a price, **When** the patient refreshes the detail screen, **Then** the assigned nurse card appears with name, optional photo, optional rating, and an optional tap-to-call phone, while the pricing card remains hidden.
3. **Given** the admin has both assigned a nurse and calculated a final amount, **When** the patient views the detail screen, **Then** both the assigned nurse card and the pricing card appear; the pricing card displays amount, currency, and the current payment status.
4. **Given** a request is cancelled, **When** the patient opens its detail screen, **Then** a clearly visible cancellation banner shows the cancellation reason, and the timeline indicates the cancelled terminal state instead of progressing further.
5. **Given** a completed request, **When** the patient opens its detail screen, **Then** a "Completed on" line shows the completion date, and all five forward steps of the timeline are marked complete.
6. **Given** the detail screen is open, **When** the patient pulls down or taps a refresh control, **Then** the latest server state is fetched and rendered, preserving previously-loaded data if the refresh fails.

---

### User Story 4 - Use the module in Arabic (RTL) and dark mode without losing clarity (Priority: P2)

The patient switches the app language to Arabic or toggles dark mode and uses the entire module — list, form, success, detail — without any layout breakage, untranslated text, or unreadable color combinations. The bilingual service description section keeps each field in its own writing direction (English field always left-to-right, Arabic field always right-to-left) regardless of the app's current language.

**Why this priority**: The product targets an Arabic-speaking patient base. A nurse request module that works only in English or only in light mode is not shippable for this audience. Bilingual input is a hard requirement because admins and other staff may operate in either language.

**Independent Test**: Switch the device or app to Arabic, walk through dashboard → list → form → submit → success → detail. Then switch to dark mode and repeat. Verify all text is translated, layouts mirror correctly, status chips remain legible, and the EN/AR description fields keep their per-field direction.

**Acceptance Scenarios**:

1. **Given** the app is set to Arabic, **When** the patient opens any screen of this module, **Then** all labels, buttons, status chips, empty states, errors, and helper text appear in Arabic with right-to-left layout.
2. **Given** the form is open in Arabic, **When** the patient types in the English service description field, **Then** the text flows left-to-right inside that field even though the rest of the screen is right-to-left.
3. **Given** dark mode is active, **When** any list, form, success, or detail screen is shown, **Then** background surfaces, status chip backgrounds, timeline accents, and text contrast remain comfortably readable and do not collapse to flat or near-invisible color combinations.
4. **Given** a duration of two or more hours, **When** displayed in Arabic, **Then** the label uses correct Arabic plural form rather than literal "hours" with a number.

---

### User Story 5 - Filter, copy reference, and call from the module (Priority: P3)

The patient can quickly find a specific request by filtering the list by status, copy a reference number to the clipboard with a single tap (from the success screen or the detail header), and place a call directly from a tap on the contact phone or the assigned nurse's phone.

**Why this priority**: These are convenience features that improve quality of life but are not blockers for the module to be usable. They complement the core flow rather than enable it.

**Independent Test**: Apply each status filter and verify the list narrows correctly. Tap the reference number on the success screen and on the detail header, then verify the system clipboard contains it and a confirmation toast appeared. Tap the contact phone on the detail screen and verify the device dialer opens with the correct number prefilled.

**Acceptance Scenarios**:

1. **Given** the list is showing all requests, **When** the patient applies the "Cancelled" filter, **Then** only cancelled requests remain and other statuses are hidden until the filter is cleared.
2. **Given** the patient is on the success screen, **When** they tap the reference number, **Then** the value is copied to the clipboard and a brief toast confirms the copy.
3. **Given** the detail screen shows a contact phone, **When** the patient taps it, **Then** the device dialer opens prepopulated with that number; the same applies to the assigned nurse phone when present.

---

### Edge Cases

- **Both descriptions empty**: Submission must be blocked client-side with a single visible error rather than relying on a server round-trip.
- **No internet on submit**: A loading indicator covers the submit action; on failure, the form is restored intact (no data loss) and an error is surfaced.
- **Submit attempt with unknown outcome (timeout, dropped connection mid-request)**: The form does not silently retry. The patient is routed to the Nurse Request list with a banner instructing them to verify whether the request was created (it will appear at the top if so) before submitting again. The form's draft is preserved while the patient verifies.
- **Token expired during a request fetch**: The patient sees no extra prompt; the session refreshes silently and the data fetch retries transparently.
- **Server returns field-level validation errors**: Each errored field shows its own error message inline; no opaque toast.
- **Governorate dropdown fails to load**: The form remains usable — governorate stays unset and city falls back to a free-text field. Submission still succeeds without the optional location identifiers.
- **Selected governorate has no associated cities, or city list fails to load**: The city field falls back to free-text input.
- **Admin assigns a nurse but pricing is not yet calculated**: The detail screen shows the assigned nurse card but no pricing card.
- **Admin cancels the request**: Detail screen shows the cancellation banner with the reason; the timeline visually terminates at the cancellation step.
- **Patient submits a description at the maximum length (2,000 characters)**: The character counter reflects the limit, the form accepts the input, and submission succeeds.
- **App killed while the form is partially filled**: On relaunch, the form starts empty. No draft is restored, and no "resume draft" prompt is shown.
- **A push notification about a status or pricing change is opened**: The corresponding request's detail screen opens directly, not the list.
- **Patient navigates back to the list after submission**: The newly submitted request is already visible at the top without requiring a manual refresh.
- **Pagination at the end of the list**: Reaching the last page does not produce a spinner that never resolves; the list cleanly ends.

## Requirements *(mandatory)*

### Functional Requirements

#### Module entry and navigation

- **FR-001**: The dashboard MUST present a Home Nursing entry card alongside other patient modules, using a nurse/medical icon and the secondary visual treatment.
- **FR-002**: Tapping the Home Nursing card MUST open the patient's Nurse Request list.
- **FR-003**: The Nurse Request list MUST provide a clear primary action ("New Request") that opens the request form.
- **FR-004**: A push notification carrying a request status or pricing update MUST deep-link directly to the corresponding request's detail screen when opened.

#### Submission form

- **FR-005**: The form MUST collect the service description in two parallel fields: English and Arabic, each multiline with a visible character counter capped at 2,000 characters.
- **FR-006**: Each description field MUST render in its native writing direction (English left-to-right; Arabic right-to-left) regardless of the app's current language.
- **FR-007**: The form MUST require at least one of the two service descriptions to contain non-whitespace content; if both are empty, submission MUST be blocked and a single inline error MUST be shown at the top of the description section.
- **FR-008**: The form MUST collect a required preferred date, restricted to today through 90 days in the future. Earlier or later dates MUST be visually disabled in the picker. The "today" boundary is computed in the clinic's time zone (Africa/Cairo), not the device time zone.
- **FR-009**: The form MUST allow an optional preferred time, with a clear "Clear" affordance to remove it once set. The picked value is interpreted as a wall-clock time in the clinic's time zone (Africa/Cairo).
- **FR-009a**: `preferred_date` and `preferred_time` MUST be transmitted and rendered as clinic-local wall-clock values (Africa/Cairo). The detail screen MUST display these values without device-time-zone shifting, so a patient who travels does not see their preferred date or time appear to drift.
- **FR-010**: The form MUST collect a required duration in hours via a stepper, restricted to integers from 1 to 24, with disabled boundary controls at the extremes.
- **FR-011**: The duration label MUST adapt to plural rules of the active language (e.g., proper Arabic plural for two-or-more hours).
- **FR-012**: The form MUST collect a required address line 1 (max 255 characters) and an optional address line 2 (max 255 characters).
- **FR-013**: The form MUST offer an optional governorate selection drawn from the existing patient location source.
- **FR-014**: When a governorate is selected, the city field MUST become a dropdown of that governorate's cities; if the city list is unavailable, the city field MUST fall back to free-text input.
- **FR-015**: Selecting a different governorate MUST clear any previously selected city.
- **FR-016**: The form MUST require a city value (either dropdown selection or free text, max 100 characters) regardless of the governorate selection.
- **FR-017**: The form MUST offer optional state, country, and postal code fields, hidden behind a "More address details" toggle by default.
- **FR-018**: The form MUST collect a required contact phone number (max 20 characters), defaulting to the Egyptian country prefix (+20), and validate it against the pattern `^\+?[0-9]{7,20}$`.
- **FR-019**: The form MUST offer an optional patient notes field (multiline, max 2,000 characters, with counter).
- **FR-020**: The form's submit action MUST be visually disabled and show a progress indicator while submission is in flight.
- **FR-021**: On submission, the form MUST trim leading/trailing whitespace from all text fields and MUST omit empty optional fields entirely from the request payload.
- **FR-022**: The form MUST never transmit a nurse identifier, coupon code, status, total amount, or payment status. These are server-controlled and out of patient scope.
- **FR-023**: When the server returns field-level validation errors, the form MUST surface each error against its corresponding field inline; cross-field errors (e.g., both descriptions empty) MUST surface as a top-level message.

#### Success confirmation

- **FR-024**: A successful submission MUST replace the form with a success screen showing an animated confirmation, the reference number prominently, a copy-to-clipboard control on the reference, the patient-facing notice ("Our team will assign a nurse and confirm details soon"), and two actions: "View Request" and "Back to Home".
- **FR-025**: "View Request" MUST navigate to the new request's detail screen in a way that allows the patient to back-navigate to the list (not to the now-discarded form).
- **FR-026**: "Back to Home" MUST return to the dashboard and discard intermediate screens.

#### List view

- **FR-027**: The list MUST be paginated at 15 entries per page and order entries by submission time, newest first.
- **FR-028**: The list MUST support pull-to-refresh and automatic next-page loading on scroll.
- **FR-029**: The list MUST offer optional filtering by status: All, Pending, Assigned, Confirmed, In Progress, Completed, Cancelled.
- **FR-029a**: The selected status filter MUST persist while the patient navigates between the list and any request detail screen within the module, so returning from a detail preserves the active filter. The filter MUST reset to "All" whenever the patient leaves the module entirely (e.g., to the dashboard or another tab) and re-enters the Nurse Request list.
- **FR-030**: Each list card MUST show: reference number, color-coded status chip, service description in the active locale (truncated to 1–2 lines), schedule line (date, time if set, duration), address line 1 plus city, assigned nurse name (only when an assigned nurse is present), and total amount (only when a final amount is present).
- **FR-031**: The list MUST present a friendly empty state with a "Request Home Nursing" call-to-action when the patient has no requests.
- **FR-032**: After a successful submission, the list MUST display the new request at the top when next opened, without requiring a manual refresh.
- **FR-033**: When the list fails to load and no cached entries exist, the screen MUST present a recoverable error state with a retry control. When a refresh fails but cached entries exist, the cached entries MUST be preserved.

#### Detail view

- **FR-034**: The detail screen MUST show: reference number with copy-to-clipboard, current status chip, submission date, a vertical status timeline, the localized service description, the schedule, the full address, the contact number with tap-to-call, optional patient notes, the assigned nurse card (only when present), the pricing card (only when total amount is present), the cancellation banner (only when cancelled), and a status history list with each transition.
- **FR-035**: The status timeline MUST visualize the lifecycle Pending → Assigned → Confirmed → In Progress → Completed, with the current step gradient-highlighted; on cancellation, the timeline MUST show termination at the cancelled step.
- **FR-036**: The assigned nurse card MUST appear if and only if the request payload includes an assigned nurse object; the pricing card MUST appear if and only if the request payload includes a non-null total amount; the cancellation banner MUST appear if and only if the status is cancelled.
- **FR-037**: A "Completed on" date MUST be shown for completed requests.
- **FR-038**: The detail screen MUST support pull-to-refresh and a manual refresh control.
- **FR-039**: Tap-to-call MUST be available on the contact phone field and on the assigned nurse phone (when present), opening the device dialer prepopulated.

#### Status semantics

- **FR-040**: Status values MUST be exactly: pending, assigned, confirmed, in_progress, completed, cancelled. The patient-facing label for each MUST be localized.
- **FR-041**: Status chip styling MUST follow consistent color semantics across the module (warm/amber for pending, indigo for assigned, blue for confirmed, purple for in progress, green for completed, red for cancelled), with both light and dark mode variants that maintain text contrast.
- **FR-042**: The patient app MUST NOT trigger any status transition. Status changes are made only by the admin and reflected on refresh.

#### Localization, theming, and accessibility

- **FR-043**: Every patient-visible string in this module MUST be served through the localization system; no string may be hardcoded in either language.
- **FR-044**: The module MUST function visually correctly in both Arabic (right-to-left) and English (left-to-right) layouts.
- **FR-045**: The module MUST maintain readable contrast and visual coherence in both light and dark themes.
- **FR-046**: Interactive controls (duration stepper buttons, status filters, primary actions) MUST meet a minimum 44-point tap target size.

#### Cross-cutting behavior

- **FR-047**: Authenticated request handling MUST be transparent: if a session is silently refreshed, the patient experience MUST not be interrupted (no extra login prompts mid-flow for an otherwise valid patient).
- **FR-048**: The submission flow MUST display a full-screen loading indicator only during submission; list and detail loading MUST use lighter inline indicators.
- **FR-049**: The reference number format MUST be `NR-YYYY-NNNN` (e.g., `NR-2026-0042`).
- **FR-050**: A nurse request MUST be filed strictly for the currently logged-in patient. The form MUST NOT include a dependent or "other patient" selector, and the submission payload MUST NOT carry a separate `patient_id`/`patient_for` field beyond the implicit identity on the bearer token.
- **FR-051**: While a submission is in flight, the submit control MUST be disabled to prevent a second send from the same form instance. The form MUST NOT auto-retry on failure.
- **FR-052**: When a submission attempt ends with an unknown outcome (request timeout, connection dropped before a response is received, or any non-validation, non-success result that does not confirm create-vs-no-create), the form MUST NOT submit again. Instead, the patient MUST be routed to the Nurse Request list with a non-blocking banner instructing them to confirm whether the request was created (it will appear at the top of the list if so) before re-submitting. The form draft MUST be preserved while the patient verifies, so they can return and resubmit if no record was created.
- **FR-053**: Form draft state (all entered text, picked date/time, duration, governorate/city selections, address fields, contact number, notes) MUST persist in-memory while the form route is alive — including across the verify-and-return roundtrip described in FR-052. The form MUST NOT write draft state to local storage; a fresh app launch (after a process kill, OS termination, or full app close) MUST present an empty form with no "resume draft" prompt.

### Key Entities *(include if feature involves data)*

- **Nurse Request**: A patient's submitted home-nursing request. Identified by a numeric id and a human-readable reference number (`NR-YYYY-NNNN`). Holds: bilingual service description (at least one language present), preferred date, optional preferred time, duration in hours, structured address (line 1, optional line 2, required city, optional state/country/postal code, optional governorate and city references), patient contact number, optional patient notes, current status, optional assigned nurse, optional total amount and currency, payment status, optional cancellation reason, optional completion timestamp, audit timestamps, and a list of status history entries.
- **Status History Entry**: A single transition in a request's lifecycle. Holds: previous status (nullable), new status, optional note, and the moment of the change. Patient-visible but does not expose who made the change.
- **Assigned Nurse**: The nurse the admin assigned to fulfill the request, exposed to the patient with: identifier, display name, optional avatar, optional contact phone, optional rating, optional short bio.
- **Governorate**: A regional location reference used when scoping the address. Holds: identifier and display name.
- **City**: A subdivision tied to a governorate. Holds: identifier and display name. Patients may also enter a free-text city when no matching reference is available.
- **Status**: A categorical lifecycle marker with a fixed set of values (pending, assigned, confirmed, in_progress, completed, cancelled), each with a localized label and a consistent color treatment.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: A patient with all required information at hand can submit a complete nurse request from the dashboard in under 90 seconds, including form fill and submission.
- **SC-002**: At least 95% of submission attempts that pass client-side validation succeed on the first server attempt; the remaining cases surface field-specific server errors that the patient can correct without reloading the form.
- **SC-003**: 100% of submissions that violate the bilingual rule (both service descriptions empty) are blocked client-side without any network round-trip.
- **SC-004**: 100% of patient-visible text in the module is served through localization (zero hardcoded strings), verified by audit.
- **SC-005**: The module renders correctly in both light and dark themes and in both Arabic (RTL) and English (LTR) layouts on every screen of the flow, with zero layout regressions reported during QA.
- **SC-006**: After admin action, status changes and pricing reveals are visible to the patient within a single refresh of either the list or the detail view (no client-side polling required, but no stale state once refreshed).
- **SC-007**: A patient who knows their reference number can locate a specific request from the list (with status filtering as needed) within 15 seconds.
- **SC-008**: Tap-to-call success rate is 100% on devices with a dialer app installed: tapping the contact phone or assigned nurse phone reliably opens the device dialer with the correct number prefilled.
- **SC-009**: 100% of submitted patient requests are stored without ever including nurse identifier, coupon code, status, total amount, or payment status in the request payload, verified by network audit.
- **SC-010**: Pagination remains performant for accounts with 100+ historical requests: scrolling to the bottom loads the next page in under 2 seconds on a healthy network.
- **SC-011**: Empty states, network failures, and validation errors each surface a recoverable path (retry, edit, or back) — there are no dead-end error screens.
- **SC-012**: The module ships with zero new static-analysis warnings introduced beyond the project's pre-existing baseline.

## Assumptions

- The patient is already authenticated; this module does not introduce a new login or registration flow.
- Reference numbers are minted by the server in the format `NR-YYYY-NNNN`; the client only displays them.
- Pricing is calculated server-side after the admin assigns a nurse; the client does not compute or modify amounts.
- The status lifecycle is enforced server-side; the client only renders the current status and history.
- Existing patient infrastructure provides: an HTTP layer with transparent session refresh, a localization layer covering English and Arabic, a theming system with light and dark modes, and a location reference source (governorates and cities) reusable from existing modules.
- Push notifications carrying a `nurse_request_status_changed` type and a reference number payload are delivered through the existing notification pipeline.
- Editing or deleting a submitted request is not part of this scope; once submitted, requests are read-only from the patient side.
- A coupon entry surface is not part of this scope; any discount, if applicable, is applied by the admin and reflected in the final pricing.
- A payment surface is not part of this scope; payment status is read-only and may be addressed by a separate payment flow if needed.
- A nurse browse or selection surface is intentionally excluded; the clinic's admin handles assignment.
- Nurse requests are scoped to the logged-in patient only. Filing on behalf of a dependent or family member (the existing "Other Patients" capability) is out of scope for v1 and may be added later without breaking the wire contract.
