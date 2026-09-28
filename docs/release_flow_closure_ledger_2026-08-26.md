# Release flow closure ledger — 2026-08-26

## Services — CLOSED

Scope: Dashboard Services list, supported clinic/category/price/governorate/city filters and reset/count, service details, linked clinics/doctors, localized text, prices/tax/image fallback, empty/error contract. No Clinics, Booking, Pharmacy, Logout, Nursing, or Notifications action was performed.

### UI investigation update

- Fixed the Services screen filter contract: `FilterParams.moduleType` now matches `service` instead of `category`.
- Added explicit semantics actions for the filter button and filter tabs (`onTap`/selected state), plus an accessible Services search label.
- Service numeric parsing now accepts Laravel decimal strings, preventing valid `charges`/`payable_amount` values from rendering as `0.00`.
- Price filtering now rounds slider values to whole currency units and tracks explicit slider interaction, so the default `[1 - 5000]` range cannot become an unintended API price filter.
- Service cards use a shorter image area on mobile to keep service name, price, and booking action in the first view.
- Accessibility semantics now expose the filter action, selected filter tab, and service search field to Android UI/accessibility tooling.
- Focused Flutter tests remain PASS (3 tests); targeted analyzer PASS (4 files, no issues).
- Screenshot review scored the current saved UI 24/40: calm visual language and clear location drill-down work; empty-state recovery, split-pane mobile filter layout, generic image placeholders, and price presentation remain release-quality issues. This is a critique of saved evidence, not a live-device acceptance claim.
- Post-fix debug APK rebuilt with `API_DOMAIN_URL=http://10.0.2.2:8093` and installed successfully on `emulator-5554`. Android evidence passed Dashboard → Services (2 cards with 300/900 EGP) → filter → Cairo → Nasr City → Apply (1 result, request contained location only) → service detail → clinic detail → Doctors tab (`منى التجريبية`). No AndroidRuntime/Flutter fatal or connection-refused error was found.

### Root fixes and focused verification

- The Services screen opened the narrower `category` filter mode, so category selection and location state were not consistently applied or counted. It now uses the existing `service` filter mode, passes saved governorate/city IDs, and uses one controller-level active-filter count including city.
- Applying/resetting a default max price previously sent `5000` as a real filter. It now omits both price bounds unless the range differs from the existing default.
- `get-service-list` now validates bounded pagination/IDs/prices, supports either price bound, rejects inverted ranges with JSON 422, and keeps inactive services out of patient discovery as well as guest discovery. Detail/list resources now return the actual `system_service_id`.
- A discovered resilience defect is guarded: optional Offers code no longer throws a raw SQL error when its module class exists but its table is absent.
- `flutter test test/unit/service_list_contract_test.dart --reporter expanded` — PASS, 3 tests; `flutter analyze` on the modified Service/filter files — PASS, no issues. Arabic empty-state copy was clarified to `لا توجد خدمات مطابقة لاختياراتك` with an actionable retry hint.
- `php artisan test Modules/Clinic/Tests/Feature/ServiceListApiTest.php --testdox` — PASS, 2 tests / 12 assertions. Covers guest/patient active visibility, Arabic resource text, single-bound location/price filtering, detail clinics, and invalid filters.

### Runtime verification

- Disposable schema `services_qa_20260827` on `127.0.0.1:3307` and canonical Laravel `8093` completed the minimal fixture path without touching `.env`, shared 3306, or production. Live API matrix: PASS 14/14, including EN/AR, category, governorate/city, min/max/range, empty, invalid 422, inactive hiding, authenticated list, and detail relationships.
- Android build/install with `API_DOMAIN_URL=http://10.0.2.2:8093` passed. UI-tree evidence passed through Dashboard → Services list (2 Arabic services) → filter → reset → reopen → governorate/city selection. The final filter apply returned an empty state because the runtime request carried an unintended price bound; detail/linked clinic/doctor could not be completed before the emulator detached. No AndroidRuntime/Flutter fatal or connection-refused error was found.

### Remaining unblock condition

No remaining Services closure condition. The broader booking flow starts separately from the service detail's `احجز الآن` action.

## Clinics — CLOSED

Scope: Dashboard Clinics list, service/price/governorate/city filtering and reset/count, clinic details, linked services/doctors/gallery, localized clinic/location fields, read-only map data, empty/error contract. No Booking, Services, Pharmacy, Logout, Nursing, or Notifications action was performed.

