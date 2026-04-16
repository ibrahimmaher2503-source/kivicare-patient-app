# Feature Specification: Pharmacy Marketplace

**Feature Branch**: `014-pharmacy-marketplace`
**Created**: 2026-04-07
**Status**: Draft
**Input**: User description: "Add pharmacy marketplace with all endpoints - controllers, UI, repo, components; integrate into home page"

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Browse Products by Category (Priority: P1)

A logged-in patient opens the pharmacy marketplace from the home screen, browses top-level categories (e.g., Medicines, Vitamins), taps into a category to see subcategories (e.g., Pain Relief, Antibiotics), and then browses the product listing for that subcategory. They can search by product name and filter by brand or product type. They tap a product to see full details including description, availability, and starting price.

**Why this priority**: Product discovery is the entry point to all downstream flows. Without the ability to browse and find products, the cart and ordering flows have no value. This is the most foundational capability of the marketplace.

**Independent Test**: Can be fully tested by opening the app, navigating to the pharmacy section from the home page, drilling into a subcategory, and viewing a product detail screen — delivers product discovery value independently.

**Acceptance Scenarios**:

1. **Given** the patient is on the home screen, **When** they tap the pharmacy marketplace entry, **Then** they see a grid of top-level categories with images and names in their selected language (Arabic/English).
2. **Given** the patient has selected a top-level category, **When** they view it, **Then** subcategories are displayed with images and names.
3. **Given** the patient is browsing a subcategory's product list, **When** they type in the search bar, **Then** the product list filters to match the search query across both Arabic and English names.
4. **Given** the patient is on the product list screen, **When** they apply brand or product-type filters, **Then** only products matching the selected filters are shown.
5. **Given** the patient taps a product card, **When** the product detail screen opens, **Then** they see: name (in their language), image, description, category/subcategory, brand, product type, starting price, stock availability, and prescription requirement indicator.
6. **Given** a product is out of stock, **When** it appears in the listing, **Then** it is visually indicated as unavailable.
7. **Given** a product requires a prescription, **When** it is displayed, **Then** a prescription indicator is clearly visible on both the list card and detail screen.

---

### User Story 2 - Manage Shopping Cart (Priority: P2)

A patient browsing products can add items to a persistent shopping cart. They can adjust quantities or remove items at any time. The cart persists across sessions. A cart item count indicator is visible from within the marketplace.

**Why this priority**: The cart bridges discovery and purchase. Without a functional cart, patients cannot proceed to checkout. It must come before the checkout flow.

**Independent Test**: Can be tested by adding multiple products to the cart, adjusting quantities, removing an item, and verifying the cart reflects the changes — delivers cart management value independently.

**Acceptance Scenarios**:

1. **Given** the patient is on a product detail screen, **When** they tap "Add to Cart" with a valid quantity, **Then** the item is added to their cart and a success confirmation is shown.
2. **Given** the product is already in the cart, **When** the patient adds it again, **Then** the quantity is incremented, not duplicated.
3. **Given** the patient opens the cart screen, **When** they view it, **Then** they see all items with product name, image, unit price, quantity controls, and a line subtotal.
4. **Given** the patient changes an item's quantity in the cart, **When** the update is saved, **Then** the cart totals update immediately to reflect the new quantity.
5. **Given** the patient taps the remove button on a cart item, **When** confirmed, **Then** the item is removed from the cart.
6. **Given** the patient attempts to add more units than any single pharmacy has in stock, **When** the add-to-cart action is submitted, **Then** a clear error message explains insufficient stock.
7. **Given** the cart is empty, **When** the patient views the cart screen, **Then** an empty-state message with a prompt to browse products is shown.

---

### User Story 3 - Find Available Pharmacies & Place Order (Priority: P3)

When the patient is ready to checkout, they provide a delivery address, and the system matches pharmacies that can fulfill their complete cart. The patient sees a list of matching pharmacies with pricing breakdown. They select a pharmacy and confirm the order with cash-on-delivery payment. Upon success, they see an order confirmation.

**Why this priority**: This is the conversion step — turning a cart into a real order. It depends on both the browse (P1) and cart (P2) flows being functional first.

