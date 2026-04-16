# Data Model: Pharmacy Marketplace

**Feature**: `014-pharmacy-marketplace`
**Date**: 2026-04-07

---

## Model Files

All models live in `lib/screens/pharmacy/model/`.

---

### `pharmacy_category_model.dart`

Represents a top-level pharmacy category OR a subcategory (same shape, different context).

```dart
class PharmacyCategoryListResponse {
  bool status;
  List<PharmacyCategory> data;
}

class PharmacyCategory {
  int id;
  String name;         // Localized (from name_ar or name_en based on locale)
  String nameAr;
  String nameEn;
  String? image;
  int sortOrder;
}
```

**API sources**:
- `GET v1/pharmacy/categories` → list of top-level categories
- `GET v1/pharmacy/categories/{id}/children` → list of subcategories

---

### `pharmacy_product_model.dart`

Two shapes: list item (summary) and full detail.

```dart
class PharmacyProductListResponse {
  bool status;
  List<PharmacyProduct> data;
  int currentPage;
  int lastPage;
  int perPage;
  int total;
}

class PharmacyProductRef {
  int id;
  String name;
}

class PharmacyProduct {
  int id;
  String name;
  String nameAr;
  String nameEn;
  String? image;
  // List view fields
  PharmacyProductRef? productType;
  PharmacyProductRef? brand;
  double priceFrom;
  bool isInStock;
  bool requiresPrescription;
  // Detail-only fields (null in list view)
  String? description;
  PharmacyProductRef? category;
  PharmacyProductRef? subcategory;
}

class PharmacyProductDetailResponse {
  bool status;
  PharmacyProduct? data;
}
```

**API sources**:
- `GET v1/pharmacy/products` → `PharmacyProductListResponse`
- `GET v1/pharmacy/products/{id}` → `PharmacyProductDetailResponse`

---

### `pharmacy_filter_model.dart`

Filter option models used in the product list filter sheet.

```dart
class PharmacyFilterListResponse {
  bool status;
  List<PharmacyFilterOption> data;
}

class PharmacyFilterOption {
  int id;
  String name;
  String? nameAr;
  String? nameEn;
}
```

**API sources**:
- `GET v1/pharmacy/filters/brands?sub_category_id=N` → `PharmacyFilterListResponse`
- `GET v1/pharmacy/filters/product-types?sub_category_id=N` → `PharmacyFilterListResponse`

---

### `pharmacy_cart_model.dart`

Cart and cart item models. The cart is always fetched fresh from the server.

```dart
class PharmacyCartResponse {
  bool status;
  PharmacyCart? data;
}

class PharmacyCart {
  List<PharmacyCartItem> items;
  int itemCount;
}

class PharmacyCartItemProduct {
  int id;
  String name;
  String? image;
  double priceFrom;
  bool isInStock;
}

class PharmacyCartItem {
  int id;                       // cart item ID (used for PATCH/DELETE)
  PharmacyCartItemProduct? product;
  int quantity;
}

class PharmacyAvailablePharmacyListResponse {
  bool status;
  List<PharmacyAvailablePharmacy> data;
  String? message;              // Non-null when data is empty (no matches)
}

class PharmacyAvailablePharmacy {
  int id;
  String name;
  String? logo;
  String? phone;
  String? address;
  double? latitude;
  double? longitude;
  double subtotal;
  double deliveryFee;
  double total;
}
```

**API sources**:
- `GET v1/pharmacy/cart` → `PharmacyCartResponse`
- `POST v1/pharmacy/cart/items` → `PharmacyCartResponse` (updated cart)
- `PATCH v1/pharmacy/cart/items/{id}` → `PharmacyCartResponse` (updated cart)
- `DELETE v1/pharmacy/cart/items/{id}` → simple `{ status, message }`
- `GET v1/pharmacy/cart/available-pharmacies?address_id=N` → `PharmacyAvailablePharmacyListResponse`

---

### `pharmacy_order_model.dart`

Order models for list view, detail view, and placement response.

