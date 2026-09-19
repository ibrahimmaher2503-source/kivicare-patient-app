# Phase 0 Research — Nurse Request (Home Nursing) Module

This document resolves the technical decisions referenced in `plan.md` so the Phase 1 design can proceed unambiguously. There are no `NEEDS CLARIFICATION` items in the Technical Context — all values are concretely chosen below with rationale.

## R0 — Clarifications applied (from `/speckit.clarify` Session 2026-04-28)

The five clarifications recorded in `spec.md` are absorbed here as binding design constraints:

- **C1 — Self-only filing**: The form has no dependent picker. The POST payload carries no `patient_id` or `patient_for` field — patient identity is implicit on the bearer token. `NurseRequestFormPayload.toJson()` (the typed allow-list builder) MUST omit any such field even if added later.
- **C2 — Duplicate-submit safety**: The submit control is bound to `RxBool isSubmitting` and is disabled while `true`. On any non-2xx, non-422 outcome (timeout, dropped connection, 5xx without a parsed body), the form does NOT auto-retry. It surfaces a localized banner key (`unknownSubmitOutcomeBanner`) and routes to `NurseRequestListScreen` via `Get.off`. The form draft is preserved on the GetX controller while the patient verifies, so they can come back via the system back gesture and resubmit if no record was created.
- **C3 — Draft persistence**: All draft state lives in `TextEditingController`s and `Rx*` fields on `NurseRequestFormController`. The controller is registered with `Get.lazyPut(... fenix: false)` and is disposed when the form route is popped. Nothing is written to `GetStorage` or any disk store. A fresh app launch (process kill, OS termination) MUST present an empty form with no "resume draft" prompt.
- **C4 — Status filter persistence**: `NurseRequestListController` is registered with `Get.lazyPut(... permanent: false)`. Pushing a detail screen does not dispose the list controller, so the filter survives detail-back-to-list. Leaving the module entirely (`Get.until((r) => r.isFirst)` or `Get.offAll(...)`) tears it down, so the next entry from the dashboard resets to "All". No persistence APIs involved.
- **C5 — Time zone**: `preferred_date` is sent as `yyyy-MM-dd` and `preferred_time` as `HH:mm`, both interpreted by the backend as wall-clock in `Africa/Cairo`. The "today through +90 days" boundary is computed against the current Cairo date, not the device date. Implementation uses a fixed UTC+02:00 offset (Egypt does not observe DST) — see R5b. The detail screen renders both values without device-time-zone shifting.

## R1 — API endpoint paths (no `v1/` prefix)

- **Decision**: Use the un-prefixed paths `nurse-requests` (and `nurse-requests/{id}`) for the patient nurse-request endpoints. Use `governorates` and `cities` (with `?governorate_id=`) for the existing location reference endpoints.
- **Rationale**: Commit `173ae10` ("fix: correct v1 prefix mismatches for nurse-requests, ...") explicitly removed the `v1/` prefix from these constants on the parent branch. The Postman collection at the repo root (`postman_collection_full.json`) confirms the canonical paths are `/api/nurse-requests` and `/api/nurse-requests/{id}` (no v1).
- **Alternatives considered**:
  - `v1/nurse-requests` — rejected: was the buggy state before the prefix-fix commit; would re-introduce the bug.
  - `v1/home-healthcare-requests` — rejected: this is a different (and presumably newer or older) endpoint family in the same Postman collection and is not referenced by any spec or recent commit; using both would duplicate work and confuse the contract.

## R2 — Bilingual description payload shape

- **Decision**: Send both languages as two top-level keys in the JSON body when at least one is non-empty: `service_description_en` and `service_description_ar`. Empty strings (after trim) are omitted entirely from the payload (per FR-021).
- **Rationale**: The spec requires "two parallel fields" (FR-005) and the form must submit at least one (FR-007). Two named fields keep the wire format explicit and trivially mappable to backend columns. Omitting empties keeps the payload terse and lets the backend distinguish "patient typed nothing" from "patient typed an empty string after deletion" without tri-state booleans.
- **Alternatives considered**:
  - Single `service_description` string + a `language` flag — rejected: loses one of the two values when the patient writes both.
  - Nested `{en, ar}` object — rejected: more nesting for no payload size benefit; harder to flat-map to URL-encoded form bodies if the backend changes content type.

## R3 — Status enum and color mapping

- **Decision**: Status values are exactly: `pending`, `assigned`, `confirmed`, `in_progress`, `completed`, `cancelled` (FR-040). Localized labels go in `language_en.dart` and `language_ar.dart` under keys `nurseStatusPending`, `nurseStatusAssigned`, `nurseStatusConfirmed`, `nurseStatusInProgress`, `nurseStatusCompleted`, `nurseStatusCancelled`. Chip colors per FR-041:

