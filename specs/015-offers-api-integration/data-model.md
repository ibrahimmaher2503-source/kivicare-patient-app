# Data Model: Offers & Coupon System Integration

**Feature**: 015-offers-api-integration
**Date**: 2026-04-16

---

## New Entities

### 1. Offer (Full Model)

**Location**: `lib/screens/offers/model/offer_model.dart`
**Purpose**: Complete offer representation for public listings and detail views

| Field | Type | JSON Key | Default | Description |
|-------|------|----------|---------|-------------|
| id | int | `id` | -1 | Unique identifier |
| slug | String | `slug` | "" | URL-safe identifier |
| titleEn | String | `title_en` | "" | English title |
| titleAr | String | `title_ar` | "" | Arabic title |
| shortLabelEn | String | `short_label_en` | "" | English badge text (e.g., "20% OFF") |
| shortLabelAr | String | `short_label_ar` | "" | Arabic badge text |
| descriptionEn | String | `description_en` | "" | English description |
| descriptionAr | String | `description_ar` | "" | Arabic description |
| termsEn | String | `terms_en` | "" | English terms & conditions |
| termsAr | String | `terms_ar` | "" | Arabic terms & conditions |
| discountType | String | `discount_type` | "" | "percentage" or "fixed" |
| discountValue | num | `discount_value` | 0 | Discount amount/percentage |
| code | String | `code` | "" | Coupon code (if applicable) |
| autoApply | bool | `auto_apply` | false | Auto-apply without code entry |
| startsAt | DateTime? | `starts_at` | null | Offer start date |
| endsAt | DateTime? | `ends_at` | null | Offer expiry date |
| isFlash | bool | `is_flash` | false | Time-limited flash sale |
| bannerText | String | `banner_text` | "" | Promotional banner text |
| bannerImage | String | `banner_image` | "" | Banner image URL |
| servicesCount | int | `services_count` | 0 | Number of applicable services |
| branchesCount | int | `branches_count` | 0 | Number of applicable branches |
| maxDiscountAmount | num | `max_discount_amount` | 0 | Cap for percentage discounts |
| minimumOrderAmount | num | `minimum_order_amount` | 0 | Minimum order threshold |

**Computed Getters**:
- `String get displayTitle` → Returns `titleAr` or `titleEn` based on `locale.value.languageCode`
- `String get displayLabel` → Returns `shortLabelAr` or `shortLabelEn` based on locale
- `String get displayDescription` → Returns `descriptionAr` or `descriptionEn` based on locale
- `String get displayTerms` → Returns `termsAr` or `termsEn` based on locale
- `bool get isExpired` → Returns `endsAt != null && endsAt!.isBefore(DateTime.now())`
- `Duration? get timeRemaining` → Returns `endsAt?.difference(DateTime.now())`
- `bool get isActive` → Returns `!isExpired && (startsAt == null || startsAt!.isBefore(DateTime.now()))`

---

### 2. ActiveOffer (Lightweight Model)

**Location**: `lib/screens/offers/model/active_offer_model.dart`
**Purpose**: Minimal offer data embedded in service/doctor responses

| Field | Type | JSON Key | Default | Description |
|-------|------|----------|---------|-------------|
| id | int | `id` | -1 | Offer ID |
| title | String | `title` | "" | Localized title (from backend) |
| label | String | `label` | "" | Localized badge label |
| discountType | String | `discount_type` | "" | "percentage" or "fixed" |
| discountValue | num | `discount_value` | 0 | Discount amount/percentage |
| code | String | `code` | "" | Coupon code (empty if auto-apply) |
| autoApply | bool | `auto_apply` | false | Auto-apply flag |
| endsAt | DateTime? | `ends_at` | null | Expiry timestamp |

**Computed Getters**:
- `bool get isExpired` → Returns `endsAt != null && endsAt!.isBefore(DateTime.now())`
- `String get formattedDiscount` → Returns "20%" or "EGP 50" based on discountType

---

### 3. DiscountCalculation

**Location**: `lib/screens/offers/model/discount_calculation_model.dart`
**Purpose**: Result of discount calculation API call

| Field | Type | JSON Key | Default | Description |
|-------|------|----------|---------|-------------|
| originalPrice | num | `original_price` | 0 | Price before discount |
| discountAmount | num | `discount_amount` | 0 | Total discount value |
| discountedPrice | num | `discounted_price` | 0 | Final price after discount |
| appliedOfferId | int? | `applied_offer_id` | null | ID of applied offer |
| appliedOfferCode | String | `applied_offer_code` | "" | Code of applied offer |
| appliedOfferTitle | String | `applied_offer_title` | "" | Title of applied offer |
| discountBreakdown | List\<DiscountBreakdownItem\> | `discount_breakdown` | [] | Itemized discount details |

---

### 4. DiscountBreakdownItem

**Location**: `lib/screens/offers/model/discount_calculation_model.dart` (same file)
**Purpose**: Single entry in discount breakdown list

