# Phase 0 Research: Labs & Radiology Booking Module

**Feature**: 022-labs-radiology-booking
**Date**: 2026-04-29

This document resolves all NEEDS CLARIFICATION items and records decisions for ambiguous patterns.

---

## R-1: Booking creation endpoint — `POST /v1/test-orders` vs `POST /v1/facility-bookings`

**Question (from spec §5)**: The Laravel API exposes both `POST /v1/test-orders` and `POST /v1/facility-bookings`. Which is the canonical creation endpoint for the patient app?

**Decision**: Use **`POST /v1/test-orders`** as the primary creation endpoint.

**Rationale**:
- The spec (§5) documents the request body and full response shape for `/v1/test-orders` as the higher-level entity that wraps booking + test + status + report.
- `GET /v1/test-orders` is the canonical list for patient order history. Using a different POST and a different GET would force the client to reconcile two ID spaces (booking ID vs order ID) on every screen.
- Keeping creation and listing on the same resource (`test-orders`) eliminates that reconciliation. The success screen, order list, and order detail all key off `test_order.id`.

**Alternatives considered**:
- **`POST /v1/facility-bookings`**: Conceptually closer to "the slot reservation" but produces a `facility_booking.id` that does not match the `GET /v1/test-orders` list. Rejected to avoid two ID spaces.
- **Try `/v1/test-orders` first, fall back to `/v1/facility-bookings` on 404/422**: Adds latency on the most critical patient action and obscures the contract. Rejected.

**Action before Phase 4 (Booking Confirmation)**: Confirm with backend team that `POST /v1/test-orders` accepts the body documented in spec §5 and returns the full Test Order shape. If the backend rejects, switch to `/v1/facility-bookings` and update `BookingPayload.endpoint` accordingly. **Document the confirmation in plan.md before starting Phase 4.**

---

## R-2: Open downloaded PDF in default viewer

**Question**: How should the app open a downloaded report PDF in the device's default viewer? The spec mentions `OpenFilex.open(file.path)` but `open_filex` is not currently in `pubspec.yaml`.

**Decision**: Add **`open_filex: ^4.5.0`** as a new dependency.

