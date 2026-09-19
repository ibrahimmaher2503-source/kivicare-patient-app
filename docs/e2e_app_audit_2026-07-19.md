# Espitalia Android End-to-End App Audit

**Audit date:** 2026-07-19  
**Repository snapshot:** branch `022-labs-radiology-booking`, commit `a106ed8`, plus the current dirty workspace  
**Production platform in scope:** Android only, as documented in `README.md:5-10`  
**Backend exercised:** `https://espitalia.net/api/`  
**Release recommendation:** **NO-GO**

## Remediation status (updated 2026-08-26)

Status legend: **DONE** means the repository fix is implemented and locally verified. **PARTIAL** means meaningful client-side work is complete but the release exit condition still needs backend, provider, or device evidence. **EXTERNAL ACTION REQUIRED** cannot be completed safely from this repository alone.

The original device audit evidence below remains dated 2026-07-19. The status updates in this section and the current verification results are local repository evidence from 2026-08-26; they do not establish production-backend, provider, Play delivery, or full device-matrix acceptance.

| Finding | Status | Applied result / remaining action |
|---|---|---|
| P0-01 Emergency overlay | **DONE** | Removed the root-level overlay injection; emergency calling remains contextual, bounded, directional, and single-labelled. |
| P0-02 Critical-operation idempotency | **PARTIAL** | Appointment, pharmacy, lab/radiology, and ICU creates now persist an opaque operation ID, send `Idempotency-Key`/`X-Request-ID`, retain it after ambiguous outcomes, and show verification UI. Laravel must enforce key replay and expose reconciliation lookups before this P0 is closed. |
| P0-03 Signing credentials in history | **EXTERNAL ACTION REQUIRED** | `android/key.properties` is deleted from the worktree, ignored, replaced by an example, and CI now scans history. Rotate/revoke the exposed key and purge Git history outside this patch. |
| P1-01 Unreachable online payments | **DONE** | Only server-safe cash/wallet methods render. Unsupported online methods remain fail-closed. |
| P1-02 Profile Midtrans failure | **DONE** | Historical profile failure was remediated locally: the disabled `midpay` plugin is removed and the profile build now passes. Release App Bundle builds also pass locally; provider/payment acceptance is not implied. |
| P1-03 Demo credentials/OTP | **PARTIAL** | Local release code no longer embeds or prefills demo email/password/OTP, and the security regression test passes. Backend invalidation of any previously distributed demo account/password remains an external gate. |
| P1-04 Shared filters | **DONE** | Corrected retry/pagination/search/reset/deselection, added independent generation guards, directional badges, and single controller ownership. |
| P1-05 Booking cascade | **DONE** | Parent changes synchronously reset descendants/pages/slots; stale request completions are ignored; regression tests cover cascade resets. |
| P1-06 Firebase identity | **EXTERNAL ACTION REQUIRED** | Regenerate configuration for the authoritative Firebase project, add OAuth clients/fingerprints, and align the backend service account. No IDs were invented locally. |
| P1-07 Push lifecycle/routes | **PARTIAL** | Local lifecycle and typed routing work is implemented: contextual permission, queued cold-start routing behind auth/router readiness, token refresh handling, logout unsubscribe, and fallback to Notifications. Live delivery and provider/Firebase acceptance remain unverified. |
| P1-08 Home-service cancellation | **PARTIAL** | Patient cancellation APIs/actions now exist for nursing and doctor home visits with reason, idempotency, expected-version/state guards, and fail-closed confirmation. The backend contract and device execution remain pending; no external endpoint was verified. |
| P1-09 Unsafe CinetPay | **DONE** | CinetPay is hidden, fail-closed, and its native package/unsafe client transaction code were removed. Re-enable only with server-created transactions and verified webhooks. |
| P1-10 Device E2E suite | **PARTIAL** | Added an executable `integration_test` suite; 4 local E2E tests pass. CI emulator/analyze/test/debug/profile/release-AAB gates are configured, but the broader sandbox-backed journey/device matrix is still required. |
| P2-01 Accessibility | **DONE** | Fixed audited names, duplicate semantics, selected states, 48 dp targets, search/filter/order actions, password visibility, and OTP error announcements. |
| P2-02 Contrast | **DONE** | Raised dark tertiary text luminance and darkened the teal gradient endpoint used behind white CTA text. |
| P2-03 Mixed localization | **PARTIAL** | Local filter labels and remaining audited literals are localized; API locale headers and localized-field selection are present. Backend English taxonomy responses and a device crawl still need validation. |
| P2-04 ICU orphan comma | **DONE** | Location parts are joined only when present; details show a localized unavailable state. |
| P2-05 RTL positioning | **DONE** | Audited badges/overlays now use directional positioning; equal physical padding remains symmetric by design. |
| P2-06 Controller ownership | **DONE** | Filter children use `Get.find`, the route owns disposal, and Pharmacy has one explicitly permanent app-level owner. |
| P2-07 App size | **PARTIAL** | Current local measurements are 43.7 MB for the arm64 `--analyze-size` App Bundle and 75.0 MB for the default release App Bundle. The historical APK evidence is retained below; final Play/device delivery acceptance and further reduction are not verified. |
| P3-01 Permission timing | **DONE** | Startup no longer requests notification permission; onboarding explains value and Settings provides an explicit retry path. |
| P3-02 Onboarding controls | **DONE** | Added localized Skip/Next/Finish, page semantics, selected state, tooltips, and 48 dp actions. |

