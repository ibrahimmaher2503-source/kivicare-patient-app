# API Contracts: Pharmacy Marketplace (Flutter Client)

**Base URL prefix**: `v1/pharmacy` (appended to `BASE_URL` from `lib/configs.dart`)
**Auth**: All endpoints require `Authorization: Bearer <token>` header (auto-injected by `buildHeaderTokens()`)
**Language header**: `global-localization: <lang_code>` (auto-injected — drives `name` field language in responses)

---

## Endpoint Map

| Method | Path | Dart Constant | Description |
|--------|------|---------------|-------------|
| GET | `v1/pharmacy/categories` | `APIEndPoints.pharmacyCategories` | List top-level categories |
| GET | `v1/pharmacy/categories/{id}/children` | `APIEndPoints.pharmacyCategoryChildren(id)` | List subcategories |
| GET | `v1/pharmacy/products` | `APIEndPoints.pharmacyProducts` | List products (filtered, paginated) |
| GET | `v1/pharmacy/products/{id}` | `APIEndPoints.pharmacyProductDetail(id)` | Product detail |
| GET | `v1/pharmacy/filters/brands` | `APIEndPoints.pharmacyFilterBrands` | Brands for subcategory |
| GET | `v1/pharmacy/filters/product-types` | `APIEndPoints.pharmacyFilterProductTypes` | Product types for subcategory |
| GET | `v1/pharmacy/cart` | `APIEndPoints.pharmacyCart` | Get current cart |
| POST | `v1/pharmacy/cart/items` | `APIEndPoints.pharmacyCartItems` | Add item to cart |
| PATCH | `v1/pharmacy/cart/items/{id}` | `APIEndPoints.pharmacyCartItemDetail(id)` | Update cart item quantity |
| DELETE | `v1/pharmacy/cart/items/{id}` | `APIEndPoints.pharmacyCartItemDetail(id)` | Remove cart item |
| GET | `v1/pharmacy/cart/available-pharmacies` | `APIEndPoints.pharmacyAvailablePharmacies` | Pharmacy matching |
| POST | `v1/pharmacy/orders` | `APIEndPoints.pharmacyOrders` | Place order |
| GET | `v1/pharmacy/orders` | `APIEndPoints.pharmacyOrders` | List orders |
| GET | `v1/pharmacy/orders/{id}` | `APIEndPoints.pharmacyOrderDetail(id)` | Order detail |
| POST | `v1/pharmacy/orders/{id}/cancel` | `APIEndPoints.pharmacyOrderCancel(id)` | Cancel order |

---

## Request / Response Contracts

### GET products — Query Parameters

| Parameter | Dart type | Included when |
|-----------|-----------|---------------|
| `sub_category_id` | `int` | subcategory selected |
| `search` | `String` | search query non-empty |
| `brand_ids[]` | `List<int>` | at least one brand selected |
| `product_type_ids[]` | `List<int>` | at least one type selected |
| `per_page` | `int` | always (default 15) |
| `page` | `int` | always (starts at 1) |

**Query string example** (multiple array params):
```
v1/pharmacy/products?sub_category_id=5&page=1&per_page=15&brand_ids[]=1&brand_ids[]=3
```

### POST cart/items — Body

```json
{ "product_id": 10, "quantity": 2 }
```

### PATCH cart/items/{id} — Body

```json
{ "quantity": 5 }
```

### GET cart/available-pharmacies — Query

```
?address_id=5
```

### POST orders — Body

```json
{
  "pharmacy_id": 1,
  "address_id": 5,
  "payment_method": "cash_on_delivery"
}
```

### GET orders — Query Parameters

| Parameter | Default | Notes |
|-----------|---------|-------|
| `per_page` | 15 | |
| `page` | 1 | |
| `status` | (omitted) | Optional filter |

---

## Error Handling

| HTTP Status | Meaning | Flutter action |
|-------------|---------|----------------|
| 401 | Token expired | `reGenerateToken()` auto-retry (handled by `buildHttpResponse`) |
| 404 | Resource not found | Show error state with back navigation |
| 422 | Validation error | Show `toast()` with server message from response body |
| 5xx | Server error | Show generic error toast |

The validation error body shape:
```json
{ "status": false, "message": "Insufficient stock at any single pharmacy." }
```
Extract `message` field for toast display.

---

## HTTP Method Types (Dart)

```dart
HttpMethodType.GET     // for all GET calls
HttpMethodType.POST    // for cart/items, orders, orders/{id}/cancel
HttpMethodType.PATCH   // for cart/items/{id}
HttpMethodType.DELETE  // for cart/items/{id} (remove)
```

Note: `DELETE` is handled by `buildHttpResponse` with `method: HttpMethodType.DELETE`.

---

## Navigation Contract (Screen Arguments)

| Screen | Arguments | Type |
|--------|-----------|------|
| `PharmacyCategoriesScreen` | — | none (top-level entry) |
| `PharmacyProductListScreen` | subcategoryId, subcategoryName | positional or named args |
| `PharmacyProductDetailScreen` | productId | `int` via `Get.arguments` |
| `PharmacyCartScreen` | — | none |
| `PharmacyCheckoutScreen` | — | none (reads cart from controller) |
| `PharmacyOrderListScreen` | — | none |
| `PharmacyOrderDetailScreen` | orderId | `int` via `Get.arguments` |
