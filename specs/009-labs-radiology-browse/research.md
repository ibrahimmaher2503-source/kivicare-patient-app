# Research: Labs & Radiology Centers Browse

**Feature Branch**: `009-labs-radiology-browse`
**Date**: 2026-04-02

## R1: Existing RadiologyCenter Model

**Decision**: Reuse the existing `RadiologyCenter` model at `lib/screens/radiology/model/radiology_center_model.dart`.

**Rationale**: The model already includes all needed fields (id, name, scanTypes, governorate, city) plus pagination response handling (`RadiologyCenterListResponse`). The model has extra fields (description, address, contactNumber, email, profileImage, rating, operatingHours, pricing) which are simply ignored on the card — they'll be useful when a detail screen is added later.

**Alternatives considered**:
- Create a new minimal `RadiologyCenter` model under `lab_test/model/` — rejected because it would duplicate the existing model and create drift.
- Extend the existing model — not needed, it already has everything.

## R2: Lab Model (New)

**Decision**: Create a new `Lab` model at `lib/screens/lab_test/model/lab_model.dart`.

**Rationale**: No existing model matches the Lab entity. The `LabTest` model represents a test/procedure, not a physical facility. The Lab API response is simple: `{id, name, governorate, city}`. A lightweight model avoids carrying irrelevant fields.

**Alternatives considered**:
- Reuse `LabTest` model — rejected because LabTest has 12+ fields specific to test procedures (code, sampleType, price, turnaroundTime) that don't apply to physical labs.
- Use a generic `Map<String, dynamic>` — rejected per constitution principle VII (maintainability).

## R3: Navigation Pattern

**Decision**: Use direct `Get.to()` navigation, not named routes.

**Rationale**: The entire codebase (261 files) uses `Get.to(() => Screen())` with `arguments: {}` for parameter passing. No `app_routes.dart` or `app_pages.dart` exists. Introducing named routes would break the existing convention and add unnecessary infrastructure.

**Alternatives considered**:
- Create `app_routes.dart` / `app_pages.dart` for the whole app — rejected as out of scope and would touch dozens of existing files.
- Named routes for just these 2 screens — rejected for inconsistency.

## R4: API Call Pattern — Public Endpoints

**Decision**: Both APIs are called via `buildHttpResponse()` without authentication headers.

**Rationale**: The spec states both endpoints are public (no auth). The existing `buildHttpResponse()` function already handles the case where no auth token is needed — it only adds `Authorization: Bearer` when `loginUserData.value.apiToken` is available. Both `labsSearch` and `radiologySearch` endpoints are already defined in `api_end_points.dart`.

**Alternatives considered**: N/A — standard pattern.

## R5: Scan Type Filter Values

**Decision**: Use existing `ScanTypeConst` values from `lib/utils/constants.dart`.

**Rationale**: Constants already defined: `mri`, `ct`, `xray`, `ultrasound`, `mammogram`, `dexa`. The user's spec lists: MRI, CT, X-ray, Ultrasound as chips. Match these to the existing constants. The "All" option sends no `scan_type` parameter (empty string).

**Alternatives considered**:
- Hardcode strings in the controller — rejected per existing convention of using constants.

## R6: GovernoratesCityPicker Integration

**Decision**: Use the existing `GovernoratesCityPicker` widget as-is.

**Rationale**: The component at `lib/components/governorates_city_picker.dart` provides:
- `onGovernorateChanged(int?)` callback
- `onCityChanged(int?)` callback
- Session-level caching of governorates/cities
- Styled with the design system (12px radius, modern fills)

No modifications needed. Both new screens pass their controller's reactive IDs and re-fetch on change.

**Alternatives considered**: N/A — exact fit.

## R7: Existing Locale Keys

**Decision**: Some locale keys already exist; add only the missing ones.

**Rationale**: Already available:
- `labTests`, `laboratory`, `radiology`, `all`, `searchHere`, `noDataFound`, `somethingWentWrong`
- `radiologyCenters`, `availableScans`, `noRadiologyCentersFound`
- `governorate`, `allGovernorates`, `allCities`, `selectGovernorate`

Still needed:
- `labs` (short title for the Labs screen — distinct from `labTests`)
- `browseLabs` (subtitle)
- `scanType` (filter label)
- `noLabsFound` (empty state)
- Scan type labels: `mri`, `ct`, `xray`, `ultrasound` (display labels if not already present)

**Alternatives considered**: N/A.
