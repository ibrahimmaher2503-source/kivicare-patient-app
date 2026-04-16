# Developer Quickstart: Pharmacy Marketplace

**Branch**: `014-pharmacy-marketplace`
**Feature**: In-app pharmacy marketplace — browse products, manage cart, place orders.

---

## Architecture at a Glance

```
Home Screen
  └─► PharmacyCategoriesScreen        (top-level categories grid)
        └─► PharmacyProductListScreen  (products + search + filters)
              └─► PharmacyProductDetailScreen  (full product + Add to Cart)

Cart (accessible from any pharmacy screen via cart icon)
  └─► PharmacyCartScreen              (items, quantities, totals)
        └─► PharmacyCheckoutScreen    (address → pharmacy matching → confirm)
              └─► PharmacyOrderDetailScreen  (order confirmation / detail)

PharmacyOrderListScreen  (orders history, accessible from profile/menu)
  └─► PharmacyOrderDetailScreen       (order detail + cancel button)
```

---

## New Files

### Models — `lib/screens/pharmacy/model/`

| File | Contents |
|------|----------|
| `pharmacy_category_model.dart` | `PharmacyCategoryListResponse`, `PharmacyCategory` |
| `pharmacy_product_model.dart` | `PharmacyProductListResponse`, `PharmacyProduct`, `PharmacyProductDetailResponse`, `PharmacyProductRef` |
| `pharmacy_filter_model.dart` | `PharmacyFilterListResponse`, `PharmacyFilterOption` |
| `pharmacy_cart_model.dart` | `PharmacyCartResponse`, `PharmacyCart`, `PharmacyCartItem`, `PharmacyCartItemProduct`, `PharmacyAvailablePharmacyListResponse`, `PharmacyAvailablePharmacy` |
| `pharmacy_order_model.dart` | `PharmacyOrderListResponse`, `PharmacyOrderSummary`, `PharmacyOrderDetail`, `PharmacyOrderDetailResponse`, `PharmacyOrderItem`, `PharmacyOrderAddress`, `PharmacyOrderPharmacyRef`, `PharmacyOrderPlacedResponse` |

### Components — `lib/screens/pharmacy/components/`

| File | Description |
|------|-------------|
| `pharmacy_category_card.dart` | Category grid card with image + name |
| `pharmacy_product_card.dart` | Product list card (image, name, price, stock/Rx badges) |
| `pharmacy_cart_item_tile.dart` | Cart item row with quantity stepper and remove button |
| `pharmacy_order_card.dart` | Order list card (pharmacy, status badge, total, date) |
| `available_pharmacy_card.dart` | Pharmacy selection card with pricing breakdown |

### Controllers & Screens

| Controller | Screen | Manages |
|------------|--------|---------|
| `PharmacyCategoriesController` | `PharmacyCategoriesScreen` | Top-level + subcategory navigation |
| `PharmacyProductListController` | `PharmacyProductListScreen` | Paginated product list, search, filters |
| `PharmacyProductDetailController` | `PharmacyProductDetailScreen` | Single product + quantity selector |
| `PharmacyCartController` | `PharmacyCartScreen` | Cart CRUD + item count badge |
| `PharmacyCheckoutController` | `PharmacyCheckoutScreen` | Address, pharmacy matching, order placement |
| `PharmacyOrderListController` | `PharmacyOrderListScreen` | Paginated order history |
| `PharmacyOrderDetailController` | `PharmacyOrderDetailScreen` | Order detail + cancel |

---

## Modified Files

| File | What Changes |
|------|-------------|
| `lib/utils/api_end_points.dart` | Add `// Pharmacy Marketplace` group (~13 constants/helpers) |
| `lib/api/core_apis.dart` | Add ~12 static API methods + model imports |
| `lib/locale/languages.dart` | Add ~35 abstract getter declarations |
| `lib/locale/language_en.dart` | Add English values |
| `lib/locale/language_ar.dart` | Add Arabic values (or EN placeholder + `// TODO: translate`) |
| `lib/screens/home/home_screen.dart` | Add `PharmacyHomeCard` entry widget |

---

## Key Patterns to Follow

### API method pattern (from `CoreServiceApis`)
```dart
static Future<PharmacyCategoryListResponse> getPharmacyCategories() async {
  return PharmacyCategoryListResponse.fromJson(
    await handleResponse(
      await buildHttpResponse(
        APIEndPoints.pharmacyCategories,
        method: HttpMethodType.GET,
      ),
    ),
  );
}
```

### Paginated list method pattern
```dart
static Future<void> getPharmacyProducts({
  required int subCategoryId,
  required List<PharmacyProduct> list,
  String search = '',
  List<int> brandIds = const [],
  List<int> productTypeIds = const [],
  int page = 1,
  int perPage = 15,
  Function(bool)? lastPageCallback,
}) async {
  String params = 'sub_category_id=$subCategoryId&page=$page&per_page=$perPage';
  if (search.isNotEmpty) params += '&search=${Uri.encodeComponent(search)}';
  for (final id in brandIds) params += '&brand_ids[]=$id';
  for (final id in productTypeIds) params += '&product_type_ids[]=$id';

  final res = PharmacyProductListResponse.fromJson(
    await handleResponse(
      await buildHttpResponse('${APIEndPoints.pharmacyProducts}?$params', method: HttpMethodType.GET),
    ),
  );
  if (page == 1) list.clear();
  list.addAll(res.data);
  lastPageCallback?.call(res.currentPage >= res.lastPage);
}
```

### Cart mutation + refresh pattern
```dart
Future<void> addToCart(int productId, int quantity) async {
  try {
    isLoading(true);
    final updated = await CoreServiceApis.addToPharmacyCart(
      productId: productId, quantity: quantity,
    );
    cart.value = updated.data;
  } catch (e) {
    toast(e.toString());
  } finally {
    isLoading(false);
  }
}
```

### Locale string usage
```dart
// In any widget with BuildContext
locale.value.pharmacyMarketplace  // NOT hardcoded 'Pharmacy'
```

---

## Running the Feature

1. Ensure you're on branch `014-pharmacy-marketplace`
2. `flutter pub get` (no new packages expected)
3. `flutter run` — navigate to Home → Pharmacy card
4. `flutter analyze` — zero new warnings required before committing

## Testing Checklist

- [ ] Categories load from `GET v1/pharmacy/categories`
- [ ] Subcategories load when parent tapped
- [ ] Product list paginates and search filters work
- [ ] Brand/product type filters update list correctly
- [ ] Add to cart shows success; cart badge updates
- [ ] Quantity update and remove work
- [ ] Pharmacy matching returns results given valid address_id
- [ ] Order placement succeeds and cart clears
- [ ] Order appears in order history immediately
- [ ] Cancel pending order removes cancel button after success
- [ ] Arabic locale shows correct RTL layout
- [ ] Out-of-stock products show badge; add-to-cart is disabled
