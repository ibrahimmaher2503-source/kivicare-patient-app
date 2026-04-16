# Quickstart: Labs & Radiology Centers Browse

**Feature Branch**: `009-labs-radiology-browse`
**Date**: 2026-04-02

## Prerequisites

- Flutter 3.0+ / Dart 3.0+ installed
- Branch `009-labs-radiology-browse` checked out
- `flutter pub get` run

## What to Build (in order)

### Step 1: Lab Model + API Method

1. Create `lib/screens/lab_test/model/lab_model.dart`
   - `Lab` class: `{id, name, governorate, city}` with `fromJson()` / `toJson()`
   - `LabListResponse` class parsing `data.items[]` + `data.pagination{}`
   - Reuse existing `Governorate` and `City` models from `lib/models/`

2. Add `searchLabs()` static method to `lib/api/core_apis.dart`
   - Follow the existing `searchLabs()` pattern (which searches LabTests)
   - Use `APIEndPoints.labsSearch` endpoint
   - Params: page, perPage, testName, governorateId, cityId
   - Parse into `LabListResponse`, manage list + pagination callback

### Step 2: Radiology Centers API Method

1. Reuse existing `RadiologyCenter` model from `lib/screens/radiology/model/radiology_center_model.dart`

2. Add `searchRadiologyCenters()` static method to `lib/api/core_apis.dart`
   - Use `APIEndPoints.radiologySearch` endpoint
   - Params: page, perPage, scanType, governorateId, cityId
   - Parse into `RadiologyCenterListResponse`

### Step 3: Labs List Screen

1. Create `lib/screens/lab_test/labs_list_controller.dart` — clone pattern from `lab_test_list_controller.dart`:
   - `RxList<Lab>`, search debounce, governorate/city filters, pagination
   - No department filter (labs only)

2. Create `lib/screens/lab_test/components/lab_card.dart`
   - Display: lab name, governorate, city
   - Follow `LabTestCard` styling (16px radius, soft shadows, gradient accents)

3. Create `lib/screens/lab_test/labs_list_screen.dart`
   - Search bar + GovernoratesCityPicker + paginated list of LabCards

### Step 4: Radiology Centers Screen

1. Create `lib/screens/lab_test/radiology_centers_controller.dart`
   - Same as LabsListController but add: `selectedScanType` RxString + scan type chips
   - Use `ScanTypeConst` values from `lib/utils/constants.dart`

2. Create `lib/screens/lab_test/components/radiology_center_card.dart`
   - Display: center name, scan type badge, governorate, city

3. Create `lib/screens/lab_test/radiology_centers_screen.dart`
   - Search bar + scan type chips + GovernoratesCityPicker + paginated list

### Step 5: Navigation Integration

1. Modify `lib/screens/lab_test/lab_test_categories_screen.dart`
   - Smart routing: if category is radiology → navigate to RadiologyCentersScreen

2. Modify `lib/screens/home/components/quick_services_component.dart`
   - Add "Labs" and "Radiology Centers" navigation cards

### Step 6: Localization

1. Add new keys to all 5 language files in `lib/locale/`
   - `labs`, `browseLabs`, `noLabsFound`, `scanType`
   - Scan type display labels if not already present

## Key Patterns to Follow

- **Controller lifecycle**: `Get.put()` in `initState()`, `Get.delete()` in `dispose()`
- **Pagination**: page starts at 1, clear list on page 1, append on subsequent pages
- **Search debounce**: `debounce(searchQuery, (_) { ... }, time: Duration(milliseconds: 500))`
- **Navigation**: `Get.to(() => Screen(), arguments: {'key': value})`
- **Styling**: Use `GoogleFonts.outfit()` for headings, `GoogleFonts.plusJakartaSans()` for body, 16px card radius
