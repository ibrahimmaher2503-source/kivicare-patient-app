# Tasks: Pharmacy Marketplace

**Input**: Design documents from `/specs/014-pharmacy-marketplace/`
**Prerequisites**: plan.md ✅, spec.md ✅, research.md ✅, data-model.md ✅, contracts/pharmacy-api.md ✅, quickstart.md ✅

**Tests**: Unit tests included for cart mutations and order placement (critical healthcare path, per constitution §VI).

**Organization**: Tasks grouped by user story to enable independent implementation and testing of each story.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies on incomplete tasks)
- **[Story]**: Which user story this task belongs to (US1–US4)

---

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Create the new module directory structure. No blocking dependencies.

- [X] T001 Create `lib/screens/pharmacy/model/`, `lib/screens/pharmacy/components/` directories (create placeholder `.gitkeep` or first model file)

**Checkpoint**: Directory structure ready — parallel model creation can begin

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: All data models, API endpoints, service methods, and locale keys that EVERY user story depends on. No user story work can start until this phase is complete.

**⚠️ CRITICAL**: Phases 3–6 are blocked until this phase is complete.

### 2A: Data Models

- [X] T002 [P] Create `PharmacyCategoryListResponse` and `PharmacyCategory` models (bilingual name, image, sortOrder, fromJson) in `lib/screens/pharmacy/model/pharmacy_category_model.dart`
- [X] T003 [P] Create `PharmacyProductRef`, `PharmacyProduct`, `PharmacyProductListResponse`, `PharmacyProductDetailResponse` models (all fields from data-model.md including nameAr/nameEn, priceFrom, isInStock, requiresPrescription, description) in `lib/screens/pharmacy/model/pharmacy_product_model.dart`
- [X] T004 [P] Create `PharmacyFilterOption` and `PharmacyFilterListResponse` models in `lib/screens/pharmacy/model/pharmacy_filter_model.dart`
- [X] T005 [P] Create `PharmacyCartItemProduct`, `PharmacyCartItem`, `PharmacyCart`, `PharmacyCartResponse`, `PharmacyAvailablePharmacy`, `PharmacyAvailablePharmacyListResponse` models (cart item has id for PATCH/DELETE, availablePharmacy has subtotal/deliveryFee/total) in `lib/screens/pharmacy/model/pharmacy_cart_model.dart`
- [X] T006 [P] Create `PharmacyOrderPharmacyRef`, `PharmacyOrderSummary`, `PharmacyOrderItem`, `PharmacyOrderAddress`, `PharmacyOrderDetail`, `PharmacyOrderDetailResponse`, `PharmacyOrderListResponse` (with meta pagination), `PharmacyOrderPlacedResponse` models in `lib/screens/pharmacy/model/pharmacy_order_model.dart`

### 2B: API Endpoint Constants

- [X] T007 Add `// Pharmacy Marketplace` constant group to `lib/utils/api_end_points.dart`: `pharmacyCategories`, `pharmacyCategoryChildren(int id)`, `pharmacyProducts`, `pharmacyProductDetail(int id)`, `pharmacyFilterBrands`, `pharmacyFilterProductTypes`, `pharmacyCart`, `pharmacyCartItems`, `pharmacyCartItemDetail(int id)`, `pharmacyAvailablePharmacies`, `pharmacyOrders`, `pharmacyOrderDetail(int id)`, `pharmacyOrderCancel(int id)`

### 2C: API Service Methods (depends on T002–T007)

