# Implementation Plan: Offers & Coupon System Integration

**Branch**: `015-offers-api-integration` | **Date**: 2026-04-16 | **Spec**: [spec.md](./spec.md)
**Input**: Feature specification from `/specs/015-offers-api-integration/spec.md`

## Summary

Integrate a comprehensive offers and coupon system into the Espitalia Patient App. This involves creating 4 new data models (Offer, ActiveOffer, DiscountCalculation, CouponValidation), updating 3 existing models (Doctor, Service, Booking), and adding 7 new API methods to support offer discovery, coupon validation, and discount application during the booking flow.

## Technical Context

**Language/Version**: Dart 3.0+ / Flutter 3.0+
**Primary Dependencies**: GetX 4.7.2+, nb_utils, http package
**Storage**: GetStorage for non-sensitive data; no new storage requirements
**Testing**: flutter_test (widget/unit tests recommended for API parsing)
**Target Platform**: Android, iOS, Web (platform parity required)
**Project Type**: Mobile App (Flutter)
**Performance Goals**: Offer badges render within 100ms of data load; coupon validation < 2s
**Constraints**: Null-safe JSON parsing, additive-only model changes, no breaking changes
**Scale/Scope**: 4 new models, 3 model updates, 7 API methods, ~8 files modified/created

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

| Principle | Status | Notes |
|-----------|--------|-------|
| I. Platform Parity | ✅ PASS | Pure Dart models and API calls - no platform-specific code |
| II. Patient Data Security | ✅ PASS | No sensitive data in offer models; uses existing HTTPS infrastructure |
| III. GetX Architecture | ✅ PASS | Will use existing `locale.value` pattern for localization getters |
| IV. Backend Contract Fidelity | ✅ PASS | New endpoints added to `api_end_points.dart`; follows established patterns |
| V. Localization-First | ✅ PASS | All display text via `displayTitle`/`displayLabel` getters using locale |
| VI. Testing Discipline | ⚠️ RECOMMENDED | Should add tests for JSON parsing edge cases |
| VII. Simplicity | ✅ PASS | No new abstractions; follows existing model patterns exactly |

**Gate Status**: ✅ PASSED - No violations requiring justification

## Project Structure

### Documentation (this feature)

```text
specs/015-offers-api-integration/
├── spec.md              # Feature specification
├── plan.md              # This file
├── research.md          # Phase 0 output
├── data-model.md        # Phase 1 output
├── quickstart.md        # Phase 1 output
├── contracts/           # Phase 1 output (API contracts)
└── checklists/
    └── requirements.md  # Spec quality checklist
```

### Source Code (repository root)

```text
lib/
├── screens/
│   ├── offers/
│   │   └── model/
│   │       ├── offer_model.dart           # NEW: Full Offer model
│   │       ├── active_offer_model.dart    # NEW: Lightweight ActiveOffer
│   │       ├── discount_calculation_model.dart  # NEW: Discount breakdown
│   │       └── coupon_validation_model.dart     # NEW: Validation result
│   ├── doctor/
│   │   └── model/
│   │       └── doctor_list_res.dart       # UPDATE: Add hasActiveOffer
│   ├── service/
│   │   └── model/
│   │       └── service_list_model.dart    # UPDATE: Add activeOffers, bestOffer
│   └── booking/
│       └── model/
│           ├── appointments_res_model.dart     # UPDATE: Add offer fields
│           └── appointment_detail_res.dart     # UPDATE: Add offer fields
├── api/
│   └── offers_apis.dart                   # NEW: All offer API methods
└── utils/
    └── api_end_points.dart               # UPDATE: Add offer endpoints

test/
└── screens/
    └── offers/
        └── model/
            └── offer_model_test.dart      # RECOMMENDED: Parsing tests
```

**Structure Decision**: Follows existing Flutter app conventions with models co-located in feature directories (`lib/screens/offers/model/`). API methods centralized in `lib/api/offers_apis.dart` following `core_apis.dart` pattern.

## Complexity Tracking

> No violations to justify - all changes follow existing patterns.

| Aspect | Complexity Level | Justification |
|--------|------------------|---------------|
| New models | Low | Standard Dart classes with fromJson/toJson |
| Model updates | Low | Additive fields only, no signature changes |
| API integration | Low | Follows established `core_apis.dart` patterns |
| Localization | Low | Uses existing `locale.value` global state |
