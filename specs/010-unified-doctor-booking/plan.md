# Implementation Plan: Unified Doctor-First Booking Experience

**Branch**: `010-unified-doctor-booking` | **Date**: 2026-04-05 | **Spec**: `specs/010-unified-doctor-booking/spec.md`
**Input**: Feature specification from `/specs/010-unified-doctor-booking/spec.md`

## Summary

Restructure the Espitalia patient app to prioritize direct doctor booking. The work aggregates three fragmented booking systems (clinic-based, call, independent) into a unified frontend layer — a `UnifiedDoctor` model with `BookingCapability` list, a single card design, and a tabbed detail screen. The home screen section order is reordered to surface Popular Doctors first, Quick Services cards are reordered and relabeled, and all user-facing jargon ("Independent Booking", "Call Booking") is replaced with patient-friendly terms. No backend changes required — the frontend aggregates from existing separate API endpoints using `doctorId` as the deduplication key.

---

## Technical Context

**Language/Version**: Dart 3.0+ / Flutter 3.0+
**Primary Dependencies**: GetX 4.7.2 (state management + navigation), nb_utils (UI helpers), Google Fonts
**Storage**: GetStorage (local state); no new storage requirements
**Testing**: `flutter test` (widget tests recommended for UnifiedDoctorCard, UnifiedDoctorDetailController)
**Target Platform**: Android, iOS, Web (all three per constitution Principle I)
**Project Type**: Mobile app (Flutter)
**Performance Goals**: Doctor list loads ≤2s; capabilities load in parallel on detail open; slot fetch ≤1.5s
**Constraints**: No backend changes; must preserve all 3 booking flows end-to-end; English + Arabic; dark mode; RTL
**Scale/Scope**: ~261 existing Dart files; this feature touches ~15 files, creates ~5 new files

---

## Constitution Check

*Re-verified after Phase 1 design.*

### I. Platform Parity ✅
All new widgets (`UnifiedDoctorCard`, `UnifiedDoctorDetailScreen`, home section reorder) use standard Flutter/GetX patterns with no platform-specific code. Dark mode handled via existing `isDarkMode` reactive var. RTL maintained — no hardcoded directional offsets introduced.

### II. Patient Data Security ✅
No new API endpoints introduced. All existing API calls already use HTTPS via `network_utils.dart`. No new credential storage. The `doctorId` deduplication key is non-sensitive.

### III. GetX Architecture Consistency ✅
- All new state uses `.obs` + `Obx()`
- Navigation uses `Get.to()` exclusively
- `UnifiedDoctorDetailController` embedded in detail screen (current convention)
- No competing state management

### IV. Backend Contract Fidelity ✅
- No existing API contracts modified
- Three existing endpoints reused as-is: `v1/get-doctor-list`, `v1/call-doctors`, `v1/independent-doctors`
- New API method `getIndependentDoctorServices()` follows `buildHttpResponse() → handleResponse() → deserialization` pattern
- All endpoints remain in `api_end_points.dart`

### V. Localization-First ✅
Four new locale keys added to both language files (en + ar). Arabic uses English fallback with `// TODO: translate` comment. No hardcoded user-facing strings.

### VI. Testing Discipline (RECOMMENDED) ✅
Widget tests planned for `UnifiedDoctorCard` and integration test for unified detail booking flow. Not blocking for P1/P5 label changes.

### VII. Simplicity & Maintainability ✅
- No new packages introduced
- `UnifiedDoctor` model uses factory constructors instead of inheritance hierarchy
- `BookingCapability` is a plain class (no repository pattern)
- Existing booking flows untouched — unified screen delegates to them
- Source files kept under 500 lines (detail screen split into tab components)

**Gate result**: PASS — no violations.

---

## Project Structure

### Documentation (this feature)

```text
specs/010-unified-doctor-booking/
├── plan.md              # This file
├── research.md          # Phase 0 output — all NEEDS CLARIFICATION resolved
├── data-model.md        # Phase 1 output — UnifiedDoctor, BookingCapability, ServiceInfo entities
├── quickstart.md        # Phase 1 output — implementation guide per user story
├── contracts/           # Phase 1 output — API and navigation contracts
│   ├── api-contracts.md
│   └── navigation-contracts.md
└── tasks.md             # Phase 2 output (created by /speckit.tasks — NOT this command)
```

### Source Code (repository root)