### Verification after remediation

| Check | Result |
|---|---|
| `flutter analyze --no-pub` | **PASS** — 0 errors and only the 24 known `Radio.groupValue` / `Radio.onChanged` deprecation infos |
| `flutter test --no-pub --reporter expanded` | **PASS** — 82 passed, 7 legacy TODO tests skipped (current local rerun; the historical 67-pass result is retained in the original evidence below) |
| Audit regression tests | **PASS** — 12 passed |
| Focused analysis of all changed modules and `integration_test/` | **PASS** — no issues |
| `flutter build apk --profile --no-pub` | **PASS** — 137,710,653-byte APK |
| Local executable E2E suite | **PASS** — 4 tests passed locally; this is not production-backend or full device-matrix acceptance |
| Device integration suite (2026-07-19 audit) | **NOT RUN LOCALLY** — the only attached device was not assumed safe; CI is configured to use an isolated API 35 emulator |
| Release App Bundle (`arm64`, `--analyze-size`) | **PASS** — 43.7 MB local artifact |
| Default release App Bundle | **PASS** — 75.0 MB local artifact |

The release remains **NO-GO** until P0-02 backend idempotency/reconciliation and P0-03 signing-key rotation/history purge are completed. Firebase alignment (P1-06) and safe cancellation APIs (P1-08) remain external release actions.

## Executive summary

The release APK builds, installs, launches, survives a cold restart, loads the public dashboard, and supports Arabic/English plus light/dark theme switching. Public doctor, clinic, laboratory, radiology, pharmacy, and ICU entry flows were exercised on an Android 15 emulator. Guest protection consistently redirected protected actions to sign-in.

The app is not ready for production release. The audit found **22 actionable findings**:

| Severity | Count | Meaning |
|---|---:|---|
| P0 | 3 | Release blocker, security exposure, or risk of duplicate clinical/financial operations |
| P1 | 10 | Major feature, build, configuration, or reliability failure |
| P2 | 7 | Important accessibility, localization, data presentation, or maintainability defect |
| P3 | 2 | Product enhancement that should enter the near-term backlog |

The most urgent blockers are:

1. The global emergency button is mounted above the Navigator overlay. It causes a debug assertion on every screen and physically intercepts unrelated controls in release, opening the phone dialer when the user taps a clinic filter.
2. Appointment, pharmacy, lab/radiology, and ICU creation calls have no idempotency key or reliable unknown-outcome reconciliation. A timeout after server commit can lead to duplicate bookings, orders, or requests when the patient retries.
3. `android/key.properties` exists in Git history. Its current staged deletion does not revoke or remove previously committed signing credentials.
4. Ten online payment methods are displayed but are rejected before their gateway branches can run.
5. The profile APK cannot compile because the custom `midpay` plugin does not provide its Midtrans dependency to the profile variant.

## What was tested

### Environment

| Item | Value |
|---|---|
| Flutter | 3.41.9 stable |
| Dart | 3.11.5 |
| Device | Pixel 7-like Android emulator, Android API 35 |
| Viewport | 1080 x 2400 |
| App variants | Debug and release |
| Locales | Arabic RTL and English LTR |
| Themes | Light and dark |
| Emulator safety | Read-only AVD; a separately connected physical phone was not touched |

### Safety boundary and limitations

This was a non-destructive audit. No phone call was placed, even though the overlay defect opened the dialer. No appointment, ICU admission, nursing request, home visit, laboratory order, pharmacy order, upload, cancellation, account deletion, or payment was submitted.

The production configuration pre-filled a demo email, password, and OTP. The first login step advanced to OTP, but the pre-filled OTP did not complete authentication during the audit. Consequently:

- Guest and public journeys were device-tested.
- Sign-in, registration, forgot-password, validation, settings, locale, and theme shells were device-tested.
- Authenticated read/write journeys were traced through code and existing automated tests, but were not claimed as successful E2E executions.
- Push delivery, payment provider callbacks, maps, calendar sync, and real upload/download behavior require controlled test services or credentials and were not triggered against production.

### Evidence levels

| Label | Meaning |
|---|---|
| Device pass | Completed on the release APK against the live public API |
| Device partial | UI and safe actions completed, but mutation or authentication was intentionally stopped |
| Device fail | Reproduced runtime or interaction defect |
| Static verified | Defect is directly present in reachable code |
| Not verified | Requires a sandbox account, external provider, or backend mutation |

## Automated and build results

| Check | Result | Evidence |
|---|---|---|
| `flutter analyze --no-pub` | PASS | 0 errors, 0 warnings, 33 infos |
| Full `flutter test --no-pub --reporter expanded` | PASS WITH GAPS | Remediation rerun: 67 passed, 7 skipped |
| Debug APK build | PASS | 246,610,323 bytes; about 184 seconds |
| Profile APK build | **PASS AFTER REMEDIATION** | Disabled `midpay` removed; 137,710,653-byte profile APK produced |
| Release APK build | PASS | 100,138,755 bytes |
| Release signature check | PASS | APK Signature Scheme v2 verified with one signer |
| Release runtime | PASS WITH BLOCKERS | No fatal `AndroidRuntime` crash observed; interaction defects remain |
| Debug runtime | **FAIL** | `RawTooltip widgets require an Overlay` assertion covers the app |

