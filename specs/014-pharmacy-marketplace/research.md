# Research: Pharmacy Marketplace

**Phase**: 0 — Outline & Research
**Feature**: `014-pharmacy-marketplace`
**Date**: 2026-04-07

---

## Decision 1: Directory Structure

**Decision**: Mirror the `lib/screens/lab_test/` module structure exactly — separate controller and screen files, a dedicated `model/` subdirectory, and a `components/` subdirectory for reusable widgets.

**Rationale**: The lab_test module (`lib/screens/lab_test/`) is the closest analogue — it has paginated browsing (categories → tests), order creation, order detail, and cancellation. Mirroring it gives developers familiar navigation and reduces onboarding friction. The constitution (§VII) demands simplicity; using an established pattern is simpler than inventing a new one.

**Alternatives considered**: A single flat directory with all files — rejected because it would become unwieldy at 16+ files. A monorepo-style `pharmacy/` package — rejected as overengineering for a single app module.

---

## Decision 2: API Endpoint Constants Location

**Decision**: Add all pharmacy endpoints to `lib/utils/api_end_points.dart` using the same grouped-constant pattern as existing v1 endpoints (e.g., `labTests`, `testOrders`).

**Rationale**: The constitution (§IV) requires all API endpoints to be defined in `api_end_points.dart`. Existing v1 pattern uses string constants like `'v1/lab-tests'` and static helper methods for parameterized paths (e.g., `labTestDetail(int id)`). The pharmacy API base is `v1/pharmacy/...` — add one constant group.

**Path prefix**: `v1/pharmacy` for all new endpoints.

**Alternatives considered**: Separate endpoint constants file — rejected (constitution forbids scattering URLs outside `api_end_points.dart`).

---

## Decision 3: API Service Methods Location

**Decision**: Add all pharmacy API methods as static methods on `CoreServiceApis` in `lib/api/core_apis.dart`, following the established `buildHttpResponse → handleResponse → model.fromJson` pipeline.

**Rationale**: All existing feature APIs (lab tests, nurses, ICU, bookings) live in `CoreServiceApis`. The constitution (§IV) mandates this pattern. The class already has 50+ static methods; adding ~12 pharmacy methods is consistent and avoids a new file that would need constitution-level justification.

**Alternatives considered**: A dedicated `PharmacyApis` class in `lib/api/pharmacy_apis.dart` — would be cleaner but violates §VII (no new abstractions unless proven necessary; existing pattern works).

---

## Decision 4: Cart State Management

**Decision**: The cart is a server-side resource; the app does not maintain a local cart store. `PharmacyCartController` holds a reactive `Rx<PharmacyCart?>` that is refreshed from the server after each mutation (add/update/remove). No local-first cart sync.

**Rationale**: The API contract defines the cart as server-side (`GET /cart` returns the canonical state). Maintaining a parallel local store would require conflict resolution logic. The spec (FR-009–FR-012) only requires displaying cart contents and enabling mutations — not offline cart support. Keeping it server-driven is simpler and correct.

**Cart badge**: A `PharmacyCartController` registered globally (via `Get.put()` in the pharmacy entry screen or lazily via `Get.lazyPut()`) exposes `cartItemCount.obs` for the home screen badge.

**Alternatives considered**: Local-first cart with sync — rejected (over-engineering for the stated requirements; no offline requirement in spec).

---

## Decision 5: Pagination Strategy

**Decision**: Use the same load-more pagination pattern as `lab_test_list_screen.dart` — `ScrollController` triggers `loadMore()` when near the bottom, a `lastPageCallBack` signals when the final page is reached.

**Rationale**: The `meta.last_page` / `meta.current_page` pattern is already established in `LabTestListResponse`. Products and orders both return `meta` pagination objects matching this shape.

**Alternatives considered**: Pull-to-refresh with page reset — included alongside load-more for refresh, not instead of it.

---

## Decision 6: Localization Keys Namespace

**Decision**: Prefix all new locale keys with the section comment `// Pharmacy Marketplace` and use camelCase keys like `pharmacyMarketplace`, `myPharmacyOrders`, `addToCart` (reuse if already exists), etc.

**Rationale**: The existing `languages.dart` already has an `addToCart` key (found in the radiology section). Where keys overlap (e.g., `search`, `loadMore`, `error`, `noData`), they will be reused rather than duplicated — following §VII (no duplication).

**New keys required**: ~35 new strings (pharmacy-specific). Full list documented in `data-model.md`.

---

## Decision 7: Home Screen Integration Point