```text
lib/
├── locale/
│   ├── language_en.dart                   # MODIFY — add 4 new keys
│   ├── language_ar.dart                   # MODIFY — add 4 new keys (+ TODO: translate)
│   ├── language_de.dart                   # MODIFY — add 4 new keys (+ TODO: translate)
│   ├── language_fr.dart                   # MODIFY — add 4 new keys (+ TODO: translate)
│   └── language_hi.dart                   # MODIFY — add 4 new keys (+ TODO: translate)
│
├── screens/
│   ├── home/
│   │   ├── home_screen.dart               # MODIFY — reorder sections (indices 5-7)
│   │   └── components/
│   │       ├── quick_services_component.dart  # MODIFY — reorder cards, update labels
│   │       └── quick_book_component.dart      # MODIFY (P4) — doctor-first redesign
│   │
│   ├── doctor/
│   │   ├── model/
│   │   │   └── unified_doctor_model.dart      # CREATE — UnifiedDoctor, BookingCapability, BookingType, ServiceInfo
│   │   ├── components/
│   │   │   ├── unified_doctor_card.dart       # CREATE — single card for all contexts
│   │   │   └── popular_doctor_component.dart  # MODIFY — use UnifiedDoctorCard
│   │   ├── unified_doctor_detail_screen.dart  # CREATE — tabbed screen (Book/About/Reviews/Quals)
│   │   └── unified_doctor_detail_controller.dart  # CREATE — loads capabilities from 3 APIs
│   │
│   ├── search/
│   │   └── doctor_search_screen.dart          # MODIFY — use UnifiedDoctorCard, navigate to unified detail
│   │
│   ├── call_booking/
│   │   ├── call_doctor_list_screen.dart       # MODIFY — use UnifiedDoctorCard
│   │   └── components/call_doctor_card.dart   # KEEP (used internally in booking flow)
│   │
│   └── independent_booking/
│       ├── independent_doctor_list_screen.dart  # MODIFY — use UnifiedDoctorCard
│       └── components/independent_doctor_card.dart  # KEEP (used internally in booking flow)

test/
└── screens/
    └── doctor/
        ├── unified_doctor_model_test.dart     # RECOMMENDED — factory constructors + merge logic
        └── unified_doctor_card_test.dart      # RECOMMENDED — badge rendering per capability
```

**Structure Decision**: Single Flutter project with new files in existing `lib/screens/doctor/` tree. All 5 user stories target only the frontend layer — no new directories outside `lib/screens/doctor/` and `lib/locale/`.

---

## Phase 0 Output: Research

See `research.md` for complete findings. Summary of key decisions:

| Question | Resolution |
|----------|-----------|
| Backend unified endpoint? | Not available. Frontend aggregation via `doctorId` dedup key. |
| Doctor ID consistency? | ✅ `doctorId: int` present in all 3 models with identical JSON key `doctor_id` |
| Booking flow reuse? | ✅ Existing flows preserved; unified detail delegates to each. |
| Home reorder breaks animation? | No — staggered system uses list index; reorder auto-fixes timing. |
| Search covers all booking types? | No — `searchDoctors` is clinic-based only. Capabilities loaded lazily on detail. |

---

## Phase 1 Output: Design

### Data Model (`data-model.md`)

**New entities**:
- `BookingType` (enum): `clinic | videoCall | phoneCall | inPerson`
- `BookingCapability`: `type, isAvailable, startingPrice, services: List<ServiceInfo>`
- `ServiceInfo`: unified wrapper over `ServiceElement`, `CallService`, `IndependentService`
- `UnifiedDoctor`: common identity core + `bookingCapabilities: List<BookingCapability>`

**Factory constructors**: `UnifiedDoctor.fromDoctor()`, `.fromCallDoctor()`, `.fromIndependentDoctor()`, `.fromTopDoctor()`

**Dedup merge**: `UnifiedDoctor.mergeWith(other)` — appends capabilities by `doctorId`

**Unchanged**: `Doctor`, `CallDoctor`, `IndependentDoctor` — not modified; serve as source types

**New locale keys** (en + ar): `bookADoctor`, `videoConsult`, `myDoctorAppointments`, `myVideoConsults`

### Contracts (`contracts/`)

See `contracts/api-contracts.md` and `contracts/navigation-contracts.md`.

**API integration**: 3 existing endpoints consumed without modification; 1 method added to `CoreServiceApis` for independent doctor services loading
**Navigation**: `UnifiedDoctorCard` navigates to `UnifiedDoctorDetailScreen(doctor: UnifiedDoctor)` on body tap; badge taps navigate directly to existing booking screens

### Quickstart (`quickstart.md`)