Of the 33 analyzer infos, 24 are the known `Radio.groupValue` / `Radio.onChanged` deprecations in `payment_screen.dart`, which this audit did not count as regressions. The other 9 are style-only brace notices in `app_common.dart`.

The seven skipped tests are empty TODO shells in `test/integration/lab_test_browsing_test.dart:6-74`. The only general widget smoke test is the app scaffold shell in `test/widget_test.dart:10`.

## Journey coverage matrix

| Journey | Result | Notes |
|---|---|---|
| Install and cold launch | Device pass | Release APK installed and launched on Android 15 |
| Notification permission | Device pass | Android permission prompt appeared before app UI |
| Three-page onboarding | Device pass | All Next actions reached the welcome screen |
| Welcome and guest entry | Device pass | Explore entered the public dashboard |
| Guest dashboard | Device pass | Public configuration and dashboard data loaded |
| Cold restart and preference persistence | Device pass | English and dark mode survived force-stop/relaunch |
| Arabic RTL to English LTR | Device pass | Direction and framework strings changed immediately |
| Light to dark theme | Device pass | Main surfaces and navigation changed correctly |
| Sign-in shell | Device partial | Demo login advanced to OTP; OTP completion was blocked |
| Empty registration validation | Device pass | Required-field messages were displayed |
| Forgot-password shell | Device partial | Screen and email entry rendered; no email was sent |
| Doctor list and detail | Device pass | Public list, doctor detail, and protected Book action loaded |
| Clinic list | Device partial / fail | List loaded; filter tap opened the dialer due to emergency overlay |
| Appointment booking | Device partial | Guest gate passed; authenticated cascade/payment not submitted |
| Laboratory browsing | Device pass | Hub, facilities, facility detail, tests, and protected booking entry loaded |
| Radiology browsing | Device pass | Radiology tab and center listing loaded |
| Pharmacy | Device partial | Dashboard and empty state loaded; live catalog returned no products; upload was gated |
| ICU | Device partial / fail | Hospital list/detail loaded; overlay collision and orphan location comma reproduced |
| Home nursing | Device partial | Guest gate passed; authenticated form traced statically |
| Doctor home visit | Device partial | Guest gate passed; authenticated form traced statically |
| Appointment bottom tab | Device pass | Guest access redirected to sign-in |
| Settings | Device pass | Language, theme, About, Contact, and Sign In entries rendered |
| Profile, family members, encounters, incidents | Not verified | Requires authenticated sandbox data |
| Cart, checkout, orders, refunds, uploads | Not verified | Requires authenticated sandbox data and product fixtures |
| Push delivery and deep links | Static verified only | Routing defects described below; no real notification sent |
| Online payment providers | Static fail | Controller blocks every online gateway before invocation |

## Findings

### ✅ DONE — P0-01: Global emergency control breaks debug and intercepts unrelated release controls

**Evidence:** Device fail, debug and release. `lib/main.dart:159-172` adds `GlobalEmergencyCallButton` through `GetMaterialApp.builder`. `lib/components/global_emergency_call_button.dart:32-45` wraps a small FAB in `Tooltip`.

In debug, Flutter reports `No Overlay widget found. RawTooltip widgets require an Overlay` because the builder context is above the Navigator overlay. In release, the red error assertion is stripped, but the fixed control overlaps feature content:

- On the Arabic clinic list, the emergency button occupied approximately `[32,304]-[158,430]` while the filter occupied `[42,333]-[163,453]`.
- Tapping the visible clinic filter opened Android's dialer with emergency number `123`. No call was placed.
- The control also covers part of the language dropdown, the main Book Appointment CTA, and the ICU call action depending on direction and screen.
- Its semantics node is exposed as a button covering `[0,0]-[1080,2400]`, while the visible FAB is a separate unnamed node.

**Impact:** A core browsing/filter action can perform an unexpected emergency-call action. Every debug screen is effectively blocked, and TalkBack receives a full-screen, misleading emergency button.

**Recommendation:** Do not inject the control from above the Navigator. Mount one emergency action per app scaffold or insert it through a Navigator-owned `OverlayEntry`. Reserve layout space, respect safe areas and text direction, use a minimum 48 dp target, provide one semantic button, and add collision tests for every top-level route.

**Release exit condition:** No Flutter overlay assertion in debug; no geometric overlap at 320-600 dp widths, Arabic or English, 100-200% text scale; TalkBack exposes exactly one correctly bounded emergency action.

### 🟡 PARTIAL — P0-02: Critical create operations are not idempotent and do not reconcile unknown outcomes

**Evidence:** Static verified.

