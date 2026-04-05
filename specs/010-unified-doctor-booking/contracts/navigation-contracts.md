# Navigation Contracts: Unified Doctor-First Booking Experience

**Feature**: 010-unified-doctor-booking
**Date**: 2026-04-05

All navigation uses GetX: `Get.to()`, `Get.back()`, `Get.offAll()`. No `Navigator.push()` direct usage.

---

## New Screen: UnifiedDoctorDetailScreen

**File**: `lib/screens/doctor/unified_doctor_detail_screen.dart`

**Arguments** (passed via GetX arguments or constructor):
```dart
final UnifiedDoctor doctor;   // REQUIRED — pre-populated from list card
```

**Entry points** (navigates FROM):
| Source | Context | Navigation Call |
|--------|---------|----------------|
| `UnifiedDoctorCard` body tap | All doctor list contexts | `Get.to(() => UnifiedDoctorDetailScreen(doctor: unified))` |
| `PopularDoctorComponent` | Home screen | `Get.to(() => UnifiedDoctorDetailScreen(doctor: unified))` |
| `DoctorSearchScreen` result tap | Search hub | `Get.to(() => UnifiedDoctorDetailScreen(doctor: unified))` |

**Exit points** (navigates TO from this screen):
| Tab | Action | Navigates To |
|-----|--------|-------------|
| Book — At Clinic | "Book Now" | Existing `BookingFormScreen` (with doctor + service pre-selected) |
| Book — Video Call | "Book Now" | Existing `BookCallScreen` (with callDoctor + service pre-selected) |
| Book — Phone Call | "Book Now" | Existing `BookCallScreen` (callType: phone) |
| Book — In-Person | "Book Now" | Existing `BookIndependentScreen` (with independentDoctor + service pre-selected) |
| Reviews tab | Paginated scroll | (no navigation — in-tab) |
| About tab | Social links | `launchUrl()` for external links |

---

## Modified Navigation: UnifiedDoctorCard Badge Taps

The unified card shows booking badges. Badge taps skip the detail screen and go directly to booking:

```dart
// Badge tap routing
switch (capability.type) {
  case BookingType.clinic:
    // Navigate to clinic booking flow
    // Requires reconstructing a Doctor object from UnifiedDoctor for the existing flow
    Get.to(() => DoctorDetailScreen(doctorData: doctor.toDoctor()));
  case BookingType.videoCall:
  case BookingType.phoneCall:
    // Navigate to call booking flow
    // Requires fetching or caching CallDoctor data
    Get.to(() => CallDoctorDetailScreen(callDoctorData: doctor.toCallDoctor()));
  case BookingType.inPerson:
    // Navigate to independent booking flow
    Get.to(() => IndependentDoctorDetailScreen(doctorData: doctor.toIndependentDoctor()));
}
```

**Note**: When `UnifiedDoctor` was built from a single-type source (e.g., `fromDoctor()`), the `toCallDoctor()` and `toIndependentDoctor()` back-conversion cannot fully populate capabilities (e.g., `hasVideoCall` is unknown from the clinic model alone). In this case, badge taps are only shown for capabilities that are confirmed from the original source model. If the card is shown from a list that only provides clinic doctors, only the clinic badge appears.

---

## Unchanged Navigation (Existing Flows Preserved)

| Source | Navigates To | Change |
|--------|-------------|--------|
| `DoctorCard` selection in `DoctorsListScreen` | Booking wizard continuation | None |
| `CallDoctorListScreen` card tap | `CallDoctorDetailScreen` | Replaced with `UnifiedDoctorCard` but same destination if badge not tapped; body tap goes to `UnifiedDoctorDetailScreen` |
| `IndependentDoctorListScreen` card tap | `IndependentDoctorDetailScreen` | Same as above |
| `BookCallScreen` | `PaymentScreen` | None |
| `BookIndependentScreen` | `PaymentScreen` | None |

---

## Quick Services Navigation (P1)

The Quick Services cards' navigation targets are unchanged. Only card order and display labels change:

| Card | Navigation Target | Change |
|------|------------------|--------|
| "Book a Doctor" (was "Independent Booking") | `IndependentDoctorListScreen` | Label only |
| "Video Consult" (was "Call Booking") | `CallDoctorListScreen` | Label only |

---

## QuickBook Widget Navigation (P4)

New doctor-first QuickBook widget navigation:

```
Step 1: Search bar → doctor results bottom sheet
Step 2: Doctor selected → booking type chips
Step 3: Booking type selected → date picker shown
Step 4: Date selected → slot fetch → slot grid shown
Step 5: Slot selected → "Book Now" → appropriate booking endpoint → confirmation
```

The confirmation screen is the existing `BookingSuccessScreen` or equivalent, already used by all 3 booking flows.
