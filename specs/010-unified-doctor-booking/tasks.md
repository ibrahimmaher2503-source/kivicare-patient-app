# Tasks: Unified Doctor-First Booking Experience

**Input**: Design documents from `/specs/010-unified-doctor-booking/`
**Branch**: `010-unified-doctor-booking`
**Prerequisites**: plan.md ✅, spec.md ✅, research.md ✅, data-model.md ✅, contracts/ ✅, quickstart.md ✅

**Tests**: Not requested. No test tasks included.

**Languages**: English (en) and Arabic (ar) only.

**Organization**: Tasks grouped by user story. Each story phase is independently testable.

## Format: `[ID] [P?] [Story?] Description`

- **[P]**: Can run in parallel (different files, no dependencies on other in-progress tasks)
- **[Story]**: Which user story (US1–US5 map to P1–P5 in spec.md)
- All tasks include exact file paths

---

## Phase 1: Setup

**Purpose**: Establish baseline before any changes.

- [X] T001 Run `flutter analyze` from project root; record any pre-existing warnings as baseline (do not fix; used to verify no new warnings are introduced by this feature)

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Shared infrastructure required by multiple user stories. **T002 and T003-T004 form an atomic batch** — the app will not compile until both language files implement the abstract getters added in T002. Commit T002-T004 together.

- [X] T002 Add 4 abstract getters to `BaseLanguage` abstract class in `lib/locale/languages.dart`: `String get bookADoctor`, `String get videoConsult`, `String get myDoctorAppointments`, `String get myVideoConsults`
- [X] T003 [P] Implement 4 locale keys in `lib/locale/language_en.dart`: `bookADoctor → 'Book a Doctor'`, `videoConsult → 'Video Consult'`, `myDoctorAppointments → 'My Doctor Appointments'`, `myVideoConsults → 'My Video Consults'`
- [X] T004 [P] Implement 4 locale keys in `lib/locale/language_ar.dart`: same English text as language_en.dart with `// TODO: translate` comment on each
- [X] T005 Create `lib/screens/doctor/model/unified_doctor_model.dart` with the following in order: (1) `BookingType` enum — values: `clinic`, `videoCall`, `phoneCall`, `inPerson`; (2) `BookingCapability` class — fields: `type: BookingType`, `isAvailable: bool`, `startingPrice: double`, `services: List<ServiceInfo>`; (3) `ServiceInfo` class — fields: `id: int`, `name: String`, `durationMin: int`, `charges: double`, `finalPrice: double`, `bookingType: BookingType`, `rawService: dynamic`, factory constructors `fromClinicService(ServiceElement s)` / `fromCallService(CallService s)` / `fromIndependentService(IndependentService s)`; (4) `UnifiedDoctor` class — identity fields (`id`, `doctorId`, `fullName`, `firstName`, `lastName`, `email`, `mobile`, `gender`, `expert`, `experience`, `profileImage`, `averageRating: double`, `totalReviews`, `aboutSelf`, `description`, `address`, `latitude`, `longitude`), `bookingCapabilities: List<BookingCapability>`, factory constructors `fromDoctor(Doctor d)` / `fromCallDoctor(CallDoctor d)` / `fromIndependentDoctor(IndependentDoctor d)` / `fromPopularDoctorData(dynamic d)` (inspect `lib/screens/doctor/model/doctor_list_res.dart` for the exact PopularDoctorData class name and fields), `mergeWith(UnifiedDoctor other)` method (asserts same `doctorId`, merges capabilities); (5) top-level `List<UnifiedDoctor> deduplicateDoctors(List<UnifiedDoctor> doctors)` function

**Checkpoint**: Run `flutter analyze` — zero errors. App compiles. Foundation ready.

---

## Phase 3: User Story 1 — Doctor-First Home Screen Layout (Priority: P1) 🎯 MVP

**Goal**: Popular Doctors appear before clinics/services on home screen; Quick Services cards surface doctor options first; Popular Doctor cards have a visible Book entry point.

