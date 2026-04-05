# Feature Specification: Enhance Filter Screens & Controllers

**Feature Branch**: `011-enhance-filters`
**Created**: 2026-04-05
**Status**: Draft
**Input**: User description: "I need to enhance filters screens and controller for all UI and logic based on recent updates"

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Unified Location Filtering Across All Modules (Priority: P1)

As a patient, I want to filter any provider list (doctors, clinics, labs, radiology centers, nurses, home healthcare) by governorate and city so that I find providers near me, regardless of which browse or search screen I'm using.

**Why this priority**: Location is the most impactful filter for healthcare — patients need nearby providers. Currently, location filtering exists in search screens and some list controllers, but the main booking filter modal (`FilterScreen`) lacks it entirely. This gap means patients using the filter modal cannot narrow results by location.

**Independent Test**: Can be tested by opening any provider list screen, applying a governorate/city filter, and verifying the results only include providers from that area.

**Acceptance Scenarios**:

1. **Given** a patient is on the doctor list screen, **When** they open the filter modal and select a governorate, **Then** only doctors from that governorate appear in results.
2. **Given** a patient has selected a governorate in the filter modal, **When** they select a city within that governorate, **Then** results narrow to that city.
3. **Given** a patient has applied location filters, **When** they tap "Reset", **Then** location filters clear and all results return.
4. **Given** a patient is on any search screen with location filters already active, **When** they change the governorate, **Then** the city selection resets and results update immediately.

---

### User Story 2 - Consistent Filter UI Across Booking Filter Modal and Search Screens (Priority: P2)

As a patient, I want the filter experience to look and feel the same whether I'm using the filter modal (from browse screens) or the dedicated search screens, so that the app feels cohesive and predictable.

**Why this priority**: The booking filter modal uses an older two-column layout with basic styling, while search screens use the newer "Clinical Elegance" design with gradient headers, glass borders, and animated chips. This visual inconsistency creates a disjointed experience. Aligning them improves perceived quality and reduces user confusion.

**Independent Test**: Can be tested by opening the filter modal and comparing its visual design, typography, and interaction patterns against the search screens — they should share the same design tokens (card radius, shadows, input styling, color tokens).

**Acceptance Scenarios**:

1. **Given** a patient opens the filter modal from any browse screen, **When** they view the filter UI, **Then** it uses the same design tokens (16px card radius, navy-tinted shadows, gradient accents, glass-style borders) as the rest of the app.
2. **Given** a patient switches between the filter modal and a search screen, **When** they compare the filter controls, **Then** similar filter types (location, price, etc.) use the same widget patterns and animation style.
3. **Given** a patient views the filter type list on the left sidebar, **When** they select a filter type, **Then** the selection uses the app's gradient accent colors and smooth animations consistent with the search filter chips.

---

### User Story 3 - Active Filter Count and Indicator Badges (Priority: P2)

As a patient, I want to see at a glance how many filters I have active so I know my results are being narrowed and I can easily clear them.

**Why this priority**: The current filter count tracking in the filter controller is inconsistent — it uses multiple separate counters with complex, sometimes inaccurate increment logic. Patients may not realize filters are active, leading to confusion when they see fewer results than expected.

**Independent Test**: Can be tested by applying various filter combinations and verifying the filter icon badge shows the correct count, and that "clear all" resets the count to zero.

**Acceptance Scenarios**:

1. **Given** a patient has applied 2 filters (e.g., clinic + price range), **When** they return to the list screen, **Then** the filter icon shows a badge with "2".
2. **Given** a patient has active filters, **When** they open the filter modal, **Then** they see clear visual indicators on which filter categories have active selections.
3. **Given** a patient taps "Reset" in the filter modal, **When** they return to the list, **Then** the badge count is zero and all results display.
4. **Given** a patient applies a location filter on a search screen, **When** they view the active filter state, **Then** the location filter counts toward the active filter total.

---

### User Story 4 - Module-Specific Advanced Filters in Filter Modal (Priority: P3)

As a patient browsing doctors, I want to filter by specialty and gender in addition to the existing filters (clinic, rating, service), so I can find the right doctor faster.

**Why this priority**: The dedicated doctor search screen already supports gender and specialty filters, but the main booking filter modal does not expose them. This creates an inconsistency — patients who discover these filters in search cannot access them from the browse flow. Extending the filter modal with module-specific filters when relevant improves discoverability.

**Independent Test**: Can be tested by opening the filter modal from the doctor list, verifying specialty and gender filter options appear, selecting them, and confirming results are correctly filtered.

**Acceptance Scenarios**:

1. **Given** a patient opens the filter modal from the doctor list, **When** they view available filter types, **Then** they see "Specialty" and "Gender" in addition to the existing filter types.
2. **Given** a patient selects a specialty in the filter modal, **When** they apply filters, **Then** only doctors with that specialty appear.
3. **Given** a patient opens the filter modal from the service list, **When** they view available filter types, **Then** module-irrelevant filters (specialty, gender) do not appear.

