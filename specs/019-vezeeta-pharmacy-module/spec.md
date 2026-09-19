# Feature Specification: Vezeeta-Style Pharmacy Module

**Feature Branch**: `019-vezeeta-pharmacy-module`
**Created**: 2026-04-28
**Status**: Draft
**Input**: User description: Build a complete Pharmacy module integrated into the Espitalia Patient App, mirroring the UX of Vezeeta Pharmacy. Patients can browse pharmacy products by category, search and filter by brand/type/price, manage a cart with multi-pharmacy availability matching, upload prescriptions (camera + gallery, multi-image), validate and apply coupons at checkout, place orders, track status with cancel/refund support, receive in-app notifications for order updates, and operate fully in Arabic (RTL) and English (LTR).

## Clarifications

### Session 2026-04-28

- Q: For prescription-required items, must the attached prescription be in the `approved` state before the patient can place the order, or is a `pending` upload sufficient (with the pharmacy verifying during order processing)? → A: Pending upload is sufficient at checkout; the pharmacy verifies the prescription as part of the order's normal Confirmed/Preparing workflow and can hold or reject the order at that stage.
- Q: When a fulfilling pharmacy has been selected and the patient then adds a product the selected pharmacy can't fulfill, how should the system respond? → A: Re-validate availability on every cart change; if the selected pharmacy can no longer fulfill the cart, automatically clear the selection and prompt the patient to re-pick from the updated availability list.
- Q: How should the checkout screen behave when one or more cart items have become unavailable (out of stock or no longer carried by the selected pharmacy) since the cart was last loaded? → A: Highlight unavailable items in red and show a banner explaining the issue; disable the "Place Order" button until the patient removes them or reduces quantities to available stock. Items are not auto-removed.
- Q: How should pharmacy events (order status changes, prescription review outcomes, refund decisions, promotions) be delivered to the patient — push notifications, in-app list, or both? → A: Both. Every server-side pharmacy event MUST produce a push notification to the device (via the existing FCM integration) AND an entry in the in-app pharmacy notifications list. The in-app list is the durable record so nothing is lost if a push is missed or dismissed.
- Q: Should there be an upper bound on the quantity a patient can add to a single cart line, and where does that bound come from? → A: Server-driven per-line maximum. Each product carries a maximum-order-quantity attribute returned by the backend; the client enforces it in the quantity stepper, the "Add to Cart" action, and checkout validation. If the backend does not specify one, the client falls back to a sensible default. The line is also bounded above by current stock.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Browse, Order, and Receive Over-the-Counter Products (Priority: P1)

A patient opens the Pharmacy section from the dashboard, browses available products by category or via search, adds items to a cart, selects a fulfilling pharmacy, chooses a payment method, places the order, and receives the products. This is the core revenue-generating shopping journey and the minimum viable product for the module.

**Why this priority**: Without this end-to-end flow, no other pharmacy capability has business value. Every other feature (prescriptions, refunds, notifications) layers on top of a working product → cart → checkout → order pipeline.

**Independent Test**: A logged-in patient can open the Pharmacy entry point on the dashboard, find a non-prescription product (such as a vitamin or first-aid item) by scrolling, searching, or browsing categories, add it to the cart, complete checkout with an existing delivery address and payment method, and see a confirmation that the order was placed.

**Acceptance Scenarios**:

