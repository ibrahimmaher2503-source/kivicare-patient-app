# Implementation Plan: Labs & Radiology Module

**Branch**: `001-labs-radiology-module` | **Date**: 2026-03-29 | **Spec**: [spec.md](spec.md)
**Input**: Feature specification from `/specs/001-labs-radiology-module/spec.md`

## Summary

Integrate a Labs & Radiology module into the Espitalia Patient App
allowing patients to browse test categories, search and filter lab/
radiology tests, place test orders, track order status, cancel pending
orders, and download PDF reports. The module connects to 8 REST API
endpoints on the Laravel backend.

**Critical finding**: The codebase already contains a substantially
complete implementation at `lib/screens/lab_test/`. The plan focuses on
verifying contract compliance, completing missing features (cancel
order, report download), ensuring design system compliance, and
validating all translations.

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
**Scale/Scope**: 8 API endpoints, 4 models, ~10 screens/components,
5 language files

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1.*

| Principle | Status | Notes |
|-----------|--------|-------|
| I. Platform Parity | PASS | All screens use Flutter widgets — no platform-specific code. PDF download uses cross-platform `path_provider`. |
| II. Patient Data Security | PASS | Auth endpoints use Bearer tokens via existing network layer. No new sensitive data storage. All API calls via HTTPS. |
| III. GetX Architecture | PASS | All controllers use `.obs`/`Obx()`. Navigation via `Get.to()`/`Get.back()`. Controllers registered with `Get.put()`. |
| IV. Backend Contract Fidelity | PASS | Endpoints defined in `api_end_points.dart`. API methods in `core_apis.dart` follow `buildHttpResponse()` → `handleResponse()` pattern. |
| V. Localization-First | PASS | All strings use `locale.value.<key>`. Keys defined in all 5 language files. |
| VI. Testing Discipline | N/A | Tests recommended but not mandatory. Module does not touch auth/payment flows. |
| VII. Simplicity | PASS | No new packages. No unnecessary abstractions. Self-contained in `lib/screens/lab_test/`. |

**Post-Phase 1 Re-check**: No changes to gate status. Report download
uses existing HTTP infrastructure with `dart:io` for file operations.

## Project Structure

### Documentation (this feature)

```text
specs/001-labs-radiology-module/
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
│   └── core_apis.dart                    # API methods (existing, verify/extend)
├── screens/
│   └── lab_test/
│       ├── model/
│       │   ├── lab_test_model.dart        # LabTest model (existing, verify)
│       │   ├── lab_test_category_model.dart # Category model (existing, verify)
│       │   └── test_order_model.dart      # Order + Item models (existing, verify)
│       ├── components/
│       │   ├── lab_test_card.dart          # Test list card (existing, verify design)
│       │   ├── lab_test_category_card.dart # Category card (existing, verify design)
│       │   └── test_order_card.dart        # Order list card (existing, verify design)
│       ├── lab_test_categories_controller.dart  # (existing)
│       ├── lab_test_categories_screen.dart      # (existing)
│       ├── lab_test_list_controller.dart        # (existing)
│       ├── lab_test_list_screen.dart            # (existing)
│       ├── lab_test_detail_screen.dart          # (existing)
│       ├── create_test_order_controller.dart    # (existing)
│       ├── create_test_order_screen.dart        # (existing)
│       ├── test_order_list_controller.dart      # (existing)
│       ├── test_order_list_screen.dart          # (existing)
│       └── test_order_detail_screen.dart        # (existing, add cancel + download)
├── utils/
│   ├── api_end_points.dart            # Endpoint constants (existing, verify)
│   └── colors.dart                    # Status colors (existing)
├── locale/
│   ├── languages.dart                 # Base keys (existing, verify completeness)
│   ├── language_en.dart               # English (existing, verify)
│   ├── language_ar.dart               # Arabic (existing, verify)
│   ├── language_de.dart               # German (existing, verify)
│   ├── language_fr.dart               # French (existing, verify)
│   └── language_hi.dart               # Hindi (existing, verify)
└── screens/home/components/
    └── quick_services_component.dart  # Home integration (existing)
```

**Structure Decision**: Existing Flutter mobile app structure. All lab
test code is self-contained in `lib/screens/lab_test/` following the
established per-feature directory pattern. No new directories needed.

## Complexity Tracking

No constitution violations. No complexity justifications needed.
