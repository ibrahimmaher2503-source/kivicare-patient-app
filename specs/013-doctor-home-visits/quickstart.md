# Quickstart: Doctor Home Visit Requests

**Feature**: 013-doctor-home-visits
**Date**: 2026-04-06

## Prerequisites

- Flutter 3.0+ / Dart 3.0+ installed
- Espitalia app builds and runs successfully
- Laravel backend with doctor visit endpoints deployed (v1/doctor-visit/*)
- Valid test accounts (patient, admin, receptionist, doctor roles)

## Integration Points

### 1. Authentication (existing — no changes)

The doctor visit feature uses the existing auth system. All API calls go through `buildHttpResponse()` in `lib/network/network_utils.dart`, which automatically injects Bearer tokens and handles 401 token refresh.

No new authentication setup required.

### 2. API Endpoints

Add 5 endpoint constants to `lib/utils/api_end_points.dart`:

```dart
// Doctor Home Visit
static const String doctorVisitRequests = 'v1/doctor-visit/requests';
static String doctorVisitRequestDetail(String reference) => '$doctorVisitRequests/$reference';
static const String adminDoctorVisitRequests = 'v1/admin/doctor-visit/requests';
static String adminDoctorVisitRequestStatus(String reference) => '$adminDoctorVisitRequests/$reference/status';
static String adminDoctorVisitRequestAssignDoctor(String reference) => '$adminDoctorVisitRequests/$reference/assign-doctor';
```

### 3. Model Classes

Create `lib/screens/doctor_visit/model/doctor_visit_request_model.dart` with:
- `DoctorSummary` (id, name)
- `PatientSummary` (id, name, email)
- `DoctorVisitRequest` (full entity with fromJson/toJson)
- `DoctorVisitRequestListResponse` (paginated wrapper)

Follow existing patterns from `lib/models/test_order_model.dart`:
- Use `?? defaultValue` for null safety
- Check `is Map` / `is List` before nested deserialization
- camelCase Dart properties, snake_case JSON keys

### 4. Localization Keys

Add ~20 keys to all three files:
- `lib/locale/languages.dart` — abstract getters
- `lib/locale/language_en.dart` — English values
- `lib/locale/language_ar.dart` — Arabic values

Key categories:
- Feature labels: `doctorHomeVisit`, `visitRequests`, `submitVisitRequest`
- Form labels: `visitReason`, `preferredDate`, `contactPhone`, `preferredDoctor`, `additionalNotes`
- Status labels: `statusPending`, `statusConfirmed`, `statusCancelled`, `statusCompleted`
- Messages: `visitRequestSubmitted`, `visitRequestUpdated`, `noVisitRequests`
- Admin labels: `assignDoctor`, `updateStatus`, `cancellationReason`

### 5. Navigation Entry Point

Add doctor visit entry to home screen's Quick Services or My Requests section:

```dart
// In lib/screens/home/ component
onTap: () {
  doIfLoggedIn(() {
    Get.to(() => DoctorVisitListScreen());
  });
}
```

### 6. Doctor Picker (reuse existing)

For the "preferred doctor" field in the request form, reuse the existing `getDoctorList` API endpoint. No new doctor-fetching logic needed.

### 7. Date Picker (Flutter Material)

Use `showDatePicker()` with:
- `firstDate: DateTime.now()` — enforces "after_or_equal:today"
- `lastDate: DateTime.now().add(Duration(days: 90))` — reasonable future limit
- No new packages needed

### 8. Role-Based UI

Check `loginUserData.value.userRole` for admin features:
- Patient users see: submit form, my requests list, request detail
- Admin/receptionist users see: all of above + admin list, status update, doctor assignment
- Doctor users see: all of above + admin list (filtered), status update (only assigned)

## New Files Summary

```
lib/screens/doctor_visit/
├── doctor_visit_request_screen.dart        # Submit form
├── doctor_visit_request_controller.dart    # Form controller
├── doctor_visit_list_screen.dart           # My requests list
├── doctor_visit_list_controller.dart       # List controller
├── doctor_visit_detail_screen.dart         # Request detail
├── doctor_visit_detail_controller.dart     # Detail controller
├── model/
│   └── doctor_visit_request_model.dart     # All model classes
└── components/
    ├── doctor_visit_card.dart              # List item card
    └── doctor_visit_status_badge.dart      # Status badge widget

test/
├── unit/models/
│   └── doctor_visit_request_model_test.dart
└── integration/
    └── doctor_visit_request_flow_test.dart
```

## Modified Files

```
lib/utils/api_end_points.dart              # Add 5 endpoint constants
lib/locale/languages.dart                   # Add ~20 abstract getters
lib/locale/language_en.dart                 # Add ~20 English strings
lib/locale/language_ar.dart                 # Add ~20 Arabic strings
lib/screens/home/...                        # Add navigation entry point
```

## Verification Steps

1. `flutter analyze` — zero new warnings
2. `flutter test` — all existing + new tests pass
3. Manual test: submit visit request as patient, view in list, tap for detail
4. Manual test: view admin list as admin/receptionist, filter by status
5. Manual test: update status, assign doctor as admin
6. Manual test: verify patient cannot see other patient's requests
7. Test on Android + one additional platform (iOS or Web)
