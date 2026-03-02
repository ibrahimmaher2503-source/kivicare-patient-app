# Feature Specification: Home Page Departments Section

**Feature Branch**: `002-home-departments-section`
**Created**: 2026-03-02
**Status**: Draft
**Input**: User description: "in home page I need to create section for departments it should have doctors, clinics, radiology, intensive-care and nurse-requests all of this sections coming soon except doctors and clinics"

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Browse Active Departments (Priority: P1)

A patient opens the home screen and sees a "Departments" section
displaying five department cards. The patient taps on "Doctors" to
browse available doctors, and taps on "Clinics" to browse available
clinics. Both navigate to the existing screens that already handle
these features.

**Why this priority**: Doctors and Clinics are the only two functional
departments. They provide immediate navigational value, giving
patients a department-oriented way to access existing features.

**Independent Test**: Can be fully tested by opening the home screen,
verifying five department cards are visible, tapping "Doctors" to
confirm navigation to the doctors list, and tapping "Clinics" to
confirm navigation to the clinics list.

**Acceptance Scenarios**:

1. **Given** a patient on the home screen, **When** the home screen
   loads, **Then** a "Departments" section is visible containing
   exactly five department cards: Doctors, Clinics, Radiology,
   Intensive Care, and Nurse Requests
2. **Given** the Departments section is visible, **When** the
   patient taps the "Doctors" card, **Then** the app navigates to
   the existing doctor listing screen
3. **Given** the Departments section is visible, **When** the
   patient taps the "Clinics" card, **Then** the app navigates to
   the existing clinic listing screen
4. **Given** the home screen is in dark mode, **When** the
   Departments section renders, **Then** cards use the dark theme
   colors consistently with other home screen sections

---

### User Story 2 - View Coming Soon Departments (Priority: P1)

A patient sees the Radiology, Intensive Care, and Nurse Requests
department cards on the home screen. Each card displays a visual
"Coming Soon" indicator. When the patient taps one of these cards,
a brief message confirms the feature is not yet available.

**Why this priority**: Coming Soon departments set patient
expectations about upcoming features and complete the departmental
navigation structure. Without proper coming-soon treatment, tapping
a non-functional card would confuse users or appear broken.

**Independent Test**: Can be fully tested by tapping each of the
three coming-soon department cards and verifying the coming-soon
indicator is visible on each card and that tapping shows an
informational message rather than navigating or crashing.

**Acceptance Scenarios**:

1. **Given** the Departments section is visible, **When** the
   patient views Radiology, Intensive Care, or Nurse Requests
   cards, **Then** each displays a visible "Coming Soon" badge
   or overlay
2. **Given** a coming-soon department card, **When** the patient
   taps it, **Then** a toast or snackbar message appears saying
   the department is coming soon
3. **Given** a coming-soon department card, **When** the patient
   taps it, **Then** no navigation occurs and the app does not
   crash or show an error
4. **Given** the Departments section, **When** comparing active
   cards (Doctors, Clinics) with coming-soon cards (Radiology,
   Intensive Care, Nurse Requests), **Then** active cards are
   visually distinct from coming-soon cards (e.g., coming-soon
   cards appear slightly muted or have an overlay)

---

### User Story 3 - Departments Section Placement and Layout (Priority: P2)

A patient scrolling through the home screen encounters the
Departments section in a logical position within the existing
content flow. The section uses a consistent visual style with
other home screen sections (section title, card-based layout).

**Why this priority**: Proper placement and visual consistency
ensure the departments section feels native to the home screen
rather than bolted on. This is important for user experience but
secondary to functional correctness.

**Independent Test**: Can be fully tested by scrolling through
the home screen and verifying the Departments section appears in
its designated position, uses the same heading style as other
sections, and cards are properly laid out on different screen sizes.

**Acceptance Scenarios**:

1. **Given** a patient on the home screen, **When** scrolling
   through content, **Then** the Departments section appears
   between the slider/banner carousel and the quick book component
2. **Given** the Departments section, **When** rendered, **Then**
   it has a section title ("Departments") matching the style of
   existing section titles (e.g., "Category", "Popular Services")
3. **Given** a device with a narrow screen, **When** viewing
   the Departments section, **Then** all five department cards
   are accessible via horizontal scrolling without being clipped
