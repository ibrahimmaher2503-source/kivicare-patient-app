# Research: Home Page Departments Section

**Branch**: `002-home-departments-section`
**Date**: 2026-03-02

## R1: Home Screen Section Composition Pattern

**Decision**: New sections are added as child widgets inside a `Column`
within a `SingleChildScrollView` in `home_screen.dart`.

**Current section order** (lines 63-70 of home_screen.dart):
1. `ChooseCategoryComponents` — category grid
2. `SliderComponent` — auto-scrolling banner carousel
3. `QuickBookComponent` — quick appointment booking form
4. `UpcomingAppointmentComponents` — next appointment card
5. `PopularServiceComponent` — horizontal service list
6. `PerfectClinicComponent` — horizontal clinic list
7. `PopularDoctorComponent` — horizontal doctor list

**Insertion point**: The Departments section will be inserted between
`SliderComponent` (position 2) and `QuickBookComponent` (position 3),
per FR-007 in the spec.

**Rationale**: Departments are a high-level navigational concept.
Placing them right after the banner carousel and before the booking
form gives them prominent visibility while keeping the action-oriented
quick book form accessible without excessive scrolling.

**Alternatives considered**:
- After QuickBookComponent: Would push departments below the fold
  on smaller screens, reducing discoverability.
- Before categories: Categories serve a different purpose (filtering
  services), so departments should not replace them.

## R2: Section Component Structure

**Decision**: Follow the established pattern used by
`PerfectClinicComponent` and `PopularDoctorComponent`.

**Standard structure**:
```
Column(
  16.height,
  ViewAllLabel(...).paddingOnly(left: 16, right: 8),
  HorizontalList(spacing: 16, padding: EdgeInsets.symmetric(horizontal: 16), ...),
)
```

**Key widgets**:
- `ViewAllLabel` from `lib/utils/view_all_label_component.dart` —
  renders section title + optional "View All" button
- `HorizontalList` from `nb_utils` — horizontal scrollable card list
- `.visible()` extension — conditional rendering

**Rationale**: Using the identical pattern ensures visual consistency
and reduces cognitive load for developers.

## R3: Navigation Targets for Active Departments

**Decision**: Reuse existing list screens with the same parameters
used by the home screen's "View All" actions.

**Doctors navigation**:
```dart
Get.to(
  () => DoctorViewListScreen(
    title: locale.value.doctors,
    isFromDashboard: true,
  ),
  arguments: {"isPopular": 1},
);
```

**Clinics navigation**:
```dart
Get.to(
  () => ClinicListComponent(
    title: locale.value.clinics,
    isFromDashboard: true,
  ),
  arguments: {"isPopular": 1},
);
```

**Rationale**: These are the same screens used by PopularDoctorComponent
and PerfectClinicComponent "View All" actions. Reusing them avoids
creating new screens and maintains navigational consistency.

**Alternatives considered**:
- Creating new department-specific list screens: Rejected per
  Constitution Principle VII (Simplicity). The existing screens
  already serve the same purpose.

## R4: Coming Soon Behavior

**Decision**: Use `toast()` from `nb_utils` for the coming-soon
tap feedback. Apply visual muting via reduced opacity on
coming-soon cards.

**Toast pattern** (established in codebase):
```dart
toast(locale.value.comingSoon);
```

**Visual distinction**: Coming-soon cards will use `Opacity(0.5)`
or similar muting, plus a small "Coming Soon" text badge on the
card itself.

**Rationale**: Toast is the lightest-weight feedback mechanism
already used throughout the app. A badge provides persistent
visual indication without requiring user interaction.

**Alternatives considered**:
- Dialog popup: Too disruptive for a simple informational message.
- Snackbar with action: Overkill; no action is needed.
- Disabled card (no tap response): Users might think the app is
  broken if nothing happens on tap.

## R5: Department Data Source

**Decision**: Departments are defined as a static local list in
the component. No API call, no model in dashboard response.

**Rationale**: Per spec assumption, the five departments are fixed
and do not come from the backend. Adding them to the API would
require Laravel backend changes (out of scope) and add network
dependency for static data. A simple Dart list of department
objects is sufficient.

**Alternatives considered**:
- Add to DashboardRes model from API: Requires backend changes
  (out of scope) and adds unnecessary network dependency.
- Store in local storage: Overkill for five hardcoded items that
  never change at runtime.

## R6: Localization Strings Required

**Decision**: Add the following locale keys to `BaseLanguage` and
all five language implementations:

| Key | English Value | Purpose |
|-----|--------------|---------|
| `departments` | "Departments" | Section title |
| `doctors` | "Doctors" | Already exists in locale |
| `clinics` | "Clinics" | Already exists in locale |
| `radiology` | "Radiology" | Department name |
| `intensiveCare` | "Intensive Care" | Department name |
| `nurseRequests` | "Nurse Requests" | Department name |
| `comingSoon` | "Coming Soon" | Badge text + toast message |

**Rationale**: Constitution Principle V (Localization-First)
requires all user-facing strings to go through the locale system.

## R7: Icon Assets

**Decision**: Add five new department icon assets to
`assets/icons/` as PNG files, then regenerate `assets.dart`.

**Required icons**:
- `ic_department_doctors.png`
- `ic_department_clinics.png`
- `ic_department_radiology.png`
- `ic_department_intensive_care.png`
- `ic_department_nurse_requests.png`

**Rationale**: Existing icons (`ic_doctor.png`, `ic_clinic.png`)
are used in other contexts. Dedicated department icons ensure
the section has its own visual identity and avoid conflicts.

**Alternative**: Reuse `ic_doctor.png` and `ic_clinic.png` for
Doctors and Clinics departments. Acceptable fallback if
dedicated icons are not available.
