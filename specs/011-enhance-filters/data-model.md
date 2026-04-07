# Data Model: Enhance Filter Screens & Controllers

**Branch**: `011-enhance-filters` | **Date**: 2026-04-05

## Entities

### FilterParams

Typed parameter class replacing the positional `Get.arguments` List. Passed when opening FilterScreen.

| Field | Type | Default | Description |
|-------|------|---------|-------------|
| clinicId | int | -1 | Pre-selected clinic ID |
| serviceType | String | "" | "In Clinic" / "Online" / "" |
| priceMin | String | "" | Minimum price (as string for API) |
| priceMax | String | "" | Maximum price (as string for API) |
| moduleType | String | required | "doctor" / "service" / "clinic" / "category" |
| categoryId | int | -1 | Pre-selected category ID |
| governorateId | int? | null | Pre-selected governorate |
| cityId | int? | null | Pre-selected city |
| specialtyId | int? | null | Pre-selected specialty (doctors only) |
| gender | String | "" | Pre-selected gender (doctors only) |
| ratingMin | String | "" | Minimum rating (doctors only) |
| ratingMax | String | "" | Maximum rating (doctors only) |

**Validation**: `moduleType` is required and must be one of the four recognized values.

### FilterTypeConfig

Defines which filter types are available for each module.

| Field | Type | Description |
|-------|------|-------------|
| key | String | Filter type identifier (e.g., "location", "clinic", "price") |
| label | String | Localized display label |
| modules | List<String> | Which module types show this filter |

**Static configuration** (not API-driven):

| Filter Type | Doctor | Service | Clinic | Category |
|-------------|--------|---------|--------|----------|
| Location | yes | yes | yes | yes |
| Clinic | yes | yes | - | yes |
| Price | - | - | - | yes |
| Rating | yes | - | - | - |
| Service | yes | - | yes | - |
| Category | - | yes | - | - |
| Service Type | yes | - | - | - |
| Specialty | yes | - | - | - |
| Gender | yes | - | - | - |

### ActiveFilterCount (Computed)

Not a stored entity — derived from current FilterController state.

**Computation logic**: For each filter parameter, check if it differs from its default value. Count non-default parameters.

| Parameter | Default | "Active" when |
|-----------|---------|---------------|
| clinicId | -1 | > 0 |
| serviceType | "" | non-empty |
| priceMin/priceMax | "" / "" | either non-empty and non-zero |
| ratingMin/ratingMax | "" / "" | either non-empty |
| governorateId | null | non-null |
| cityId | null | non-null |
| specialtyId | null | non-null |
| gender | "" | non-empty |
| categoryId | -1 | > 0 |
| serviceId | -1 | > 0 |

## Relationships

```
FilterParams ──passes-to──> FilterController ──applies-to──> ListController
                                   │
                                   ├── DoctorListController
                                   ├── ServiceListController
                                   ├── ClinicListController
                                   └── (future: LabsListController, etc.)
```

## State Transitions

```
FilterScreen opened
  → FilterController.onInit() reads FilterParams
  → Populates reactive vars from params
  → User interacts with filter widgets
  → User taps "Apply"
    → applyFilter() writes to target ListController
    → Computes activeFilterCount
    → Get.back(result: activeFilterCount)
    → ListController refreshes its list from API
  → User taps "Reset"
    → resetFilter() clears all reactive vars to defaults
    → applyFilter() with isReset=true
    → Get.back(result: 0)
```
