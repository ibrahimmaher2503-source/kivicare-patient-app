# Quickstart — Nurse Request (Home Nursing) Module

A short orientation for any contributor (or the next AI session) about how to build, run, and verify this module against the Espitalia Patient App.

## 1. Prerequisites

- Flutter 3.0+ / Dart 3.0+
- Android Studio or VS Code with the Flutter extension
- A test patient account on `https://espitalia.net/`
- Either a real device or an emulator with a SIM (for tap-to-call verification)

## 2. Bring up the workspace

```bash
flutter pub get
flutter run
```

Sign in with the test patient account. The dashboard should expose a "Home Nursing" entry card alongside the other patient modules (booking, encounter, incident management).

## 3. Files you will edit / create

Mandatory edits:

- `lib/utils/api_end_points.dart` — add 3 constants (see contracts/api-endpoints.md → "Endpoint constants to add"). If they already exist on this branch from an earlier commit, leave them untouched.
- `lib/api/nurse_request_apis.dart` — NEW file with 3 static methods.
- `lib/locale/language_en.dart` and `lib/locale/language_ar.dart` — add the keys listed in §6 below to BOTH files.

New module:

- `lib/screens/nurse_request/` — entire feature folder, structured per `plan.md` → "Project Structure".

Dashboard wire-up:

- `lib/screens/dashboard/` — add the "Home Nursing" card per the dashboard's existing card pattern (no new layouts; reuse the existing tile component). Tap → `Get.to(() => const NurseRequestListScreen())`.

Push-notification dispatcher:

- `lib/utils/push_notification_service.dart` — add a `case "nurse_request_status_changed":` that calls `Get.to(() => NurseRequestDetailScreen(requestId: payload["request_id"]))`.

## 4. Wiring order

Build in this order so each commit compiles in isolation:

1. **Endpoints + API service**: Add the 3 endpoint constants and create `nurse_request_apis.dart`. Commit.
2. **Models**: `NurseRequestModel`, `AssignedNurseModel`, `StatusHistoryEntry`, `NurseRequestListResponse`, `NurseRequestFormPayload`. Round-trip JSON via the contract examples in `contracts/api-endpoints.md`. Commit.
3. **Localization**: Add keys to both language files. Commit.
4. **Components**: Status chip, status timeline, assigned nurse card, pricing card, cancellation banner, bilingual description field, duration stepper, governorate-city picker, status filter bar, list card. Commit per logical group.
5. **Screens, in dependency order**: list → form → success → detail. Each with its controller. Commit per screen.
6. **Dashboard entry + push dispatcher**. Commit.

After each step run `flutter analyze` — the goal is **zero new warnings beyond the pre-existing baseline** (Constitution + SC-012).

## 5. Manual verification per user story

Do this on Android first, then on at least one of iOS or Web (Constitution I).

### Story 1 — Submit a request (P1)

1. Dashboard → "Home Nursing" → "New Request".
2. Fill English description with a short text. Leave Arabic empty. Set preferred date to tomorrow. Duration 2h. Address line 1 = "12 Test St.". City = "Cairo". Phone = "+201001234567". Submit.
3. Expect: success screen with `NR-YYYY-NNNN` reference number, copy-to-clipboard control, and a notice that a nurse will be assigned.
4. Tap "View Request" → detail screen opens. Back arrow returns to the list (NOT to the form).
5. Repeat with Arabic-only description: should succeed.
6. Repeat with both empty: should be blocked client-side with a single inline error at the top of the description section.
7. Repeat with phone "+12" (too short): should show a phone field error and not submit.
8. Open the date picker: dates before today and beyond +90 days are visibly disabled.
9. Set duration stepper to 1: decrement disabled. Set to 24: increment disabled.

### Story 2 — List the patient's requests (P1)

1. Re-enter Home Nursing.
2. Newly submitted request appears at the top (without manual refresh).
3. Pull-to-refresh works.
4. Scroll to the bottom of a long list (50+ entries): next page loads automatically.
5. Empty filter case: tap "Cancelled" filter on a brand-new account with no cancellations — empty state with "Request Home Nursing" CTA appears.
6. Once admin has assigned a nurse and priced (test via backend admin or curl), the card shows assigned nurse name and total amount.

### Story 3 — Detail with timeline + cancel/refund (P2)

1. Open any request from the list.
2. Pending → only the "Pending" step is highlighted.
3. After admin assigns: pull-to-refresh on detail → assigned nurse card visible, no pricing card yet.
4. After admin prices: pricing card visible with amount, currency, payment status.
5. Cancel the request via the admin → patient pulls-to-refresh → cancellation banner appears, timeline terminates at cancelled.
6. On a completed request: "Completed on" date visible; all 5 forward steps marked complete.
7. Tap the contact phone: device dialer opens prepopulated.

