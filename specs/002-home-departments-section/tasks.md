# Tasks: Home Page Departments Section

**Input**: Design documents from `/specs/002-home-departments-section/`
**Prerequisites**: plan.md (required), spec.md (required), research.md, data-model.md, quickstart.md

**Tests**: Not requested in specification. Tests are RECOMMENDED per constitution but not included in this task list.

**Organization**: Tasks are grouped by user story to enable independent implementation and testing of each story.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (e.g., US1, US2, US3)
- Include exact file paths in descriptions

## Path Conventions

- **Flutter mobile app**: `lib/` for source, `assets/` for resources, `test/` for tests
- Paths are relative to repository root

---

## Phase 1: Setup

**Purpose**: Add icon assets and ensure project builds cleanly

- [X] T001 Add 5 department icon PNG files to `assets/icons/`: `ic_department_doctors.png`, `ic_department_clinics.png`, `ic_department_radiology.png`, `ic_department_intensive_care.png`, `ic_department_nurse_requests.png`. If custom icons are not yet available, create simple colored placeholder PNGs (64x64) so the build succeeds and cards render with visible icons.
- [X] T002 Run `flutter pub get` to regenerate `lib/generated/assets.dart` with the new icon asset paths. Verify the generated file contains entries for all five new icons.

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Add all localization strings required by the department components. MUST complete before any user story implementation since components reference these locale keys.

**CRITICAL**: No user story work can begin until this phase is complete.

- [X] T003 Add abstract getter declarations to `lib/locale/languages.dart` (BaseLanguage class): `departments`, `radiology`, `intensiveCare`, `nurseRequests`, `comingSoon`. Check if `doctors` and `clinics` already exist — only add if missing.
- [X] T004 [P] Add English translations to `lib/locale/language_en.dart`: departments → "Departments", radiology → "Radiology", intensiveCare → "Intensive Care", nurseRequests → "Nurse Requests", comingSoon → "Coming Soon"
- [X] T005 [P] Add Arabic translations to `lib/locale/language_ar.dart`: departments → "الأقسام", radiology → "الأشعة", intensiveCare → "العناية المركزة", nurseRequests → "طلبات التمريض", comingSoon → "قريباً"
- [X] T006 [P] Add German translations to `lib/locale/language_de.dart`: departments → "Abteilungen", radiology → "Radiologie", intensiveCare → "Intensivstation", nurseRequests → "Pflegeanfragen", comingSoon → "Demnächst"
- [X] T007 [P] Add French translations to `lib/locale/language_fr.dart`: departments → "Départements", radiology → "Radiologie", intensiveCare → "Soins Intensifs", nurseRequests → "Demandes Infirmières", comingSoon → "Bientôt Disponible"
- [X] T008 [P] Add Hindi translations to `lib/locale/language_hi.dart`: departments → "विभाग", radiology → "रेडियोलॉजी", intensiveCare → "गहन चिकित्सा", nurseRequests → "नर्स अनुरोध", comingSoon → "जल्द आ रहा है"

**Checkpoint**: Run `flutter analyze` — zero new warnings. All locale files compile without missing override errors.

---

## Phase 3: User Story 1 - Browse Active Departments (Priority: P1) MVP

**Goal**: Patient sees 5 department cards on home screen. Tapping "Doctors" navigates to doctor list; tapping "Clinics" navigates to clinic list.

**Independent Test**: Open home screen → verify 5 cards visible → tap Doctors → doctor list opens → go back → tap Clinics → clinic list opens.

### Implementation for User Story 1

