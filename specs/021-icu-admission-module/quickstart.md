# Quickstart: ICU Admission Module

**Phase**: 1 — Design
**Branch**: `021-icu-admission-module`
**Date**: 2026-04-29

This guide walks a developer through running the ICU module end-to-end on a local device, plus the manual checks needed before declaring a story complete.

---

## 1. Prerequisites

- Flutter SDK 3.0.0+ on the `stable` channel.
- A logged-in user account against the staging backend (`https://espitalia.net/api/`).
- An Android emulator OR connected device (primary), and access to either iOS Simulator or Chrome for the platform-parity check (Constitution I).
- The backend has the ICU endpoints from `contracts/icu-api.md` deployed and seeded with at least:
  - 3+ hospitals across 2+ governorates,
  - 4+ ICU department types attached across those hospitals,
  - 1 hospital with `available_beds: 0` everywhere (for the empty-state edge case),
  - 1 hospital with `latitude/longitude` populated and 1 without.

If no staging backend is available, mock responses can be wired in by overriding `buildHttpResponse` in test mode (out of scope for the patient-facing build).

---

## 2. Configuration

1. In `lib/configs.dart`, ensure the new constant is present:

   ```dart
   const EMERGENCY_HOTLINE = '+20XXXXXXXXXX'; // production hotline
   ```

   For local dev, point at your own number to verify the dialer launches.

2. In `lib/utils/constants.dart`, ensure the storage key is present:

   ```dart
   const String lastIcuRequestReferenceKey = 'lastIcuRequestReference';
   ```

3. In `lib/utils/api_end_points.dart`, the 10 new endpoints from `contracts/icu-api.md` §1 must be declared.

4. Verify the new locale keys resolve:
   ```bash
   flutter analyze
   ```
   Any `language_en.dart` key missing from `language_ar.dart` (or vice versa) surfaces as an analyzer error because both implement the same abstract `BaseLanguage`.

---

## 3. Running the App

```bash
flutter pub get
flutter run                 # Android (default)
# or
flutter run -d chrome       # Web
flutter run -d ios          # iOS (macOS only)
```

The ICU dashboard is reached from the main app dashboard's ICU tile (added separately as part of dashboard wiring, not in this module's surface).

---

## 4. Smoke Test — User Story 1 (P1) — Submit Request

1. Open ICU dashboard → tap "Browse Hospitals".
2. Pick any hospital → tap **Request ICU Admission Here**.
3. Confirm the hospital field is **pre-filled and visually locked** (FR-017).
4. Pick an ICU department from the cascading picker (FR-016 — switch hospitals once and confirm the department resets).
5. Fill required fields: patient name, age, gender, diagnosis, urgency, accompanying name + phone.
6. Switch urgency to **Critical** → verify the non-blocking emergency-hotline alert appears (FR-015).
7. Tap **Submit**.
   - Expected: success screen with reference number `ICU-YYYY-NNNN` (FR-020).
   - Expected: tapping the reference copies it to the clipboard with a toast (FR-021).
8. Force-close the app; reopen → the success screen surfaces a "Last reference: ICU-YYYY-NNNN" affordance fed by `GetStorage` (FR-022, SC-004).

---

## 5. Smoke Test — User Story 2 (P1) — Browse / Search / Filter

1. ICU dashboard → "Browse Hospitals".
2. Type a partial hospital name → list filters within ~1 s (FR-001).
3. Open the filter sheet → pick a governorate → verify the city dropdown resets and only shows that governorate's cities (existing reuse).
4. Apply ICU department-type filter → verify only matching hospitals appear (FR-003).
5. Apply "available beds only" toggle → verify zero-bed hospitals disappear (FR-004).
6. Scroll to bottom → next page loads without manual action (FR-005).
7. Pull to refresh → list re-fetches (FR-006).
8. Open hospital detail → tap **Call Emergency** → device dialer opens with the emergency number (FR-008, FR-033).
9. On Web (Chrome), tap the same button → expect "Number copied to clipboard" toast (research.md §6 platform fallback).