- [X] T008 [P] Add to `lib/api/core_apis.dart`: `getPharmacyCategories()` → `PharmacyCategoryListResponse` (GET pharmacyCategories) and `getPharmacyCategoryChildren(int id)` → `PharmacyCategoryListResponse` (GET pharmacyCategoryChildren(id)); add model imports
- [X] T009 [P] Add to `lib/api/core_apis.dart`: `getPharmacyProducts({required int subCategoryId, required List<PharmacyProduct> list, String search, List<int> brandIds, List<int> productTypeIds, int page, int perPage, Function(bool)? lastPageCallback})` (GET pharmacyProducts with query params per contracts/pharmacy-api.md); `getPharmacyProductDetail(int id)` → `PharmacyProductDetailResponse`
- [X] T010 [P] Add to `lib/api/core_apis.dart`: `getPharmacyFilterBrands(int subCategoryId)` and `getPharmacyFilterProductTypes(int subCategoryId)` → `PharmacyFilterListResponse`
- [X] T011 [P] Add to `lib/api/core_apis.dart`: `getPharmacyCart()` → `PharmacyCartResponse`; `addToPharmacyCart({required int productId, required int quantity})` → `PharmacyCartResponse` (POST); `updatePharmacyCartItem({required int itemId, required int quantity})` → `PharmacyCartResponse` (PATCH); `removePharmacyCartItem(int itemId)` → void/base response (DELETE)
- [X] T012 [P] Add to `lib/api/core_apis.dart`: `getAvailablePharmacies(int addressId)` → `PharmacyAvailablePharmacyListResponse` (GET pharmacyAvailablePharmacies?address_id=N)
- [X] T013 [P] Add to `lib/api/core_apis.dart`: `placePharmacyOrder({required int pharmacyId, required int addressId, String paymentMethod = 'cash_on_delivery'})` → `PharmacyOrderPlacedResponse` (POST); `getPharmacyOrders({required List<PharmacyOrderSummary> list, int page, int perPage, String? status, Function(bool)? lastPageCallback})` → paginated; `getPharmacyOrderDetail(int id)` → `PharmacyOrderDetailResponse`; `cancelPharmacyOrder(int id)` → base response (POST to pharmacyOrderCancel)

### 2D: Localization (depends on T002–T006 for key names, can run alongside 2B–2C)

- [X] T014 Add ~35 abstract getter declarations under `// Pharmacy Marketplace` comment in `lib/locale/languages.dart`: `pharmacyMarketplace`, `pharmacy`, `myPharmacyOrders`, `browseMedicines`, `pharmacyCategories`, `pharmacySubCategories`, `products`, `noProductsFound`, `outOfStock`, `requiresPrescription`, `priceFrom`, `filterProducts`, `selectBrands`, `selectProductTypes`, `noBrandsAvailable`, `noProductTypesAvailable`, `productDetails`, `myCart`, `cartEmpty`, `cartEmptyMessage`, `itemsInCart`, `quantity`, `removeFromCart`, `updateQuantity`, `proceedToCheckout`, `selectDeliveryAddress`, `findPharmacies`, `availablePharmacies`, `noPharmaciesAvailable`, `deliveryFee`, `selectPharmacy`, `placeOrder`, `orderPlaced`, `orderPlacedMessage`, `orderHistory`, `orderDetail`, `orderStatus`, `orderItems`, `cancelOrder`, `orderCancelledSuccess`, `cannotCancelOrder`, `cashOnDelivery`, `insufficientStock`, `addressId`, `enterAddressId`
- [X] T015 [P] Add English string values for all ~35 keys declared in T014 to `lib/locale/language_en.dart`
- [X] T016 [P] Add Arabic string values (or EN placeholder + `// TODO: translate` comment) for all ~35 keys to `lib/locale/language_ar.dart`

**Checkpoint**: Foundation complete — all 4 user story phases can now begin (sequentially or in parallel)

---

## Phase 3: User Story 1 — Browse Products by Category (Priority: P1) 🎯 MVP

**Goal**: Patient can navigate from home screen → pharmacy categories → subcategory → product list (with search + filters) → product detail screen.

**Independent Test**: Open app on `014-pharmacy-marketplace` branch → tap pharmacy card on home → browse categories → select subcategory → search for "panadol" → view product detail. All screens render with correct data and localized strings.

### Components (parallelizable)

- [X] T017 [P] [US1] Create `PharmacyCategoryCard` widget (image with `CachedImageWidget`, localized name, tap callback) in `lib/screens/pharmacy/components/pharmacy_category_card.dart`
- [X] T018 [P] [US1] Create `PharmacyProductCard` widget (image, localized name, `priceFrom`, stock badge, prescription badge) in `lib/screens/pharmacy/components/pharmacy_product_card.dart`

### Categories Screen (depends on T017)