**Independent Test**: Can be tested with a pre-loaded cart by selecting a delivery address, viewing matched pharmacies, selecting one, and placing an order — delivers purchase completion value independently.

**Acceptance Scenarios**:

1. **Given** the patient has items in their cart, **When** they proceed to checkout, **Then** they are prompted to select a delivery address.
2. **Given** the patient has selected a delivery address, **When** they request available pharmacies, **Then** the system returns pharmacies that can fulfill the entire cart with subtotal, delivery fee, and total for each.
3. **Given** no pharmacy can fulfill the full cart, **When** the pharmacy matching returns, **Then** a clear message is displayed explaining the situation and suggesting the patient adjust their cart.
4. **Given** the patient selects a pharmacy from the list, **When** they review the order summary, **Then** they see pharmacy details, all items, subtotal, delivery fee, and total before confirming.
5. **Given** the patient confirms the order with cash-on-delivery payment, **When** the order is placed successfully, **Then** an order confirmation screen shows order ID, pharmacy details, and total amount.
6. **Given** a stock conflict occurs at the moment of order placement, **When** the order fails, **Then** a descriptive error is shown and the patient remains on the checkout screen.
7. **Given** the cart is empty, **When** the patient attempts to proceed to checkout, **Then** they are prompted to add products first.

---

### User Story 4 - View & Manage Orders (Priority: P4)

A patient can view their complete order history, check the status of any order, see full item-level detail, and cancel pending orders before they are processed.

**Why this priority**: Post-purchase order visibility is important for user trust and a complete shopping experience, but it is a supporting flow that does not block the core purchase flow.

**Independent Test**: Can be tested with existing placed orders by navigating to the orders list and verifying each order shows correct status, items, and totals — delivers order history value independently.

**Acceptance Scenarios**:

1. **Given** the patient has placed orders, **When** they navigate to the orders list, **Then** orders are displayed newest-first with pharmacy name, status badge, item count, total, and date.
2. **Given** the patient taps an order, **When** the detail screen opens, **Then** they see all items with snapshot pricing, pharmacy contact details, delivery address, subtotal, delivery fee, and total.
3. **Given** an order has "pending" status, **When** the patient taps "Cancel Order", **Then** a confirmation dialog is shown before proceeding.
4. **Given** the patient confirms cancellation, **When** the cancellation succeeds, **Then** the order status updates to "cancelled".
5. **Given** an order is not in "pending" status, **When** the patient views the order detail, **Then** the cancel option is not available.
6. **Given** the patient has no orders, **When** they view the orders list, **Then** an empty-state message is shown with a prompt to browse the marketplace.

---

### Edge Cases

- What happens when the patient loses internet connectivity mid-cart update?
- How does the system handle a product becoming out of stock between adding to cart and checkout?
- What if a pharmacy becomes inactive between pharmacy selection and order placement?
- How are products with requires_prescription=true communicated before the patient adds them to cart?
- What happens when pagination reaches the last page on infinite scroll?
- How does Arabic RTL layout affect product name display and cart layouts?
- What if the delivery address associated with an order is deleted — does the order detail still show address info?

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: System MUST display a pharmacy marketplace entry point on the home screen, visible to logged-in patients.
- **FR-002**: System MUST display top-level pharmacy categories with images and localized names (Arabic/English based on app language setting).
- **FR-003**: System MUST display subcategories for a selected parent category.
- **FR-004**: System MUST display a paginated, filterable product listing for a selected subcategory.
- **FR-005**: System MUST support text search across product names in both Arabic and English.
- **FR-006**: System MUST allow filtering products by brand and/or product type within a subcategory.
- **FR-007**: System MUST display available brands and product types as filter options sourced from active products in the selected subcategory.
- **FR-008**: System MUST display full product detail: name, image, description, category, brand, product type, price from, stock status, and prescription requirement flag.
- **FR-009**: System MUST allow patients to add products to a server-side cart with a specified quantity.
- **FR-010**: System MUST allow patients to update item quantity in the cart.
- **FR-011**: System MUST allow patients to remove individual items from the cart.
- **FR-012**: System MUST display the current cart contents including item count, per-item details, and aggregate totals.
- **FR-013**: System MUST prevent adding a quantity that exceeds available stock and show a user-friendly error.
- **FR-014**: System MUST find pharmacies capable of fulfilling all items in the patient's cart given a delivery address.
- **FR-015**: System MUST display each matching pharmacy's name, logo, address, subtotal, delivery fee, and total.
- **FR-016**: System MUST display a descriptive message when no pharmacies can fulfill the entire cart.
- **FR-017**: System MUST allow the patient to place an order by selecting a pharmacy and confirming cash-on-delivery payment.
- **FR-018**: System MUST show an order confirmation screen after successful order placement.
- **FR-019**: System MUST display a paginated list of the patient's orders with status, totals, and dates.
- **FR-020**: System MUST display full order detail including item-level snapshot data, pharmacy contact info, and delivery address.
- **FR-021**: System MUST allow cancellation of orders in "pending" status only, with confirmation dialog.
- **FR-022**: System MUST display appropriate empty-state screens for empty category lists, product lists, cart, and order history.
- **FR-023**: System MUST support pagination with load-more or infinite scroll for product and order lists.
- **FR-024**: System MUST clearly indicate out-of-stock products in listings and prevent adding them to cart.
- **FR-025**: System MUST clearly indicate products that require a prescription.