- Appointment creation: `lib/api/core_apis.dart:294-329`
- Pharmacy order creation: `lib/api/pharmacy_apis.dart:128-145`
- Lab/radiology order creation: `lib/api/labs_radiology_apis.dart:160-173`
- ICU admission creation: `lib/api/icu_apis.dart:57-76`
- ICU stores only a confirmed reference after success: `lib/screens/icu_admission/form/admission_request_form_controller.dart:131-143`
- ICU recovery remembers only that reference: `lib/screens/icu_admission/requests/icu_dashboard_controller.dart:14-20`

No client-generated idempotency key is sent for these operations. The nursing module has an explicit ambiguous-outcome policy, but the other clinical and commerce create flows do not.

**Impact:** If the server commits and the response is lost, a patient may retry and create duplicate appointments, clinical requests, orders, or charges.

**Recommendation:** Generate a durable operation ID before submission, send it as an idempotency key, persist a minimal pending operation record, and add a status lookup/reconciliation endpoint. Unknown outcomes must route to a verification state, never silently invite a blind retry.

**Release exit condition:** Automated timeout-after-commit tests prove that retrying each critical operation returns the original result and never creates a second record or charge.

### 🔴 EXTERNAL ACTION REQUIRED — P0-03: Android signing credentials were committed to Git history

**Evidence:** Static verified without reading or exposing any credential values. `git ls-tree -r HEAD -- android/key.properties` returns the file, and history traces it to initial commit `580d842`. The current workspace has a staged deletion, but historical objects remain.

**Impact:** Anyone with repository history may have obtained release-signing material. Deleting the file in a later commit does not revoke keys or erase history.

**Recommendation:** Rotate the upload/release credentials immediately, move secrets to protected CI variables or an external keystore, verify `.gitignore`, and purge the sensitive file from all reachable Git history. Follow Play App Signing recovery procedures if the exposed key is an upload key.

**Release exit condition:** New signing material is in use, the old key is revoked where possible, a repository-history scan is clean, and CI can build without a tracked `key.properties`.

### ✅ DONE — P1-01: All displayed online appointment payment methods are unreachable

**Evidence:** Static verified. `lib/screens/payment/payment_screen.dart:166-446` can render Stripe, Razorpay, PhonePe, PayStack, PayPal, FlutterWave, Airtel, Midtrans, Sadad, and CinetPay. `lib/screens/payment/payment_controller.dart:166-172` permits only cash and wallet, toasts `onlinePaymentUnavailable`, and returns before gateway branches at lines 174-195.

**Impact:** Patients can select an advertised online method but cannot pay with it. This creates a dead-end at the highest-value point of booking.

**Recommendation:** Either hide every unsupported method from configuration/UI or implement a server-created payment intent/session with verified server-side callbacks. Never restore client-authoritative payment confirmation.

**Release exit condition:** Every visible payment option completes in a sandbox and is confirmed server-side, or is not rendered.

### ✅ DONE — P1-02: Profile APK compilation fails in the custom Midtrans plugin

**Historical audit evidence (2026-07-19):** Build fail. `flutter build apk --profile --no-pub` produced 28 Java errors in `:midpay:compileProfileJavaWithJavac`, including unresolved `MidtransSDK`, `TransactionRequest`, and `TransactionFinishedCallback`. The app pinned `midpay` 1.1.7 from commit `a932637...` in `pubspec.yaml:92-95` and `pubspec.lock:1028-1036`.

The plugin supplies sandbox and production dependencies to debug/release variants but not the profile variant.

**Current local evidence (2026-08-26):** The disabled `midpay` plugin was removed and `flutter build apk --profile --no-pub` now passes. Release App Bundle builds also pass locally. No payment-provider or production acceptance is claimed.

**Impact:** Profile-mode performance testing and profiling are blocked, so performance regressions cannot be measured under realistic compilation settings.

**Recommendation:** Patch or replace the plugin so the Midtrans SDK is available to `profileImplementation`, then add debug/profile/release builds to CI.

**Release exit condition:** `flutter build apk --profile --no-pub` succeeds from a clean checkout.

### 🟡 PARTIAL — P1-03: Production configuration exposes hard-coded demo credentials and an ineffective demo OTP

**Historical audit evidence (2026-07-19):** Device and static verified. The live configuration enabled dummy credentials. `lib/utils/constants.dart:16-17` contained a demo email and password, and `lib/screens/auth/sign_in_sign_up/sign_in_controller.dart:43-53` pre-filled email, password, and a fixed OTP when that flag was enabled.

On the production API, tapping Sign In with the prefilled account advanced to OTP. Repeated Verify attempts with the prefilled OTP left the screen unchanged; no durable error state was exposed to automation.

**Current local evidence (2026-08-26):** The sign-in controller starts with empty email/password fields and no fixed OTP or dummy-credential prefill. The release-security regression test passes as part of the 82 passing tests. Backend invalidation of any previously distributed demo account/password and a production APK/repository secret scan remain acceptance gates and were not externally verified.

**Impact:** Production distributes reusable credentials and trains patients to accept pre-populated secrets. If the demo account can access records, confidentiality is at risk. Even if restricted, the broken demo OTP creates a misleading production login path.

**Recommendation:** Disable `is_dummy_credentials` in production, remove hard-coded secrets from release builds, invalidate the demo password/token, and keep test accounts in a separate sandbox tenant. Show persistent, accessible OTP failure text.

