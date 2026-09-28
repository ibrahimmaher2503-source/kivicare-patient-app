# Flutter Project Audit Remediation

Date: 2026-07-18

This document records the implementation outcome for
`FLUTTER_PROJECT_AUDIT.md`.

## Implemented in the Flutter repository

- A01–A24: repaired response awaiting and validation, booking/payment guards,
  multipart sequencing, Cairo timezone/DST handling, Maps configuration hooks,
  notification parsing, HTTP timeouts/errors, dashboard/controller state,
  ICU details and hospital selection, location failure paths, calendar
  timezone/success handling, safe date parsing, URI query encoding, search
  sequencing, backend-driven specialties, gallery controller ownership, and
  walkthrough completion persistence.
- B01–B08: blocking loaders, safe-area/scroll handling, responsive ICU and
  pharmacy rows, accessible typography/contrast, semantic 48-pixel filter
  controls, locale-aware date/currency/copy handling, safe directional image
  alignment and semantics, and bundled Plus Jakarta Sans/Outfit fonts.
- C01–C06: disposed owned controllers/focus nodes/streams, removed controllers
  created during reactive builds, reduced avoidable reactive allocations,
  deduplicated startup requests, changed file uploads to bounded path-based
  handling, and removed nested finite timeline lists.
- D01, D03–D08, D10: secret-bearing payment configuration is ignored and
  direct client payment execution is fail-closed; sessions use secure storage;
  passwords are never persisted; social login sends an ID token; release
  transport logs are disabled/redacted; notification visibility is private;
  exact legacy location values are deleted; dependencies are version/commit
  pinned; and logout clears Firebase plus provider sessions.
- E01–E04, E07–E08: Android is documented as the configured production target;
  unsafe manual controller deletion and global payment state were removed;
  Espitalia branding was normalized; local/generated/signing files are ignored
  and removed from Git tracking; stale asset references were removed; and all
  filter callers now use `FilterParams`, including governorate/city filters.
- E06: analyzer severity was strengthened and regression tests were added for
  Cairo DST, response parsing, typed filters, and empty/non-JSON responses.

## External release gates

These actions cannot be completed safely from source code without production
credentials or backend/organization access:

1. Laravel must create and verify all online-payment sessions and webhooks.
   Until those endpoints exist, the Flutter client exposes only cash and wallet
   and rejects direct online gateway execution.
2. Laravel must verify the Firebase/provider ID token's signature, issuer,
   audience, expiry, nonce, and provider subject.
3. Rotate the Android signing keystore and passwords, remove the old secret from
   Git history, and inject the replacement through CI.
4. Supply restricted production `GOOGLE_MAPS_API_KEY` values. Android accepts
   the Gradle property or environment variable; iOS accepts the build setting.
5. Generate the real iOS Firebase configuration for
   `com.espitalia.patient`, configure OAuth clients, and then restore
   `ios/Runner/GoogleService-Info.plist`. iOS Firebase remains intentionally
   disabled until that file is supplied.
6. Provide verified Espitalia support email, help-line, emergency hotline, Play
   Store URL, and App Store URL. Placeholder contact actions are disabled.
7. E05's full ARB/`gen_l10n` conversion and large-file architectural split is a
   migration project, not a safe mechanical patch. New code should use the
   smaller typed utilities introduced by this remediation while that migration
   is planned.

## Verification

- `flutter pub get`: passed.
- `flutter analyze --no-pub lib test`: no errors or warnings; only the
  pre-existing payment `Radio` API deprecation notices remain.
- `flutter test --no-pub`: 32 passed; the seven pre-existing empty lab
  integration placeholders remain skipped.
- `flutter build apk --debug --no-pub`: passed and produced
  `build/app/outputs/flutter-apk/app-debug.apk`.