- [X] T009 [P] [US1] Create `lib/screens/home/components/department_card_widget.dart`: A StatelessWidget that accepts department name (String), icon asset path (String), isActive (bool), and onTap (VoidCallback?). Renders a card with: icon image (using `CachedImageWidget` or `Image.asset`), department name text below, GestureDetector wrapping the card. Use `context.cardColor` for background and `boxDecorationDefault()` for card styling. Support dark mode via `isDarkMode.value` from `common_base.dart`. Card width: `Get.width / 3 - 24` to show ~3 cards visible at a time.
- [X] T010 [US1] Create `lib/screens/home/components/departments_component.dart`: A StatelessWidget containing a Column with: `16.height` top spacing, `ViewAllLabel(label: locale.value.departments, isShowAll: false)` with standard padding `.paddingOnly(left: 16, right: 8)`, and a `HorizontalList` with `spacing: 16` and `padding: EdgeInsets.symmetric(horizontal: 16)`. Define a static list of 5 department entries inline with: (1) Doctors — `isActive: true`, `onTap: () => Get.to(() => DoctorViewListScreen(title: locale.value.doctors, isFromDashboard: true), arguments: {"isPopular": 1})`, (2) Clinics — `isActive: true`, `onTap: () => Get.to(() => ClinicListComponent(title: locale.value.clinics, isFromDashboard: true), arguments: {"isPopular": 1})`, (3) Radiology — `isActive: false, onTap: null`, (4) Intensive Care — `isActive: false, onTap: null`, (5) Nurse Requests — `isActive: false, onTap: null`. Use locale keys for all department names and generated asset constants for icons.
- [X] T011 [US1] Insert `DepartmentsComponent()` into `lib/screens/home/home_screen.dart` inside the Column children list, between `SliderComponent()` and `QuickBookComponent()`. Add the import for `departments_component.dart` at the top of the file.

**Checkpoint**: Run `flutter run` — home screen shows 5 department cards after the banner. Tapping Doctors opens doctor list. Tapping Clinics opens clinic list. Other 3 cards do nothing yet (no tap handler wired).

---

## Phase 4: User Story 2 - Coming Soon Departments (Priority: P1)

**Goal**: Radiology, Intensive Care, and Nurse Requests cards show a "Coming Soon" badge and display a toast on tap. They are visually distinct from active cards.

**Independent Test**: On home screen → verify coming-soon cards have badge/overlay → tap Radiology → toast appears → tap Intensive Care → toast appears → tap Nurse Requests → toast appears → verify no navigation occurs on any tap.

### Implementation for User Story 2

- [X] T012 [US2] Add coming-soon visual state to `lib/screens/home/components/department_card_widget.dart`: When `isActive` is `false`, wrap card content in `Opacity(opacity: 0.5)` to mute the card visually. Add a `Positioned` "Coming Soon" text label (using `locale.value.comingSoon`) inside a `Stack` overlay on the card. Use small font size (8-10sp), `appColorSecondary` background with white text, positioned at top-right of the card with `BorderRadius` for a badge appearance.
- [X] T013 [US2] Add coming-soon tap handler in `lib/screens/home/components/departments_component.dart`: For departments where `isActive` is `false`, set the `onTap` callback to `() => toast(locale.value.comingSoon)` instead of `null`. This ensures tapping a coming-soon card shows user feedback rather than being unresponsive. Import `toast` from `nb_utils`.

**Checkpoint**: Run `flutter run` — coming-soon cards appear muted with badge. Tapping any of the 3 coming-soon cards shows "Coming Soon" toast. No navigation occurs. Active cards (Doctors, Clinics) are visually distinct and still navigate correctly.

---

## Phase 5: User Story 3 - Section Placement and Layout (Priority: P2)

**Goal**: Departments section feels native to the home screen with consistent styling, proper horizontal scroll, and RTL support.

**Independent Test**: Verify section title matches other section titles in font/size → scroll horizontally to see all 5 cards → switch to Arabic locale and verify RTL card order → toggle dark mode and verify styling.

### Implementation for User Story 3

- [X] T014 [US3] Verify and adjust `ViewAllLabel` usage in `lib/screens/home/components/departments_component.dart`: Ensure the `label` parameter uses the same text style as existing sections (check `ChooseCategoryComponents` and `PerfectClinicComponent` for reference). Set `isShowAll: false` since there is no "View All" destination for departments. Ensure padding matches: `.paddingOnly(left: 16, right: 8)`.
- [X] T015 [US3] Verify horizontal scroll behavior in `lib/screens/home/components/departments_component.dart`: Ensure `HorizontalList` renders all 5 cards scrollably on narrow screens (320dp width). Cards should not overflow or clip. Confirm `spacing: 16` and `padding: EdgeInsets.symmetric(horizontal: 16)` match other home screen sections.
- [X] T016 [US3] Verify RTL support in `lib/screens/home/components/departments_component.dart` and `lib/screens/home/components/department_card_widget.dart`: Ensure no hardcoded `left`/`right` padding that would break RTL. Use `paddingSymmetric` or directional-aware padding where applicable. `HorizontalList` from nb_utils handles RTL reversal automatically. Verify text alignment in department cards uses `TextAlign.center` or directional alignment.