4. **Given** the home screen with all sections loaded, **When**
   performing pull-to-refresh, **Then** the Departments section
   remains visible in its correct position

---

### Edge Cases

- What happens when the home screen is viewed by a logged-out
  user? The Departments section MUST still display since
  departments are informational/navigational and do not require
  authentication.
- How does the section behave when there is no network
  connectivity? The section MUST render with locally available
  department data (hardcoded department names and icons) since
  the five departments are fixed and do not depend on API data.
- What happens when a coming-soon department is later activated?
  The department configuration MUST be straightforward to update
  from "coming soon" to "active" with a navigation target,
  requiring minimal code changes.
- How does the section look with RTL layout (Arabic locale)?
  The horizontal card order MUST reverse for RTL languages, and
  card text MUST align correctly.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: System MUST display a "Departments" section on the
  home screen containing exactly five department cards: Doctors,
  Clinics, Radiology, Intensive Care, and Nurse Requests
- **FR-002**: System MUST navigate to the existing doctor listing
  screen when the "Doctors" department card is tapped
- **FR-003**: System MUST navigate to the existing clinic listing
  screen when the "Clinics" department card is tapped
- **FR-004**: System MUST display a "Coming Soon" visual indicator
  on the Radiology, Intensive Care, and Nurse Requests cards
- **FR-005**: System MUST show a toast or snackbar message when a
  coming-soon department card is tapped, indicating the feature is
  not yet available
- **FR-006**: System MUST NOT navigate or throw errors when a
  coming-soon department card is tapped
- **FR-007**: System MUST render the Departments section between
  the slider/banner carousel and the quick book component on the
  home screen
- **FR-008**: System MUST display each department card with an
  icon and department name label
- **FR-009**: System MUST support dark mode theming for all
  department cards consistent with the rest of the home screen
- **FR-010**: System MUST support RTL layout for Arabic locale
- **FR-011**: System MUST display the Departments section for
  both logged-in and logged-out users
- **FR-012**: System MUST render the Departments section without
  requiring an API call, using locally defined department data

### Key Entities

- **Department**: Represents a hospital department with attributes:
  name (display label), icon (visual identifier), isActive
  (whether the department is functional or coming soon), and
  navigation target (screen to navigate to when active)
- **Department Card**: A tappable UI card displaying a department's
  icon, name, and coming-soon status. Active cards navigate to
  their target screen; coming-soon cards show an informational
  message.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: 100% of users see all five department cards on the
  home screen without scrolling past the banner section
- **SC-002**: Tapping "Doctors" or "Clinics" navigates to the
  correct screen within 300ms (perceived instant)
- **SC-003**: Tapping a coming-soon card shows feedback within
  200ms (toast/snackbar) and never causes navigation or errors
- **SC-004**: The Departments section renders correctly on screen
  widths from 320dp to 600dp+ (phones and tablets)
- **SC-005**: The section displays identically in light and dark
  mode with no contrast or readability issues
- **SC-006**: RTL layout correctly reverses card order for Arabic
  locale users

## Assumptions

- The five departments (Doctors, Clinics, Radiology, Intensive
  Care, Nurse Requests) are fixed and do not need to be fetched
  from the backend API. They are defined locally in the app.
- Department icons will use existing icon assets or standard
  medical/healthcare icons available in the project's icon set.
- The "Doctors" card navigates to the same doctor listing screen
  used by the existing "Popular Doctors" View All action.
- The "Clinics" card navigates to the same clinic listing screen
  used by the existing "Popular Clinics" View All action.
- The "Coming Soon" message text will be localized and added to
  all five language files (en, ar, de, fr, hi).
- The section title "Departments" will be localized.
- When a coming-soon department becomes active in a future release,
  it will require adding a navigation target and setting
  isActive to true in the department definition.

## Out of Scope

- Backend API changes to support department data dynamically
- Implementation of Radiology, Intensive Care, or Nurse Requests
  functionality beyond the coming-soon placeholder
- Adding departments to the bottom navigation bar or drawer
- Analytics or tracking for department card interactions
- Animated transitions or special effects for coming-soon cards
- Search or filtering within the Departments section
- Department detail screens or descriptions beyond the card itself