**Release exit condition:** Production sign-in starts empty; repository and APK scans contain no reusable account secret; sandbox-only test login succeeds through OTP with auditable fixtures.

### ✅ DONE — P1-04: Shared filters contain broken retry, pagination, search, reset, and deselection logic

**Evidence:** Static verified, with the release filter also blocked by P0-01.

- Category empty-state retry calls the service loader: `lib/screens/booking/filter/components/filter_service.dart:36-50`.
- Category pagination checks service loading, increments `servicePage`, then calls clinics: lines 115-117.
- Service and category loader methods accept `search` but do not pass it to their APIs: `lib/screens/booking/filter/filter_controller.dart:283-323`.
- Reset sets maximum price/rating to zero even though default ranges are 5000/5: lines 328-346. `activeFilterCount` treats those zero maxima as active at lines 105-112.
- Tapping an already selected service, clinic, or category clears only the temporary filter object, leaving the applied `selected...Data` stale: lines 414-468.

**Impact:** Retry can show the wrong dataset, infinite scroll can mutate the wrong pager, searches do nothing, reset can leave phantom badges, and deselected filters can still be applied.

**Recommendation:** Give each dataset a typed query state, independent pager/loading flag, generation token, and reset method. Pass normalized search terms into APIs, use canonical default ranges, and clear both temporary and applied selections.

**Release exit condition:** Unit/widget tests cover retry, search, pagination, reset, reselect/deselect, Arabic/English, and slow out-of-order responses for all four filter modules.

### ✅ DONE — P1-05: Appointment booking cascades can retain stale clinics, doctors, slots, and pages

**Evidence:** Static verified in `lib/screens/slots/booking_form_screen.dart`.

- Service search/select invokes list APIs without consistently resetting pages and dependent lists: lines 72-125 and 614-626.
- Clinic selection clears the selected doctor but does not consistently clear the doctor list, doctor page, or slots before fetching: lines 644-671.
- Doctor selection reloads both time slots and the doctor list: lines 676-701.
- One broad loading flag and no request-generation guard allow older responses to overwrite a newer selection.

**Impact:** Fast selection/search changes or delayed network responses can show a clinic, doctor, or time slot belonging to the previous choice, risking an incorrect appointment.

**Recommendation:** Model the cascade as service -> clinic -> doctor -> slot. On every parent change, synchronously clear all descendants and reset their pages. Attach a generation ID to each request and ignore stale completions.

**Release exit condition:** Controlled delayed-response tests prove that only the latest cascade state can populate the UI or be submitted.

### 🔴 EXTERNAL ACTION REQUIRED — P1-06: Firebase project identity conflicts with repository production guidance

**Evidence:** Static verified.

- Production guidance names `espitalia-d934b`: `AGENTS.md:12` and `AGENTS.md:256`.
- Android configuration uses `espitalia-d69b6`: `android/app/google-services.json:3-5` and `lib/firebase_options.dart:56-57`.
- `android/app/google-services.json:15-23` contains no OAuth clients.

**Impact:** Push tokens, analytics, Crashlytics, and backend notification credentials can target different Firebase projects. Google sign-in will fail if enabled without a valid Android OAuth client and fingerprints.

**Recommendation:** Declare one authoritative Firebase project per environment, regenerate Android options, register package/signing fingerprints, configure OAuth, and validate backend service-account alignment.

**Release exit condition:** A fresh install receives a targeted push, opens the correct route, reports Crashlytics to the intended project, and completes Google sign-in if that option is enabled.

### 🟡 PARTIAL — P1-07: Push initialization is early, token refresh is unhandled, and routing coverage is incomplete

**Historical audit evidence (2026-07-19):** Static verified.

- Firebase messaging setup runs before `runApp`: `lib/main.dart:46-52`.
- `getInitialMessage()` is processed immediately during setup: `lib/utils/push_notification_service.dart:159-178`, before a Navigator is guaranteed.
- Repository-wide search found no `FirebaseMessaging.instance.onTokenRefresh` subscription.
- Routing handles nursing, ICU, and a generic appointment ID only: `lib/utils/push_notification_service.dart:132-150`.

**Current local evidence (2026-08-26):** The client now queues cold-start notification navigation until auth/router readiness, handles token refresh, unsubscribes on logout, classifies the supported notification types through typed routes, and falls back to Notifications for unknown types. Local route/unit coverage passes. Targeted push delivery, Firebase project/provider credentials, and the complete foreground/background/terminated device matrix remain unverified.

**Impact:** Cold-start notification taps can navigate too early, refreshed device tokens can stop receiving notifications, and doctor visits, labs, pharmacy, incidents, and other modules can open the wrong or no destination.

**Recommendation:** Initialize transport early but queue navigation until the first frame and authenticated router readiness. Register token refresh, synchronize tokens after login/logout, and use a typed notification-route registry with authentication guards.

**Release exit condition:** Foreground, background, terminated, logged-out, and expired-token tests pass for every notification type.

### 🟡 PARTIAL — P1-08: Patient cancellation for home-service requests needs backend/device acceptance

**Historical audit evidence (2026-07-19):** Static verified. `lib/api/nurse_request_apis.dart:8-43` exposed create/list/detail only. `lib/api/doctor_visit_apis.dart:10-78` exposed submit/list/detail only. Both UI/model families rendered cancelled states and cancellation reasons, but exposed no patient cancellation action.

