# Data Model: Home Page Departments Section

**Branch**: `002-home-departments-section`
**Date**: 2026-03-02

## Entities

### DepartmentModel

Represents a single department card displayed on the home screen.
This is a local-only model — it is not serialized from API responses.

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| name | String | Yes | Localized display name (e.g., "Doctors") |
| icon | String | Yes | Asset path to department icon |
| isActive | bool | Yes | `true` if department is functional, `false` if coming soon |
| onTap | VoidCallback? | No | Navigation callback for active departments; null for coming-soon |

**Validation Rules**:
- `name` MUST NOT be empty
- `icon` MUST reference a valid asset path
- When `isActive` is `false`, `onTap` MUST be null (enforced by
  the component, not the model)

### Static Department List

The five departments are defined as a static list. This is not a
database table or API response — it is a compile-time constant
list defined in the departments component file.

| Department | isActive | Navigation Target |
|-----------|----------|-------------------|
| Doctors | true | DoctorViewListScreen |
| Clinics | true | ClinicListComponent |
| Radiology | false | None (coming soon) |
| Intensive Care | false | None (coming soon) |
| Nurse Requests | false | None (coming soon) |

## Relationships

- **DepartmentModel → DoctorViewListScreen**: "Doctors" department
  navigates to the existing doctor listing screen
- **DepartmentModel → ClinicListComponent**: "Clinics" department
  navigates to the existing clinic listing screen
- **DepartmentModel → HomeScreen**: The departments list is rendered
  as a section within the home screen's scrollable column

## State Transitions

No state transitions. Departments are static and immutable at
runtime. The `isActive` flag is a compile-time constant that will
be changed in source code when a department becomes functional in
a future release.

## Notes

- This model does NOT extend or modify the existing `DashboardRes`
  or `DashboardData` models. Departments are entirely client-side.
- No database, local storage, or API integration is needed.
- The model is intentionally minimal per Constitution Principle VII
  (Simplicity & Maintainability).
