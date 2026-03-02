<!--
Sync Impact Report
===================
Version change: N/A (template) → 1.0.0
Modified principles: N/A (initial creation)
Added sections:
  - Core Principles (7 principles: Platform Parity, Patient Data Security,
    GetX Architecture Consistency, Backend Contract Fidelity,
    Localization-First, Testing Discipline, Simplicity & Maintainability)
  - Technology Stack Constraints
  - Development Workflow
  - Governance
Removed sections: None
Templates requiring updates:
  - .specify/templates/plan-template.md — ✅ no changes needed
    (Constitution Check section is generic and will reference this file)
  - .specify/templates/spec-template.md — ✅ no changes needed
    (spec requirements sections align with principles)
  - .specify/templates/tasks-template.md — ✅ no changes needed
    (task phases and testing policy align; testing marked optional)
  - .specify/templates/checklist-template.md — ✅ no changes needed
    (generic structure, filled per feature)
Follow-up TODOs: None
-->

# Espitalia Patient App Constitution

## Core Principles

### I. Platform Parity (NON-NEGOTIABLE)

Every user-facing feature MUST work consistently across all supported
platforms: Android, iOS, and Web. Platform-specific code MUST be
isolated behind platform checks or conditional imports, never scattered
through business logic.

- New features MUST NOT ship for one platform while leaving others
  broken or degraded. If a feature cannot be supported on a platform,
  it MUST degrade gracefully (hidden UI, informative message) rather
  than crash.
- `firebase_options.dart` MUST contain valid configuration for every
  supported platform. Placeholder values are considered broken.
- Platform-specific packages (e.g., PhonePe UPI on Android only)
  MUST be guarded with `Platform` checks or `kIsWeb` conditions.
- All acceptance testing MUST verify behavior on Android AND at least
  one additional platform (iOS or Web) before a feature is considered
  complete.

**Rationale**: The app targets three platforms. A feature that works
on Android but crashes on iOS or Web is a defect, not a partial
delivery.

### II. Patient Data Security

All code handling patient data, authentication tokens, or credentials
MUST follow secure-by-default practices. Healthcare data carries
regulatory and ethical obligations.

- API calls MUST use HTTPS exclusively (`https://espitalia.net/api/`).
  HTTP URLs MUST NOT appear in production code.
- Authentication tokens MUST be transmitted via `Authorization: Bearer`
  headers, never as URL query parameters.
- Sensitive keys (Firebase API keys, payment gateway secrets, OAuth
  client secrets) MUST NOT be hardcoded in committed source files.
  Use platform-native secure storage or environment configuration.
- Password storage for token regeneration MUST use encrypted local
  storage (GetStorage with encryption or platform keychain).
- Firebase Crashlytics MUST NOT capture user-identifiable health data
  in crash reports. Sanitize logs before transmission.

**Rationale**: Patient trust depends on data security. A single
credential leak or unencrypted transmission can compromise the
entire user base.

### III. GetX Architecture Consistency

All state management, dependency injection, and navigation MUST use
GetX patterns as established in the codebase. Mixing state management
approaches creates maintenance debt and unpredictable behavior.

- Reactive state MUST use `.obs` observables and `Obx()` widgets.
  Do not introduce `setState()`, `Provider`, `Riverpod`, or `Bloc`
  alongside GetX.
- Navigation MUST use `Get.to()`, `Get.back()`, `Get.offAll()`.
  Do not use `Navigator.push()` directly.
- Dependency injection MUST use `Get.put()` or `Get.lazyPut()`.
- Global state variables (`isLoggedIn`, `loginUserData`, `isDarkMode`,
  `locale`) MUST be accessed from `lib/utils/common_base.dart`.
  Do not create parallel global state.
- Controllers MAY be embedded in screen files (current convention)
  or placed in separate files, but each screen MUST have exactly one
  controller pattern — not both.

**Rationale**: GetX is deeply integrated across 261 Dart files.
Introducing competing patterns creates inconsistency and makes
onboarding harder.

### IV. Backend Contract Fidelity

The app MUST maintain compatibility with the Laravel REST API at
`espitalia.net`. Changes to API integration code MUST NOT break
existing endpoint contracts.

- All API endpoints MUST be defined in
  `lib/utils/api_end_points.dart`. Do not hardcode URLs in screen
  or service files.
- HTTP methods, request bodies, and expected response shapes MUST
  match the Laravel API contract. When the backend changes, update
  the corresponding model and API service file together.
- The automatic token regeneration flow in
  `lib/network/network_utils.dart` (`reGenerateToken()`) MUST NOT
  be modified without verifying it works for both password-based
  and social login users.
- New API integrations MUST follow the established pattern:
  `buildHttpResponse()` → `handleResponse()` → model deserialization.
- Error responses MUST be caught and displayed to users via
  `toast()` or appropriate error UI — never silently swallowed.

**Rationale**: The Laravel backend is a shared system. Breaking the
API contract affects all connected clients, not just this app.

### V. Localization-First

All user-facing text MUST be accessed through the localization system.
Hardcoded strings in UI code are defects.

- User-visible strings MUST use `locale.value.<key>` from the
  `BaseLanguage` system in `lib/locale/`.