**Current local evidence (2026-08-26):** Patient cancellation code is now present for both request families. The client sends a cancellation reason with an idempotency key and expected version/timestamp, applies fail-closed state/confirmation handling, and exposes localized cancellation UI. The Laravel endpoint contract, authorization/state/fee behavior, and a device run against a controlled backend are still pending; no backend acceptance is claimed.

**Impact:** A patient can request a home service but cannot withdraw it in the app, increasing operational calls, dispatch confusion, and no-show risk.

**Recommendation:** Add backend-authorized cancellation endpoints with allowed-state rules, reason capture, confirmation, optimistic locking, notification updates, and clear fee disclosure.

**Release exit condition:** A patient can cancel an eligible request exactly once; ineligible/assigned/completed states explain why cancellation is unavailable.

### ✅ DONE — P1-09: CinetPay configuration is unsafe if online payments are re-enabled

**Evidence:** Static verified in `lib/payment_gateways/cinet_pay_services.dart:21-43`.

- Notification URL is plain HTTP and points to a placeholder domain.
- Transaction IDs use a small non-cryptographic `Random().nextInt(...)` space.
- Patient email is embedded in the payment description.

**Impact:** Callbacks can be lost or spoofed, IDs can collide, and patient-identifying data can leak into third-party transaction metadata. P1-01 currently makes this latent, but it becomes a release blocker as soon as CinetPay is enabled.

**Recommendation:** Create transactions server-side with cryptographically unique IDs, HTTPS callbacks on the real domain, signed webhook verification, minimal metadata, and server-authoritative settlement state.

**Release exit condition:** Provider sandbox tests verify callback authenticity, replay defense, unique transaction IDs, and absence of unnecessary PII.

### 🟡 PARTIAL — P1-10: Executable device E2E regression coverage remains incomplete

**Historical audit evidence (2026-07-19):** Static verified. There was no `integration_test/` package directory. All seven tests named as integration coverage in `test/integration/lab_test_browsing_test.dart:6-74` were skipped TODO shells. The full suite passed 61 tests, but it did not exercise a real Navigator, live routing, device permissions, or backend workflows.

**Current local evidence (2026-08-26):** An executable `integration_test/app_regression_test.dart` suite now exists and 4 E2E tests pass locally, covering route/semantics behavior, ambiguous-outcome verification, guest guarding, and locale/direction changes. This is local hermetic coverage, not proof of production backend behavior or the full device journey matrix.

**Impact:** The emergency overlay, filter-to-dialer collision, profile build failure, mixed-language production content, and unreachable payment methods all escaped automated coverage.

**Recommendation:** Add a hermetic integration suite with a fake/sandbox backend and stable fixtures. Cover launch, onboarding, auth, guest guards, booking cascade, payment selection, labs, pharmacy, ICU, nursing, locale/theme, notification routing, and accessibility semantics.

**Release exit condition:** CI runs analyzer, unit/widget tests, integration tests, and debug/profile/release builds for every release candidate.

### ✅ DONE — P2-01: Accessibility names, bounds, state, and grouping are inconsistent

**Evidence:** Device and static verified.

- The emergency semantic node covers the full screen, while its visible FAB is separate and unnamed.
- Walkthrough Next and page indicators were focusable/clickable with blank accessible names.
- Home cart and notification controls were blank `NAF` nodes. `_GreetingActionButton` uses a 42 x 42 `GestureDetector` with no `Semantics` or `Tooltip`: `lib/screens/home/components/greetings_component.dart:76-91` and `133-184`.
- Search, filter, and ordering controls were unnamed on doctor, clinic, labs, and ICU screens.
- Sign-in fields exposed placeholder/value text while Email and Password were separate nodes; the password visibility action had no accessible name.
- Bottom navigation announced duplicated names such as `Home\nHome`. `BtmNavItem` nests `Semantics(label)`, `Tooltip(message)`, and visible `Text` without excluding duplicate descendants: `lib/screens/dashboard/components/btm_nav_item.dart:27-121`.
- Lab/Radiology tabs did not expose selected state.
- Only 11 files in `lib/screens` and `lib/components` contain `Semantics`, compared with 54 containing `GestureDetector` and 42 containing `InkWell`.

**Impact:** TalkBack and switch-access users cannot reliably identify or operate core controls. Some announcements are duplicated or spatially misleading.

**Recommendation:** Define an accessibility contract for every interactive component: unique localized name, role, selected/checked state, 48 dp target, correct bounds, focus order, and error announcement. Use `excludeSemantics` where a parent provides the final label.

**Standard:** WCAG 2.2 1.3.1, 2.4.3, 2.5.3, 2.5.8, 3.3.1, and 4.1.2.

### ✅ DONE — P2-02: Some text/CTA color pairs fail WCAG contrast

**Evidence:** Static color calculation.

