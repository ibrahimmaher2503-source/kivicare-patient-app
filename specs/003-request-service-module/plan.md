# Implementation Plan: Request Service Module

**Branch**: `003-request-service-module` | **Date**: 2026-03-29 | **Spec**: [spec.md](spec.md)
**Input**: Feature specification from `/specs/003-request-service-module/spec.md`

## Summary

Integrate a Request Service module into the Espitalia Patient App
allowing patients to submit custom service requests (not in the
standard catalog) and track their approval status. The module
connects to 2 REST API endpoints on the Laravel backend.

**Critical finding**: The codebase already contains a fully
implemented module at `lib/screens/request_service/` with 6 files,
2 API methods, models, locales, colors, constants, and home
integration. The plan focuses on verifying contract compliance,
design system compliance, and translation validation.

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
**Scale/Scope**: 2 API endpoints, 1 model, ~6 files, 5 language files

## Constitution Check

| Principle | Status | Notes |
|-----------|--------|-------|
| I. Platform Parity | PASS | All screens use Flutter widgets — no platform-specific code. |
| II. Patient Data Security | PASS | Auth endpoints use Bearer tokens via existing network layer. |
| III. GetX Architecture | PASS | Controllers use `.obs`/`Obx()`. Navigation via `Get.to()`/`Get.back()`. |
| IV. Backend Contract Fidelity | PASS | Endpoints defined in `api_end_points.dart`. API methods follow `buildHttpResponse()` pattern. |
| V. Localization-First | PASS | All strings use `locale.value.<key>`. |
| VI. Testing Discipline | N/A | Tests not mandatory for this module. |
| VII. Simplicity | PASS | No new packages. Self-contained in `lib/screens/request_service/`. |

## Project Structure

### Source Code (repository root)

```text
lib/
├── api/
│   └── core_apis.dart                          # API methods (existing)
├── screens/
│   └── request_service/
│       ├── model/
│       │   └── request_service_model.dart       # RequestService model (existing)
│       ├── components/
│       │   └── request_service_card.dart        # List card component (existing)
│       ├── request_service_list_controller.dart  # (existing)
│       ├── request_service_list_screen.dart      # (existing)
│       ├── create_request_service_controller.dart # (existing)
│       └── create_request_service_screen.dart    # (existing)
├── utils/
│   ├── api_end_points.dart                     # Endpoint constants (existing)
│   ├── colors.dart                             # Status colors (existing)
│   └── constants.dart                          # Status enums (existing)
├── locale/                                     # All 5 language files (existing)
└── screens/home/components/
    └── quick_services_component.dart           # Home integration (existing)
```

## Complexity Tracking

No constitution violations. No complexity justifications needed.
