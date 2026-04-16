# API Contract: Offers Module

**Feature**: 015-offers-api-integration
**Base URL**: `https://espitalia.net/api/`
**Date**: 2026-04-16

---

## Endpoints Summary

| Method | Endpoint | Auth | Description |
|--------|----------|------|-------------|
| GET | `/v1/offers/public` | No | List public offers |
| GET | `/v1/offers/public/{slug}` | No | Get offer by slug |
| GET | `/v1/services/{id}/offers` | No | Get service-specific offers |
| POST | `/v1/offers/validate-coupon` | Yes | Validate coupon code |
| POST | `/v1/offers/calculate-discount` | Yes | Calculate discount preview |
| POST | `/v1/offers/apply` | Yes | Apply offer to booking |
| POST | `/v1/offers/remove` | Yes | Remove applied offer |

---

## 1. GET `/v1/offers/public`

**Auth**: None
**Description**: List active, featured public offers with pagination

### Request

**Query Parameters**:
| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| page | int | No | 1 | Page number |
| per_page | int | No | 15 | Items per page |

### Response (200 OK)

```json
{
  "status": true,
  "data": [
    {
      "id": 42,
      "slug": "20-off-dental-checkup",
      "title_en": "20% Off Dental Checkup",
      "title_ar": "خصم 20% على فحص الأسنان",
      "short_label_en": "20% OFF",
      "short_label_ar": "خصم 20%",
      "description_en": "Get 20% off your first dental checkup...",
      "description_ar": "احصل على خصم 20% على فحص الأسنان الأول...",
      "terms_en": "Valid for new patients only...",
      "terms_ar": "صالح للمرضى الجدد فقط...",
      "discount_type": "percentage",
      "discount_value": 20.00,
      "code": "DENTAL20",
      "auto_apply": false,
      "starts_at": "2026-04-01T00:00:00Z",
      "ends_at": "2026-06-30T23:59:59Z",
      "is_flash": false,
      "banner_text": "Limited Time!",
      "banner_image": "https://espitalia.net/storage/offers/dental-banner.jpg",
      "services_count": 5,
      "branches_count": 3,
      "max_discount_amount": 500.00,
      "minimum_order_amount": 100.00
    }
  ],
  "meta": {
    "total": 10,
    "current_page": 1,
    "last_page": 1,
    "per_page": 15
  }
}
```

---

## 2. GET `/v1/offers/public/{slug}`

**Auth**: None
**Description**: Get single offer details by slug

### Request

**Path Parameters**:
| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| slug | string | Yes | Offer slug |

### Response (200 OK)

```json
{
  "status": true,
  "data": {
    "id": 42,
    "slug": "20-off-dental-checkup",
    "title_en": "20% Off Dental Checkup",
    "title_ar": "خصم 20% على فحص الأسنان",
    "short_label_en": "20% OFF",
    "short_label_ar": "خصم 20%",
    "description_en": "...",
    "description_ar": "...",
    "terms_en": "...",
    "terms_ar": "...",
    "discount_type": "percentage",
    "discount_value": 20.00,
    "code": "DENTAL20",
    "auto_apply": false,
    "starts_at": "2026-04-01T00:00:00Z",
    "ends_at": "2026-06-30T23:59:59Z",
    "is_flash": false,
    "banner_text": "Limited Time!",
    "banner_image": "https://...",
    "services_count": 5,
    "branches_count": 3,
    "max_discount_amount": 500.00,
    "minimum_order_amount": 100.00
  }
}
```

### Response (404 Not Found)

```json
{
  "status": false,
  "message": "Offer not found"
}
```

---

## 3. GET `/v1/services/{id}/offers`

**Auth**: None
**Description**: Get eligible offers for a specific service

### Request

**Path Parameters**:
| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| id | int | Yes | Service ID |

**Query Parameters**:
| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| branch_id | int | No | Filter by branch |
| clinic_id | int | No | Filter by clinic |
| service_charge | number | No | Service price for calculation |
| channel | string | No | "mobile", "web", "reception" |

### Response (200 OK)

```json
{
  "status": true,
  "data": [
    {
      "id": 42,
      "title": "20% Off Dental Checkup",
      "label": "20% OFF",
      "discount_type": "percentage",
      "discount_value": 20.00,
      "code": "DENTAL20",
      "auto_apply": false,
      "ends_at": "2026-06-30T23:59:59Z"
    }
  ]
}
```

---

## 4. POST `/v1/offers/validate-coupon`

**Auth**: `Authorization: Bearer {token}`
**Description**: Validate a coupon code for a service

### Request

**Headers**:
```
Content-Type: application/json
Authorization: Bearer {token}
```

**Body**:
```json
{
  "code": "DENTAL20",
  "service_id": 15,
  "branch_id": 3,
  "clinic_id": 7,
  "service_charge": 500.00,
  "channel": "mobile",
  "payment_method": "online"
}
```

