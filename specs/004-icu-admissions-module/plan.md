# Implementation Plan: ICU Admissions Module

**Branch**: `004-icu-admissions-module` | **Date**: 2026-03-29 | **Spec**: [spec.md](spec.md)
**Input**: Feature specification from `/specs/004-icu-admissions-module/spec.md`

## Summary

Build a new ICU Admissions module for the Espitalia Patient App
allowing patients to browse hospitals with ICU departments, view bed
availability, submit multi-section admission requests with file
uploads, track request status, and cancel pending requests. The
module connects to ~7 REST API endpoints on the Laravel backend.

**Critical finding**: Unlike labs, nurse, and request-service modules,
this is a **brand new module** — no existing code in the codebase.
All models, screens, controllers, API methods, endpoints, locale
keys, colors, constants, and home integration must be created from
scratch, following established patterns from the existing modules.

## Technical Context

**Language/Version**: Dart 3.0+ / Flutter 3.0+
**Primary Dependencies**: GetX 4.7.2+, nb_utils, http, google_fonts
**Storage**: GetStorage (non-sensitive), platform keychain (tokens)
**Testing**: flutter test (recommended, not mandatory per constitution)
**Target Platform**: Android (primary), iOS, Web
**Project Type**: Mobile app (Flutter cross-platform)
**Performance Goals**: Screen load <2s on standard mobile connection
**Constraints**: Must use existing network layer, GetX patterns, and
Clinical Elegance design tokens. File uploads via buildMultiPartResponse().
**Scale/Scope**: ~7 API endpoints, 3 main models + ~8 nested,
~15-20 new files, 5 language files to extend

## Constitution Check

| Principle | Status | Notes |
|-----------|--------|-------|
| I. Platform Parity | PASS | All screens will use Flutter widgets. File picker uses cross-platform packages already in pubspec. |
| II. Patient Data Security | PASS | Auth via Bearer tokens. Patient medical data (national ID, insurance) transmitted only via HTTPS. File uploads go through authenticated multipart endpoint. |
| III. GetX Architecture | PASS | Will follow established patterns: .obs, Obx(), Get.to(), Get.put(). Separate controller files per screen. |
| IV. Backend Contract Fidelity | PASS | All endpoints will be defined in api_end_points.dart. API methods in core_apis.dart following buildHttpResponse()/buildMultiPartResponse() patterns. |
| V. Localization-First | PASS | All strings via locale.value.<key>. Keys added to all 5 language files. |
| VI. Testing Discipline | N/A | Tests recommended but not mandatory. |
| VII. Simplicity | PASS | No new packages. Uses existing http, path_provider, image_picker. Self-contained in lib/screens/icu/. |

## Project Structure

### Documentation (this feature)

```text
specs/004-icu-admissions-module/
├── plan.md
├── research.md
├── data-model.md
├── quickstart.md
├── contracts/
│   └── api-endpoints.md
├── checklists/
│   └── requirements.md
└── tasks.md
```

### Source Code (NEW — to be created)

```text
lib/
├── api/
│   └── core_apis.dart                          # Add ~7 ICU API methods
├── screens/
│   └── icu/                                    # NEW DIRECTORY
│       ├── model/
│       │   ├── hospital_model.dart             # Hospital + IcuDepartment models
│       │   └── icu_admission_model.dart        # AdmissionRequest + nested models
│       ├── components/
│       │   ├── hospital_card.dart              # Hospital list card
│       │   ├── department_card.dart            # ICU department card
│       │   └── admission_request_card.dart     # Admission request list card
│       ├── hospital_list_controller.dart       # Browse hospitals
│       ├── hospital_list_screen.dart
│       ├── hospital_detail_screen.dart         # Hospital + departments
│       ├── department_list_controller.dart     # Browse departments
│       ├── department_list_screen.dart
│       ├── create_admission_controller.dart    # Multi-section form
│       ├── create_admission_screen.dart
│       ├── admission_list_controller.dart      # My requests
│       ├── admission_list_screen.dart
│       └── admission_detail_screen.dart        # Request detail + cancel
├── utils/
│   ├── api_end_points.dart                    # Add ~7 ICU endpoints
│   ├── colors.dart                            # Add ICU status + urgency colors
│   └── constants.dart                         # Add ICU status, urgency, case type, etc.
├── locale/
│   ├── languages.dart                         # Add ~40 ICU locale key getters
│   ├── language_en.dart                       # Add English translations
│   ├── language_ar.dart                       # Add Arabic translations
│   ├── language_de.dart                       # Add German translations
│   ├── language_fr.dart                       # Add French translations
│   └── language_hi.dart                       # Add Hindi translations
└── screens/home/components/
    └── quick_services_component.dart          # Add ICU entry point
```

**Structure Decision**: New `lib/screens/icu/` directory following
the per-feature pattern established by lab_test, nurse, and
request_service modules.

## Complexity Tracking

No constitution violations. File uploads use existing
`buildMultiPartResponse()` from `network_utils.dart`.
