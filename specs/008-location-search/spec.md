# Feature Specification: Location & Search

**Feature Branch**: `008-location-search`
**Created**: 2026-04-02
**Status**: Draft
**Input**: User description: "Location & Search module — public endpoints for location-based searching of healthcare providers (doctors, clinics, nurses, labs, radiology centers, home healthcare) with governorate/city filtering, pagination, and localization."

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Search for a Doctor by Location (Priority: P1)

A patient opens the app and wants to find a cardiologist near them. They select their governorate (e.g., Cairo), then their city (e.g., Nasr City), optionally filter by specialty, gender, or price range, and browse paginated results showing doctor name, specialty, experience, consultation price, profile image, and location.

**Why this priority**: Doctor search is the primary use case for a healthcare app. Patients must be able to discover and compare doctors to book appointments — this is the core value proposition of location-based search.

**Independent Test**: Can be fully tested by selecting a governorate, city, and specialty, then verifying that matching doctors appear with correct details, pagination works, and empty states display properly.

**Acceptance Scenarios**:

1. **Given** the user is on the search screen, **When** they select governorate "Cairo" and city "Nasr City", **Then** only doctors located in Cairo/Nasr City are displayed
2. **Given** search results are displayed, **When** there are more than 15 results, **Then** results are paginated at 15 per page with the ability to load more
3. **Given** the user applies a specialty filter (e.g., Cardiology), **When** results load, **Then** only doctors with the selected specialty appear
4. **Given** the user enters a name search, **When** results load, **Then** doctors whose first or last name partially matches the query appear
5. **Given** the user sets min/max price filters, **When** results load, **Then** only doctors within the specified consultation price range appear
6. **Given** the user applies a gender filter, **When** results load, **Then** only doctors of the selected gender appear
7. **Given** no doctors match the applied filters, **When** results load, **Then** an empty state is shown with a helpful message

---

### User Story 2 - Browse Governorates and Cities (Priority: P1)

A patient needs to select their location before searching. They see a list of all Egyptian governorates, pick one, and then see the cities within that governorate. This location selection feeds into all other search screens.

**Why this priority**: Location selection is a prerequisite for all other search functionality. Without governorate/city selection, no location-based filtering is possible.

**Independent Test**: Can be fully tested by loading governorates, selecting one, verifying cities load for that governorate, and confirming locale-aware names display correctly in Arabic/English.

**Acceptance Scenarios**:

1. **Given** the user opens a location picker, **When** governorates load, **Then** all 27 Egyptian governorates are displayed with locale-aware names
2. **Given** the user selects a governorate, **When** cities load, **Then** only cities belonging to that governorate are displayed
3. **Given** the user's app language is Arabic, **When** governorates and cities load, **Then** names appear in Arabic
4. **Given** the user has not selected a governorate, **When** they attempt to load cities, **Then** the system requires a governorate selection first

---

### User Story 3 - Search for a Clinic by Location (Priority: P2)

A patient wants to find a nearby clinic. They select their location, optionally filter by clinic name or specialty, and browse paginated results showing clinic name, profile image, and location.

**Why this priority**: Clinic search is the second most common use case — patients often search by clinic rather than individual doctor.

**Independent Test**: Can be fully tested by selecting a location, applying name/specialty filters, and verifying matching clinics appear with correct details and pagination.

**Acceptance Scenarios**:

1. **Given** the user selects a governorate and city, **When** clinic results load, **Then** only clinics in that location are shown
2. **Given** the user types a partial clinic name, **When** results load, **Then** clinics whose name partially matches (case-insensitive) appear
3. **Given** the user filters by specialty, **When** results load, **Then** only clinics offering that specialty appear

---

### User Story 4 - Search for a Nurse (Priority: P2)

A patient needs home nursing care. They search by location, and optionally filter by specialization, gender, or availability status. Results show nurse name, specialization, gender, availability, hourly rate, profile image, and location.

**Why this priority**: Nurse search is a key differentiator for the Espitalia platform, supporting home healthcare needs.