1. **Given** a patient is on the app dashboard, **When** they tap the Pharmacy entry point, **Then** they see a Pharmacy home screen with a search bar, promotional banners, category tiles, featured products, brand chips, and a prescription upload call-to-action.
2. **Given** the patient is on the Pharmacy home screen, **When** they tap a category tile that has subcategories, **Then** they see the subcategory list; **When** they tap a leaf category, **Then** they see a paginated product list filtered by that category.
3. **Given** the patient is on a product list, **When** they scroll near the bottom, **Then** more products load automatically without losing their position.
4. **Given** the patient taps a product card, **When** the detail screen opens, **Then** they see images, name, brand, price (current + any old/discount), stock status, description, prescription-required indicator (if applicable), and a quantity selector with an "Add to Cart" action.
5. **Given** the patient adds a product to the cart, **When** the action completes, **Then** the cart icon badge increments immediately and the patient sees a success indication.
6. **Given** the cart contains items, **When** the patient opens the cart, **Then** they see each item with image, name, brand, price, quantity stepper, and remove control, plus a running subtotal.
7. **Given** the cart has items, **When** the patient taps "View Available Pharmacies", **Then** they see a list of pharmacies that can fulfill the cart with delivery fee, estimated delivery time, distance, rating, and a flag indicating whether the pharmacy can fulfill the full cart or only part of it.
8. **Given** a pharmacy is selected, **When** the patient proceeds to checkout, **Then** they see sections for delivery address, selected pharmacy, coupon entry, payment method, and an order summary (subtotal, discount, delivery fee, total).
9. **Given** all required checkout fields are filled, **When** the patient taps "Place Order", **Then** the system confirms the order, shows a success screen with the order number, and the order appears in the orders list.

---

### User Story 2 - Order Prescription-Required Medications (Priority: P2)

A patient who needs a prescription medication uploads photos of their physical prescription (using camera or gallery, multiple images supported), then orders the prescription-required products through the same shopping flow. The pharmacy verifies the prescription before fulfillment.

**Why this priority**: Prescription medications are the most differentiated and clinically important pharmacy use case. P2 because the OTC flow (P1) must work first, but prescription support is a primary expectation of any healthcare pharmacy and unlocks a large class of products.

**Independent Test**: A patient can tap "Upload Prescription" from the Pharmacy home, capture or pick up to 5 images, optionally add notes, submit, and see the prescription appear in their prescriptions list with a "pending review" status. They can then add a prescription-required product to cart and complete checkout, and the order is linked to the uploaded prescription.

**Acceptance Scenarios**:

1. **Given** the patient taps "Upload Prescription", **When** the upload screen opens, **Then** they see brief instructions and an empty image grid with an "Add Image" control.
2. **Given** the patient taps "Add Image", **When** they choose "Take Photo" or "Choose from Gallery", **Then** the appropriate source opens and the captured/selected image appears as a thumbnail in the grid.
3. **Given** the patient has added between 1 and 5 images, **When** they tap "Submit", **Then** the system uploads all images, optionally with notes, and shows a confirmation; the prescription appears in the prescription list with status "pending".
4. **Given** the patient is on the prescription list, **When** they tap a prescription, **Then** they see all uploaded images in a carousel, current status, notes, and any rejection reason if rejected.
5. **Given** a product requires a prescription, **When** the patient views its detail page, **Then** a clear "Prescription Required" badge is displayed.
6. **Given** the cart contains a prescription-required product, **When** the patient checks out, **Then** the system enforces that at least one of the patient's prescriptions in a non-rejected state (`pending`, `reviewed`, or `approved`) is attached before the order can be placed; final approval is performed by the pharmacy during order processing.

---

### User Story 3 - Track Orders, Cancel, and Request Refunds (Priority: P3)

After placing an order, the patient can view the order list, drill into any order to see a status timeline (Placed → Confirmed → Preparing → Out for Delivery → Delivered), cancel an order while it is still cancellable, or request a refund on a delivered order within the allowed window.

**Why this priority**: Post-purchase visibility is essential for trust, but only matters once orders can actually be placed (P1). Cancel and refund flows are critical for customer service and reduce support load.