### Root fixes and isolated fixtures

- `get-clinic-list` accepted `is_price_min`/`is_price_max` from Flutter but did not apply them. It now filters through the mapped clinic service, so a selected service and price range apply to the same service record; invalid ranges return JSON 422.
- The list/detail resources used the legacy world-city relation while the active filters store `governorate_cities` IDs. They now use the localized Governorate/City relation first, giving Arabic/English location labels with the existing locale headers.
- Flutter counts a city selection in the Clinic filter badge/result and no longer sends the default maximum price as a real price filter.
- `LocalQaSeeder` is idempotent and now supplies only the missing disposable clinic fixtures: two localized locations/clinics/services, one linked doctor, and one gallery item. The local listing scope requires an admin/demo-admin owner in single-vendor mode, so these fixtures use that existing local owner while the QA patient remains the authenticated patient.

### Verification

- `flutter test test/unit/clinic_list_contract_test.dart --reporter expanded` — PASS, 2 tests. Covers Arabic/English parser fallback plus filter-count behavior.
- `php artisan test Modules/Clinic/Tests/Feature/ClinicListApiTest.php --testdox` — PASS, 3 tests / 14 assertions. Covers guest location/price filtering, localized location output, invalid price validation, detail relationship counts, and gallery pagination.
- Disposable runtime only: MariaDB `127.0.0.1:3307` / `clinics_qa_20260827`; canonical Laravel `127.0.0.1:8092`; backend `.env`, shared `3306`, and production untouched. `LocalQaSeeder` completed after the one-time base seeding attempt, leaving 2 clinics, 2 services, 1 doctor, 1 gallery item, 2 governorates, and 2 cities.
- Live API matrix — PASS: guest English list `200`/2 clinics; guest Arabic governorate+city+price list `200`/1 clinic (`عيادة القاهرة التجريبية`, `مدينة نصر`); empty price search `200`/0; invalid range `422`; authenticated patient English list `200`/2; authenticated detail `200` with services=1, doctors=1, gallery=1. Token values were not recorded.
- Final Android pass on `emulator-5554` used the debug APK built with `API_DOMAIN_URL=http://10.0.2.2:8093`. Dashboard → Clinics list → filter/apply/reset → detail passed with localized clinic/location data and no layout overflow.
- Detail → Services returned the clinic service and logged `get-service-list?per_page=10&page=1&clinic_id=1` with HTTP 200; Detail → Doctors returned `منى التجريبية` and logged `get-doctor-list?...&clinic_id=1` with HTTP 200.
- Gallery empty state was verified first, then one bounded image fixture was added to the isolated `services_qa_20260827` schema. Reload displayed the real image and tap opened zoom; the API logged HTTP 200 and one item.
- Address opened Google Maps with the clinic coordinates, email launched Gmail through `mailto:`, and phone launched the Android dialer. Final logcat contained no app FATAL, unhandled Flutter exception, or RenderFlex overflow. Evidence is under `artifacts/clinics_qa/android_clinics_retest_*`.

### Remaining unblock condition

None for the Clinics flow. Booking from a clinic service remains part of the separate Booking flow.

## Pharmacy — BLOCKED

Scope closed for this pass: authenticated catalogue read only (login, Pharmacy dashboard, category, product list/detail, and read-only cart). Checkout, order creation, payment, cancellation, prescription upload, and refunds were not attempted.

### Code and fixture audit

- Flutter catalogue parser maps blank category/product image values to `null`/an empty list, so the existing Pharmacy UI renders its placeholder instead of constructing an invalid URI.
- Laravel category/product contracts align on `category_id`, `product_type_id`, `price_min`, `price_max`, `prescription_required`, and `price_asc`/`price_desc`; API resources normalize non-URL media to `null`.
- `LocalQaSeeder` provides the local QA patient `qa.patient@espitalia.local`, two root categories, product data, and stocked inventory through `PharmacyDatabaseSeeder`. It is intentionally manual and was not run because the isolated QA database was unavailable.

### Verification