### Key Entities

- **PharmacyCategory**: A top-level product grouping (e.g., Medicines, Vitamins). Has bilingual name, image, sort order. Has child subcategories.
- **PharmacySubcategory**: A child of PharmacyCategory. Scopes product listings and filter option calls.
- **Product**: A pharmacy product with bilingual name, image, description, brand, product type, price-from, stock status, and prescription flag.
- **Brand**: A product manufacturer/label (e.g., GSK, Pfizer). Scoped per subcategory.
- **ProductType**: A product form factor (e.g., Tablets, Syrup). Bilingual. Scoped per subcategory.
- **CartItem**: One product + quantity in the patient's server-side cart. Has its own ID for update/delete operations.
- **Cart**: The patient's active cart. Contains a list of CartItems and an item count.
- **AvailablePharmacy**: A pharmacy that can fulfill the complete cart for a given address. Includes pricing breakdown.
- **PharmacyOrder**: A placed order. Includes status, pharmacy snapshot, item snapshots, address, and payment method.
- **OrderItem**: A snapshot of a product at order time (product ID, name, quantity, unit price, line total). Immutable after creation.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: A patient can discover a specific product and add it to their cart in under 60 seconds from the home screen.
- **SC-002**: The pharmacy matching step displays results within 3 seconds of the patient providing a delivery address.
- **SC-003**: 90% of patients can successfully complete a full purchase flow (browse → cart → pharmacy → order) on their first attempt without support.
- **SC-004**: All product, cart, and order screens correctly display content in both English and Arabic, including proper RTL layout for Arabic.
- **SC-005**: Out-of-stock and stock error states are communicated clearly enough that patients are never left in a dead-end without guidance.
- **SC-006**: Order history is available immediately after an order is placed, with accurate status and item detail.
- **SC-007**: The pharmacy marketplace entry point is visible on the home screen without scrolling on standard mobile screen sizes.

## Assumptions

- Delivery address management (adding/editing addresses) is a pre-existing feature; this marketplace assumes at least one address already exists on the patient's account for checkout to be possible.
- Only "cash_on_delivery" is supported as a payment method for this phase; additional payment methods are out of scope.
- The backend handles prescription enforcement server-side if needed; the app only surfaces the `requires_prescription` flag visually as an informational indicator.
- Products that are out of stock are shown in listings (to inform the patient) but cannot be added to cart.
- Order status transitions (pending → confirmed → delivered) are driven by the pharmacy/backend; the patient app only reads status and initiates cancellation of pending orders.
- The patient's delivery addresses are accessible via an existing user/address API already integrated in the app.
- Localization strings for all new pharmacy UI copy will be added to both English and Arabic locale files.

## Out of Scope

- Prescription upload or verification workflow
- Online payment methods (credit card, wallet, etc.) — cash on delivery only in this phase
- Real-time order tracking or delivery map
- Pharmacy profile pages or pharmacy browsing independent of cart checkout
- Product reviews or ratings
- Wishlist or saved products
- Push notifications for order status changes
- Admin-side pharmacy or inventory management