**Independent Test**: A patient with at least one placed order can open the orders list, tap an order, see its current status and a chronological timeline, and (if the order's state allows) cancel it via a confirmation dialog. For a delivered order, they can request a refund by selecting a reason and submitting; the refund appears in the refunds list with "requested" status.

**Acceptance Scenarios**:

1. **Given** the patient has placed orders, **When** they open the orders list, **Then** each order is shown with order number, date, total, and a color-coded status chip; the list supports pull-to-refresh and pagination.
2. **Given** the patient taps an order, **When** the detail screen opens, **Then** they see the order header, a vertical timeline showing reached and pending statuses, the fulfilling pharmacy, the line items with images and prices, the price breakdown (subtotal, discount, delivery fee, total), the delivery address, and the payment method/status.
3. **Given** the order is in a cancellable state, **When** the patient taps "Cancel Order", **Then** a confirmation dialog appears; **When** they confirm, **Then** the order status updates to "cancelled" and the cancellation is reflected immediately.
4. **Given** the order is delivered and within the refund-eligible window, **When** the patient taps "Request Refund", **Then** a form opens with a reason selector, optional notes, and (optionally) item-level selection; **When** they submit, **Then** a refund is created with status "requested" and appears in the refunds list.
5. **Given** the patient opens the refunds list, **When** they tap a refund, **Then** they see refund amount, linked order, reason, current status, and any administrator notes.

---

### User Story 4 - Filter and Sort Products to Find What I Need (Priority: P4)

A patient on a product list can apply filters (category, brand, product type, price range, prescription-required) and choose sort order (newest, price ascending/descending, popular, rating) to narrow down the catalog efficiently. A badge on the filter button shows how many filters are active.

**Why this priority**: Filters meaningfully improve discovery once the catalog has enough products to overwhelm a flat list. Important but not blocking — basic browse and search (P1) cover the smallest catalog.

**Independent Test**: A patient on a product list can tap the filter icon, set a price range and pick one or more brands, apply the filters, and see the list update to only matching products. The filter button shows a badge with the active filter count, and they can reset all filters with one action.

**Acceptance Scenarios**:

1. **Given** the patient is on a product list, **When** they tap the filter icon, **Then** the filter screen opens with current filter selections preserved.
2. **Given** the patient selects one or more brands, picks a product type, sets a min/max price, toggles "prescription only", and picks a sort option, **When** they tap "Apply Filters", **Then** the product list reloads with results matching all selected criteria and the filter button shows a badge with the count of active filters.
3. **Given** the patient has active filters, **When** they tap "Reset Filters", **Then** all filters clear and the list returns to its default sort and unfiltered state.
4. **Given** the patient changes the sort option from the product list, **When** they pick a new option, **Then** the list reorders accordingly without losing other active filters.

---

### User Story 5 - Apply Coupon Discounts at Checkout (Priority: P5)

At checkout, a patient enters a coupon code, the system validates it against the current cart, and the discount is applied to the order total. Invalid or expired coupons show a clear, friendly error.

**Why this priority**: Coupons drive promotions and conversion, but the core order can be placed without them. Lower priority because it's an enhancement, not a blocker.

**Independent Test**: A patient at checkout can type a known-valid coupon code, tap "Apply", see the discount line update in the order summary and the total recalculate. A known-invalid code shows an error message and the order summary stays unchanged.

**Acceptance Scenarios**:

1. **Given** the patient is on checkout with items in the cart, **When** they enter a valid coupon code and tap "Apply", **Then** the discount appears in the order summary, the total recalculates, and a success message is shown.
2. **Given** the patient enters an invalid, expired, or non-applicable coupon, **When** they tap "Apply", **Then** an error message explains the reason and the order totals stay unchanged.
3. **Given** a coupon has been applied, **When** the patient places the order, **Then** the order record reflects the applied coupon code and discount amount.

---

### User Story 6 - Stay Informed via In-App Notifications (Priority: P6)

The patient sees a notifications bell with an unread count badge in the Pharmacy section. Tapping it opens a notifications list. Notifications about order status changes, prescription review outcomes, refund updates, and promotions appear there. Tapping a notification navigates to the relevant screen and marks it read.

**Why this priority**: Notifications improve engagement and reduce "where is my order?" support load, but they are not blocking for a working purchase flow.

**Independent Test**: A patient with at least one notification can see an unread badge on the bell icon, open the notifications list, see unread items visually distinguished from read ones, tap one to navigate to the linked entity, and use "Mark all as read" to clear the badge.

**Acceptance Scenarios**:

1. **Given** the patient has unread notifications, **When** they view the Pharmacy home, **Then** the notifications bell shows a badge with the unread count.
2. **Given** the patient opens the notifications screen, **When** the list loads, **Then** unread notifications are visually distinguished (e.g., highlighted) from read ones, and each shows a title, body, and timestamp.
3. **Given** the patient taps an order-status notification, **When** the action triggers, **Then** they navigate to the corresponding order detail and the notification is marked read.
4. **Given** there are unread notifications, **When** the patient taps "Mark all as read", **Then** all notifications become read and the badge disappears.

---

### Edge Cases

- **Empty catalog or empty section**: If a category has no products, an inventory list returns nothing, or banners/featured/brands are all empty, each section shows a friendly empty state instead of a blank area.
- **No pharmacy can fulfill the cart**: The "Available Pharmacies" view explains that no pharmacy currently stocks the full cart and offers options (remove unavailable items or pick a partial-fulfillment pharmacy).
- **Selected pharmacy invalidated by cart change**: When the patient adds, removes, or changes the quantity of a cart item and the previously selected pharmacy can no longer fulfill the updated cart, the selection is automatically cleared and the patient sees a banner inviting them to re-open the "Available Pharmacies" list and pick a new fulfilling pharmacy.
- **Out-of-stock during checkout**: If a product becomes unavailable (or available stock is below the requested quantity) between cart and checkout, the offending line is highlighted in red, a banner explains the issue, and the "Place Order" button stays disabled until the patient removes the line or reduces the quantity to what is available. Items are not auto-removed.
- **Prescription rejected**: If an uploaded prescription is rejected, the patient sees the rejection reason on the prescription detail and a guided path to upload a new one.
- **Coupon double-apply**: If a coupon is already applied, attempting to apply another replaces the first; the patient sees a clear message about the change.
- **Cancel race condition**: If the patient taps Cancel after the pharmacy has already advanced the order beyond a cancellable state, the system shows "This order can no longer be cancelled" and refreshes the timeline.
- **Refund outside window**: A delivered order outside the refund window does not show the "Request Refund" button.
- **Network failures**: Any list screen that fails to load shows an inline error with a retry action; transient failures during cart updates revert optimistic UI changes and explain the failure.
- **Token expiry mid-session**: Authentication is refreshed transparently; the patient does not see a logout unless re-authentication actually fails.
- **RTL/LTR**: Switching between Arabic and English flips directional UI elements (back arrows, status timelines, list chevrons, etc.) and renders all strings correctly in both languages.
- **Dark mode**: Every screen, badge, shimmer, and overlay maintains contrast and legibility in dark mode.
- **Image upload failures**: If a prescription image fails to upload, the failed image is highlighted and the patient can retry without re-picking other images.
- **Maximum 5 prescription images**: Attempting to add a 6th image is blocked with a clear message.

## Requirements *(mandatory)*

### Functional Requirements

#### Catalog & Discovery

- **FR-001**: System MUST provide a Pharmacy entry point from the existing dashboard.
- **FR-002**: System MUST present a Pharmacy home with a search bar, promotional banners, browsable categories, featured products, brand chips, and a prescription upload call-to-action.
- **FR-003**: Patients MUST be able to browse a hierarchical category tree, drilling from root categories into subcategories until reaching products.
- **FR-004**: Patients MUST be able to search products by free-text query, with results updating after a brief input pause (debounced) and a recent-searches list available for re-use.
- **FR-005**: Patients MUST be able to view product lists in a grid with pagination, pull-to-refresh, and inline loading indicators.
- **FR-006**: Patients MUST be able to view a product detail page showing all images, name, brand, price (current and any strikethrough/discount), stock indicator, description, prescription-required indicator, manufacturer/dosage/unit info, and rating summary.
- **FR-007**: Patients MUST be able to filter product lists by category, brand, product type, price range, and prescription-required status.
- **FR-008**: Patients MUST be able to sort product lists by newest, price ascending, price descending, popularity, and rating.
- **FR-009**: System MUST display an active-filter count badge on the filter control whenever any filter is set.
- **FR-010**: Patients MUST be able to reset all active filters in a single action.

#### Cart

- **FR-011**: Patients MUST be able to add a product to the cart from the product detail page with a chosen quantity.
- **FR-012**: Patients MUST be able to view all current cart items with image, name, brand, unit price, quantity, and line total.
- **FR-013**: Patients MUST be able to change the quantity of any cart item using a stepper, with the change persisted on the backend after a brief debounce to avoid excessive requests.
- **FR-013a**: The system MUST enforce a per-line maximum quantity equal to `min(product.maxOrderQuantity, product.stock)`, where `maxOrderQuantity` is a server-supplied per-product policy cap. The quantity stepper MUST stop incrementing at this maximum, the "Add to Cart" action MUST cap the requested quantity at it, and checkout MUST refuse to proceed if any cart line exceeds it. If the backend does not supply `maxOrderQuantity` for a product, the client MUST apply a sensible non-zero default cap.
- **FR-014**: Patients MUST be able to remove an item from the cart.
- **FR-015**: Patients MUST be able to clear all items from the cart.
- **FR-016**: System MUST display a running cart subtotal that recalculates whenever items or quantities change.
- **FR-017**: System MUST display a globally-visible cart badge that reflects the current item count and updates reactively across screens.
- **FR-018**: Patients MUST be able to view a list of pharmacies that can fulfill the current cart, including pharmacy name, distance, delivery fee, estimated delivery time, rating, and an indicator of whether the pharmacy can fulfill the full cart or only part of it.
- **FR-019**: Patients MUST be able to select one fulfilling pharmacy for the order before proceeding to checkout.
- **FR-019a**: Whenever the cart changes (item added, removed, or quantity updated), the system MUST re-validate that the currently selected pharmacy can still fulfill the cart. If it can no longer fulfill the cart, the system MUST automatically clear the pharmacy selection and prompt the patient to re-pick from the updated "Available Pharmacies" list before proceeding to checkout.
- **FR-020**: Cart contents MUST persist for the patient across app sessions and devices (server-stored cart).

#### Prescriptions

- **FR-021**: Patients MUST be able to upload between 1 and 5 prescription images per submission, sourcing images from camera or gallery.
- **FR-022**: Patients MUST be able to optionally include notes with a prescription upload.
- **FR-023**: System MUST provide patients with a list of all their previously uploaded prescriptions, each annotated with current status (pending, reviewed, approved, rejected) and upload date.
- **FR-024**: Patients MUST be able to open a prescription to see full-resolution images, status, notes, and any rejection reason.
- **FR-025**: System MUST clearly mark prescription-required products in product lists and on the product detail page.
- **FR-026**: System MUST require at least one of the patient's prescriptions (in any non-`rejected` state — i.e., `pending`, `reviewed`, or `approved`) to be attached before the patient can place an order containing prescription-required items. Final verification is performed by the pharmacy during order processing; the pharmacy MAY hold or reject the order if the prescription is invalid or insufficient, in which case the order moves to `cancelled` with a reason.

#### Checkout, Coupons & Orders

- **FR-027**: Patients MUST select a delivery address (using the existing app address selection capability) at checkout.
- **FR-028**: Patients MUST be able to enter a coupon code at checkout and have it validated against the current cart, with the resulting discount immediately reflected in the order summary on success and a clear error message on failure.
- **FR-029**: Patients MUST select a payment method at checkout from the existing set of supported in-app payment options.
- **FR-030**: System MUST display an order summary at checkout showing subtotal, discount, delivery fee, and total, recalculating reactively as inputs change.
- **FR-031**: System MUST disable the "Place Order" action until all required checkout fields (address, pharmacy, payment method) are valid.
- **FR-031a**: When entering or refreshing the checkout screen, the system MUST verify each cart line is still available at the selected pharmacy and at the requested quantity. Any unavailable or under-stocked lines MUST be visually flagged (e.g., red highlight) and a banner MUST explain the issue. While any line is flagged, the "Place Order" action MUST remain disabled. The patient MUST resolve flagged lines by removing them or reducing the quantity to what is currently available; the system MUST NOT auto-remove items.
- **FR-032**: Upon order placement, System MUST display a success confirmation with the order number and offer paths to view the order or continue shopping.
- **FR-033**: Patients MUST be able to view a list of all their pharmacy orders sorted by most recent first, with order number, date, total, and status chip per row, supporting pull-to-refresh and pagination.
- **FR-034**: Patients MUST be able to view full order details including a chronological status timeline (Placed → Confirmed → Preparing → Out for Delivery → Delivered, plus terminal Cancelled/Refunded states), pharmacy info, line items, price breakdown, delivery address, and payment info.
- **FR-035**: Patients MUST be able to cancel an order when its current status permits, with a confirmation dialog before the cancellation is sent.
- **FR-036**: Patients MUST be able to request a refund on a delivered order when the order is within the refund-eligible window, providing a reason and optional notes; refund eligibility MUST be determined by the backend and reflected in the UI.
- **FR-037**: Patients MUST be able to view a list of all their refund requests with status (requested, approved, rejected, processed) and view full refund details including any administrator notes.

#### Notifications

- **FR-038**: System MUST display a globally-visible pharmacy notifications badge that reflects the current unread count and updates reactively.
- **FR-039**: Patients MUST be able to view a list of all their pharmacy notifications, with unread items visually distinguished from read items.
- **FR-040**: Tapping a notification MUST mark it read and navigate the patient to the entity it references (order detail, prescription detail, etc.).
- **FR-041**: Patients MUST be able to mark all notifications as read in a single action.
- **FR-041a**: Every pharmacy event (order status change, prescription review outcome, refund decision, promotion) MUST be delivered to the patient via two channels in parallel: (1) a push notification to the device using the app's existing push-notification capability, and (2) a persistent entry in the in-app pharmacy notifications list. Push notifications MUST deep-link the patient to the relevant entity when tapped. The in-app list is the authoritative durable record — patients MUST be able to see the event in the list even if the push is missed, dismissed, or arrives while the device is offline.

#### Cross-cutting

- **FR-042**: Every user-facing string in the module MUST be available in both English and Arabic and respect right-to-left layout when Arabic is selected.
- **FR-043**: Every screen in the module MUST render correctly in both light and dark color modes.
- **FR-044**: Every list, action, and form MUST handle authentication token expiry transparently — the patient MUST NOT see a forced logout or repeated error toasts simply because their session token expired during a request.
- **FR-045**: Every list screen MUST display a friendly empty state when no data is present and a recoverable error state with a retry action when loading fails.
- **FR-046**: Cart mutations and similar quick interactions MUST use optimistic UI (immediate visual feedback) and MUST revert and explain the change if the underlying request fails.

### Key Entities

- **Product**: A purchasable item, with identity, name, brand association, optional category and product type, current and reference prices, stock quantity, an optional per-order maximum-quantity policy cap (used to bound how much one patient can buy in a single order), image set, prescription-required flag, descriptive attributes (unit, dosage, manufacturer), and rating summary.
- **Brand**: A manufacturer or product family used for filtering and display, with name and logo.
- **Category**: A hierarchical grouping of products. Categories may have subcategories; leaf categories contain products.
- **Product Type**: A classification used as a filter facet (e.g., tablets, syrups, cosmetics).
- **Cart**: The current open shopping basket for a patient, comprising a set of cart items, a subtotal, an applied coupon (optional), and a discount.
- **Cart Item**: A single line in the cart referencing a product, with quantity, unit price, and line total.
- **Pharmacy Match**: A pharmacy that can (fully or partially) fulfill the current cart, with name, address, delivery fee, estimated delivery time, distance, rating, and an indicator of full vs. partial fulfillment.
- **Coupon**: A discount code, valid against a cart, producing a discount amount or percentage when applied.
- **Order**: A placed purchase, with order number, status (pending → confirmed → preparing → out for delivery → delivered, plus cancelled and refunded terminal states), line items, subtotal, delivery fee, discount, total, applied coupon (optional), fulfilling pharmacy, delivery address, payment method/status, status timestamps, and flags indicating whether cancellation or refund is currently allowed.
- **Order Item**: A single line in an order — a snapshot of the product, quantity, unit price, and line total at the time of order placement.
- **Prescription**: A patient-uploaded prescription, comprising one or more images, an optional patient note, status (pending, reviewed, approved, rejected), an optional rejection reason, and timestamps for upload and review.
- **Refund**: A patient-initiated refund request against a delivered order, with the requested amount, reason, status (requested, approved, rejected, processed), optional administrator notes, and timestamps.
- **Pharmacy Notification**: An in-app notification to the patient about a relevant pharmacy event (order status change, prescription review outcome, refund update, promotion), with title, body, type, optional payload referencing a target entity, read/unread state, and timestamp.

### Assumptions

- **Authenticated patients only**: The Pharmacy module is available only to logged-in patients. Guest browsing is not in scope.
- **Server-side cart**: A patient has at most one open cart at a time, persisted on the backend so it follows them across devices and sessions.
- **One pharmacy per order**: Each order is fulfilled by exactly one pharmacy chosen from the "available pharmacies" matching list. Multi-pharmacy split orders are out of scope for this version.
- **Backend-driven refund window**: Whether a delivered order is currently refund-eligible is determined by the backend and exposed via a flag on the order; the client does not encode the refund window itself.
- **Prescription enforcement at checkout**: Patients can freely add prescription-required products to their cart; at checkout, attaching a prescription in any non-`rejected` state (`pending`, `reviewed`, or `approved`) is sufficient to place the order. Final clinical review happens during pharmacy order processing — the pharmacy may approve and proceed, or reject the order with a reason if the prescription is invalid.
- **Existing payment gateways**: The module reuses the existing in-app payment integrations rather than introducing new providers.
- **Existing localization infrastructure**: All strings flow through the app's existing English + Arabic localization system.
- **Standard delivery, no scheduling**: Orders are placed for standard pharmacy fulfillment. Scheduled delivery windows or recurring delivery are out of scope.
- **Voice search optional**: A microphone affordance may appear in the search bar, but voice-to-text capability itself is optional and not gating on launch.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: A patient can go from opening the Pharmacy entry point to a placed order for an over-the-counter product in under 2 minutes when address and payment method are already saved.
- **SC-002**: At least 95% of attempts to place an order succeed on the first try (no avoidable client-side validation, retry, or session-refresh loop required).
- **SC-003**: At least 90% of patients who open the Pharmacy section browse to at least one product detail page (indicating discoverable navigation and useful home-screen sections).
- **SC-004**: The Pharmacy home and any product list show initial content within 2 seconds on a typical mobile connection, with skeleton/shimmer placeholders shown immediately while loading.
- **SC-005**: Cart, prescription, order, and notification counts (badges) reflect server state within 1 second of any change visible to the patient.
- **SC-006**: 100% of user-facing strings in the module are translatable and render correctly in both English (LTR) and Arabic (RTL).
- **SC-007**: Every screen in the module passes visual verification in both light and dark color modes with no contrast or legibility regressions.
- **SC-008**: Patients can independently complete each of the six prioritized user stories above without external help (verified via guided usability testing, with drop-off below 10% per story).
- **SC-009**: Customer-support contact volume related to "where is my order?" drops by at least 30% after launch (because in-app order tracking and notifications cover that question).
- **SC-010**: Cancel and refund actions complete within 1 second of confirmation, with the order's status reflecting the new state immediately on the order detail screen.
