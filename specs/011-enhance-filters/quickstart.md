# Quickstart: Enhance Filter Screens & Controllers

**Branch**: `011-enhance-filters` | **Date**: 2026-04-05

## Prerequisites

- Flutter 3.0+ / Dart 3.0+ installed
- Android emulator or device connected
- Run `flutter pub get` to ensure dependencies are current

## Key Files to Modify

### Core Filter Logic
- `lib/screens/booking/filter/filter_controller.dart` — Main changes: add FilterParams class, location/specialty/gender vars, consolidated filter count, updated applyFilter()
- `lib/screens/booking/filter/filter_screen.dart` — Update to accept FilterParams, apply design tokens

### Filter Components (UI Updates)
- `lib/screens/booking/filter/components/type_list_component.dart` — Add shadow/gradient on selection
- `lib/screens/booking/filter/components/filter_category.dart` — Add shadow on selected chips
- `lib/screens/booking/filter/components/filter_service.dart` — Add shadow on selected chips
- `lib/screens/booking/filter/components/service_type_filter/filter_service_type_component.dart` — Add shadow on selected chips
- `lib/screens/booking/filter/components/rating_filter.dart` — Fix hardcoded "Rating" string

### New Filter Component
- `lib/screens/booking/filter/components/filter_location_component.dart` — New: GovernoratesCityPicker wrapper for filter modal
- `lib/screens/booking/filter/components/filter_specialty_component.dart` — New: specialty picker for doctor module
- `lib/screens/booking/filter/components/filter_gender_component.dart` — New: gender selector for doctor module

### List Screens (Badge + Argument Updates)
- `lib/screens/home/components/doctor_list_screen.dart` — Pass FilterParams, unified badge
- `lib/screens/home/components/clinic_list_screen.dart` — Pass FilterParams, unified badge
- `lib/screens/home/components/popular_service_list.dart` — Pass FilterParams, unified badge
- `lib/screens/service/services_list_screen.dart` — Pass FilterParams, unified badge

### List Controllers (New Filter Params)
- `lib/screens/doctor/doctor_list_controller.dart` — Add specialtyId, gender vars; pass to searchDoctors()
- `lib/screens/clinic/clinic_list_controller.dart` — Already has location; ensure consistency
- `lib/screens/service/service_list_controller.dart` — Add governorateId/cityId if needed

### Locale
- `lib/locale/languages.dart` — Add `filterLocation` key to BaseLanguage
- `lib/locale/language_en.dart` — Add English value
- `lib/locale/language_ar.dart` — Add Arabic value

## Running & Testing

```bash
# Run the app
flutter run

# Quick verification flow:
# 1. Open Doctor list → tap filter icon → verify Location filter type appears
# 2. Select a governorate → verify city dropdown enables
# 3. Apply → verify doctor list filters by location
# 4. Verify badge shows correct count
# 5. Reset → verify badge clears, all results return
# 6. Switch to Arabic → verify all labels display in Arabic

# Static analysis
flutter analyze
```

## Architecture Notes

- **State management**: All filter state uses GetX `.obs` observables and `Obx()` widgets
- **Navigation**: FilterScreen opened via `Get.to()`, results returned via `Get.back(result: ...)`
- **API**: All search methods already accept governorate_id, city_id, specialty_id, gender — just need to wire params through
- **Design tokens**: Use colors from `lib/utils/colors.dart` (surfaceElevated, glassStroke, softShadowColor, etc.)
- **Fonts**: Google Fonts — Plus Jakarta Sans (body) + Outfit (headers)