- [X] T019 [US1] Create `PharmacyCategoriesController` (GetxController: `RxList<PharmacyCategory> categories`, `RxBool isLoading`, `Rx<String?> errorMessage`, `onInit` calls `loadCategories()`, `RxBool showingSubcategories`, `Rx<PharmacyCategory?> selectedParent`, `loadSubcategories(int parentId)`) in `lib/screens/pharmacy/pharmacy_categories_controller.dart`
- [X] T020 [US1] Create `PharmacyCategoriesScreen` (AppScaffold, grid of `PharmacyCategoryCard`s for top-level categories; on tap, load and show subcategory grid; subcategory tap navigates to `PharmacyProductListScreen`; empty/error states via `EmptyErrorStateWidget`) in `lib/screens/pharmacy/pharmacy_categories_screen.dart`

### Product List Screen (depends on T018)

- [X] T021 [US1] Create `PharmacyProductListController` (GetxController: `RxList<PharmacyProduct> products`, pagination state `currentPage`/`isLastPage`, `RxBool isLoading`, `RxString searchQuery`, `RxList<int> selectedBrandIds`, `RxList<int> selectedProductTypeIds`, `RxList<PharmacyFilterOption> availableBrands`, `RxList<PharmacyFilterOption> availableProductTypes`; `loadProducts(int subCategoryId)`, `loadMore()`, `onSearchChanged(String)`, `loadFilterOptions(int subCategoryId)`, `applyFilters()`, `clearFilters()`, `int get activeFilterCount`) in `lib/screens/pharmacy/pharmacy_product_list_controller.dart`
- [X] T022 [US1] Create `PharmacyProductListScreen` (AppScaffold; search bar; filter button with `FilterCountBadge`; `ListView` of `PharmacyProductCard`s with load-more on scroll; filter bottom sheet with brand/product-type multi-select checkboxes; pull-to-refresh; empty state) in `lib/screens/pharmacy/pharmacy_product_list_screen.dart`

### Product Detail Screen

- [X] T023 [US1] Create `PharmacyProductDetailController` (GetxController: `Rx<PharmacyProduct?> product`, `RxBool isLoading`, `RxInt selectedQuantity`, `loadProduct(int id)`) in `lib/screens/pharmacy/pharmacy_product_detail_controller.dart`
- [X] T024 [US1] Create `PharmacyProductDetailScreen` (AppScaffold; `CachedImageWidget` for product image; name, description, brand, type, category/subcategory, `priceFrom`; stock badge; prescription warning chip; quantity stepper; "Add to Cart" button — button calls `PharmacyCartController.addToCart()` but is disabled if `!product.isInStock`) in `lib/screens/pharmacy/pharmacy_product_detail_screen.dart`

### Home Screen Integration

- [X] T025 [US1] Add pharmacy marketplace entry card to `lib/screens/home/home_screen.dart` (tappable card/row widget showing pharmacy icon + `locale.value.pharmacyMarketplace` label; navigates to `PharmacyCategoriesScreen`; placement: in the existing service-shortcuts section, consistent with other module cards)

**Checkpoint**: US1 complete — verify browse flow end-to-end before proceeding

---

## Phase 4: User Story 2 — Manage Shopping Cart (Priority: P2)

**Goal**: Patient can add products to cart, adjust quantities, remove items, and view the cart with totals and item count badge.

**Independent Test**: Add 2 products from product detail screens, open cart screen, change quantity of one, remove the other, verify cart updates correctly and cart badge reflects item count.

### Cart Item Component

- [X] T026 [P] [US2] Create `PharmacyCartItemTile` widget (product image + name + price, quantity stepper with `+`/`-` buttons calling controller, remove button with confirmation; shows loading per-item on update) in `lib/screens/pharmacy/components/pharmacy_cart_item_tile.dart`

### Cart Controller (global cart state)

- [X] T027 [US2] Create `PharmacyCartController` (GetxController: `Rx<PharmacyCart?> cart`, `RxBool isLoading`, `int get itemCount` computed from cart, `Future<void> loadCart()`, `Future<void> addToCart(int productId, int quantity)`, `Future<void> updateItem(int itemId, int quantity)`, `Future<void> removeItem(int itemId)`) — register with `Get.lazyPut()` in `lib/screens/pharmacy/pharmacy_cart_controller.dart`

### Cart Screen (depends on T026, T027)