| Status | Light-mode tint | Light-mode text | Dark-mode tint | Dark-mode text |
|--------|-----------------|-----------------|----------------|----------------|
| pending | amber 100 | amber 900 | amber 800 | amber 100 |
| assigned | indigo 100 | indigo 900 | indigo 800 | indigo 100 |
| confirmed | blue 100 | blue 900 | blue 800 | blue 100 |
| in_progress | purple 100 | purple 900 | purple 800 | purple 100 |
| completed | green 100 | green 900 | green 800 | green 100 |
| cancelled | red 100 | red 900 | red 800 | red 100 |

- **Rationale**: The six tints map to Material's standard 100/900 swatches, which already pass WCAG AA at the typical chip text size. Using the same hue family in both light and dark mode (just swapping intensities) keeps the visual association ("amber = waiting, green = done") stable for the patient regardless of theme.
- **Alternatives considered**:
  - Using project gradient tokens for chips — rejected: gradients render poorly inside small chip backgrounds and reduce text contrast.
  - Status-tint stored on the backend — rejected: spec FR-041 fixes this on the client, and backend-driven colors are over-engineering for a fixed enum of 6 values.

## R4 — Reference number formatting

- **Decision**: The reference number is server-minted (Assumption in spec) and the client only renders it. Format string: `NR-{year:0000}-{seq:0000}` (FR-049). The client treats it as opaque text for sorting; no parsing or validation.
- **Rationale**: Server-minting avoids client/server divergence, prevents collisions in the rare case of offline retry, and matches the existing patterns used by the booking module (`appointment_id` is also opaque on the client).
- **Alternatives considered**:
  - Client-generated UUID + display-only formatting — rejected: spec mandates a stable, year-scoped human-readable ID.

## R5b — Africa/Cairo wall-clock without `package:timezone`

- **Decision**: Compute `nowInCairo = DateTime.now().toUtc().add(const Duration(hours: 2))` for the today-boundary check (FR-008). Render the chosen `preferred_date` via `DateFormat.yMMMMd(localeCode).format(date)` from `intl`, which is locale-aware but treats the `DateTime` as a calendar date with no implicit time-zone shift. Send `DateFormat('yyyy-MM-dd').format(date)` on the wire.
- **Rationale**: Egypt currently does not observe daylight saving; the fixed +02:00 offset is correct year-round. Adding `package:timezone` solely to handle a non-DST country violates Constitution VII (Simplicity). If Egypt re-introduces DST, switch to `tz.getLocation('Africa/Cairo')` at that time — a localized change.
- **Alternatives considered**: `package:timezone` with `tz.getLocation('Africa/Cairo')` — rejected as overkill today. Device-local time — rejected by clarification C5.

## R5 — Bilingual input direction handling

- **Decision**: Wrap the English description in a `Directionality(textDirection: TextDirection.ltr, ...)` and the Arabic description in `Directionality(textDirection: TextDirection.rtl, ...)`, both inside the same parent that inherits the app's current direction. The cursor, alignment, and IME hints follow the wrapped direction (FR-006).
- **Rationale**: Flutter's `TextField` honors the nearest `Directionality` ancestor. Using two scoped wrappers gives each field its native writing direction without mutating the surrounding form's direction. This is the same approach used by the existing incident-management description component (per CLAUDE.md), so the convention is already in the codebase.
- **Alternatives considered**:
  - `textDirection:` parameter on `TextField` only — rejected: doesn't fully control hint and label direction in nested decorations.
  - Single auto-detect field — rejected: the spec requires two parallel fields (FR-005).

## R6 — Tap-to-call across platforms

- **Decision**: Use `url_launcher` with a `tel:<phone>` URI for both the contact phone and the assigned-nurse phone (FR-039). Wrap in `canLaunchUrl` and gracefully fall back to a "no dialer available" toast on the rare device that returns false (e.g., a tablet without a SIM).
- **Rationale**: `url_launcher` is already a transitive dependency through the existing payment gateways and is the standard Flutter idiom. The `tel:` scheme is supported by Android, iOS, and Chromium (which delegates to OS handler) — satisfying Constitution I (Platform Parity).
- **Alternatives considered**:
  - Native platform channel — rejected: introduces platform-specific code without any benefit.
  - `flutter_phone_direct_caller` — rejected: requires the call permission on Android, which is excessive for "open the dialer with number prefilled". `tel:` opens the dialer, which is what the spec asks for.

## R7 — Pluralization for the duration label

- **Decision**: Use `Intl.plural()` from the `intl` package, keyed off `duration` (integer hours), with `one`, `two`, `few`, `many`, `other` forms in Arabic and `one`/`other` forms in English. Localization keys: `nurseDurationHoursLabel(int n)` returning the formatted string.
- **Rationale**: Arabic has six plural categories per CLDR; the spec's FR-011 specifically requires "two-or-more" (the `two` and `few`/`many` cases) to render correctly. `intl` is already pulled in transitively for date formatting and is the only Dart-ecosystem option with full CLDR plural support.
- **Alternatives considered**:
  - Hand-rolled `if (n == 1)` / `else` — rejected: produces incorrect Arabic ("2 ساعة" instead of "ساعتان").
  - Skipping plurals — rejected: violates FR-011.