**Independent Test**: Can be fully tested by selecting a location, filtering by availability "available", and verifying matching nurses appear with correct details.

**Acceptance Scenarios**:

1. **Given** the user selects a location, **When** nurse results load, **Then** only active nurses in that area are shown
2. **Given** the user filters by availability "available", **When** results load, **Then** only nurses marked as available appear
3. **Given** the user filters by gender and specialization, **When** results load, **Then** only matching nurses appear
4. **Given** a nurse has no profile image, **When** results display, **Then** a default avatar is shown

---

### User Story 5 - Search for a Lab (Priority: P3)

A patient needs lab testing. They search by location and optionally by lab name. Results show lab name and location.

**Why this priority**: Lab search supports the lab test ordering flow already in the app, enabling patients to find labs near them.

**Independent Test**: Can be fully tested by selecting a location and verifying matching labs appear with name and location.

**Acceptance Scenarios**:

1. **Given** the user selects a location, **When** lab results load, **Then** only labs in that area are shown
2. **Given** the user searches by name, **When** results load, **Then** labs whose name partially matches appear

---

### User Story 6 - Search for a Radiology Center (Priority: P3)

A patient needs an imaging scan. They search by location and optionally by scan type (e.g., MRI, CT, X-ray). Results show center name, scan type, and location.

**Why this priority**: Radiology search supports diagnostic imaging needs. Scan type is an exact-match filter, making it a focused search.

**Independent Test**: Can be fully tested by selecting a location, filtering by scan type "MRI", and verifying matching centers appear.

**Acceptance Scenarios**:

1. **Given** the user selects a location and scan type "MRI", **When** results load, **Then** only radiology centers offering MRI in that area appear
2. **Given** the user selects scan type "CT", **When** results load, **Then** only centers matching exactly "CT" appear (not partial matches)

---

### User Story 7 - Search for Home Healthcare Providers (Priority: P3)

A patient needs home healthcare services (e.g., physiotherapy, elderly care). They search by location and optionally by service type. Results show provider name, service type, and location.

**Why this priority**: Home healthcare is a growing segment; this completes the full provider search suite.

**Independent Test**: Can be fully tested by selecting a location and service type, verifying matching providers appear.

**Acceptance Scenarios**:

1. **Given** the user selects a location and service type "physiotherapy", **When** results load, **Then** only home healthcare providers offering physiotherapy in that area appear
2. **Given** no providers match, **When** results load, **Then** an appropriate empty state is displayed

---

### Edge Cases

- What happens when the backend returns zero results for any search? (Display empty state with suggestion to broaden filters)
- What happens when the user has no internet connection during search? (Show offline error with retry option)
- What happens when a search request times out or fails? (Show error state with retry)
- What happens when a doctor/nurse has null specialty or null consultation price? (Display gracefully — omit the field or show "Not specified")
- What happens when pagination reaches the last page? (Stop loading more, indicate no more results)
- What happens when the user rapidly changes filters? (Cancel previous requests, only show results for the latest filter state)
- What happens when the governorate list fails to load? (Show error state; city picker should be disabled until governorate loads)
- How does the app handle the transition between governorate selection and city loading? (Show loading indicator for cities, clear previous city selection when governorate changes)

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: System MUST allow users to browse all Egyptian governorates with locale-aware names (Arabic/English)
- **FR-002**: System MUST allow users to browse cities within a selected governorate with locale-aware names
- **FR-003**: System MUST allow users to search for doctors by location (governorate, city), specialty, name, gender, and price range — all filters optional
- **FR-004**: System MUST allow users to search for clinics by location (governorate, city), specialty, and name — all filters optional
- **FR-005**: System MUST allow users to search for nurses by location (governorate, city), specialization, gender, and availability — all filters optional
- **FR-006**: System MUST allow users to search for labs by location (governorate, city) and name — all filters optional
- **FR-007**: System MUST allow users to search for radiology centers by location (governorate, city) and scan type (exact match) — all filters optional
- **FR-008**: System MUST allow users to search for home healthcare providers by location (governorate, city) and service type (exact match) — all filters optional
- **FR-009**: All search results MUST be paginated at 15 items per page with infinite scroll / load-more capability
- **FR-010**: All search functionality MUST work without user authentication (public access)
- **FR-011**: All search results MUST respect the app's current language setting for localized content
- **FR-012**: System MUST display an appropriate empty state when no results match the applied filters
- **FR-013**: System MUST display an error state with retry capability when a search request fails
- **FR-014**: City selection MUST depend on governorate selection — changing governorate resets city selection and reloads cities
- **FR-015**: System MUST gracefully handle null/missing fields in search results (e.g., null specialty, null price, no profile image)
- **FR-016**: Name-based searches MUST use partial matching (case-insensitive) for doctors, clinics, nurses, and labs
- **FR-017**: Scan type (radiology) and service type (home healthcare) searches MUST use exact matching