```dart
class PharmacyOrderListResponse {
  bool status;
  List<PharmacyOrderSummary> data;
  int currentPage;
  int lastPage;
  int perPage;
  int total;
}

class PharmacyOrderPharmacyRef {
  int id;
  String name;
  String? phone;
  String? address;
}

class PharmacyOrderSummary {
  int id;
  PharmacyOrderPharmacyRef? pharmacy;
  double total;
  String status;
  int itemCount;
  String createdAt;
}

class PharmacyOrderItem {
  int id;
  int productId;
  String productName;
  int quantity;
  double price;
  double lineTotal;
}

class PharmacyOrderAddress {
  String? addressLine1;
  String? city;
}

class PharmacyOrderDetail {
  int id;
  String status;
  PharmacyOrderPharmacyRef? pharmacy;
  List<PharmacyOrderItem> items;
  double subtotal;
  double deliveryFee;
  double total;
  String paymentMethod;
  PharmacyOrderAddress? address;
  String createdAt;
  String updatedAt;
}

class PharmacyOrderDetailResponse {
  bool status;
  PharmacyOrderDetail? data;
}

class PharmacyOrderPlacedResponse {
  bool status;
  PharmacyOrderSummary? data;     // partial order data returned on creation
  String? message;
}
```

**API sources**:
- `GET v1/pharmacy/orders` → `PharmacyOrderListResponse`
- `GET v1/pharmacy/orders/{id}` → `PharmacyOrderDetailResponse`
- `POST v1/pharmacy/orders` → `PharmacyOrderPlacedResponse` (201)
- `POST v1/pharmacy/orders/{id}/cancel` → `{ status, message }` (200)

---

## API Endpoint Constants

Add to `lib/utils/api_end_points.dart` (grouped under `// Pharmacy Marketplace`):

```dart
// Pharmacy Marketplace
static const String pharmacyCategories = 'v1/pharmacy/categories';
static String pharmacyCategoryChildren(int id) => '$pharmacyCategories/$id/children';
static const String pharmacyProducts = 'v1/pharmacy/products';
static String pharmacyProductDetail(int id) => '$pharmacyProducts/$id';
static const String pharmacyFilterBrands = 'v1/pharmacy/filters/brands';
static const String pharmacyFilterProductTypes = 'v1/pharmacy/filters/product-types';
static const String pharmacyCart = 'v1/pharmacy/cart';
static const String pharmacyCartItems = 'v1/pharmacy/cart/items';
static String pharmacyCartItemDetail(int id) => '$pharmacyCartItems/$id';
static const String pharmacyAvailablePharmacies = 'v1/pharmacy/cart/available-pharmacies';
static const String pharmacyOrders = 'v1/pharmacy/orders';
static String pharmacyOrderDetail(int id) => '$pharmacyOrders/$id';
static String pharmacyOrderCancel(int id) => '$pharmacyOrders/$id/cancel';
```

---

## Locale Keys

Add to `lib/locale/languages.dart` under `// Pharmacy Marketplace`:

```dart
// Pharmacy Marketplace
String get pharmacyMarketplace;
String get pharmacy;
String get myPharmacyOrders;
String get browseMedicines;
String get pharmacyCategories;
String get pharmacySubCategories;
String get products;
String get noProductsFound;
String get outOfStock;
String get requiresPrescription;
String get priceFrom;
String get filterProducts;
String get selectBrands;
String get selectProductTypes;
String get noBrandsAvailable;
String get noProductTypesAvailable;
String get productDetails;
String get cart;
String get cartEmpty;
String get cartEmptyMessage;
String get itemsInCart;
String get quantity;
String get removeFromCart;
String get updateQuantity;
String get proceedToCheckout;
String get selectDeliveryAddress;
String get findPharmacies;
String get availablePharmacies;
String get noPharmaciesAvailable;
String get deliveryFee;
String get subtotal;
String get selectPharmacy;
String get placeOrder;
String get orderPlaced;
String get orderPlacedMessage;
String get orderHistory;
String get orderDetail;
String get orderStatus;
String get orderItems;
String get cancelOrder;
String get orderCancelledSuccess;
String get cannotCancelOrder;
String get cashOnDelivery;
String get insufficientStock;
```

---

## State Transitions

### Cart Item Lifecycle
```
[Not in cart] → addToCart() → [In cart: quantity N]
[In cart] → updateQuantity(N) → [In cart: quantity N]
[In cart] → removeItem() → [Not in cart]
```

### Order Status Transitions (read-only in app)
```
pending → confirmed → [out_for_delivery] → delivered
pending → cancelled (patient-initiated or system)
```
The patient app can only trigger: `pending → cancelled` via `POST /orders/{id}/cancel`.

---

## Validation Rules

| Field | Rule |
|-------|------|
| Cart quantity | Integer ≥ 1 |
| Add to cart | Product must be active and in stock |
| Stock check | At least one pharmacy must have `stock_qty ≥ requested qty` |
| Order placement | Cart non-empty, pharmacy active + fully stocked, address_id valid |
| Order cancellation | Order status must be `pending` |
| `address_id` | Must belong to authenticated user |
