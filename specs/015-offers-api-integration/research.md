# Research: Offers & Coupon System Integration

**Feature**: 015-offers-api-integration
**Date**: 2026-04-16

## Research Summary

All technical decisions for this feature are informed by existing codebase patterns and documented API contracts. No external research was required as the implementation follows established conventions.

---

## 1. Model Parsing Patterns

**Decision**: Use null-safe defensive parsing for all JSON fields

**Rationale**: Existing models in the codebase (`ServiceElement`, `Doctor`, etc.) use explicit type checking patterns:
```dart
// Pattern used consistently across codebase
field: json['field'] is Type ? json['field'] : defaultValue,
// For lists:
list: json['list'] is List ? List<T>.from(json['list'].map((x) => T.fromJson(x))) : [],
```

**Alternatives considered**:
- `json['field'] as Type?` - Rejected: Throws on type mismatch instead of using default
- `json['field'] ?? defaultValue` - Rejected: Doesn't handle wrong type (e.g., int instead of String)

**Source**: `lib/screens/service/model/service_list_model.dart` lines 161-194

---

## 2. Localization Getter Pattern

**Decision**: Use `locale.value.languageCode` from global state for display getters

**Rationale**: The app maintains `locale` as a global reactive variable in `main.dart`. All localized content checks `locale.value.languageCode == 'ar'` for RTL/Arabic support.

**Implementation pattern**:
```dart
String get displayTitle => locale.value.languageCode == 'ar' ? titleAr : titleEn;
```

**Alternatives considered**:
- Using `Get.locale` - Rejected: Codebase uses custom `locale` variable, not GetX's built-in
- Passing locale as parameter - Rejected: Would require refactoring all call sites

**Source**: Constitution Principle V (Localization-First), `lib/main.dart`

---

## 3. API Service Pattern

**Decision**: Create `OffersApis` class following `CoreServiceApis` static method pattern

**Rationale**: All existing API methods follow this exact pattern:
```dart
static Future<ReturnType> methodName({params}) async {
  final response = await handleResponse(
    await buildHttpResponse(
      '${APIEndPoints.endpoint}?query=$params',
      method: HttpMethodType.GET,
    ),
  );
  return ReturnType.fromJson(response);
}
```

**Alternatives considered**:
- Instance methods with dependency injection - Rejected: Would break consistency with 1400+ line `core_apis.dart`
- Repository pattern wrapper - Rejected: Constitution Principle VII (Simplicity) - no abstractions without proven reuse

**Source**: `lib/api/core_apis.dart` entire file

---

## 4. Endpoint Naming Convention

**Decision**: Use `v1/offers/*` prefix for new endpoints

**Rationale**: Newer endpoints in the codebase use `v1/` prefix (nurses, pharmacy, lab-tests). Legacy endpoints omit version prefix. Following modern convention.

**Endpoints to add**:
- `v1/offers/public` - List public offers
- `v1/offers/public/{slug}` - Single offer by slug
- `v1/services/{id}/offers` - Service-specific offers
- `v1/offers/validate-coupon` - POST coupon validation
- `v1/offers/calculate-discount` - POST discount calculation
- `v1/offers/apply` - POST apply offer
- `v1/offers/remove` - POST remove offer

**Source**: `lib/utils/api_end_points.dart` lines 74-166

---

## 5. DateTime Handling

**Decision**: Parse dates as `DateTime?` using `DateTime.tryParse()`, store as nullable

**Rationale**: Offer `startsAt` and `endsAt` fields may be null (no expiry). Use `tryParse` for safety:
```dart
endsAt: json['ends_at'] is String ? DateTime.tryParse(json['ends_at']) : null,
```

**Computed getters**:
```dart
bool get isExpired => endsAt != null && endsAt!.isBefore(DateTime.now());
Duration? get timeRemaining => endsAt?.difference(DateTime.now());
```

**Alternatives considered**:
- Store as String, parse on access - Rejected: Inefficient, repeated parsing
- Require non-null dates - Rejected: API contract allows null for unlimited offers

---

## 6. Existing Model Updates Strategy

**Decision**: Additive-only changes to existing models

**Rationale**: Constitution Principle IV (Backend Contract Fidelity) requires not breaking existing signatures. Updates must:
1. Add new nullable fields with defaults
2. Parse new fields defensively (handle missing keys)
3. Include new fields in `toJson()` only if non-null

**Doctor model addition**:
```dart
// In constructor defaults
this.hasActiveOffer = false,

// In fromJson
hasActiveOffer: json['has_active_offer'] is bool ? json['has_active_offer'] : false,
```

**ServiceElement model addition**:
```dart
// Field
List<ActiveOffer> activeOffers;

// Constructor default
this.activeOffers = const <ActiveOffer>[],

// fromJson
activeOffers: json['active_offers'] is List
    ? List<ActiveOffer>.from(json['active_offers'].map((x) => ActiveOffer.fromJson(x)))
    : [],

// Getter
ActiveOffer? get bestOffer => activeOffers.isEmpty
    ? null
    : activeOffers.reduce((a, b) => a.discountValue > b.discountValue ? a : b);
```

**Source**: `lib/screens/doctor/model/doctor_list_res.dart`, `lib/screens/service/model/service_list_model.dart`

---

## 7. Discount Breakdown List Structure

**Decision**: Use separate `DiscountBreakdownItem` class for breakdown entries

**Rationale**: The `discount_breakdown` array in API response contains objects with offer details. Type safety requires a dedicated model:

```dart
class DiscountBreakdownItem {
  int offerId;
  String title;
  String code;
  String discountType;
  num discountAmount;
}
```

**Source**: API contract spec section 5 (POST /offers/calculate-discount response)

---

## Resolved Clarifications

| Item | Resolution |
|------|------------|
| Import path for ActiveOffer | `import '../../../screens/offers/model/active_offer_model.dart'` from service/doctor models |
| Main locale accessor | `locale.value.languageCode` from `lib/main.dart` (requires import) |
| Nullable vs default empty for activeOffers | Default empty list `const <ActiveOffer>[]` for null-safety |
| bestOffer when empty list | Return `null`, not throw - callers check `service.bestOffer != null` |

---

## No External Dependencies Required

All implementation uses existing packages:
- `http` - Already in pubspec for API calls
- `get` - Already in pubspec for reactive state
- No new packages needed