**Independent Test**: Open app → verify Popular Doctors section appears before Popular Clinics; scroll Quick Services → "Book a Doctor" is 2nd card, "Video Consult" is 3rd card; tap a Popular Doctor card → doctor detail is reachable within 1 tap.

- [X] T006 [P] [US1] Reorder `_children` list in `lib/screens/home/home_screen.dart` — move `PopularDoctorComponent` (currently at index 7) to index 5, shifting `PopularServiceComponent` to index 6 and `PerfectClinicComponent` to index 7 (new order: index 5 = Popular Doctors, index 6 = Popular Services, index 7 = Perfect Clinics)
- [X] T007 [P] [US1] Update `lib/screens/home/components/quick_services_component.dart`: (a) reorder the navigation cards list so that the existing "Independent Booking" card moves to position index 1 (2nd card) and existing "Call Booking" card moves to position index 2 (3rd card); (b) change their display labels from the old `locale.value.independentBooking` / `locale.value.callBooking` to `locale.value.bookADoctor` / `locale.value.videoConsult`; (c) in the My Requests tiles section update "My Independent Bookings" to use `locale.value.myDoctorAppointments` and "My Call Bookings" to use `locale.value.myVideoConsults`
- [X] T008 [P] [US1] Add a "Book" action CTA to `lib/screens/doctor/components/popular_doctor_card.dart` — a compact "Book" button or badge overlaid on the card that navigates via `Get.to(() => DoctorDetailScreen(doctorData: ...))` (uses existing `DoctorDetailScreen`; will be updated to `UnifiedDoctorDetailScreen` in Phase 6)

**Checkpoint**: US1 fully functional. Verify: home section order, Quick Services card order and labels, My Requests tile labels, Popular Doctor Book button.

---

## Phase 4: User Story 5 — Consistent Patient-Friendly Labels (Priority: P5)

**Goal**: Zero instances of "Independent Booking" or "Call Booking" in any user-facing screen title or label across the app.

**Independent Test**: Navigate through all screens listed below → no screen title reads "Independent Booking" or "Call Booking"; all doctor-related screens use "Book a Doctor" / "Video Consult" terminology.

- [X] T009 [P] [US5] Update app bar title in `lib/screens/call_booking/call_doctor_list_screen.dart` to use `locale.value.videoConsult`
- [X] T010 [P] [US5] Update app bar title in `lib/screens/independent_booking/independent_doctor_list_screen.dart` to use `locale.value.bookADoctor`
- [X] T011 [P] [US5] Update app bar title in `lib/screens/call_booking/call_doctor_detail_screen.dart` to use `locale.value.videoConsult`
- [X] T012 [P] [US5] Update app bar title in `lib/screens/independent_booking/independent_doctor_detail_screen.dart` to use `locale.value.bookADoctor`
- [X] T013 [P] [US5] Update page/app bar title in `lib/screens/call_booking/book_call_screen.dart` to use `locale.value.videoConsult`
- [X] T014 [P] [US5] Update page/app bar title in `lib/screens/independent_booking/book_independent_screen.dart` to use `locale.value.bookADoctor`

**Checkpoint**: US5 complete. Search codebase for "Independent Booking" and "Call Booking" strings in UI text — zero user-facing occurrences should remain.

---

## Phase 5: User Story 2 — Unified Doctor Card with Booking Options (Priority: P2)

**Goal**: A single `UnifiedDoctorCard` widget used across all doctor listing contexts, showing booking type badges for each available booking method.

**Independent Test**: Navigate to any doctor list (Home Popular Doctors, Call Doctors list, Independent Doctors list, Search results) → all show the same card design with profile photo, name, specialty, rating; cards for call doctors show video/phone badge; cards for independent doctors show in-person badge; badge tap navigates to correct booking flow; card body tap navigates to doctor detail screen.