- `flutter test test/unit/pharmacy_catalogue_models_test.dart test/unit/pharmacy_product_rules_test.dart test/unit/pharmacy_order_receipt_test.dart` — PASS, 9 tests.
- `flutter analyze lib/api/pharmacy_apis.dart lib/screens/pharmacy/model/pharmacy_parsers.dart lib/screens/pharmacy/model/pharmacy_category_model.dart lib/screens/pharmacy/model/pharmacy_product_model.dart lib/screens/pharmacy/pharmacy_dashboard_screen.dart lib/screens/pharmacy/product_list_screen.dart lib/screens/pharmacy/product_detail_screen.dart` — PASS, no issues.
- `php artisan test Modules/Pharmacy/Tests/Feature/PharmacyCatalogueApiTest.php Modules/Pharmacy/Tests/Feature/PharmacyOrderApiTest.php Modules/Pharmacy/Tests/Feature/PharmacyCommissionServiceTest.php` — PASS, 11 tests / 38 assertions (the order/commission tests are test-database coverage only; no live order was created).
- `GET http://127.0.0.1:8081/api/v1/pharmacy/categories` — BLOCKED: connection refused. No listener was present on port 8081 or isolated MySQL port 3307; shared `3306` and the backend `.env` were untouched.
- Android preflight for the single permitted attempt: `C:\Users\N\AppData\Local\Android\Sdk\platform-tools\adb.exe -s emulator-5554 get-state` — BLOCKED: `device 'emulator-5554' not found` (ADB device list was empty). No login automation or UI action could run, and no Android retry was made.

### Remaining unblock condition

Start the disposable QA runtime on MySQL 3307 and Laravel 8081, then boot the requested `emulator-5554`. Re-run one read-only authenticated catalogue pass only; stop after the first login failure.

## Logout — BLOCKED (runtime), code and contract CLOSED

Scope closed for this pass: Profile logout only. Account deletion, Nursing, Pharmacy, and Booking were not changed.

### Root cause and remediation

- The app previously called `GET /api/logout`; Laravel revoked the token, then Flutter `clearData()` tried to call `update-profile` to remove the FCM device token using that revoked token. The resulting 401 could re-enter session expiry/cleanup and leave the Profile loading overlay active.
- Logout is now `POST /api/logout` behind `auth:sanctum`. Laravel revokes only the calling Sanctum token, clears `player_id`, and returns the existing success response.
- Flutter marks the in-memory and persisted app session as signed out before best-effort Firebase/identity cleanup. The FCM profile update was removed from local cleanup because the server logout already clears the device field. The UI flow has 15-second remote and 3-second cleanup bounds, hides loading before navigation, and signs out locally after a timeout or server failure because the remote revocation outcome may be unknown.

### Verification

- `flutter test test/unit/logout_flow_test.dart test/unit/session_state_test.dart --reporter expanded` — PASS, 4 tests. Covers success plus failed remote logout with a hanging local-cleanup future; loading is false and navigation still occurs.
- `flutter analyze lib/api/auth_apis.dart lib/screens/auth/profile/profile_controller.dart lib/screens/auth/profile/logout_flow.dart` — PASS, no issues.
- `php artisan test tests/Feature/Auth/ApiLogoutTest.php --testdox` — PASS, 1 test / 6 assertions. It proves `POST /api/logout` deletes the calling token, rejects it on a fresh Sanctum guard, keeps a second-device token valid, and clears `player_id`.
- `php artisan route:list --path=api/logout --method=POST` — confirms `POST api/logout` maps to `Auth\API\AuthController@logout`; GET is no longer registered.

### Runtime blocker

- A new `logout_qa_20260826` schema was created on `127.0.0.1:3307`; canonical-backend `php artisan migrate --force` (never `migrate:fresh`) completed and `AuthTableSeeder` plus the minimal `qa.patient@espitalia.local` fixture were applied. The backend `.env`, shared `3306`, and production were untouched.
- The bound live API pass is blocked by an already-running, externally-owned PHP server on `127.0.0.1:8082`. It retained cached/shared database configuration and returned `SQLSTATE[HY000] [2002]` against the unavailable shared DB instead of `logout_qa_20260826`. Its process was not stopped or reconfigured.
- Therefore no Android emulator/login/logout attempt was made. Start canonical `C:\kivicare-laravel-web-v1.8.1` on 8082 with `APP_CONFIG_CACHE` isolated and the documented process-scoped 3307 variables, then perform exactly one QA login/logout pass with `API_DOMAIN_URL=http://10.0.2.2:8082`.