---

### User Story 5 - Localized and Accessible Filter Labels (Priority: P3)

As a patient using the app in Arabic, I want all filter labels, options, and messages to display correctly in my language with proper RTL layout.

**Why this priority**: Some filter labels are currently hardcoded in English (e.g., "In Clinic", "Online" in the service type list). All user-facing strings must go through the locale system. This also affects new filters being added (location, specialty, gender).

**Independent Test**: Can be tested by switching the app to Arabic and verifying every filter label, dropdown option, and button text appears in Arabic with correct RTL alignment.

**Acceptance Scenarios**:

1. **Given** a patient uses the app in Arabic, **When** they open any filter screen, **Then** all filter labels, options, and buttons display in Arabic.
2. **Given** a patient uses the app in Arabic, **When** they view the filter type sidebar, **Then** the layout is mirrored for RTL with proper text alignment.
3. **Given** a new filter type is added (e.g., governorate, specialty), **When** the patient views it in any language, **Then** the label is sourced from the locale system.

---

### Edge Cases

- What happens when a governorate has no cities? The city dropdown should remain disabled with a "Select Governorate" hint.
- What happens when applied filters return zero results? An appropriate empty state should display with a prompt to adjust or clear filters.
- What happens when the user applies filters, navigates to a detail screen, then returns? Filter state should persist for the duration of the browse session.
- What happens when multiple filter types conflict (e.g., a specialty with no doctors in the selected city)? Zero results display gracefully, no errors thrown.
- What happens when the governorate/city API call fails? Dropdown shows a fallback state; other filters remain usable.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: The booking filter modal MUST include a "Location" filter type with governorate and city dropdowns, reusing the existing `GovernoratesCityPicker` component.
- **FR-002**: Location filter selections in the filter modal MUST be passed to the corresponding list controller's API call (doctor, service, clinic) and filter results server-side.
- **FR-003**: The filter modal UI MUST use the app's design system tokens: 16px card radius, 12px input radius, gradient accents, glass-style borders, navy-tinted shadows.
- **FR-004**: The filter type sidebar MUST use animated selection indicators consistent with the `SearchFilterChips` styling used in search screens.
- **FR-005**: Active filter count MUST be computed from a single source of truth by checking which filter parameters differ from their default values.
- **FR-006**: The filter icon on list screens MUST display a badge showing the number of active filters, updating reactively.
- **FR-007**: All search screens MUST display active filter state clearly (e.g., selected chips, filled dropdowns).
- **FR-008**: The filter modal MUST support module-specific filter types — specialty and gender for doctors, scan type for radiology — shown only when contextually relevant.
- **FR-009**: All user-facing filter labels (including "In Clinic", "Online", and all new filter types) MUST use the locale system via `locale.value.<key>`.
- **FR-010**: The "Reset" action MUST clear all filters including new ones (location, specialty, gender) and refresh the list to show unfiltered results.
- **FR-011**: Filter state MUST persist while the user navigates to detail screens and back within the same browse session.
- **FR-012**: Empty result states after filtering MUST display a clear message suggesting the user adjust or clear filters.

### Key Entities

- **Filter State**: Represents the current set of active filters for a given module (clinic ID, service type, price range, rating range, location, specialty, gender). Tracks which filters differ from defaults.
- **Filter Type**: A named category of filter (Location, Clinic, Price, Rating, Service Type, Specialty, Gender, Scan Type) with module-specific visibility rules.
- **Location Filter**: A governorate + city pair sourced from cached API data. City depends on governorate selection.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Patients can filter any provider list by location (governorate/city) from both the filter modal and search screens, with results updating in under 2 seconds.
- **SC-002**: The filter modal and search screens share a visually consistent design — no visible style mismatches when comparing equivalent filter controls.
- **SC-003**: Active filter badge count matches the actual number of non-default filter parameters 100% of the time (no stale or incorrect counts).
- **SC-004**: All filter labels render correctly in both English and Arabic, with proper RTL layout in Arabic mode.
- **SC-005**: Patients can apply, reset, and re-apply filters without encountering errors or stale state — filter reset returns all results within 2 seconds.
- **SC-006**: Filter state survives navigation to detail screens and back — patients don't lose their filter selections during a browse session.

## Assumptions

- The Laravel backend already supports filtering by governorate/city for all provider types (doctors, clinics, labs, etc.) via the existing `search*` API methods.
- The `GovernoratesCityPicker` component and its API caching mechanism are stable and reusable as-is.
- Specialty and gender data for doctors is available through existing API endpoints.
- The app's design system (colors, typography, spacing tokens from Phase 1 UI modernization) is the target standard for all filter UI updates.
- Filter state persistence means in-memory retention during the browse session, not persistent storage across app launches.