**Decision**: Add a tappable pharmacy banner/card widget to the home screen's "services" section, consistent with how other service modules (Lab Tests, Nurse Requests) are surfaced. The specific placement is a `PharmacyHomeCard` widget inserted into the existing grid/list of service shortcuts.

**Rationale**: The spec requires the pharmacy entry be visible without scrolling on standard screens. The home screen already has a service shortcuts section. Adding a card there (rather than a new tab or bottom nav item) is the least invasive approach — no navigation structure changes required.

**Alternatives considered**: New bottom nav tab — rejected (invasive architectural change, requires changes to `DashboardScreen` nav bar). New home section — possible future enhancement.

---

## Decision 8: Delivery Address Source

**Decision**: The checkout flow calls an existing user-address API (assumed to exist per spec Assumptions). If no dedicated address API exists in the app yet, the checkout will present a text field for address ID entry as a temporary measure, with a `// TODO: replace with address picker` comment. This is flagged for the implementation task.

**Rationale**: Spec assumption states "delivery address management is a pre-existing feature." The `core_apis.dart` does not currently show a user-address endpoint. If the API exists at `v1/user/addresses` (common pattern), it will be wired in. If not, a numeric ID input is the minimal viable path.

---

## Decision 9: Product List Filter State

**Decision**: Filters (brands, product types) are managed within `PharmacyProductListController` as `RxList<int> selectedBrandIds` and `RxList<int> selectedProductTypeIds`. A filter bottom sheet (reusable `_PharmacyFilterSheet` widget) is shown on demand, not a separate screen — consistent with the Simplicity principle.

**Rationale**: The lab test module uses a simpler approach (filter within the same controller). The pharmacy filter has two axes (brands, product types) which can both be multi-select checkboxes in a bottom sheet. A dedicated filter screen would be over-engineering for two filter dimensions.

---

## Summary: Files to Create

| Path | Type |
|------|------|
| `lib/screens/pharmacy/model/pharmacy_category_model.dart` | Model |
| `lib/screens/pharmacy/model/pharmacy_product_model.dart` | Model |
| `lib/screens/pharmacy/model/pharmacy_cart_model.dart` | Model |
| `lib/screens/pharmacy/model/pharmacy_order_model.dart` | Model |
| `lib/screens/pharmacy/model/pharmacy_filter_model.dart` | Model |
| `lib/screens/pharmacy/components/pharmacy_category_card.dart` | Widget |
| `lib/screens/pharmacy/components/pharmacy_product_card.dart` | Widget |
| `lib/screens/pharmacy/components/pharmacy_cart_item_tile.dart` | Widget |
| `lib/screens/pharmacy/components/pharmacy_order_card.dart` | Widget |
| `lib/screens/pharmacy/components/available_pharmacy_card.dart` | Widget |
| `lib/screens/pharmacy/pharmacy_categories_controller.dart` | Controller |
| `lib/screens/pharmacy/pharmacy_categories_screen.dart` | Screen |
| `lib/screens/pharmacy/pharmacy_product_list_controller.dart` | Controller |
| `lib/screens/pharmacy/pharmacy_product_list_screen.dart` | Screen |
| `lib/screens/pharmacy/pharmacy_product_detail_controller.dart` | Controller |
| `lib/screens/pharmacy/pharmacy_product_detail_screen.dart` | Screen |
| `lib/screens/pharmacy/pharmacy_cart_controller.dart` | Controller |
| `lib/screens/pharmacy/pharmacy_cart_screen.dart` | Screen |
| `lib/screens/pharmacy/pharmacy_checkout_controller.dart` | Controller |
| `lib/screens/pharmacy/pharmacy_checkout_screen.dart` | Screen |
| `lib/screens/pharmacy/pharmacy_order_list_controller.dart` | Controller |
| `lib/screens/pharmacy/pharmacy_order_list_screen.dart` | Screen |
| `lib/screens/pharmacy/pharmacy_order_detail_controller.dart` | Controller |
| `lib/screens/pharmacy/pharmacy_order_detail_screen.dart` | Screen |

## Summary: Files to Modify

| Path | Change |
|------|--------|
| `lib/utils/api_end_points.dart` | Add pharmacy endpoint constants |
| `lib/api/core_apis.dart` | Add pharmacy API static methods + model imports |
| `lib/locale/languages.dart` | Add ~35 pharmacy locale key declarations |
| `lib/locale/language_en.dart` | Add English pharmacy strings |
| `lib/locale/language_ar.dart` | Add Arabic pharmacy strings |
| `lib/screens/home/home_screen.dart` | Add pharmacy entry card/widget |