**Checkpoint**: Run `flutter run` with Arabic locale — cards appear in RTL order. Switch back to English — cards appear in LTR order. Toggle dark mode — all card colors update correctly. Scroll horizontally on narrow screen — all 5 cards accessible.

---

## Phase 6: Polish & Cross-Cutting Concerns

**Purpose**: Final verification and cleanup

- [X] T017 Run `flutter analyze` and fix any warnings introduced by new files in `lib/screens/home/components/departments_component.dart` and `lib/screens/home/components/department_card_widget.dart`
- [X] T018 Verify the Departments section renders for logged-out users: launch app without logging in, confirm departments section is visible on home screen (no auth guard on the section)
- [X] T019 Run quickstart.md verification steps (all 11 steps) from `specs/002-home-departments-section/quickstart.md` as a final smoke test

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies — can start immediately
- **Foundational (Phase 2)**: Depends on Phase 1 (icons must exist for asset generation). BLOCKS all user stories.
- **User Story 1 (Phase 3)**: Depends on Phase 2 (locale keys must compile)
- **User Story 2 (Phase 4)**: Depends on Phase 3 (card widget must exist to add coming-soon state)
- **User Story 3 (Phase 5)**: Depends on Phase 3 (component must exist to verify layout)
- **Polish (Phase 6)**: Depends on all user stories being complete

### User Story Dependencies

- **User Story 1 (P1)**: Can start after Foundational (Phase 2) — creates the core components
- **User Story 2 (P1)**: Depends on User Story 1 — modifies the card widget created in US1
- **User Story 3 (P2)**: Can start after User Story 1 — verifies and adjusts layout created in US1. Can run in parallel with User Story 2 if desired.

### Within Each User Story

- T009 and T010: T009 (card widget) can be built in parallel with T010 (section component) since T010 imports T009 but they are separate files
- T010 depends on T009 at integration time
- T011 depends on T010 (must have component to insert)
- T012 depends on T009 (must have card widget to add coming-soon state)
- T013 depends on T010 (must have component to add toast handlers)
- T014-T016 depend on T010 (must have component to verify)

### Parallel Opportunities

- **Phase 2**: T004, T005, T006, T007, T008 can ALL run in parallel (different language files)
- **Phase 3**: T009 can run in parallel with early parts of T010 (separate files)
- **Phase 5**: T014, T015, T016 can all run in parallel (independent verification tasks)

---

## Parallel Example: Phase 2 (Foundational)

```bash
# After T003 completes (abstract base class), launch all translations in parallel:
Task: "Add English translations in lib/locale/language_en.dart"
Task: "Add Arabic translations in lib/locale/language_ar.dart"
Task: "Add German translations in lib/locale/language_de.dart"
Task: "Add French translations in lib/locale/language_fr.dart"
Task: "Add Hindi translations in lib/locale/language_hi.dart"
```

## Parallel Example: Phase 3 (User Story 1)

```bash
# Launch card widget and section component in parallel:
Task: "Create department_card_widget.dart in lib/screens/home/components/"
Task: "Create departments_component.dart in lib/screens/home/components/"
# Then sequentially:
Task: "Insert DepartmentsComponent into home_screen.dart"
```

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Complete Phase 1: Setup (add icons)
2. Complete Phase 2: Foundational (add locale strings)
3. Complete Phase 3: User Story 1 (create components + insert in home)
4. **STOP and VALIDATE**: 5 department cards visible, Doctors/Clinics navigate correctly
5. This is a functional MVP — departments are visible and active ones work

### Incremental Delivery

1. Complete Setup + Foundational → build succeeds with new assets and strings
2. Add User Story 1 → 5 cards render, 2 navigate → Deploy/Demo (MVP!)
3. Add User Story 2 → coming-soon cards have badge + toast → Deploy/Demo
4. Add User Story 3 → layout polished, RTL verified → Deploy/Demo
5. Polish → analyze clean, logged-out verified → Final delivery

---

## Notes

- [P] tasks = different files, no dependencies
- [Story] label maps task to specific user story for traceability
- US1 and US2 are both P1 but US2 depends on US1 (modifies card widget created in US1)
- US3 is mostly verification/adjustment of work done in US1
- No API changes, no backend dependencies — entire feature is client-side
- Total: 19 tasks across 6 phases
- Icon assets may need designer input — placeholder PNGs are acceptable for development
- Commit after each phase checkpoint for clean git history