| Field | Type | JSON Key | Default | Description |
|-------|------|----------|---------|-------------|
| offerId | int | `offer_id` | -1 | Offer ID |
| title | String | `title` | "" | Offer title |
| code | String | `code` | "" | Coupon code |
| discountType | String | `discount_type` | "" | "percentage" or "fixed" |
| discountAmount | num | `discount_amount` | 0 | Discount for this item |

---

### 5. CouponValidation

**Location**: `lib/screens/offers/model/coupon_validation_model.dart`
**Purpose**: Result of coupon validation API call

| Field | Type | JSON Key | Default | Description |
|-------|------|----------|---------|-------------|
| success | bool | `status` | false | Validation success flag |
| offerId | int? | `offer_id` | null | Validated offer ID |
| code | String | `code` | "" | Validated coupon code |
| title | String | `title` | "" | Offer title |
| discountType | String | `discount_type` | "" | "percentage" or "fixed" |
| discountValue | num | `discount_value` | 0 | Discount amount/percentage |
| originalPrice | num | `original_price` | 0 | Original price |
| discountAmount | num | `discount_amount` | 0 | Calculated discount |
| finalPrice | num | `final_price` | 0 | Price after discount |
| terms | String | `terms` | "" | Offer terms |
| failureReason | String | `reason` | "" | Error reason if failed |
| message | String | `message` | "" | API message |

**Computed Getters**:
- `bool get isValid` → Alias for `success`

---

## Updated Entities

### 6. Doctor (Update)

**Location**: `lib/screens/doctor/model/doctor_list_res.dart`
**Change Type**: Additive field

| New Field | Type | JSON Key | Default | Description |
|-----------|------|----------|---------|-------------|
| hasActiveOffer | bool | `has_active_offer` | false | Has applicable offers |

**Parsing addition**:
```dart
hasActiveOffer: json['has_active_offer'] is bool ? json['has_active_offer'] : false,
```

---

### 7. ServiceElement (Update)

**Location**: `lib/screens/service/model/service_list_model.dart`
**Change Type**: Additive field + computed getter

| New Field | Type | JSON Key | Default | Description |
|-----------|------|----------|---------|-------------|
| activeOffers | List\<ActiveOffer\> | `active_offers` | [] | List of active offers |

**New Getter**:
```dart
ActiveOffer? get bestOffer => activeOffers.isEmpty
    ? null
    : activeOffers.reduce((a, b) => a.discountValue > b.discountValue ? a : b);
```

**Required Import**:
```dart
import '../../offers/model/active_offer_model.dart';
```

---

### 8. AppointmentData (Update)

**Location**: `lib/screens/booking/model/appointments_res_model.dart`
**Change Type**: Additive fields

| New Field | Type | JSON Key | Default | Description |
|-----------|------|----------|---------|-------------|
| offerId | int? | `offer_id` | null | Applied offer ID |
| offerDiscount | num | `offer_discount` | 0 | Discount amount applied |
| offerCode | String | `offer_code` | "" | Coupon code used |

---

### 9. AppointmentDetailData (Update)

**Location**: `lib/screens/booking/model/appointment_detail_res.dart`
**Change Type**: Additive fields (same as AppointmentData)

| New Field | Type | JSON Key | Default | Description |
|-----------|------|----------|---------|-------------|
| offerId | int? | `offer_id` | null | Applied offer ID |
| offerDiscount | num | `offer_discount` | 0 | Discount amount applied |
| offerCode | String | `offer_code` | "" | Coupon code used |

---

## Entity Relationships

```
┌─────────────┐         ┌─────────────────┐
│   Offer     │         │  ActiveOffer    │
│  (full)     │◄────────│  (lightweight)  │
└─────────────┘         └────────┬────────┘
                                 │ embedded in
                                 ▼
                        ┌─────────────────┐
                        │ ServiceElement  │
                        └────────┬────────┘
                                 │ offered by
                                 ▼
                        ┌─────────────────┐
                        │    Doctor       │
                        │ hasActiveOffer  │
                        └─────────────────┘

┌──────────────────┐     ┌──────────────────┐
│ CouponValidation │────▶│DiscountCalculation│
│  (validation)    │     │   (calculation)   │
└──────────────────┘     └────────┬─────────┘
                                  │ contains
                                  ▼
                         ┌───────────────────────┐
                         │DiscountBreakdownItem  │
                         └───────────────────────┘
                                  │ stored in
                                  ▼
                         ┌───────────────────────┐
                         │  AppointmentData      │
                         │  (offer fields)       │
                         └───────────────────────┘
```

---

## Validation Rules

| Entity | Field | Rule |
|--------|-------|------|
| Offer | discountType | Must be "percentage" or "fixed" |
| Offer | discountValue | Must be >= 0; if percentage, <= 100 |
| Offer | code | Max 50 characters |
| DiscountCalculation | discountedPrice | Must equal originalPrice - discountAmount |
| CouponValidation | finalPrice | Must equal originalPrice - discountAmount when success=true |
| ActiveOffer | discountValue | Must be > 0 for display |

---

## State Transitions

**Offer Lifecycle**:
```
Created → Active → Expired
           ↓
        isFlash=true → Flash Expired (time-based)
```

**Coupon Application Flow**:
```
Not Applied → Validating → Applied (success)
                   ↓
              Failed (show failureReason)
```