- [X] T015 [US2] Create `lib/screens/doctor/components/unified_doctor_card.dart` — widget accepting `required UnifiedDoctor doctor` parameter; renders: profile photo via `CachedImageWidget` (80×80 rounded), doctor name (boldTextStyle), specialty/expert (primaryTextStyle muted), star rating + review count, horizontal row of booking type badges (one per `capability` in `doctor.bookingCapabilities` where `isAvailable == true`; badge shows icon + label + starting price if > 0); "Currently Unavailable" chip if `bookingCapabilities.isEmpty`; body tap: `Get.to(() => DoctorDetailScreen(doctorData: doctor.toClinicDoctor()))` as temporary placeholder; badge tap routing: `BookingType.clinic` → `DoctorDetailScreen`, `BookingType.videoCall`/`phoneCall` → `CallDoctorDetailScreen(callDoctorData: doctor.toCallDoctor())`, `BookingType.inPerson` → `IndependentDoctorDetailScreen(doctorData: doctor.toIndependentDoctor())`; add back-conversion helpers `toClinicDoctor()`, `toCallDoctor()`, `toIndependentDoctor()` to `UnifiedDoctor` in `lib/screens/doctor/model/unified_doctor_model.dart`
- [X] T016 [P] [US2] Update `lib/screens/doctor/components/popular_doctor_component.dart` — inspect the doctor data model used (likely `PopularDoctorData` from `doctor_list_res.dart`); convert each item to `UnifiedDoctor` via `UnifiedDoctor.fromPopularDoctorData(item)` (add/adjust factory constructor in `unified_doctor_model.dart` to match actual field names); replace `PopularDoctorCard` usages with `UnifiedDoctorCard`
- [X] T017 [P] [US2] Update `lib/screens/call_booking/call_doctor_list_screen.dart` — convert the `CallDoctor` list items to `UnifiedDoctor.fromCallDoctor(item)` before rendering; replace `CallDoctorCard` with `UnifiedDoctorCard`; the existing controller and data loading stays unchanged — only the rendering layer changes
- [X] T018 [P] [US2] Update `lib/screens/independent_booking/independent_doctor_list_screen.dart` — convert `IndependentDoctor` items to `UnifiedDoctor.fromIndependentDoctor(item)` before rendering; replace `IndependentDoctorCard` with `UnifiedDoctorCard`; keep existing controller and data loading unchanged
- [X] T019 [P] [US2] Update `lib/screens/search/doctor_search_screen.dart` — in the results rendering section, map each `Doctor` item to `UnifiedDoctor.fromDoctor(item)` before passing to `UnifiedDoctorCard`; replace existing card widget with `UnifiedDoctorCard`

**Checkpoint**: US2 complete. All 4 doctor list contexts show `UnifiedDoctorCard`. Badge navigation works per booking type.

---

## Phase 6: User Story 3 — Unified Doctor Detail with Booking Tabs (Priority: P3)

**Goal**: A single `UnifiedDoctorDetailScreen` with tabs Book/About/Reviews/Qualifications, where the Book tab shows all available booking methods for that doctor.

**Independent Test**: Navigate to any doctor profile via `UnifiedDoctorCard` body tap → unified detail screen opens with "Book" tab active; for a call doctor the Book tab shows a "Video Call" section; tapping "Book Now" opens the existing booking flow for that type; About/Reviews/Qualifications tabs display correct content; no loss of functionality in any booking path.