## R8 — Status filter UI

- **Decision**: Render the status filter as a single horizontally-scrollable chip row at the top of the list ("All", "Pending", "Assigned", "Confirmed", "In Progress", "Completed", "Cancelled"). Selecting a chip resets pagination to page 1 and re-fetches with `?status=<value>` (or no `status` for "All"). The currently-selected chip uses the gradient-secondary background; others use the surface tint.
- **Rationale**: Chip rows give all 7 options at a glance, work in RTL, and don't require extra screen real estate that a dropdown would. The pattern is already used in the booking and encounter modules for similar filters.
- **Alternatives considered**:
  - Dropdown / popover menu — rejected: extra tap to discover available filters.
  - Tabbed status filter — rejected: 7 tabs do not fit comfortably on a phone width and would require horizontal swipe gestures that conflict with the inner scroll.

## R9 — Pagination strategy

- **Decision**: Server-driven cursor-style pagination via `?page=N&per_page=15` (FR-027). Trigger next-page load when the scroll controller is within 200 px of the maximum extent and the current page is not the last page (server returns `last_page` or equivalent in the standard Laravel pagination meta). Maintain a single `RxList` of all loaded entries; on filter change or pull-to-refresh, clear and re-load from page 1.
- **Rationale**: Laravel's standard pagination response (`{ data: [], meta: { current_page, last_page, per_page, total }, links: { ... } }`) is what the rest of the patient app already consumes. Using the same pattern means the existing helpers in `network_utils.dart` and the `BaseResponseModel` apply directly.
- **Alternatives considered**:
  - Cursor-based pagination — rejected: backend exposes page-based pagination per existing usage; switching is unnecessary.
  - Manual "Load more" button — rejected: spec mandates infinite scroll (FR-028).

## R10 — Form draft persistence (decision: in-memory only)

- **Decision**: Per clarification C3, persist draft state in-memory on `NurseRequestFormController` for the lifetime of the form route — including across the verify-and-return roundtrip from C2. Do NOT write any draft to local storage. A fresh app launch (process kill / OS termination) presents an empty form with no resume prompt.
- **Rationale**: Matches C3 exactly. Avoids putting PII (address, phone, notes) on disk. The simplest implementation (Constitution VII): rely on Flutter's natural widget-tree retention through backgrounding, and let Get destroy the controller when the form route is popped.
- **Alternatives considered**:
  - GetStorage-backed draft — rejected by C3.
  - Save on `dispose` only — rejected by C3 and adds disk-PII risk.

## R11 — Governorate and city dependency

- **Decision**: Reuse the existing `governorates` and `cities` endpoint constants (already present in HEAD of `api_end_points.dart`). Build a fresh `governorate_city_picker` widget in `lib/screens/nurse_request/components/` because the previously-shared `lib/components/governorates_city_picker.dart` was deleted on the parent branch and may not be restored before this module ships. Keep the new widget self-contained but factor it back into a shared component later if/when other modules also need it.
- **Rationale**: Reusing the endpoint paths is mandatory (Constitution IV — single source of truth for endpoints). Building the picker locally avoids a dependency on parent-branch cleanup work landing first; if the shared component is restored, this can be replaced in a follow-up.
- **Alternatives considered**:
  - Wait for the shared component to land on the parent branch — rejected: blocks this feature on unrelated work.
  - Skip governorate/city dropdowns entirely — rejected: spec requires them with a graceful free-text fallback (FR-013/FR-014).

## R12 — Push-notification deep-linking

- **Decision**: A push notification with payload `{type: "nurse_request_status_changed", reference_number: "NR-2026-0042", request_id: 42}` is handled by the existing `lib/utils/push_notification_service.dart` background/foreground handler, which calls `Get.to(() => NurseRequestDetailScreen(requestId: 42))` when the patient taps the notification. No new push-handling code is required in this module — only a registration of the new payload type with the existing dispatcher.
- **Rationale**: The existing notification dispatcher is the single point of inbound push handling per Constitution IV, and CLAUDE.md confirms it lives in `lib/utils/push_notification_service.dart`. Adding a `case` for `nurse_request_status_changed` is the minimal change and keeps deep-link logic centralized.
- **Alternatives considered**:
  - Per-module push handler — rejected: duplicates the dispatcher and complicates upgrades.

## R13 — No payment surface in this module

- **Decision**: This module does NOT integrate with `lib/payment_gateways/`. The pricing card on the detail screen is purely informational, showing the amount the admin calculated and the current payment status. Payment, if required, is handled by a separate flow.
- **Rationale**: Spec assumption: "A payment surface is not part of this scope." Constitution VII mandates not adding speculative integrations.
- **Alternatives considered**:
  - Stub a "Pay Now" button — rejected: spec excludes payment from scope.

---

All Technical Context items have concrete decisions. No `NEEDS CLARIFICATION` items remain. Ready for Phase 1.