- [X] T028 [US2] Create `PharmacyCartScreen` (AppScaffold with cart icon in app bar showing `itemCount`; `ListView` of `PharmacyCartItemTile`s; aggregate subtotal display; "Proceed to Checkout" button → `PharmacyCheckoutScreen`; empty state with "Browse Medicines" CTA) in `lib/screens/pharmacy/pharmacy_cart_screen.dart`

### Wire Add-to-Cart into Product Detail (depends on T027, T024)

- [X] T029 [US2] Update `PharmacyProductDetailScreen` in `lib/screens/pharmacy/pharmacy_product_detail_screen.dart`: wire "Add to Cart" button to `PharmacyCartController.addToCart(productId, quantity)`; show success toast on add; show stock error toast on 422 response

### Cart Badge in Category/Product Screens (depends on T027)

- [X] T030 [US2] Add cart icon with `Obx` badge (showing `itemCount` from `PharmacyCartController`) to `PharmacyCategoriesScreen` and `PharmacyProductListScreen` app bars in `lib/screens/pharmacy/pharmacy_categories_screen.dart` and `lib/screens/pharmacy/pharmacy_product_list_screen.dart`

**Checkpoint**: US2 complete — verify full cart CRUD independently

---

## Phase 5: User Story 3 — Find Available Pharmacies & Place Order (Priority: P3)

**Goal**: Patient proceeds from cart, selects a delivery address, sees matched pharmacies with pricing, selects one, and places a cash-on-delivery order with confirmation.

**Independent Test**: With items in cart, tap "Proceed to Checkout", enter a valid `address_id`, trigger pharmacy matching, select first pharmacy, confirm order — verify success screen and cart cleared.

### Available Pharmacy Component

- [X] T031 [P] [US3] Create `AvailablePharmacyCard` widget (pharmacy logo + name + address; subtotal / delivery fee / total breakdown; select/highlight state) in `lib/screens/pharmacy/components/available_pharmacy_card.dart`

### Checkout Controller (depends on T012)

- [X] T032 [US3] Create `PharmacyCheckoutController` (GetxController: `RxInt addressId`, `RxList<PharmacyAvailablePharmacy> availablePharmacies`, `Rx<PharmacyAvailablePharmacy?> selectedPharmacy`, `RxBool isLoadingPharmacies`, `RxBool isPlacingOrder`, `Rx<String?> matchMessage`, `Future<void> findPharmacies()`, `Future<void> placeOrder()`) in `lib/screens/pharmacy/pharmacy_checkout_controller.dart`

### Checkout Screen (depends on T031, T032)

- [X] T033 [US3] Create `PharmacyCheckoutScreen` (3-step layout: (1) address ID input field with "Find Pharmacies" button; (2) list of `AvailablePharmacyCard`s or empty-message; (3) order summary + "Confirm Order" button; loading indicators during matching and placement; on success navigate to `PharmacyOrderDetailScreen` with new order ID; on 422 error show toast) in `lib/screens/pharmacy/pharmacy_checkout_screen.dart`

### Post-Order Wiring (depends on T033, T028)

- [X] T034 [US3] Wire "Proceed to Checkout" button in `PharmacyCartScreen` (`lib/screens/pharmacy/pharmacy_cart_screen.dart`) to navigate to `PharmacyCheckoutScreen`; after successful order, call `PharmacyCartController.loadCart()` to refresh cart badge

**Checkpoint**: US3 complete — verify checkout + order placement end-to-end

---

## Phase 6: User Story 4 — View & Manage Orders (Priority: P4)

**Goal**: Patient can view paginated order history, inspect full order detail with item snapshots, and cancel pending orders after confirmation.

**Independent Test**: Navigate to orders list from profile/menu; verify existing order appears with status badge; open order detail; if status is "pending" verify cancel button is visible and triggers confirmation dialog.

### Order Card Component

- [X] T035 [P] [US4] Create `PharmacyOrderCard` widget (pharmacy name, status badge with color, item count, total, formatted date; tap callback) in `lib/screens/pharmacy/components/pharmacy_order_card.dart`

### Order List (depends on T035)