### Story 4 — Arabic / RTL + dark mode (P2)

1. Switch app language to Arabic. Walk through dashboard → list → form → success → detail. Verify all labels are Arabic, layout is RTL.
2. While the app is in Arabic, on the form: type in the English description field — text flows LTR inside that field. Type in the Arabic description — text flows RTL inside that field.
3. Set duration to 2 hours: label uses correct Arabic plural ("ساعتان"). Set to 5 hours: uses "خمس ساعات" (or correct CLDR-formatted variant via `Intl.plural`).
4. Toggle dark mode. Re-walk every screen. Verify status chip text contrast and timeline accent legibility.

### Story 5 — Filter + clipboard + tap-to-call (P3)

1. List screen → tap "Cancelled" filter → only cancelled requests visible.
2. Success screen → tap reference number → toast "Copied". Paste somewhere outside the app to verify clipboard.
3. Detail screen header → tap reference number → same.
4. Detail → tap contact phone → dialer opens with number prefilled.
5. Detail → if assigned nurse phone present → tap → dialer opens.

## 6. Localization keys to add

Add to `lib/locale/language_en.dart` and `lib/locale/language_ar.dart` (mirror under matching keys; provide proper Arabic translations and CLDR-correct plurals). All keys are accessed via `locale.value.<key>`.

```text
homeNursing                       (Home Nursing / تمريض منزلي)
newRequest
myRequests
requestHomeNursing                (CTA on empty state)
serviceDescriptionEnglish
serviceDescriptionArabic
atLeastOneDescriptionRequired
preferredDate
preferredTime
clear                             (small affordance to clear preferred time)
durationHours                     (label for the stepper)
durationHoursValue                (formatted with Intl.plural over `n`)
addressLine1
addressLine2
moreAddressDetails                (toggle label)
governorate
city
state                             (label for optional state field; reuse if exists)
country
postalCode
contactPhone
patientNotes
submit
submitting
requestSubmitted                  (success header)
referenceNumber
copyReferenceNumber
copied                            (toast)
notifyTeamWillAssign              ("Our team will assign a nurse and confirm details soon")
viewRequest
backToHome
filterAll
filterPending
filterAssigned
filterConfirmed
filterInProgress
filterCompleted
filterCancelled
nurseStatusPending
nurseStatusAssigned
nurseStatusConfirmed
nurseStatusInProgress
nurseStatusCompleted
nurseStatusCancelled
assignedNurse
nurseRating
nursePhone
estimatedTotal
paymentStatusUnpaid
paymentStatusPaid
paymentStatusRefunded
cancellationReason
completedOn
statusHistory
emptyRequestsTitle                ("No requests yet")
emptyRequestsSubtitle             ("Submit your first request to get started")
loadFailed                        (recoverable error title)
retry
phoneInvalid                      (inline error)
descriptionTooLong                (counter overflow)
notesTooLong
addressTooLong
cityRequired
addressLine1Required
preferredDateRequired
durationOutOfRange
```

Plurals (use `Intl.plural`):

- `durationHoursValue(int n)` → English: `"$n hour"` / `"$n hours"`. Arabic: full CLDR forms (`zero`, `one`, `two`, `few`, `many`, `other`).

## 7. Common pitfalls

- **Hardcoding strings.** Don't. Every visible string MUST go through `locale.value.<key>` (Constitution V). If you need a placeholder Arabic translation, use the English string + a `// TODO: translate` comment.
- **Sending forbidden fields.** The form payload must be built from an allow-list, NOT by `model.toJson()`. SC-009 verifies this with a network audit.
- **Missing token refresh.** All API methods MUST go through `buildHttpResponse()`. Never use `http.get/post` directly.
- **Mutating status from the client.** Never. The patient client only renders the current status (FR-042).
- **`isDarkMode` import.** It lives in `lib/utils/app_common.dart`, NOT in `common_base.dart`. (CLAUDE.md memo.)
- **`Directionality` for bilingual fields.** Each description field is wrapped in its own `Directionality` so the cursor/IME flow per-field, not per-app (R5 in research.md).

## 8. Done definition

- All 5 user stories pass manual verification on Android + at least one of iOS or Web.
- `flutter analyze` reports zero new warnings beyond the pre-existing baseline.
- All strings flow through localization (audit by grep: no string literals containing English words appear in `lib/screens/nurse_request/**.dart` outside of CSS-style identifiers).
- Network audit (Charles, Proxyman, or `flutter_inappwebview` proxy) confirms the create-request body never contains: `id`, `reference_number`, `status`, `assigned_nurse`, `total_amount`, `currency`, `payment_status`, `cancellation_reason`, `completed_at`, `status_history`.