**Rationale**:
- `open_filex` is the active fork of the discontinued `open_file` package, supports Android, iOS, and Web (no-op on Web — returns a clear status), is null-safe, MIT-licensed, and updated within the last 6 months (Constitution §Technology Stack Constraints).
- No existing package in the tree opens arbitrary file paths. `url_launcher` cannot reliably open `file://` URIs cross-platform.
- This is a single new dependency for a single concrete need (Constitution VII: simplicity — only add when the standard library or existing deps can't solve it).

**Alternatives considered**:
- **`url_launcher` with `Uri.file(path)`**: Inconsistent across Android versions (FileProvider is required on Android 7+ for content sharing) and unreliable for opening PDFs in third-party viewers. Rejected.
- **In-app PDF viewer (`flutter_pdfview` / `syncfusion_flutter_pdfviewer`)**: Adds significant package size and an in-app viewer surface that the spec does not require. Spec explicitly says "open in default viewer". Rejected.
- **Share sheet only (`share_plus`)**: Would force the patient through an extra "Save to Files" tap. Worse UX. Rejected.

**Platform handling**:
- **Android**: `open_filex` uses `FileProvider` automatically when the file is in app-private storage (`getApplicationDocumentsDirectory()`). Add the standard FileProvider manifest entry only if `open_filex`'s built-in provider is insufficient (verify during Phase 5).
- **iOS**: Files in `Documents/` are openable directly.
- **Web**: `open_filex.open` returns a "not supported" result; UI shows the disabled-with-message state per FR-022 / SC-005 graceful-degradation requirement.

---

## R-3: Web platform behavior for report download

**Question**: How does report download behave on Web given `path_provider`'s limitations and `open_filex`'s no-op?

**Decision**: On Web, **trigger a browser download** using a blob URL and **omit the "open in viewer" step**. The Download Report button is enabled, but its behavior is browser-native download (Save As) instead of in-app open.

**Rationale**:
- Constitution I (Platform Parity): a feature must work across all supported platforms or **degrade gracefully** — never crash. A web user clicking Download should still receive their file.
- The spec's Download flow (FR-021..023) is silent on Web specifics; the spec is mobile-first. Graceful browser download satisfies the user intent on Web without breaking the mobile flow.
- This branches only inside `ReportDownloadService` — UI does not need a separate Web code path.

**Implementation sketch** (encoded in `report_download_service.dart`):
```
if (kIsWeb) {
  // Fetch bytes, build a Blob, anchor.click() to trigger Save As.
} else {
  // Save to getApplicationDocumentsDirectory(), then open_filex.open(path).
}
```

**Alternatives considered**:
- **Hide the Download button on Web**: Violates Platform Parity intent more than necessary; the user's data is reachable, just slightly differently presented. Rejected.
- **Use `share_plus` on Web**: `share_plus` Web support is partial; browser download is more universal. Rejected.

---

## R-4: Slot conflict detection (HTTP status code)

**Question**: The spec describes a "slot conflict" edge case (FR-014). What HTTP status code or response shape signals it?

**Decision**: Treat **HTTP 409 Conflict** OR **HTTP 422** with a validation error keyed on `slot_id` as a slot-conflict signal. Default to 409.

**Rationale**:
- 409 Conflict is the conventional REST signal for resource state conflicts.
- 422 with field-level errors is also common in Laravel and the existing app already maps 422 to per-field errors via `handleResponse()`.
- Treating either signal as a slot conflict avoids a brittle dependency on the backend's exact choice.

**Action before Phase 4**: Confirm exact response shape with backend. Update `BookingConfirmationController.confirmBooking()` error mapping to match.

**App behavior on detection**:
1. Show dialog: `locale.value.slotConflictTitle` / `slotConflictBody`.
2. Pop confirmation screen back to slot selection.
3. Trigger `SlotSelectionController.loadSlots()` to refresh availability.

---

## R-5: HTTP client for binary download

**Question**: Should report download use the existing `http` package or add `dio`?

**Decision**: Use the existing **`http`** package via `http.Client.send()` for streaming.

**Rationale**:
- Constitution VII: do not add packages when an existing dependency suffices. `http` is already in `pubspec.yaml` (`^1.4.0`).
- A signed URL or authenticated GET returning a PDF stream is well-supported by `http.Client.send()` + `response.stream.toBytes()`.
- The expected file size (a single diagnostic report) is under a few MB; full-buffer download is acceptable. We do not need `dio`'s progress callbacks for this MVP (acceptable per Constitution VII).
- The endpoint may return a signed URL JSON instead of raw bytes — `ReportDownloadService` handles both: if `Content-Type: application/json`, parse `report_url` and re-fetch; if `application/pdf`, write directly.

**Alternatives considered**:
- **`dio`**: Better for download progress and cancellation. Not justified for v1 (Constitution VII). Reconsider if download progress UX becomes required.

---

## R-6: GetStorage TTL for cached test categories

**Question**: How is the "7-day TTL" implemented?

**Decision**: Store an envelope `{cachedAt: <iso8601>, data: [...]}` under key `labs_radiology.test_categories`. On read, parse `cachedAt` and treat as stale if `now - cachedAt > 7d`. On stale, fall through to network and overwrite.

**Rationale**:
- GetStorage has no native TTL.
- A simple envelope is one of the established patterns elsewhere in the codebase (used in similar caches).
- Cache is read-through, write-on-success. On network failure with stale cache present, we still serve stale data and surface a non-blocking warning chip on the categories screen.

---

## R-7: Reuse of existing Location Filter

**Question**: How is the existing Location Filter (governorate/city) integrated?

**Decision**: Reuse `lib/screens/booking/filter/components/filter_location_component.dart` (per CLAUDE.md) opened from a `LocationFilterChip` on the hub. The chip displays the current selection or "All Locations" and accepts callbacks `(governorateId, cityId)` to feed back into `LabsRadiologyHubController.onLocationFilterChanged()`.

**Rationale**:
- Constitution VII (Simplicity) and the spec's explicit reuse mandate.
- No code duplication; the hub controller exposes `Rxn<int> selectedGovernorateId` and `Rxn<int> selectedCityId` that mirror the existing `FilterController` API surface.

**Note**: If `FilterLocationComponent` requires a parent `FilterController` instance, wrap usage in a lightweight adapter (transient `FilterController` registered with `Get.lazyPut`) that the hub disposes when leaving the route.

---

## R-8: Calendar strip RTL behavior

**Question**: How does the horizontal calendar strip behave in Arabic (RTL)?

**Decision**: Use a `ListView.builder(scrollDirection: Axis.horizontal)` inside a `Directionality` widget that **inherits from the locale**. Date items render with weekday-short / day-number / month layout per spec §11. Selection state (`Rxn<DateTime> selectedDate`) is locale-independent.

**Rationale**:
- Flutter's default `Directionality` flips horizontal scroll direction automatically when the inherited direction is RTL — the user scrolls right-to-left as expected for Arabic.
- Date numerals render via `intl`'s `DateFormat` with the locale, producing Arabic-Indic digits when `locale.languageCode == 'ar'` (verify; otherwise force `DateFormat('EEE, d MMM', languageCode)`).

**Alternatives considered**:
- **Force LTR for the calendar strip regardless of locale**: Inconsistent with the rest of the app. Rejected.

---

## R-9: Hub tab persistence (last-selected facility type)

**Question**: Should the hub remember the last-selected tab between sessions?

**Decision**: **Yes** — persist `lastFacilityType` (`lab` | `radiology`) in GetStorage. Default to `lab` on first launch.

**Rationale**:
- Spec §9 lists this as Optional but recommended. It is a 4-line change with measurable UX value (return-to-domain).
- Constitution VII still satisfied: this is one key, no abstraction.

---

## R-10: Order list optimistic refresh after booking/cancel

**Question**: How does `TestOrdersListController` get refreshed after a successful booking submit or cancel?

**Decision**: Check `Get.isRegistered<TestOrdersListController>()`. If true, call its `refresh()`. If false, do nothing — the list will fetch fresh data the next time it opens.

**Rationale**:
- Avoids a hard dependency: if the user has never opened the orders list, the controller is not registered and we skip the refresh.
- Trivial to implement; matches existing patterns elsewhere in the codebase.

---

## Summary of resolved items

| ID | Topic | Decision |
|---|---|---|
| R-1 | Booking POST endpoint | `POST /v1/test-orders` (confirm with backend before Phase 4) |
| R-2 | Open PDF in viewer | Add `open_filex: ^4.5.0` |
| R-3 | Web report download | Browser-native download via blob; no in-app viewer |
| R-4 | Slot conflict signal | HTTP 409 OR 422 keyed on `slot_id` |
| R-5 | Binary download client | Existing `http` package, `http.Client.send()` |
| R-6 | Categories cache TTL | Envelope `{cachedAt, data}`, 7-day stale check |
| R-7 | Location filter reuse | Existing `FilterLocationComponent` + lightweight adapter if needed |
| R-8 | Calendar strip RTL | Inherit `Directionality` from locale; `intl` for date formatting |
| R-9 | Last tab persistence | GetStorage `lastFacilityType`, default `lab` |
| R-10 | Optimistic refresh | `Get.isRegistered<TestOrdersListController>()` guard |

**Outstanding items**: R-1 and R-4 require a backend confirmation before Phase 4. They do not block Phases 1–3.