- [X] T020 [US3] Add `getIndependentDoctorServices(int sourceId)` static method to `lib/api/core_apis.dart` — `GET /v1/independent-doctors/{sourceId}/services`; follows same implementation pattern as existing `getCallDoctorServices()`; returns `List<IndependentService>` deserialized from response; add corresponding endpoint constant to `lib/utils/api_end_points.dart` if not already present
- [X] T021 [US3] Create `lib/screens/doctor/unified_doctor_detail_controller.dart` — `GetxController`; constructor field `final UnifiedDoctor doctor`; `RxList<BookingCapability> capabilities`; `RxBool isLoadingCapabilities`; `onInit()` fires `Future.wait([_loadClinicCapability(), _loadCallCapability(), _loadIndependentCapability()])` where each calls the appropriate API with `.catchError((_) => [])` so partial failure doesn't block other capabilities loading; populates `capabilities` from non-empty results; for clinic: if getDoctorDetails returns services, create `BookingCapability(type: clinic, ...)`; for call: create `videoCall`/`phoneCall` entries based on `callType` field; for independent: create `inPerson` entry; exposes per-capability form state (`selectedService`, `selectedDate`, `selectedSlot` as `Map<BookingType, Rx<...>>`); exposes `loadSlots(BookingType type)` calling the correct slots endpoint per type
- [X] T022 [P] [US3] Create `lib/screens/doctor/unified_doctor_detail_screen.dart` scaffold — `StatefulWidget` accepting `required UnifiedDoctor doctor`; instantiates `UnifiedDoctorDetailController` via `Get.put()`; `DefaultTabController(length: 4)`; custom `AppBar` with back button; hero header (profile image via `CachedImageWidget`, name, specialty, rating + review count, experience badge); `TabBar` with tabs: Book / About / Reviews / Qualifications; `TabBarView` body with 4 placeholder children (populated in T024–T027)
- [X] T023 [P] [US3] Create `lib/screens/doctor/components/booking_method_section.dart` — `StatelessWidget` accepting `required BookingCapability capability` and `required UnifiedDoctorDetailController controller`; header row: booking type icon + label + starting price badge + expand/collapse chevron; expanded body: (1) service `DropdownButtonFormField` bound to `controller.selectedService[capability.type]`; (2) date picker field using `showDatePicker()` (min: tomorrow, max: 90 days out); (3) slot chips `Wrap` using existing `TimeSlotChip` pattern, loaded via `controller.loadSlots(capability.type)` on date selection; (4) "Book Now" `ElevatedButton` enabled only when service + date + slot selected; navigates to correct booking screen: `clinic` → `BookingFormScreen`, `videoCall`/`phoneCall` → `BookCallScreen`, `inPerson` → `BookIndependentScreen`
- [X] T024 [US3] Implement Book tab body in `lib/screens/doctor/unified_doctor_detail_screen.dart` — first `TabBarView` child: `Obx()` watching `controller.capabilities`; shows `LoaderWidget` while `controller.isLoadingCapabilities.value`; empty state via `EmptyErrorStateWidget` if no capabilities; otherwise `Column` of `BookingMethodSection(capability: cap, controller: controller)` for each capability
- [X] T025 [US3] Implement About tab body in `lib/screens/doctor/unified_doctor_detail_screen.dart` — second child: scrollable column with bio text (`doctor.aboutSelf` or `doctor.description`), contact info (mobile, email), address if non-empty, social links row (Facebook/Instagram/Twitter icons) using `launchUrl()` from `url_launcher`
- [X] T026 [US3] Implement Reviews tab body in `lib/screens/doctor/unified_doctor_detail_screen.dart` — third child: paginated `ListView` of `DoctorReviewCard` widgets from `lib/screens/doctor/components/`; load via controller; empty state if no reviews
- [X] T027 [US3] Implement Qualifications tab body in `lib/screens/doctor/unified_doctor_detail_screen.dart` — fourth child: `ListView` of `DoctorQualificationCard` widgets from `lib/screens/doctor/components/`; load via controller; empty state if no qualifications
- [X] T028 [US3] Update `lib/screens/doctor/components/unified_doctor_card.dart` body tap — replace the T015 placeholder navigation with `Get.to(() => UnifiedDoctorDetailScreen(doctor: doctor))`; this updates navigation from all listing contexts simultaneously