- `textTertiaryDark` `#7A8494` on `surfaceElevatedDark` `#1A2436` is about **4.12:1**, below 4.5:1 for normal 12 px bottom-navigation text. Tokens: `lib/utils/colors.dart:52,122`; usage: `lib/screens/dashboard/components/btm_nav_item.dart:100-105`.
- White on the light end of `gradientSecondaryEnd` `#13BAAA` is about **2.43:1**. White CTA text is used over this gradient in `lib/screens/pharmacy/utils/pharmacy_empty_state.dart:97-123` and `lib/screens/pharmacy/product_detail_screen.dart:369-405`.

**Impact:** Low-vision users can lose navigation and action labels, especially in dark mode or bright environments.

**Recommendation:** Darken the teal behind white text, use navy text on the light gradient region, or replace text gradients with a solid accessible action color. Raise dark tertiary text luminance.

**Standard:** WCAG 2.2 1.4.3.

### 🟡 PARTIAL — P2-03: English mode still presents Arabic clinical categories, and localization is incomplete

**Evidence:** Device and static verified. After switching to English and cold restarting, framework labels were English while Specialization and Category cards remained Arabic. The English dark-mode screenshot captures this mixed-language state. Several reachable areas also retain hard-coded labels such as payment method names and filter headings rather than consistently using `locale.value`.

**Impact:** English users receive a partially unreadable clinical taxonomy. Mixed language is especially risky when choosing a specialty or service.

**Recommendation:** Ensure the backend honors `global-localization: en`, define a clear fallback rule, and never silently fall back to Arabic inside an English screen. Move remaining literals into both language files and add response-localization contract tests.

**Release exit condition:** A scripted crawl finds no unexpected Arabic in English mode and no unexpected English in Arabic mode, excluding proper names and user-entered text.

### ✅ DONE — P2-04: ICU location formatting renders an orphan comma

**Evidence:** Device and static verified. Live ICU hospital cards and detail screens displayed `,` when both city and governorate were absent. The strings are built unconditionally in `lib/screens/icu_admission/components/hospital_card.dart:50-59` and `lib/screens/icu_admission/hospitals/hospital_detail_screen.dart:53-60`.

**Impact:** The UI looks broken and makes missing facility-location data harder to understand.

**Recommendation:** Join only non-empty location parts. If all parts are absent, hide the row or show a localized `Location unavailable` label.

### ✅ DONE — P2-05: Physical left/right positioning creates avoidable RTL collision risk

**Evidence:** Static verified. Examples include `Positioned(right: 0)` in `lib/screens/booking/filter/components/filter_service.dart:96-99` and the cart badge `Positioned(right: -5)` in `lib/screens/home/components/greetings_component.dart:164-167`. Repository scans found additional `EdgeInsets.only(left/right)` and `paddingOnly(left/right)` use in screen code.

**Impact:** Badges, overlays, and content order can mirror incorrectly or collide in Arabic. P0-01 demonstrates how fixed physical placement becomes a real interaction failure.

**Recommendation:** Use `PositionedDirectional`, `EdgeInsetsDirectional`, directional alignment, and golden tests for both directions.

### ✅ DONE — P2-06: Route-level controller ownership is broad and can preserve stale state

**Evidence:** Static verified. Screen code contains 85 `Get.put(...)` call sites, only 2 `Get.lazyPut(...)`, and no `Get.create(...)`. Multiple filter child components independently call `Get.put(FilterController())`, including `filter_screen.dart:21` and components such as `filter_service.dart:13`. `GreetingsComponent` resolves or creates a `PharmacyController` during widget construction at `lib/screens/home/components/greetings_component.dart:20-22`.

**Impact:** Controllers can outlive the route that owns their query, hold stale filters/list pages, or be recreated from widget build paths. This amplifies the booking/filter races above.

**Recommendation:** Define route bindings with explicit ownership, use `Get.find` in children, clear disposable route state on close, and reserve `fenix` only for intentionally recoverable services.

### 🟡 PARTIAL — P2-07: The universal release APK is large

**Historical audit evidence (2026-07-19):** Build result. `app-release.apk` was 100,138,755 bytes, about 95.5 MiB. The debug APK was about 235 MiB.

**Current local evidence (2026-08-26):** The arm64 release App Bundle analyzed locally is 43.7 MB, and the default release App Bundle is 75.0 MB. These are artifact measurements only; Play-delivered split size, install/update behavior, and external acceptance were not verified.

**Impact:** Large downloads increase install abandonment, update cost, storage pressure, and cold-install time, especially on constrained mobile networks.

**Recommendation:** Ship an Android App Bundle, run `flutter build appbundle --analyze-size`, inspect native/payment SDK contribution, remove unused platform assets/code, and apply ABI/resource splitting for non-Play distribution.

### ✅ DONE — P3-01: Notification permission is requested before value is explained

**Evidence:** Device and static verified. `PushNotificationService().setupFirebaseMessaging()` is awaited before `runApp` at `lib/main.dart:46-52`, and permission is requested during setup.

**Impact:** A first-launch system prompt without context can reduce opt-in and makes onboarding feel abrupt.

**Enhancement:** Explain appointment reminders and clinical status alerts during onboarding, then request permission from an explicit patient action. Preserve a settings path for users who decline.

### ✅ DONE — P3-02: Onboarding has no visible Skip action and its progress controls are not described

**Evidence:** Device verified. All three pages could be advanced, but no visible Skip action was offered. Page indicators and the Next control had blank automation/accessibility names.