Priority-ordered implementation guide:
1. **P1** (3 files, ~20 lines): Reorder home sections + Quick Services cards
2. **P5** (5 locale files): Add 4 patient-friendly label keys
3. **P2** (2 new files, 4 modified): UnifiedDoctor model + UnifiedDoctorCard
4. **P3** (3 new files, N modified): UnifiedDoctorDetailScreen with booking tabs
5. **P4** (2 new files, 1 modified): Doctor-first QuickBook widget (highest effort)

---

## Implementation Decisions

### D1: Home Screen Reorder (P1)

Swap indices in `home_screen.dart` `_children` list:

**Before**: `[..., PopularServiceComponent, PerfectClinicComponent, PopularDoctorComponent]` (indices 5, 6, 7)
**After**: `[..., PopularDoctorComponent, PopularServiceComponent, PerfectClinicComponent]` (indices 5, 6, 7)

3-line change. Animation timing corrects automatically via index-based stagger.

### D2: Quick Services Card Reorder (P1)

In `quick_services_component.dart`, move the "Independent Booking" entry from position 8 to position 1 and "Call Booking" from position 7 to position 2. Update display labels to use new locale keys `bookADoctor` and `videoConsult`.

### D3: UnifiedDoctor Model (P2)

New file: `lib/screens/doctor/model/unified_doctor_model.dart`
- `BookingType` enum (4 values)
- `BookingCapability` plain class
- `ServiceInfo` plain class with `rawService: dynamic` field for API calls
- `UnifiedDoctor` plain class with factory constructors and `mergeWith()` method
- `deduplicateDoctors()` top-level function

No inheritance hierarchy. No new packages.

### D4: UnifiedDoctorCard (P2)

New file: `lib/screens/doctor/components/unified_doctor_card.dart`

Card shows:
- Profile image (CachedImageWidget, 80px diameter)
- Name, specialty (nb_utils text styles)
- Star rating + review count
- Booking type badges (only for `isAvailable == true` capabilities)
- "Currently Unavailable" chip if `capabilities.isEmpty`
- Body tap → `Get.to(() => UnifiedDoctorDetailScreen(doctor: doctor))`
- Badge tap → direct navigation to relevant booking screen

Used in: `PopularDoctorComponent`, `DoctorSearchScreen`, `CallDoctorListScreen`, `IndependentDoctorListScreen`

The clinic `DoctorsListScreen` (selection wizard) keeps `DoctorCard` — it uses selection state not applicable here.

### D5: UnifiedDoctorDetailScreen (P3)

New files: `unified_doctor_detail_screen.dart` + `unified_doctor_detail_controller.dart`

**Controller** fires 3 parallel futures on `onInit`:
1. `getDoctorDetails(doctorId)` → clinic services + qualifications + reviews
2. `getCallDoctorServices(doctorId)` → call capabilities (catchError → empty)
3. `getIndependentDoctorServices(doctorId)` → independent capabilities (catchError → empty)

**Screen** uses `DefaultTabController` with 4 tabs: Book, About, Reviews, Qualifications.

**Book tab** renders one `BookingMethodSection` per capability. Each section:
- Header: icon + label + starting price badge
- Expandable: service dropdown, date picker, slot grid
- "Book Now" button → navigates to existing booking confirmation flow

**Existing detail screens** (`DoctorDetailScreen`, `CallDoctorDetailScreen`, `IndependentDoctorDetailScreen`) kept intact. Navigation points updated to route to `UnifiedDoctorDetailScreen` instead.

### D6: Label Updates (P5)

Update quick service card labels and My Requests tile labels in `quick_services_component.dart`. Update app bar titles in `call_doctor_list_screen.dart`, `independent_doctor_list_screen.dart`, `call_doctor_detail_screen.dart`, `independent_doctor_detail_screen.dart`, `book_call_screen.dart`, `book_independent_screen.dart`.

All via new locale keys — no hardcoded strings.

### D7: Doctor-First QuickBook Widget (P4)

Replace `QuickBookComponent` service-first flow. New step order:
1. "Search doctor or specialty" → `CoreServiceApis.searchDoctors()` → doctor selector bottom sheet
2. Select booking type (chips: At Clinic / Video / Phone / In-Person) — only shows types where doctor has capability
3. Date picker
4. Slot grid (calls appropriate slot endpoint per booking type)
5. "Book Now" → appropriate booking API

**Implemented last** (highest risk, most UI change). Uses `UnifiedDoctor` model from P2.

---

## Complexity Tracking

> No constitution violations — this table is empty by design.

| Violation | Why Needed | Simpler Alternative Rejected Because |
|-----------|------------|-------------------------------------|
| (none) | — | — |