- [X] T036 [US4] Create `PharmacyOrderListController` (GetxController: `RxList<PharmacyOrderSummary> orders`, pagination state, `RxBool isLoading`, `loadOrders()`, `loadMore()`) in `lib/screens/pharmacy/pharmacy_order_list_controller.dart`
- [X] T037 [US4] Create `PharmacyOrderListScreen` (AppScaffold; `ListView` of `PharmacyOrderCard`s; load-more on scroll; pull-to-refresh; empty state with "Browse Medicines" CTA) in `lib/screens/pharmacy/pharmacy_order_list_screen.dart`

### Order Detail (depends on T037)

- [X] T038 [US4] Create `PharmacyOrderDetailController` (GetxController: `Rx<PharmacyOrderDetail?> order`, `RxBool isLoading`, `RxBool isCancelling`, `loadOrder(int id)`, `cancelOrder()` — shows `showConfirmDialogCustom` before calling API, refreshes order on success) in `lib/screens/pharmacy/pharmacy_order_detail_controller.dart`
- [X] T039 [US4] Create `PharmacyOrderDetailScreen` (AppScaffold; pharmacy card with phone/address; items list with quantity × price = lineTotal; subtotal/delivery/total summary; payment method chip; delivery address; status badge; "Cancel Order" button visible ONLY if `order.status == 'pending'`; `orderCancelledSuccess` toast on success) in `lib/screens/pharmacy/pharmacy_order_detail_screen.dart`

### Entry Points for Order History (depends on T037)

- [X] T040 [US4] Add "My Pharmacy Orders" navigation entry to the profile/account screen or to the pharmacy home (categories screen app bar) — navigate to `PharmacyOrderListScreen`; also wire `PharmacyCheckoutScreen` success navigation to go through `PharmacyOrderDetailScreen`

**Checkpoint**: US4 complete — all user stories functional end-to-end

---

## Phase 7: Polish & Cross-Cutting Concerns

**Purpose**: Quality, analysis clean, tests for critical paths.

### Static Analysis

- [X] T041 Run `flutter analyze` from repo root; fix any new warnings or errors introduced by T002–T040 (zero new warnings target per constitution §VII) — check `lib/screens/pharmacy/`, `lib/api/core_apis.dart`, `lib/utils/api_end_points.dart`, `lib/locale/`

### Unit Tests for Critical API Paths (constitution §VI)

- [X] T042 [P] Create unit tests for cart API methods: `addToPharmacyCart`, `updatePharmacyCartItem`, `removePharmacyCartItem` — mock `buildHttpResponse`; test success response maps to `PharmacyCart`; test 422 throws with correct message in `test/unit/pharmacy/pharmacy_cart_api_test.dart`
- [X] T043 [P] Create unit tests for `placePharmacyOrder` — mock successful 201 response and stock-conflict 422; verify `PharmacyOrderPlacedResponse.fromJson` parses correctly; test `cancelPharmacyOrder` success in `test/unit/pharmacy/pharmacy_order_api_test.dart`
- [X] T044 [P] Create unit tests for all pharmacy model `fromJson` methods — verify null-safety, missing fields default to safe values, pagination meta parsed from `meta` object in `test/unit/pharmacy/pharmacy_models_test.dart`

### RTL & Localization Verification

- [ ] T045 [P] Switch app to Arabic locale; manually verify `PharmacyCategoriesScreen`, `PharmacyProductListScreen`, `PharmacyCartScreen`, `PharmacyCheckoutScreen`, `PharmacyOrderListScreen` render correctly in RTL; confirm no hardcoded English strings visible

### Quickstart Checklist Run

- [ ] T046 Run through `specs/014-pharmacy-marketplace/quickstart.md` testing checklist — verify all 13 items pass; document any failures with repro steps

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies — start immediately
- **Foundational (Phase 2)**: Depends on Phase 1 — **BLOCKS all user story phases**
  - 2A (Models): Parallel with each other, start after T001
  - 2B (API endpoints): Can start alongside 2A; T007 depends on knowing endpoint paths (use contracts/pharmacy-api.md)
  - 2C (API methods): Depends on 2A + 2B complete (T002–T007)
  - 2D (Localization): T014 depends on knowing key names; T015 + T016 parallel after T014