**Checkpoint**: US3 complete. Verify: doctor card body tap opens unified detail → Book tab active → capability sections load → Book Now navigates to correct existing flow → About/Reviews/Qualifications tabs render → all existing booking end-to-end flows still work.

---

## Phase 7: User Story 4 — Doctor-First Quick Book Widget (Priority: P4)

**Goal**: Home screen QuickBook widget searches by doctor name/specialty as the primary input.

**Independent Test**: Open home screen → QuickBook shows "Search doctor or specialty" as first input; type a name → matching doctors appear; select doctor → booking type chips appear; select type + date + slot → "Book Now" creates booking and shows confirmation.

- [X] T029 [P] [US4] Create `lib/screens/home/components/doctor_quick_book_controller.dart` — `GetxController`; `TextEditingController searchCont`; `RxList<UnifiedDoctor> doctorResults`; `Rx<UnifiedDoctor?> selectedDoctor`; `Rx<BookingCapability?> selectedCapability`; `Rx<DateTime?> selectedDate`; `RxString selectedSlot`; `RxList<String> slots`; `RxBool isSearching`, `isLoadingSlots`; `onInit()` sets up debounce on search input (500ms) calling `CoreServiceApis.searchDoctors(name: query)` and mapping results to `UnifiedDoctor.fromDoctor()`; `onDoctorSelected(UnifiedDoctor d)` clears downstream state; `onDateSelected(DateTime d)` calls correct slots endpoint based on `selectedCapability.type`; `bookAppointment()` calls `doIfLoggedIn()` then appropriate booking API
- [X] T030 [US4] Create `lib/screens/home/components/doctor_quick_book_component.dart` — `StatelessWidget` using `DoctorQuickBookController`; Step 1: search input with placeholder text `locale.value.bookADoctor` → bottom sheet with doctor list on focus; Step 2: booking type chip row (from `selectedDoctor.bookingCapabilities`, visible after doctor selected); Step 3: date picker field (visible after capability selected); Step 4: slot chips grid `Wrap` (loaded from `controller.slots` after date selected); Step 5: "Book Now" `ElevatedButton` enabled when all fields selected — calls `controller.bookAppointment()`; cascade clearing on upstream selection changes
- [X] T031 [US4] Replace `QuickBookComponent` with `DoctorQuickBookComponent` in `lib/screens/home/home_screen.dart` — update import and widget reference at index 2 in `_children` list; ensure home screen pull-to-refresh also resets `DoctorQuickBookController` state

**Checkpoint**: US4 complete. Verify: QuickBook searches by doctor name, completes booking in ≤4 interactions (search + doctor select + date + slot), confirmation shown.

---

## Phase 8: Polish & Cross-Cutting Concerns

- [X] T032 [P] Verify dark mode in `lib/screens/doctor/components/unified_doctor_card.dart` and `lib/screens/doctor/unified_doctor_detail_screen.dart` — all color references use `isDarkMode.value` conditional or nb_utils context extensions; fix any hardcoded light-mode hex colors
- [X] T033 [P] Verify RTL layout in `lib/screens/doctor/components/unified_doctor_card.dart` and `lib/screens/doctor/components/booking_method_section.dart` — replace any hardcoded `TextAlign.left`, `EdgeInsets.only(left:...)`, `Alignment.centerLeft` with `TextAlign.start`, `EdgeInsetsDirectional`, `Alignment.centerStart`
- [X] T034 Run `flutter analyze` from project root; compare output against T001 baseline; fix any new warnings introduced in T002–T033 files; confirm zero new warnings beyond baseline

---

## Dependencies & Execution Order

### Phase Dependencies

```
Phase 1 (Setup)        → no dependencies
Phase 2 (Foundational) → depends on Phase 1
Phase 3 (US1)          → depends on Phase 2 (locale keys)
Phase 4 (US5)          → depends on Phase 2 (locale keys) — can run in parallel with Phase 3
Phase 5 (US2)          → depends on Phase 2 (UnifiedDoctor model)
Phase 6 (US3)          → depends on Phase 5 (UnifiedDoctorCard must exist)
Phase 7 (US4)          → depends on Phase 2 (UnifiedDoctor model) — can start after Phase 2
Phase 8 (Polish)       → depends on Phases 3–7 complete
```

