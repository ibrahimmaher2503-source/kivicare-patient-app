# Implementation Plan: Home Page Departments Section

**Branch**: `002-home-departments-section` | **Date**: 2026-03-02 | **Spec**: [spec.md](./spec.md)
**Input**: Feature specification from `/specs/002-home-departments-section/spec.md`

## Summary

Add a "Departments" section to the home screen displaying five
hospital department cards (Doctors, Clinics, Radiology, Intensive
Care, Nurse Requests). Doctors and Clinics are active and navigate
to existing list screens. Radiology, Intensive Care, and Nurse
Requests display a "Coming Soon" badge and show a toast on tap.
The section is placed between the banner carousel and the quick
book form. Department data is locally defined — no API changes.

## Technical Context

**Language/Version**: Dart 3.0+ / Flutter 3.0+
**Primary Dependencies**: GetX 4.7.2+ (state management, navigation), nb_utils (UI utilities, toast, HorizontalList)
**Storage**: N/A (departments are hardcoded constants)
**Testing**: flutter test (recommended, not mandatory per constitution)
**Target Platform**: Android, iOS, Web (all three per Platform Parity principle)
**Project Type**: Mobile app (Flutter multi-platform)
**Performance Goals**: <300ms navigation on tap, 60fps scroll
**Constraints**: No API dependency, offline-capable, RTL support
**Scale/Scope**: 2 new component files, 7 locale file updates, 1 home screen modification, 5 icon assets

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

| Principle | Status | Notes |
|-----------|--------|-------|
| I. Platform Parity | PASS | No platform-specific code. Uses standard Flutter widgets (Column, GestureDetector, Container, Text, Image). Works identically on Android, iOS, and Web. |
| II. Patient Data Security | PASS | No patient data handled. No API calls. No credentials. Pure UI navigation feature. |
| III. GetX Architecture Consistency | PASS | Uses `Get.to()` for navigation. Uses `Get.find<HomeController>()` to access existing state. No new state management patterns introduced. |
| IV. Backend Contract Fidelity | PASS | No API changes. No modifications to `api_end_points.dart`, `network_utils.dart`, or any API service file. Department data is local-only. |
| V. Localization-First | PASS | All strings (section title, department names, "Coming Soon" text) go through `locale.value.<key>`. Added to all 5 language files. |
| VI. Testing Discipline | PASS | UI-only feature, no auth/payment/booking paths modified. Tests recommended but not mandatory. |
| VII. Simplicity & Maintainability | PASS | No new packages. No abstractions. Simple static list of departments. Two component files (section + card). No models directory needed. |

**Post-Phase 1 re-check**: All gates still PASS. No design decisions
introduced platform-specific code, new dependencies, or API changes.

## Project Structure

### Documentation (this feature)

```text
specs/002-home-departments-section/
├── spec.md              # Feature specification
├── plan.md              # This file
├── research.md          # Phase 0 research findings
├── data-model.md        # Department entity definition
├── quickstart.md        # Verification guide
└── checklists/
    └── requirements.md  # Spec quality checklist
```

### Source Code (repository root)

```text
lib/
├── screens/home/
│   ├── home_screen.dart                          # MODIFY: insert DepartmentsComponent
│   └── components/
│       ├── departments_component.dart            # NEW: section with department list
│       └── department_card_widget.dart            # NEW: individual department card
├── locale/
│   ├── languages.dart                            # MODIFY: add abstract getters
│   ├── language_en.dart                          # MODIFY: add English strings
│   ├── language_ar.dart                          # MODIFY: add Arabic strings
│   ├── language_de.dart                          # MODIFY: add German strings
│   ├── language_fr.dart                          # MODIFY: add French strings
│   └── language_hi.dart                          # MODIFY: add Hindi strings
└── generated/
    └── assets.dart                               # AUTO-REGENERATED after adding icons

assets/icons/
├── ic_department_doctors.png                     # NEW: department icon
├── ic_department_clinics.png                     # NEW: department icon
├── ic_department_radiology.png                   # NEW: department icon
├── ic_department_intensive_care.png              # NEW: department icon
└── ic_department_nurse_requests.png              # NEW: department icon
```

**Structure Decision**: This feature adds two new component files
in the existing `lib/screens/home/components/` directory, following
the established pattern where each home screen section has its own
component file (e.g., `perfect_clinic_list.dart`,
`popular_service_list.dart`). No new directories are created.
The department card widget is separated from the section component
to keep files under 500 lines per Constitution Principle VII.

## Complexity Tracking

> No violations. All constitution principles pass without exceptions.