### Key Entities

- **Governorate**: An Egyptian administrative division (27 total). Attributes: id, locale-aware name.
- **City**: A city within a governorate. Attributes: id, locale-aware name, parent governorate.
- **Doctor (search result)**: A healthcare professional. Attributes: id, name, gender, experience, specialty (nullable), consultation price (nullable), profile image, governorate, city.
- **Clinic (search result)**: A healthcare facility. Attributes: id, name, profile image, governorate, city.
- **Nurse (search result)**: A nursing professional. Attributes: id, name, specialization, gender, availability status (available/busy/off_duty), hourly rate, profile image, governorate, city.
- **Lab (search result)**: A laboratory facility. Attributes: id, name, governorate, city.
- **Radiology Center (search result)**: An imaging facility. Attributes: id, name, scan type, governorate, city.
- **Home Healthcare Provider (search result)**: A home care service. Attributes: id, name, service type, governorate, city.
- **Pagination**: Metadata for paginated results. Attributes: current page, last page, items per page (15), total count.

## Scope & Boundaries

### In Scope

- Governorate and city browsing with localization
- Search screens for: doctors, clinics, nurses, labs, radiology centers, home healthcare providers
- Location-based filtering (governorate + city) across all search types
- Type-specific filters (specialty, name, gender, price, availability, scan type, service type)
- Paginated results with load-more / infinite scroll
- Empty states and error states for all search screens
- Integration of location/search into existing app navigation (home screen quick services, etc.)
- Reusable location picker component (governorate + city dropdowns)

### Out of Scope

- Booking or appointment creation from search results (handled by existing booking flow)
- Map-based search or GPS-based "near me" functionality
- Provider detail pages (existing screens handle doctor/clinic details)
- Saved searches or search history
- Push notifications for search-related events
- Admin or provider-side management of location data

## Assumptions

- The backend API endpoints described (governorates, cities, doctors/search, clinics/search, nurses/search, labs/search, radiology/search, home-healthcare/search) are already deployed and functional
- The base URL for search endpoints is `{APP_URL}/api` (not `/api/v1`)
- All search endpoints are unauthenticated — no bearer token is needed
- Governorates list is static (27 Egyptian governorates) and can be cached locally after first fetch
- Cities list per governorate changes infrequently and can be cached for the duration of a session
- The app's existing localization system (Accept-Language header) is used for locale-aware responses
- Search results sort order is newest first (server-side) — no client-side sort is needed
- Profile images may be null; a default placeholder is used when missing

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Users can find a healthcare provider (doctor, clinic, nurse, lab, radiology center, or home healthcare) within 3 taps from the home screen
- **SC-002**: Search results display within 2 seconds of applying filters on a standard mobile connection
- **SC-003**: 90% of users who start a provider search successfully view at least one result on their first attempt
- **SC-004**: Location picker (governorate + city) loads and is interactive within 1 second
- **SC-005**: All 6 provider search types are accessible from the app and return correctly filtered results
- **SC-006**: Pagination works seamlessly — users can browse through all pages of results without errors or duplicate items
- **SC-007**: Search screens display correctly in both Arabic and English, with all names and labels localized
- **SC-008**: Empty and error states are user-friendly and provide clear guidance (retry or broaden filters)