| Field | Type | Required | Validation |
|-------|------|----------|------------|
| code | string | Yes | Max 50 characters |
| service_id | int | Yes | Must exist |
| branch_id | int | No | Must exist if provided |
| clinic_id | int | No | Must exist if provided |
| service_charge | number | Yes | Min 0 |
| channel | string | No | "web", "mobile", "reception" |
| payment_method | string | No | "cash", "online", "advance" |

### Response (200 OK - Success)

```json
{
  "status": true,
  "data": {
    "offer_id": 42,
    "code": "DENTAL20",
    "title": "20% Off Dental Checkup",
    "discount_type": "percentage",
    "discount_value": 20.00,
    "original_price": 500.00,
    "discount_amount": 100.00,
    "final_price": 400.00,
    "terms": "Valid for dental checkup services only."
  },
  "message": "Coupon applied successfully"
}
```

### Response (200 OK - Failure)

```json
{
  "status": false,
  "message": "This coupon has expired",
  "data": {
    "code": "DENTAL20",
    "reason": "expired"
  }
}
```

**Possible failure reasons**:
- `expired` - Coupon past end date
- `not_started` - Coupon before start date
- `not_applicable` - Not valid for this service
- `usage_limit_reached` - Maximum uses exceeded
- `minimum_not_met` - Order below minimum amount
- `invalid_code` - Code doesn't exist

---

## 5. POST `/v1/offers/calculate-discount`

**Auth**: `Authorization: Bearer {token}`
**Description**: Calculate discount preview without applying

### Request

**Body**:
```json
{
  "service_id": 15,
  "branch_id": 3,
  "clinic_id": 7,
  "service_charge": 500.00,
  "coupon_code": "DENTAL20",
  "offer_id": null,
  "channel": "mobile",
  "payment_method": "online"
}
```

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| service_id | int | Yes | Service ID |
| service_charge | number | Yes | Service price |
| coupon_code | string | No | Manual coupon code |
| offer_id | int | No | Specific offer ID to apply |
| branch_id | int | No | Branch ID |
| clinic_id | int | No | Clinic ID |
| channel | string | No | Channel identifier |
| payment_method | string | No | Payment method |

### Response (200 OK)

```json
{
  "status": true,
  "data": {
    "original_price": 500.00,
    "discount_amount": 100.00,
    "discounted_price": 400.00,
    "applied_offer_id": 42,
    "applied_offer_code": "DENTAL20",
    "applied_offer_title": "20% Off Dental Checkup",
    "discount_breakdown": [
      {
        "offer_id": 42,
        "title": "20% Off Dental Checkup",
        "code": "DENTAL20",
        "discount_type": "percentage",
        "discount_amount": 100.00
      }
    ]
  }
}
```

---

## 6. POST `/v1/offers/apply`

**Auth**: `Authorization: Bearer {token}`
**Description**: Apply offer to current booking session

### Request

**Body**:
```json
{
  "offer_id": 42,
  "service_id": 15,
  "service_charge": 500.00,
  "branch_id": 3,
  "channel": "mobile"
}
```

### Response (200 OK)

```json
{
  "status": true,
  "data": {
    "original_price": 500.00,
    "discount_amount": 100.00,
    "discounted_price": 400.00,
    "applied_offer_id": 42,
    "applied_offer_code": "DENTAL20",
    "applied_offer_title": "20% Off Dental Checkup"
  },
  "message": "Offer applied successfully"
}
```

---

## 7. POST `/v1/offers/remove`

**Auth**: `Authorization: Bearer {token}`
**Description**: Remove currently applied offer

### Request

**Body**:
```json
{
  "service_charge": 500.00
}
```

### Response (200 OK)

```json
{
  "status": true,
  "data": {
    "original_price": 500.00,
    "discount_amount": 0,
    "discounted_price": 500.00
  },
  "message": "Offer removed"
}
```

---

## Embedded Offer Data in Existing Endpoints

### `/doctors/search` Response Enhancement

```json
{
  "data": [
    {
      "id": 1,
      "full_name": "Dr. Ahmed",
      "has_active_offer": true,
      ...
    }
  ]
}
```

### Service Response Enhancement

```json
{
  "data": [
    {
      "id": 15,
      "name": "Dental Checkup",
      "active_offers": [
        {
          "id": 42,
          "title": "20% Off",
          "label": "20% OFF",
          "discount_type": "percentage",
          "discount_value": 20.00,
          "code": "DENTAL20",
          "auto_apply": false,
          "ends_at": "2026-06-30T23:59:59Z"
        }
      ],
      ...
    }
  ]
}
```

### Appointment Response Enhancement

```json
{
  "data": {
    "id": 100,
    "offer_id": 42,
    "offer_discount": 100.00,
    "offer_code": "DENTAL20",
    ...
  }
}
```

---

## Error Responses

All endpoints return consistent error format:

```json
{
  "status": false,
  "message": "Error description",
  "errors": {
    "field_name": ["Validation error message"]
  }
}
```

| HTTP Code | Scenario |
|-----------|----------|
| 401 | Missing or invalid auth token (protected endpoints) |
| 404 | Offer/service not found |
| 422 | Validation errors |
| 500 | Server error |