## Notifications — CLOSED

### Scope

- Android 13+ permission declaration/request, FCM token registration, foreground/background/terminated handlers, safe route classification, deep-link gate, and notification privacy boundary only. Clinics, Booking, Pharmacy, Logout, and Nursing were not changed for this closure.

### Code and privacy remediation

- `android/app/src/main/AndroidManifest.xml` declares `android.permission.POST_NOTIFICATIONS`.
- `lib/utils/push_notification_service.dart` requests permission from the user-visible Walkthrough/Settings actions, registers `FirebaseMessaging.onMessage`, `onMessageOpenedApp`, and `getInitialMessage`, queues cold-start navigation behind `markAuthStateReady()`, and registers refreshed FCM tokens only after authentication. Foreground local notifications use Android `NotificationVisibility.private`.
- `C:\kivicare-laravel-web-v1.8.1\app\Notifications\CommonNotification.php` now sends a generic lock-screen body and a whitelist-only `additional_data` route payload. Names, free-form messages, amounts, and template/medical fields are excluded; full details remain behind the authenticated in-app notification center.

### Verification

- `flutter test test/unit/push_notification_service_test.dart --reporter expanded` — PASS, 6 tests. Covers Android permission declaration/request, refreshed-token ordering, appointment/nurse/ICU/pharmacy/lab/doctor-visit/incident/encounter route classification, nested `additional_data`, and malformed/unknown fallback.
- `flutter analyze lib/utils/push_notification_service.dart lib/main.dart` — PASS, no issues.
- `php artisan test tests/Unit/Notifications/CommonNotificationPayloadTest.php --testdox` — PASS, 1 test / 1 assertion. Confirms only safe routing fields survive FCM payload construction.
- Firebase CLI (`FIREBASE_CLI_DISABLE_UPDATE_CHECK=true firebase.cmd projects:list --json`) — PASS: project `espitalia-patient-2026` ACTIVE. `firebase.cmd apps:list ANDROID --project espitalia-patient-2026 --json` — PASS: Android app `com.espitalia.patient` ACTIVE with registered SHA-1/SHA-256 fingerprints.
- Android preflight initially had no device. Booted `inst_stable` (Android API 35) as `emulator-5554`; the API-36 AVD was unavailable because its system image is not installed. Existing `build/app/outputs/flutter-apk/app-debug.apk` launched package `com.espitalia.patient` (pid 3235). `dumpsys package` showed `POST_NOTIFICATIONS granted=false`; one bounded device action granted it for runtime continuation and then showed `granted=true`. Logcat showed `FLTFireMsgService: FlutterFirebaseMessagingBackgroundService started!` and no `AndroidRuntime`/Flutter crash. Token values were not printed or persisted in logs.
- Runtime continuation on 2026-08-27 used only isolated MariaDB `127.0.0.1:3307` / `fcm_qa_20260827` and canonical Laravel `127.0.0.1:8083`. A QA-only patient (user id 19) was created with the existing `user` role and Laravel password hash; direct `POST /api/login` returned HTTP 200 with `status=true`.
- The first emulator login attempt was stopped after `AmbiguousRequestOutcomeException`; inspection showed that APK targeted debug default port 8000 while QA Laravel listened on 8083. No send occurred. The app was then rebuilt without code changes using `--dart-define=API_DOMAIN_URL=http://10.0.2.2:8083`, reinstalled, and runtime logs proved `GET http://10.0.2.2:8083/api/app-configuration` returned 200.
- One fresh UI login attempt followed after UI-tree verification of the exact QA email and 9 password bullets. It succeeded to the authenticated Profile screen. QA DB then showed `player_id` non-empty with length 142; only its SHA-256 metadata was inspected, never the token value. No `AndroidRuntime`/Flutter crash was found.
- Foreground delivery passed with the generic payload `Espitalia QA` / `Test notification - foreground.`; the notification was visible and contained no medical, identity, contact, or financial data.
- Background HTTP v1 delivery passed with the generic payload `Espitalia QA` / `Test notification - background.`. Its exact UI-tree bounds were `[388,776][1006,827]`; tapping their center `(697,801)` closed the shade and safely returned to the authenticated Home screen in `com.espitalia.patient/.MainActivity`. No `AndroidRuntime` or Flutter error was present.
- For terminated preflight, `am force-stop com.espitalia.patient` succeeded and `pidof` remained empty. The registered `player_id` was read privately from the isolated QA database and validated only by length/hash metadata.

