# Quickstart: Offers & Coupon System Integration

**Feature**: 015-offers-api-integration
**Date**: 2026-04-16

---

## Implementation Order

1. **Models** (create in order):
   - `lib/screens/offers/model/active_offer_model.dart`
   - `lib/screens/offers/model/offer_model.dart`
   - `lib/screens/offers/model/discount_calculation_model.dart`
   - `lib/screens/offers/model/coupon_validation_model.dart`

2. **API Endpoints** (add to `lib/utils/api_end_points.dart`):
   ```dart
   static const String offersPublic = '${baseUrl}v1/offers/public';
   static const String offersPublicBySlug = '${baseUrl}v1/offers/public/'; // append slug
   static const String serviceOffers = '${baseUrl}v1/services/'; // append {id}/offers
   static const String validateCoupon = '${baseUrl}v1/offers/validate-coupon';
   static const String calculateDiscount = '${baseUrl}v1/offers/calculate-discount';
   static const String applyOffer = '${baseUrl}v1/offers/apply';
   static const String removeOffer = '${baseUrl}v1/offers/remove';
   ```

3. **API Service** (create `lib/api/offers_apis.dart`):
   - Follow `core_apis.dart` static method pattern
   - 7 methods matching contract endpoints

4. **Model Updates** (additive changes only):
   - `lib/screens/doctor/model/doctor_list_res.dart` → add `hasActiveOffer`
   - `lib/screens/service/model/service_list_model.dart` → add `activeOffers`, `bestOffer`
   - `lib/screens/booking/model/appointments_res_model.dart` → add offer fields
   - `lib/screens/booking/model/appointment_detail_res.dart` → add offer fields

---

## Key Patterns

### Model fromJson
```dart
// Null-safe defensive parsing
field: json['field'] is Type ? json['field'] : defaultValue,

// List parsing
list: json['list'] is List
    ? List<T>.from(json['list'].map((x) => T.fromJson(x)))
    : [],

// Nullable DateTime
endsAt: json['ends_at'] is String ? DateTime.tryParse(json['ends_at']) : null,
```

### Localization Getter
```dart
import '../../main.dart'; // for locale

String get displayTitle => locale.value.languageCode == 'ar' ? titleAr : titleEn;
```

### API Method
```dart
static Future<List<Offer>> getPublicOffers({int page = 1, int perPage = 15}) async {
  final response = await handleResponse(
    await buildHttpResponse(
      '${APIEndPoints.offersPublic}?page=$page&per_page=$perPage',
      method: HttpMethodType.GET,
    ),
  );
  return (response['data'] as List)
      .map((x) => Offer.fromJson(x))
      .toList();
}
```

---

## Computed Getters Reference

### Offer
- `displayTitle` → Localized title
- `displayLabel` → Localized short label
- `displayDescription` → Localized description
- `displayTerms` → Localized terms
- `isExpired` → `endsAt != null && endsAt!.isBefore(DateTime.now())`
- `isActive` → Not expired and started
- `timeRemaining` → `endsAt?.difference(DateTime.now())`

### ActiveOffer
- `isExpired` → Same as above
- `formattedDiscount` → "20%" or "EGP 50"

### ServiceElement (after update)
- `bestOffer` → Highest discount offer or null

---

## Validation Failure Reasons

| Reason | User Message |
|--------|-------------|
| `expired` | "This coupon has expired" |
| `not_started` | "This coupon is not yet active" |
| `not_applicable` | "This coupon is not valid for this service" |
| `usage_limit_reached` | "This coupon has reached its usage limit" |
| `minimum_not_met` | "Minimum order amount not met" |
| `invalid_code` | "Invalid coupon code" |

---

## Import Paths

From service/doctor models to ActiveOffer:
```dart
import '../../offers/model/active_offer_model.dart';
```

From anywhere to locale:
```dart
import '../../main.dart';
```

---

## Testing Checklist

- [ ] Offer.fromJson with all fields populated
- [ ] Offer.fromJson with null optional fields
- [ ] ActiveOffer.fromJson parsing
- [ ] DiscountCalculation.fromJson with breakdown
- [ ] CouponValidation.fromJson success case
- [ ] CouponValidation.fromJson failure case
- [ ] ServiceElement.fromJson with activeOffers
- [ ] ServiceElement.bestOffer returns highest discount
- [ ] Doctor.fromJson with hasActiveOffer
- [ ] Localized getters return correct language