**Impact:** Returning or confident users must traverse every page, while assistive-technology users receive little progress context.

**Enhancement:** Add a localized Skip action, announce `Page X of 3`, label Next/Finish, and make decorative dots non-focusable unless they are interactive.

## UI and UX quality score

This score follows the repository's product guidance: calm healthcare presentation, Arabic-first support, low cognitive load, accessibility, responsiveness, and consistent theming.

| Dimension | Score | Assessment |
|---|---:|---|
| Accessibility | 1/4 | Major naming, bounds, grouping, contrast, and selected-state gaps; one critical interaction collision |
| Performance | 2/4 | Public lists load and use caching/pagination, but profile profiling is blocked, APK is large, and async state lacks cancellation/generation guards |
| Responsive behavior | 2/4 | Pixel 7 layout is generally stable, but only one viewport was tested and fixed overlays/physical positioning create collisions |
| Theming | 3/4 | Light/dark and Arabic/English switching work and persist; several contrast and hard-coded color exceptions remain |
| Anti-patterns | 3/4 | Visual hierarchy is coherent and calm; repeated gradient/card treatments and generic medical imagery reduce distinctiveness but do not overwhelm the UI |
| **Total** | **11/20** | Visually credible foundation, not release-ready because interaction and accessibility correctness are insufficient |

## Positive findings

- Release cold launch, onboarding, guest entry, dashboard loading, and preference persistence worked without a fatal Android runtime crash.
- Arabic RTL and English LTR direction changed immediately, and dark mode remained usable across the tested home/settings paths.
- Guest guards consistently protected appointment, nursing, home visit, pharmacy upload, labs booking, and ICU admission entry actions.
- Public doctor, clinic, laboratory, radiology, and ICU data paths handled live responses and navigation.
- Registration required-field validation was visible and understandable.
- Analyzer has no errors or warnings, and all 61 enabled automated tests pass.
- Network diagnostics observed during debug used redacted request/response logging rather than dumping full bodies or authorization headers.
- Nursing request code has stronger privacy and unknown-outcome handling than the other mutation modules, including in-memory drafts and a verification banner.
- The README correctly limits production support to Android and does not advertise unconfigured web/desktop targets.

## Recommended remediation order

### Release gate 1: safety and security

1. Remove/re-architect the global emergency overlay and add interaction/semantics regression tests.
2. Rotate and purge signing credentials.
3. Add idempotency and unknown-outcome reconciliation to every clinical/order create operation.
4. Disable and invalidate production dummy credentials.

### Release gate 2: core journeys

1. Hide or safely implement online payment methods.
2. Repair `midpay` profile compilation and add all build variants to CI.
3. Repair filters and appointment cascade state/race behavior.
4. Reconcile Firebase projects and complete push token/deep-link handling.
5. Add patient cancellation for home nursing and home visits.

### Release gate 3: inclusive quality

1. Run a TalkBack pass and fix names, roles, bounds, focus order, selected state, and form error announcements.
2. Correct contrast tokens and white-on-light-teal CTAs.
3. Complete bilingual API/content behavior and replace physical positioning with directional equivalents.
4. Fix ICU location formatting and reduce bundle size.

## Required retest setup

Use a non-production backend tenant with disposable fixtures and a test user whose OTP is controlled by the test environment. Include products, wallet balance, appointments in every status, encounters, family members, incidents, lab/radiology reports, nursing/home-visit requests, ICU requests, and payment sandbox accounts.

Minimum release matrix:

- Oldest supported Android version and Android 15.
- Small phone width, Pixel-class phone, and large phone/tablet.
- Arabic RTL and English LTR.
- Light, dark, and system theme.
- 100%, 150%, and 200% text scale.
- TalkBack and keyboard/switch navigation.
- Online, slow network, offline, timeout-after-server-commit, and token-expiry conditions.
- Fresh install, upgrade install, logged-out, logged-in, and expired-session states.

Recommended CI commands after remediation:

```powershell
flutter analyze --no-pub
flutter test --no-pub --reporter expanded
flutter test integration_test --no-pub
flutter build apk --debug --no-pub
flutter build apk --profile --no-pub
flutter build appbundle --release --no-pub --analyze-size
```

## Visual evidence

- [Debug overlay failure](screenshots/e2e_audit_2026-07-19_home_ar.png)
- [Release walkthrough](screenshots/e2e_audit_2026-07-19_release_walkthrough.png)
- [Release ICU overlap and missing-location punctuation](screenshots/e2e_audit_2026-07-19_release_icu.png)
- [Arabic light settings with emergency control over the language selector](screenshots/e2e_audit_2026-07-19_settings.png)
- [English dark home with Arabic clinical categories and emergency CTA overlap](screenshots/e2e_audit_2026-07-19_home_dark_en.png)

## Final assessment

The app has a solid visual foundation and a meaningful amount of unit-level validation, but the tested build is **not safe to release**. The emergency overlay alone blocks normal interaction and debug verification. Signing-history exposure and non-idempotent clinical/financial creation flows add security and patient-safety risk. After the P0 and P1 items are resolved, the same journey matrix should be rerun against a sandbox account, followed by automated device coverage so these failures cannot return.
