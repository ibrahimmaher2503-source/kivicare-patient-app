# Quickstart: Unified Doctor-First Booking Experience

**Branch**: `010-unified-doctor-booking` | **Date**: 2026-04-02

## Prerequisites

- Flutter 3.0+ / Dart 3.0+ installed
- Project dependencies installed (`flutter pub get`)
- Backend API running at `https://espitalia.net/api/`
- Connected device/emulator for testing

## Implementation Order

Execute user stories in priority order. Each is independently testable.

### P1: Doctor-First Home Screen Layout (Quick Win)

**Files to modify** (3 files, ~20 lines changed):

1. `lib/screens/home/home_screen.dart`
   - Reorder sections: move `PopularDoctorComponent` to index 5 (before PopularService and PerfectClinic)

2. `lib/screens/home/components/quick_services_component.dart`
   - Move "Independent Booking" card from position 9 to position 2
   - Move "Call Booking" card from position 8 to position 3

3. `lib/screens/doctor/components/popular_doctor_card.dart`
   - Add a "Book" button/icon that navigates to doctor detail

**Verify**: Open app → scroll home screen → Popular Doctors appears before Clinics; Quick Service cards show doctor options first.

### P5: Patient-Friendly Labels (Quick Win — do alongside P1)

**Files to modify** (5 locale files):

1. `lib/locale/language_en.dart` — rename keys
2. `lib/locale/language_ar.dart` — rename keys
3. `lib/locale/language_de.dart` — rename keys
4. `lib/locale/language_fr.dart` — rename keys
5. `lib/locale/language_hi.dart` — rename keys

**Key renames**: "Independent Booking" → "Book a Doctor", "Call Booking" → "Video Consult", plus My Requests labels.

**Verify**: Navigate all screens → no "Independent Booking" or "Call Booking" text visible.

### P2: Unified Doctor Card

**Files to create**:

1. `lib/screens/doctor/model/unified_doctor_model.dart` — UnifiedDoctor, BookingCapability, BookingType, ServiceInfo
2. `lib/screens/doctor/components/unified_doctor_card.dart` — single card widget

**Files to modify**:

3. `lib/screens/doctor/components/popular_doctor_component.dart` — use UnifiedDoctorCard
4. `lib/screens/home/components/doctor_list_screen.dart` — use UnifiedDoctorCard
5. `lib/screens/clinic/components/clinic_doctors_component.dart` — use UnifiedDoctorCard
6. `lib/screens/search/doctor_search_screen.dart` — use UnifiedDoctorCard

**Verify**: All doctor lists render the same card design.

### P3: Unified Doctor Detail with Booking Tabs

**Files to create**:

1. `lib/screens/doctor/unified_doctor_detail_screen.dart` — main screen with tabs
2. `lib/screens/doctor/unified_doctor_detail_controller.dart` — loads capabilities from 3 APIs
3. `lib/screens/doctor/components/booking_method_section.dart` — expandable booking section per type

**Files to modify**:

4. All navigation points that currently go to `DoctorDetailScreen`, `CallDoctorDetailScreen`, or `IndependentDoctorDetailScreen` — redirect to unified screen

**Verify**: Open any doctor → see Book/About/Reviews/Quals tabs → Book tab shows all available methods → can complete booking via any method.

### P4: Doctor-First Quick Book Widget

**Files to create**:

1. `lib/screens/home/components/doctor_quick_book_component.dart` — new widget
2. `lib/screens/home/components/doctor_quick_book_controller.dart` — controller

**Files to modify**:

3. `lib/screens/home/home_screen.dart` — replace QuickBookComponent with DoctorQuickBookComponent

**Verify**: Home screen QuickBook shows "Search doctor or specialty" → search returns doctors → can book.

## Key Patterns

### Creating UnifiedDoctor from existing models

```dart
// From clinic search
final unified = UnifiedDoctor.fromDoctor(clinicDoctor);

// From call booking
final unified = UnifiedDoctor.fromCallDoctor(callDoctor);

// Merging capabilities on detail screen
unified.loadCapabilities(); // fires 3 parallel API calls
```

### Loading booking capabilities lazily

```dart
Future<void> loadCapabilities(int doctorId) async {
  // Fire all 3 in parallel, catch errors individually
  final results = await Future.wait([
    CoreServiceApis.getDoctorDetails(doctorId: doctorId).catchError((_) => null),
    CoreServiceApis.getCallDoctorServices(doctorId: doctorId).catchError((_) => []),
    CoreServiceApis.getIndependentDoctorServices(doctorId: doctorId).catchError((_) => []),
  ]);
  // Build capabilities from non-null/non-empty results
}
```

### Slot fetching per booking type

```dart
switch (bookingType) {
  case BookingType.clinic:
    // GET /get-time-slots?doctor_id=&clinic_id=&service_id=&appointment_date=
  case BookingType.videoCall:
  case BookingType.phoneCall:
    // POST /v1/call-doctors/{id}/slots {date, call_service_id}
  case BookingType.inPerson:
    // POST /v1/independent-doctors/{id}/slots {date, independent_service_id}
}
```

## Testing Checklist

- [ ] P1: Home sections in correct order (Doctors before Clinics)
- [ ] P1: Quick Service cards reordered (Book a Doctor 2nd, Video Consult 3rd)
- [ ] P1: Popular Doctor card has Book action
- [ ] P5: No "Independent Booking" text anywhere in UI
- [ ] P5: No "Call Booking" text anywhere in UI
- [ ] P2: Unified card renders in all doctor list contexts
- [ ] P3: Detail screen shows all booking types for multi-capability doctor
- [ ] P3: Can complete clinic booking from unified detail
- [ ] P3: Can complete call booking from unified detail
- [ ] P3: Can complete independent booking from unified detail
- [ ] P4: QuickBook searches doctors by name
- [ ] P4: QuickBook completes booking in 4 interactions
- [ ] All: Dark mode renders correctly
- [ ] All: Arabic (RTL) layout works
