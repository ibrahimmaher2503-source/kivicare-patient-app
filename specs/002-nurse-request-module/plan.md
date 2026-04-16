# Implementation Plan: Nurse Request Module

**Branch**: `002-nurse-request-module` | **Date**: 2026-03-29 | **Spec**: [spec.md](spec.md)
**Input**: Feature specification from `/specs/002-nurse-request-module/spec.md`

## Summary

Integrate a Nurse Request module into the Espitalia Patient App
allowing patients to browse available nurses, view nurse profiles,
create home care requests, track request status, edit pending
requests, and cancel pending/confirmed requests. The module connects
to 7 REST API endpoints on the Laravel backend.

**Critical finding**: The codebase already contains a fully
implemented module at `lib/screens/nurse/` with 12 files, all 7 API
methods, models, locales, colors, constants, and home integration.
The plan focuses on verifying contract compliance, ensuring design
system compliance, and validating translations.

## Technical Context

**Language/Version**: Dart 3.0+ / Flutter 3.0+
**Primary Dependencies**: GetX 4.7.2+, nb_utils, http, google_fonts
**Storage**: GetStorage (non-sensitive), platform keychain (tokens)
**Testing**: flutter test (recommended, not mandatory per constitution)
**Target Platform**: Android (primary), iOS, Web
**Project Type**: Mobile app (Flutter cross-platform)
**Performance Goals**: Screen load <2s on standard mobile connection
**Constraints**: Must use existing network layer, GetX patterns, and
Clinical Elegance design tokens
**Scale/Scope**: 7 API endpoints, 2 main models + 4 nested, ~12 files,
5 language files

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1.*

| Principle | Status | Notes |
|-----------|--------|-------|
| I. Platform Parity | PASS | All screens use Flutter widgets — no platform-specific code. |
| II. Patient Data Security | PASS | Auth endpoints use Bearer tokens via existing network layer. All API calls via HTTPS. Address data handled client-side only for form submission. |
| III. GetX Architecture | PASS | All controllers use `.obs`/`Obx()`. Navigation via `Get.to()`/`Get.back()`. Controllers registered with `Get.put()`. |
| IV. Backend Contract Fidelity | PASS | Endpoints defined in `api_end_points.dart`. API methods in `core_apis.dart` follow `buildHttpResponse()` pattern. |
| V. Localization-First | PASS | All strings use `locale.value.<key>`. Keys defined in all 5 language files. |
| VI. Testing Discipline | N/A | Tests recommended but not mandatory. Module does not touch auth/payment flows. |
| VII. Simplicity | PASS | No new packages. Self-contained in `lib/screens/nurse/`. |

## Project Structure

### Documentation (this feature)

```text
specs/002-nurse-request-module/
├── plan.md
├── research.md
├── data-model.md
├── quickstart.md
├── contracts/
│   └── api-endpoints.md
├── checklists/
│   └── requirements.md
└── tasks.md              (created by /speckit.tasks)
```

### Source Code (repository root)

```text
lib/
├── api/
│   └── core_apis.dart                       # API methods (existing, verify)
├── screens/
│   └── nurse/
│       ├── model/
│       │   ├── nurse_model.dart              # Nurse model (existing, verify)
│       │   └── nurse_request_model.dart      # Request + nested models (existing, verify)
│       ├── components/
│       │   ├── nurse_card.dart               # Nurse list card (existing, verify)
│       │   └── nurse_request_card.dart       # Request list card (existing, verify)
│       ├── nurse_list_controller.dart        # (existing)
│       ├── nurse_list_screen.dart            # (existing)
│       ├── nurse_detail_screen.dart          # (existing)
│       ├── create_nurse_request_controller.dart # (existing, create+edit)
│       ├── create_nurse_request_screen.dart  # (existing, create+edit)
│       ├── nurse_request_list_controller.dart # (existing)
│       ├── nurse_request_list_screen.dart    # (existing)
│       └── nurse_request_detail_screen.dart  # (existing, cancel+edit actions)
├── utils/
│   ├── api_end_points.dart                  # Endpoint constants (existing)
│   ├── colors.dart                          # Status + availability colors (existing)
│   └── constants.dart                       # Status + availability enums (existing)
├── locale/
│   ├── languages.dart                       # Base keys (existing)
│   ├── language_en.dart                     # (existing)
│   ├── language_ar.dart                     # (existing)
│   ├── language_de.dart                     # (existing)
│   ├── language_fr.dart                     # (existing)
│   └── language_hi.dart                     # (existing)
└── screens/home/components/
    └── quick_services_component.dart        # Home integration (existing)
```

**Structure Decision**: Existing Flutter mobile app structure. All nurse
code is self-contained in `lib/screens/nurse/`. No new directories needed.

## Complexity Tracking

No constitution violations. No complexity justifications needed.