---

## 6. Smoke Test — User Story 3 (P2) — Track / Cancel

1. ICU dashboard → "My Admission Requests".
2. List loads newest-first with status chip + urgency badge + hospital + patient name + preferred date (FR-024).
3. Apply each status filter; verify the list narrows correctly (FR-025).
4. Open a `Pending` request → verify "Cancel Request" button is visible (FR-030).
5. Open an `Admitted` request → verify the assignment card shows room/bed/admitted date AND no cancel button (FR-027, FR-005-equivalent for the negative).
6. Open a `Discharged` request → verify discharge info appears and timeline shows all transitions (FR-026, FR-028).
7. Open a `Rejected` or `Cancelled` request → verify the highlighted reason banner (FR-029).
8. Cancel a `Pending` request:
   - Tap Cancel → confirmation dialog with optional reason field (max 500 chars, FR-031).
   - Confirm → list reflects new `Cancelled` status; detail timeline gains the `Cancelled` step.

---

## 7. Smoke Test — User Story 4 (P3) — Browse Departments

1. ICU dashboard → "Browse ICU Departments".
2. Each card shows icon + name + description (FR-007's department side).
3. Tap a card → opens the hospital list pre-filtered to hospitals offering that department type (Acceptance Scenario 4.2).

---

## 8. Cross-Cutting Verification

These checks apply to every story and must all pass before the module is considered complete.

| Check | How |
|-------|-----|
| **Constitution I — Platform parity** | Repeat §4–§7 on Android plus iOS-or-Web. Confirm no platform-only crash and that `tel:` falls back to clipboard on web. |
| **Constitution V — Localisation** | Switch locale to Arabic in app settings → confirm all ICU strings are translated and layout flips RTL (SC-009, FR-035). Then switch back to English. |
| **Dark mode** | Toggle dark mode → re-walk a sample of screens (dashboard, hospital list, hospital detail, form, success, request list, request detail). Confirm no white-on-white or invisible-text regressions (FR-036). |
| **Static analysis** | `flutter analyze` reports **zero new warnings** vs the baseline before this branch (SC-010). |
| **Push notification deep link** | With a test FCM payload of `{ "type": "icu_admission_status_changed", "request_id": <id> }`, foreground-tap the notification → app navigates directly to the request detail screen for that id (research.md §3). |
| **Reference recovery** | Submit a request, force-close the app within 2 seconds, re-open → reference is retrievable from `GetStorage` and surfaced on the success affordance within 5 s (SC-004). |
| **Cancel within 3 taps** | From the request list, cancel a `Pending` request: list → detail → cancel + confirm = 3 taps (SC-008). |

---

## 9. Demo Seed Data Suggestion (backend side)

```text
Hospital A (Cairo)         — Cardiac ICU (4 beds), General ICU (10 beds), emergency phone set
Hospital B (Giza)          — Neonatal ICU (2 beds), General ICU (0 beds), no coordinates
Hospital C (Alexandria)    — Surgical ICU (0 beds across all depts) — for "no beds" case

Existing requests for the demo user:
  ICU-2026-0001 — Pending     (cancellable)
  ICU-2026-0002 — Under Review (cancellable)
  ICU-2026-0003 — Approved    (not cancellable)
  ICU-2026-0004 — Admitted    (room ICU-3B / bed 12, admitted 2026-04-25)
  ICU-2026-0005 — Discharged  (discharged 2026-04-20, summary present)
  ICU-2026-0006 — Rejected    (with reason)
  ICU-2026-0007 — Cancelled   (with reason)
```

This covers every status branch in the timeline and every conditional UI element from FR-026..029.

---

## 10. Definition of Done (per User Story)

A user story is "done" when:

1. The story's Acceptance Scenarios from `spec.md` are all reproducible against the running app.
2. The relevant cross-cutting checks in §8 pass.
3. New strings exist in **both** language files.
4. `flutter analyze` is clean (no new warnings).
5. The recommended widget tests for that story (per `plan.md` §Project Structure → `test/`) exist and pass.