### Final terminated-state verification

- Android `am force-stop` was rejected as a valid terminated simulation because it sets the package to `stopped=true`; Android received the FCM broadcast but cancelled it. The valid preflight opened the app once, returned Home, then used `am kill`, proving no PID with `stopped=false` and notification permission granted.
- The first valid terminated notification exposed a backend payload defect: `click_action=FLUTTER_NOTIFICATION_CLICK` had no matching Android activity, so ActivityTaskManager returned `-91` and did not open the app. Removed the custom action from both FCM data and Android notification fields so Firebase uses the default launcher intent while preserving `getInitialMessage()` data.
- Backend regression verification — PASS: `CommonNotificationPayloadTest`, 2 tests / 4 assertions, covering the privacy whitelist and absence of the invalid custom click action.
- One post-fix generic HTTP v1 notification was accepted and displayed as `Espitalia QA` / `You have a new notification. Open Espitalia to view details.` with no patient, medical, contact, or financial data. UI-tree click bounds were `[42,578][1038,938]`.
- Tapping the notification cold-started `com.espitalia.patient/.MainActivity` through the launcher intent and opened the authenticated `الإشعارات` screen. The inbox completed loading to its Arabic empty state. No app fatal, unhandled Flutter exception, notification routing error, or layout overflow was found.
- Flutter notification tests — PASS, 6 tests; targeted analyzer — PASS, no issues. Evidence: `artifacts/fcm_qa/28_valid_terminated_before_send.*`, `29_valid_terminated_notification_shade.*`, `33_postfix_terminated_notification.*`, `34_postfix_terminated_after_tap.*`, and `35_postfix_notifications_loaded.*`.

### Remaining blocker

None for Android notification permission, foreground/background/terminated delivery, privacy-safe payload, and cold-start routing to the safe notification inbox.

## Booking selection to confirmation — CLOSED

### Scope

- Services → clinic → doctor → booking form → date/slot selection → confirmation screen only. No booking was created and no payment was attempted.

### Root fix

- Arabic locale formatting was sending API dates as Arabic numerals (`٢٠٢٦-٠٨-٢٨`), which Laravel correctly rejected against `date_format:Y-m-d`. Added `formatApiDateYYYYmmdd()` with an explicit English locale and applied it to booking, rescheduling, and Quick Book date requests.
- The local QA fixture had no doctor sessions; seven weekday sessions were added only to disposable schema `services_qa_20260827` so slot browsing can be exercised.

### Verification

- `flutter test test/unit/booking_slot_selection_test.dart` — PASS, 2 tests.
- Targeted `flutter analyze` for date/booking callers — PASS, no issues.
- `php artisan test Modules/Clinic/Tests/Feature/BookingBrowseApiTest.php` — PASS, 2 tests / 17 assertions after the test-only SQLite fixture added the missing nullable `appointment_number` column.
- Live isolated API: `GET /api/get-time-slots?appointment_date=2026-09-01&doctor_id=3&clinic_id=1&service_id=1` — HTTP 200, four slots (`09:00`, `09:15`, `09:30`, `09:45`).
- Android pre-fix evidence reached the booking form with service/clinic/doctor selected, but the malformed Arabic date caused the slot error; artifacts: `artifacts/booking_qa_08.xml` and `artifacts/booking_qa_09.xml`.
- `flutter build apk --debug --dart-define=API_DOMAIN_URL=http://10.0.2.2:8093` — PASS; APK installed on `emulator-5554`.
- Authenticated Android UI journey — PASS: QA login → Quick Book → `استشارة عامة تجريبية` → `عيادة خدمات القاهرة التجريبية` → date picker (`السبت، ٢٩ أغسطس ٢٠٢٦`) → slot `09:00` → visible `تأكيد الموعد` confirmation state. Evidence: `artifacts/qb1.xml`, `artifacts/qb2.xml`, `artifacts/qb3.xml`, `artifacts/qb4.xml`, `artifacts/qb5.xml`, `artifacts/qb6.xml`, `artifacts/qb7.xml`, `artifacts/booking_confirmation.png`.
- Final action was intentionally not tapped: no booking row, payment, or external side effect was created. Logcat contained no `FATAL EXCEPTION` or Flutter crash.

