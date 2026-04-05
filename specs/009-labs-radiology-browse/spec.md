# Feature Specification: Labs & Radiology Centers Browse

**Feature Branch**: `009-labs-radiology-browse`
**Created**: 2026-04-02
**Status**: Draft
**Input**: User description: "Create two new screens for browsing physical lab facilities and radiology centers, with search, location filters, scan type filters, pagination, and navigation integration into the existing lab test module."

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Browse Physical Labs by Location (Priority: P1)

A patient wants to find physical laboratory facilities near their location. They open the Labs screen, select their governorate and city from the location picker, and see a paginated list of labs in that area. They can also type a lab name to search. As they scroll down, more results load automatically.

**Why this priority**: Finding a nearby lab is the most fundamental action — without it, patients cannot locate where to go for their tests. This is the core value proposition of the feature.

**Independent Test**: Can be fully tested by opening the Labs screen, selecting a governorate/city, and verifying that matching labs appear in a scrollable list. Delivers immediate value by helping patients locate lab facilities.

**Acceptance Scenarios**:

1. **Given** the patient is on the Labs screen, **When** they select a governorate and city, **Then** the system displays a paginated list of labs in that location.
2. **Given** the patient is viewing lab results, **When** they scroll to the bottom of the list, **Then** additional results load automatically if more pages exist.
3. **Given** the patient is on the Labs screen, **When** they type a lab name in the search field, **Then** results are filtered by partial name match after a brief delay.
4. **Given** the patient is on the Labs screen with no filters, **When** the screen loads, **Then** all available labs are displayed (paginated).

---

### User Story 2 - Browse Radiology Centers with Scan Type Filter (Priority: P1)

A patient needs an MRI scan and wants to find a radiology center that offers it. They open the Radiology Centers screen, select the "MRI" scan type chip, optionally filter by location, and see a list of matching centers. They can search by center name and scroll for more results.

**Why this priority**: Equally critical as lab browsing — radiology centers serve a distinct patient need (imaging), and the scan type filter is essential because patients typically know what type of scan they need.

**Independent Test**: Can be fully tested by opening the Radiology Centers screen, selecting a scan type chip (e.g., MRI), and verifying that only centers offering that scan type appear. Delivers value by helping patients find the right imaging facility.

**Acceptance Scenarios**:

1. **Given** the patient is on the Radiology Centers screen, **When** they tap the "MRI" scan type chip, **Then** only centers with scan_type "MRI" are displayed.
2. **Given** the patient has selected a scan type and location, **When** results load, **Then** only centers matching both the scan type and location are shown.
3. **Given** the patient is viewing radiology center results, **When** they scroll to the bottom, **Then** additional pages load automatically.
4. **Given** the patient taps "All" scan type chip, **When** results reload, **Then** all radiology centers are displayed regardless of scan type.

---

### User Story 3 - Navigate to Labs or Radiology from Lab Test Module (Priority: P2)

A patient browsing the Lab Test section of the app sees clear entry points to "Labs" and "Radiology Centers." They can navigate directly from the categories screen or from dashboard navigation cards. When tapping a radiology-related category, they are taken to the Radiology Centers screen instead of the generic test list.

**Why this priority**: Navigation integration is essential for discoverability but depends on the two browse screens existing first. Without proper navigation, patients won't find the new screens.

**Independent Test**: Can be tested by navigating to the Lab Test section and verifying that "Labs" and "Radiology Centers" navigation options are visible and lead to the correct screens.

**Acceptance Scenarios**:

1. **Given** the patient is on the Lab Test Categories screen, **When** they tap a category with department "radiology" or slug containing "radiology", **Then** they are navigated to the Radiology Centers screen (not the generic test list).
2. **Given** the patient is on the Lab Test section entry point, **When** they see navigation options, **Then** "Labs" and "Radiology Centers" cards/buttons are visible.
3. **Given** the patient taps the "Labs" navigation card, **When** the transition completes, **Then** the Labs list screen is displayed.
4. **Given** the patient taps the "Radiology Centers" navigation card, **When** the transition completes, **Then** the Radiology Centers screen is displayed.

---

### User Story 4 - Multi-language Support for New Screens (Priority: P3)

A patient using the app in Arabic sees all labels, titles, and filter options on the Labs and Radiology Centers screens in Arabic. The same applies for German, French, and Hindi users.

**Why this priority**: The app already supports 5 languages; new screens must maintain parity. Lower priority because English serves as a functional fallback during development.

**Independent Test**: Can be tested by switching app language to Arabic and verifying all new screen labels render in Arabic.

**Acceptance Scenarios**:

1. **Given** the app language is set to Arabic, **When** the patient opens the Labs screen, **Then** the title reads "المعامل" and all labels are in Arabic.
2. **Given** the app language is set to Arabic, **When** the patient opens the Radiology Centers screen, **Then** the title reads "مراكز الأشعة" and scan type labels are in Arabic.

---

### Edge Cases

- What happens when no labs or radiology centers match the search/filter criteria? The system displays an appropriate empty state with a clear message.
- What happens when the network request fails? The system shows an error state with a retry option.
- What happens when the user clears all filters? The system reloads the unfiltered, paginated list.
- What happens when the user types very quickly in the search field? Search requests are debounced (500ms delay) to avoid excessive requests.
- What happens when the user reaches the last page of results? No further loading is triggered and no "loading more" indicator appears.
- What happens on the Radiology Centers screen when no scan type is selected? The "All" chip is selected by default, showing all centers.

## Requirements *(mandatory)*

### Functional Requirements

**Labs Screen**

- **FR-001**: System MUST display a searchable, paginated list of physical lab facilities.
- **FR-002**: System MUST allow filtering labs by governorate and city using the existing shared location picker component.
- **FR-003**: System MUST support partial name matching for lab search via the `test_name` parameter with 500ms debounce.
- **FR-004**: System MUST support scroll-to-load-more pagination, loading the next page when the user scrolls near the bottom.
- **FR-005**: System MUST display each lab's name, governorate, and city in a card format.
- **FR-006**: System MUST show distinct loading states: initial load (full screen) vs. loading more (bottom indicator).
- **FR-007**: System MUST display an empty state when no labs match the current filters/search.

**Radiology Centers Screen**

- **FR-008**: System MUST display a searchable, paginated list of radiology centers.
- **FR-009**: System MUST allow filtering radiology centers by scan type using horizontal chips: All, MRI, CT, X-ray, Ultrasound.
- **FR-010**: System MUST allow filtering radiology centers by governorate and city using the existing shared location picker component.
- **FR-011**: System MUST support search by center name with 500ms debounce.
- **FR-012**: System MUST support scroll-to-load-more pagination for radiology center results.
- **FR-013**: System MUST display each radiology center's name, scan type, governorate, and city in a card format.
- **FR-014**: System MUST default to "All" scan type when no specific filter is selected.
- **FR-015**: System MUST show distinct loading states and an empty state when no results match.

**Navigation**

- **FR-016**: System MUST provide navigation entry points to "Labs" and "Radiology Centers" from the Lab Test section.
- **FR-017**: System MUST route radiology-related categories (department = "radiology" or slug containing "radiology") to the Radiology Centers screen instead of the generic test list.
- **FR-018**: System MUST support direct navigation via named routes (`/labs` and `/radiology-centers`).

**Localization**

- **FR-019**: System MUST provide translations for all new screen titles, labels, and filter options in all 5 supported languages (English, Arabic, German, French, Hindi).

**Public Access**

- **FR-020**: Both screens MUST be accessible without authentication (public endpoints, no auth token required).

### Key Entities

- **Lab**: A physical laboratory facility. Attributes: unique identifier, name, associated governorate, associated city.
- **Radiology Center**: A physical radiology/imaging facility. Attributes: unique identifier, name, scan type offered (MRI, CT, X-ray, Ultrasound), associated governorate, associated city.
- **Governorate**: A geographic region (first-level administrative division). Attributes: identifier, name.
- **City**: A city within a governorate. Attributes: identifier, name.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Users can find a lab in their area within 10 seconds of opening the Labs screen (select location, view results).
- **SC-002**: Users can filter radiology centers by scan type with a single tap, seeing updated results within 2 seconds.
- **SC-003**: Search results update automatically after the user stops typing, with no manual "search" button needed.
- **SC-004**: Scrolling through 100+ results is seamless — additional pages load without the user needing to tap a "load more" button.
- **SC-005**: Both screens are fully usable in all 5 supported languages with correct labels and layout direction.
- **SC-006**: Both screens are accessible to unauthenticated users (no login required to browse).
- **SC-007**: Empty and error states are clearly communicated, allowing the user to adjust filters or retry.

## Assumptions

- The existing `GovernoratesCityPicker` shared component is reusable as-is for both new screens.
- The backend APIs (`/api/labs/search` and `/api/radiology/search`) are already implemented and return the documented response structures.
- The scan type values are a fixed set: MRI, CT, X-ray, Ultrasound (plus "All" as a UI-only option that sends no filter).
- Lab and radiology center cards are display-only — tapping a card does not navigate to a detail screen in this feature scope (detail screens can be added in a future iteration).
- The pagination uses `per_page: 15` as the default page size, matching the API response structure.
- Both screens follow the existing app's "Clinical Elegance" design system (Phase 1 tokens: 16px card radius, soft shadows, gradient accents).
