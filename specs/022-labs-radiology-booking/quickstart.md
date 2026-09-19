# Quickstart — Manual Smoke Test

End-to-end manual walkthrough used to validate the module after each implementation phase. Mirrors the user stories in `spec.md` and the acceptance criteria in `spec.md §SC-*`.

## Prerequisites

- Flutter 3.0+ installed and `flutter doctor` clean
- Logged-in patient account with valid token (real or test backend)
- Android emulator (primary) **or** physical device, plus optionally an iOS simulator and Chrome
- Test data exists in the backend: at least 2 labs, 1 radiology center, 1 test category with ≥3 tests, 1 facility with available slots in the next 7 days, 1 completed order with `report_url` populated, 1 pending or confirmed order

## Build & run

```bash
flutter pub get
flutter run                  # Android (primary)
# Optional secondary platforms (Constitution I):
# flutter run -d <ios-sim-id>
# flutter run -d chrome
```

## Walk the flow

### 1. Discovery (US1, US3)

1. Open app → log in → reach Dashboard.
2. **Verify**: a "Labs & Radiology" tile is present.
3. Tap it → `LabsRadiologyHubScreen` opens.
4. **Verify**: Labs tab is active by default (or last-selected per R-9), facility list paginates as you scroll, and a "Browse Test Categories" / "All Tests" / "My Test Orders" quick-action row is visible.
5. Tap "Radiology" tab → list reloads with radiology centers.
6. Type "Cairo" in the search bar → list debounces (~400ms) then filters server-side.
7. Tap the location filter chip → governorate/city picker opens (existing module). Pick a governorate → list reloads.
8. Tap "Browse Test Categories" → grid loads (verify shimmer on first load, instant on revisit if within 7 days — R-6).
9. Tap a category → tests list opens.
10. Type "CBC" in the tests search → debounced server search updates list.
11. Tap a test → bottom sheet shows description, prep instructions, turnaround, price, "Book Test" CTA.

### 2. Booking — facility-first path (US1)

1. Back to hub → tap a lab card.
2. **Verify** facility detail shows: hero header, rating + reviews, services chips, top-5 tests with price pills, address card, contact row, sticky "Book Appointment" button.
3. Tap "Book this test" on one of the tests → slot selection opens with that test pre-selected.
4. **Verify** calendar strip shows next 14 days, today is highlighted, first available date is pre-selected.
5. Tap a date → slot grid updates. Available slots are tappable; unavailable slots are dimmed and not tappable.
6. Tap an available slot → it becomes filled-gradient. "Continue" enables.
7. Tap "Continue" → booking confirmation opens with summary, optional notes, price summary, sticky "Confirm Booking".
8. Type a few characters in patient notes → counter updates, max 1000.
9. Tap "Confirm Booking" → success screen appears with reference number `TO-YYYY-NNNN`.
10. Tap the reference number → "Reference copied" toast appears (paste into another app to verify).
11. Tap "View Order" → order detail opens.

### 3. Order tracking (US2)

1. From order detail, **verify**: status timeline renders correctly for the current status (e.g., Pending → Confirmed → Sample Collected → In Progress → Completed). For radiology, "Sample Collected" step is hidden.
2. **Verify** test info card, facility info card (with tap-to-call and open-in-maps), slot info, patient notes, price, payment status chip.
3. Pull-to-refresh → status updates if backend changed it.
4. Back to "My Test Orders" → list shows newest first.
5. Apply status filter "Pending" → list filters.
6. Tap a Pending order → "Cancel Order" button is visible.
7. Tap "Cancel Order" → confirmation dialog with optional reason field.
8. Type a reason → tap "Cancel Order" → status updates to Cancelled, banner shows reason.
9. Reopen a Completed order with a report → tap "Download Report".
10. **Verify** PDF saves to device storage and opens in default viewer.
11. **Verify** for a Completed order without a report, the Download button is hidden or shows "Report not ready" toast.

### 4. Edge cases (acceptance scenarios in spec)

- **Slot conflict**: Two devices simultaneously book the last slot. The losing device sees the slot-conflict dialog, refreshed slot grid, no duplicate order created (FR-014).
- **Lab without a test**: On a lab facility, try to confirm without selecting a test → submission blocked with clear error (FR-010).
- **Radiology without a test**: On a radiology center, confirm without a test → succeeds.
- **Network failure on confirm**: Toggle airplane mode just before tapping Confirm → user-friendly error with retry; no duplicate order on subsequent retry.
- **Network failure on download**: Toggle airplane mode mid-download → toast with retry button; no partial file left in `getApplicationDocumentsDirectory()`.
- **Permission denied (Android 13+)**: Revoke storage permission for the app → tap Download → explanation dialog with "Open Settings" link.
- **Token expiry**: Wait until token expires (or simulate) → next API call seamlessly refreshes via `reGenerateToken()`; the user is not bounced to login mid-flow (FR-028).

### 5. Localization & dark mode (FR-024, FR-025, SC-005)

1. In Settings, switch to Arabic.
2. Reopen the module → verify all 8 screens translate, layout flips RTL.
3. **Verify** calendar strip scrolls right-to-left in Arabic.
4. **Verify** slot times render in Arabic locale.
5. Switch dark mode on.
6. **Verify** all status chips, slot states (available/selected/unavailable), gradient buttons, and cards keep adequate contrast.

### 6. Web platform (Constitution I — graceful degradation)

1. `flutter run -d chrome`.
2. Walk through hub → facility detail → slot selection → confirm.
3. **Verify** report download triggers a browser download (Save As) instead of opening in viewer.
4. **Verify** no JS console errors and the UI behaves identically to mobile within the Web limitations.

## Static analysis gate

After each phase:

```bash
flutter analyze
```

**Required**: zero new warnings (Constitution §Development Workflow, SC-007). Pre-existing warnings noted in CLAUDE.md (Radio deprecation in payment_screen.dart, AppBarTheme color) are unchanged.

## Unit tests gate

```bash
flutter test test/screens/labs_radiology/
```

Required tests (per plan.md):

- `booking_payload_test.dart` — confirms forbidden fields are never serialised; required fields present; `validate()` returns expected codes.
- `test_order_status_test.dart` — `isCancellable`, `isTerminal`, `fromString`, `apiValue` round-trip.
- `slots_response_test.dart` — `slotsFor(date)` returns correct list for a known fixture; empty list for missing dates.
- `test_order_model_test.dart` — `canCancel`, `hasReport` reflect the underlying state.

## Done criteria

- All sections above pass on Android.
- At least the dashboard entry, hub, slot selection, and confirmation flow pass on iOS or Web (Platform Parity).
- Zero new `flutter analyze` warnings.
- All required unit tests pass.
- Localisation keys verified in both `language_en.dart` and `language_ar.dart`.
- No call site references `/v1/admin/facility-bookings/*` (`grep -r "v1/admin/facility-bookings" lib/` returns nothing).