### Within-Phase Dependencies

**Phase 2**: T002 → [T003 ∥ T004] (both must complete before app compiles); T005 is independent of T002-T004

**Phase 5 (US2)**: T015 → [T016 ∥ T017 ∥ T018 ∥ T019] (card must exist before list screens use it)

**Phase 6 (US3)**: [T020 ∥ T022 ∥ T023] in parallel, then T021 → T024 → T025 → T026 → T027 → T028

**Phase 7 (US4)**: T029 → T030 → T031

### Parallel Opportunities

**Phase 3 (US1)**: T006 ∥ T007 ∥ T008 — all different files

**Phase 4 (US5)**: T009 ∥ T010 ∥ T011 ∥ T012 ∥ T013 ∥ T014 — all different files

**Phase 5 (US2)**: T015 → [T016 ∥ T017 ∥ T018 ∥ T019]

**Phase 6 (US3)**: [T020 ∥ T022 ∥ T023] simultaneously, then sequential tab impls

**Phase 8**: T032 ∥ T033 → T034

---

## Implementation Strategy

### MVP First (US1 + US5 — 10 tasks)

1. Phase 1: T001
2. Phase 2: T002 → [T003 ∥ T004] → T005
3. Phase 3: T006 ∥ T007 ∥ T008
4. Phase 4: T009-T014 (all parallel)
5. **STOP and VALIDATE**: Doctor-first layout, zero jargon labels, no regressions

Delivers SC-001 (2-tap booking path), SC-004 (zero jargon), SC-005 (doctors first in home screen).

### Incremental After MVP

- US2 (Phase 5): Unified card → consistent browsing
- US3 (Phase 6): Unified detail → all options discoverable in one screen
- US4 (Phase 7): QuickBook redesign → most ambitious story
- Phase 8: Polish

---

## Acceptance Verification

| Acceptance Scenario | Tasks |
|---------------------|-------|
| Popular Doctors before Clinics on home screen | T006 |
| "Book a Doctor" 2nd Quick Service card | T007 |
| "Video Consult" 3rd Quick Service card | T007 |
| My Requests: "My Doctor Appointments" / "My Video Consults" | T007 |
| No "Independent Booking" / "Call Booking" text in UI | T007, T009–T014 |
| Unified card in all doctor list contexts | T015–T019 |
| Booking type badges on unified card | T015 |
| Badge tap → direct booking flow | T015 |
| Unified detail screen with Book tab default | T022 |
| Book tab shows available booking methods only | T021, T024 |
| Graceful handling of partial availability | T021 |
| QuickBook searches by doctor name | T029–T031 |
| Booking in ≤4 interactions from QuickBook | T030 |

---

## Notes

- **T002-T004 atomic batch**: Must commit together — app won't compile until both en and ar implement the 4 new abstract getters.
- **T015 back-conversion helpers**: `toClinicDoctor()`, `toCallDoctor()`, `toIndependentDoctor()` on `UnifiedDoctor` needed for badge tap navigation; they reconstruct partial typed objects from `UnifiedDoctor` fields.
- **T016 PopularDoctorData**: Inspect the actual class name and fields in `lib/screens/doctor/model/doctor_list_res.dart` before writing the factory constructor — it may be named differently.
- **T020 endpoint constant**: Check `lib/utils/api_end_points.dart` first — the independent services endpoint may already be defined from a prior module.
- **Existing flows untouched**: `DoctorCard` in `DoctorsListScreen`, `CallDoctorDetailScreen`, `IndependentDoctorDetailScreen`, `BookCallScreen`, `BookIndependentScreen` are not modified (SC-007).