- New strings MUST be added to ALL language files: `language_en.dart`,
  `language_ar.dart`, `language_de.dart`, `language_fr.dart`,
  `language_hi.dart`.
- If a translation is unknown, use the English string as a placeholder
  and add a `// TODO: translate` comment in non-English files.
- RTL layout support MUST be maintained for Arabic (ar) locale.
- Date and number formatting MUST use the `intl` package, not manual
  string formatting.

**Rationale**: The app serves a multilingual patient base. Hardcoded
English strings break the experience for non-English users and are
difficult to find later.

### VI. Testing Discipline (RECOMMENDED)

Tests are strongly recommended for critical paths and SHOULD be
included when modifying authentication, payment, or booking flows.
Tests are not mandatory for all changes.

- Authentication flows (login, registration, token refresh, social
  sign-in) SHOULD have widget or integration tests.
- Payment gateway integrations SHOULD have unit tests for request
  building and response parsing.
- New API service methods SHOULD include tests for success and error
  responses.
- Test files MUST be placed in the `test/` directory mirroring the
  `lib/` structure.
- Tests MUST NOT depend on live backend services. Use mock responses
  for API testing.

**Rationale**: Healthcare and payment features carry high risk.
Testing these paths catches regressions before they reach patients.
Making tests recommended (not mandatory) avoids blocking velocity
on low-risk UI changes.

### VII. Simplicity & Maintainability

Prefer the simplest solution that meets requirements. Do not add
abstractions, patterns, or infrastructure for hypothetical future
needs.

- Do not introduce new packages when existing dependencies or
  Dart standard library can solve the problem.
- Do not create wrapper classes around packages unless the wrapper
  adds meaningful project-specific behavior.
- Payment gateway services MUST remain self-contained in
  `lib/payment_gateways/`. Do not create shared payment abstractions
  unless three or more gateways share identical logic.
- Screen files SHOULD remain under 500 lines. Extract components
  only when reuse is proven (used in 2+ screens), not speculative.
- Custom package forks (iqonic-design GitHub) SHOULD be replaced
  with upstream versions when upstream catches up.

**Rationale**: The codebase has 261 files across 59 directories.
Every unnecessary abstraction increases cognitive load for
developers joining the project.

## Technology Stack Constraints

- **Language**: Dart 3.0+ / Flutter 3.0+
- **State Management**: GetX 4.7.2+ (exclusive — no mixing)
- **Local Storage**: GetStorage for non-sensitive data; platform
  keychain for credentials
- **Networking**: `http` package via `lib/network/network_utils.dart`
- **Firebase**: Core, Auth, Messaging, Crashlytics, Analytics
- **Maps**: `google_maps_flutter` + `geolocator` + `geocoding`
- **Payments**: 10 gateway integrations in `lib/payment_gateways/`
  (custom forks from iqonic-design for 5 of them)
- **Minimum Android SDK**: Inherited from Flutter (API 21+)
- **Target/Compile SDK**: 35
- **iOS**: Minimum deployment target per Flutter defaults
- **Web**: Chrome-based browsers (primary target)

New dependencies MUST be justified. Prefer packages with:
- Dart 3 / null-safety support
- Active maintenance (updated within last 6 months)
- Compatible licenses (MIT, BSD, Apache 2.0)

## Development Workflow

- **Branching**: Feature branches named `###-feature-name`
  (e.g., `001-firebase-domain-setup`). Merge to `main` via PR.
- **Specifications**: Feature specs live in `specs/###-feature-name/`.
  Use SpecKit commands (`/speckit.specify`, `/speckit.plan`,
  `/speckit.tasks`) for structured planning.
- **Commits**: Atomic commits with descriptive messages. Reference
  task IDs when applicable.
- **Code Review**: Changes to `lib/network/`, `lib/api/`,
  `lib/payment_gateways/`, and `lib/utils/common_base.dart` SHOULD
  receive review before merge due to high blast radius.
- **Firebase Configuration**: Changes to `firebase_options.dart`
  MUST be generated via `flutterfire configure`, not hand-edited.
- **Asset References**: Use `lib/generated/assets.dart` constants.
  Do not hardcode asset paths as strings.
- **Analysis**: Run `flutter analyze` before committing. Zero
  warnings is the target; new warnings MUST NOT be introduced.

## Governance

This constitution is the authoritative reference for development
decisions on the Espitalia Patient App. When a development practice
conflicts with a principle above, the principle takes precedence.

- **Amendments**: Any principle change MUST be documented with
  rationale, updated in this file, and reflected in dependent
  templates via the Sync Impact Report.
- **Versioning**: This constitution follows semantic versioning:
  - MAJOR: Principle removed or fundamentally redefined
  - MINOR: New principle added or existing principle materially
    expanded
  - PATCH: Wording clarifications, typo fixes, non-semantic edits
- **Compliance**: Features planned via SpecKit MUST include a
  Constitution Check in their plan.md confirming alignment with
  all applicable principles.
- **Runtime Guidance**: `CLAUDE.md` at the repository root provides
  runtime development guidance (commands, patterns, structure).
  It MUST NOT contradict this constitution.

**Version**: 1.0.0 | **Ratified**: 2026-03-02 | **Last Amended**: 2026-03-02