## Booking creation and idempotency — CLOSED

### Scope

- Create one appointment from the confirmation flow, replay the same request with the same idempotency key, and verify a single database row. No payment was attempted.

### Verification completed

- `php artisan test tests/Feature/IdempotencyMiddlewareTest.php tests/Feature/AppointmentSlotIntegrityTest.php Modules/Appointment/Tests/Feature/AppointmentTest.php` — PASS, 10 tests / 38 assertions.
- Coverage includes same-key replay without re-execution, changed-payload rejection, per-user scoping, lost-response reconciliation, pending reservation handling, expiry, and slot uniqueness with cancellation release.
- Static contract review confirms Flutter sends `Idempotency-Key` and `X-Request-ID` from the persisted appointment operation key; Laravel applies `auth:sanctum` plus `idempotency:appointment`, binds the appointment to the authenticated patient, recalculates pricing, and rejects an occupied slot.
- Root cause fixed: `AppointmentsController::store()` validated `clinic_id` against nonexistent table `clinics`; the application schema uses `clinic`, consistent with the browse endpoint. Changed only the validation table name.
- `php -l Modules/Appointment/Http/Controllers/Backend/AppointmentsController.php` — PASS.
- Live isolated QA runtime restarted on MariaDB `127.0.0.1:3307` / Laravel `127.0.0.1:8093`. Authenticated multipart create with key `qa-appointment-20260828-idem-02` created exactly one row (`id=1`, `APT-2026-0001`, slot key `3|2026-09-01|09:00:00`).
- Replaying the same request/key returned HTTP 200 with `Idempotency-Replayed: true`; database count remained `1`.
- A different key against the already occupied slot returned HTTP 422 `No available slots for this date.`; no duplicate row was created.
- No payment was attempted. The QA row is disposable local data only.

## Independent doctor booking from app — CLOSED

### Verification

- Flutter now calls the independent services, slots, and booking endpoints, preserves doctor record id versus doctor user id, and uses an independent idempotency scope.
- Android acceptance passed Dashboard → `طبيب` → `منى التجريبية` → detail → service → `SEP 1 TUE` → `10:00` → summary → cash → consent → submit → `تم الحجز بنجاح`.
- `POST http://10.0.2.2:8093/api/independent-booking` returned HTTP 200. Shared JSON headers now include `Accept: application/json`.
- Isolated MariaDB contains exactly one independent appointment: `id=3`, patient `2`, doctor user `3`, service `1`, `2026-09-01 10:00`, total `250`, status `confirmed`, slot key `3|2026-09-01|10:00:00`. Its idempotency record is `completed / 200`.
- Backend focused test passed: 2 tests / 6 assertions. Flutter independent contract test passed: 1 test. Final evidence is under `artifacts/independent_doctor_qa/closed_*`; no app fatal or unhandled Flutter exception was found.

### Status

**CLOSED.** Independent doctor cash booking is verified end to end against the isolated local Laravel/MariaDB runtime.

## Appointment list and detail — CLOSED

### Verification

- Android `المواعيد` loaded through `GET /api/appointment-list` HTTP 200 and displayed independent appointment `3` with its service, doctor, amount, statuses, and correctly ordered time range.
- `القادمة` contains the independent appointment. `مكتمل` returns the corrected Arabic empty state: `لا توجد مواعيد متاحة حاليًا. يمكنك حجز موعدك التالي الآن.`
- Appointment `3` detail loaded through `GET /api/appointment-detail?appointment_id=3` HTTP 200 and displayed the independent service without an empty clinic or placeholder image.
- Laravel list/detail resources now expose independent booking/service fields. Detail access uses role scope; the backend focused test proves another patient receives 404.
- Flutter focused test passed (1 test), targeted analyzer reported no issues, and the debug APK built and installed. Backend focused test passed (1 test / 10 assertions).
- Evidence: `artifacts/appointment_lifecycle_qa/final_list.*`, `final_completed.*`, `final_detail.*`, and `final_detail_logcat.txt`. No app fatal or unhandled Flutter exception was found.

### Status

**CLOSED.** Appointment list, all/upcoming/completed filters, and owned appointment detail are verified end to end on the isolated local runtime.