- **US1 (Phase 3)**: Depends on Phase 2 complete
- **US2 (Phase 4)**: Depends on Phase 2 complete; US1 recommended first (cart needs product detail screen)
- **US3 (Phase 5)**: Depends on Phase 2 + US2 complete (needs working cart)
- **US4 (Phase 6)**: Depends on Phase 2 + US3 complete (order detail is shown post-checkout)
- **Polish (Phase 7)**: Depends on desired user stories complete

### User Story Dependencies

- **US1 (P1)**: Independent after Phase 2 — no dependency on other stories
- **US2 (P2)**: Independent after Phase 2, but T029 wires into US1 screen; US1 recommended first
- **US3 (P3)**: Depends on US2 (needs cart with items to checkout)
- **US4 (P4)**: Depends on US3 (orders are created by checkout; detail screen navigated from checkout)

### Within Each User Story

- Component tasks `[P]` → can start together
- Controller before screen (screen imports controller)
- Core screen before wiring into other screens
- Story complete before moving to next priority

### Parallel Opportunities (within Phase 2)

```
After T001:
  T002 [P] pharmacy_category_model.dart
  T003 [P] pharmacy_product_model.dart
  T004 [P] pharmacy_filter_model.dart
  T005 [P] pharmacy_cart_model.dart
  T006 [P] pharmacy_order_model.dart
  T007    api_end_points.dart (can run with models)

After T002–T007:
  T008 [P] core_apis.dart — category methods
  T009 [P] core_apis.dart — product methods
  T010 [P] core_apis.dart — filter methods
  T011 [P] core_apis.dart — cart methods
  T012 [P] core_apis.dart — pharmacy matching
  T013 [P] core_apis.dart — order methods
  T014    languages.dart — abstract getters

After T014:
  T015 [P] language_en.dart
  T016 [P] language_ar.dart
```

### Parallel Opportunities (within US1)

```
After Phase 2:
  T017 [P] [US1] pharmacy_category_card.dart
  T018 [P] [US1] pharmacy_product_card.dart

After T017:
  T019 [US1] pharmacy_categories_controller.dart
  T020 [US1] pharmacy_categories_screen.dart

After T018:
  T021 [US1] pharmacy_product_list_controller.dart
  T022 [US1] pharmacy_product_list_screen.dart

Independent:
  T023 [US1] pharmacy_product_detail_controller.dart
  T024 [US1] pharmacy_product_detail_screen.dart

After T024:
  T025 [US1] home_screen.dart integration
```

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Complete Phase 1 (T001)
2. Complete Phase 2 — Foundational (T002–T016)
3. Complete Phase 3 — US1 (T017–T025)
4. **STOP and VALIDATE**: Can browse categories → products → detail from home screen
5. Run `flutter analyze` — no new warnings
6. Demo/review browse flow before proceeding

### Incremental Delivery

1. Foundation (Phase 1+2) → Framework ready
2. + US1 (Phase 3) → Browse marketplace (demo-able MVP)
3. + US2 (Phase 4) → Add cart management → Test add/update/remove
4. + US3 (Phase 5) → Add checkout + order placement → Test full purchase
5. + US4 (Phase 6) → Add order history + cancel → Complete experience
6. Polish (Phase 7) → Production-ready

### Parallel Agent Strategy

With multiple agents/developers after Phase 2:
- Agent A: US1 (T017–T025) — browse screens
- Agent B: US2 (T026–T030) — cart (can start on components in parallel)
- Agent C: Localization refinement / RTL testing

US3 and US4 must follow US2 (serial dependency on cart state).

---

## Notes

- `[P]` tasks write to different files — safe to run concurrently
- `[Story]` label maps each task to a spec user story for traceability
- `PharmacyCartController` must be registered via `Get.lazyPut()` before any screen that uses it
- For `PATCH` and `DELETE` cart item calls, use `HttpMethodType.PATCH` and `HttpMethodType.DELETE` in `buildHttpResponse`
- The `address_id` input in checkout is a temporary number field per research.md Decision 8 — add `// TODO: replace with address picker` comment
- `FilterCountBadge` from `lib/components/filter_count_badge.dart` can be reused in product list filter button
- Reuse existing `showConfirmDialogCustom` for the cancel order confirmation dialog
- Commit after each completed task or logical group; reference task ID in commit message
