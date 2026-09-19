# Tasks: Vezeeta-Style Pharmacy Module

**Input**: Design documents from `specs/019-vezeeta-pharmacy-module/`
**Prerequisites**: plan.md (required), spec.md (required for user stories)

**Organization**: Tasks are grouped by user story to enable independent implementation and testing of each story.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (e.g., US1, US2, US3)
- File paths are relative to repository root

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Project initialization and basic structure

- [x] T001 [P] Add Pharmacy API endpoints to `lib/utils/api_end_points.dart`
- [x] T002 [P] Create Pharmacy API service in `lib/api/pharmacy_apis.dart`
- [x] T003 [P] Add Pharmacy module translations to `lib/locale/language_en.dart`
- [x] T004 [P] Add Pharmacy module translations to `lib/locale/language_ar.dart`

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Core infrastructure that MUST be complete before ANY user story can be implemented

- [x] T005 [P] Create `PharmacyController` for shared state (cart count, unread notifications) in `lib/screens/pharmacy/pharmacy_controller.dart`
- [x] T006 [P] Create base `PharmacyResponseModel` if needed for pharmacy-specific responses in `lib/screens/pharmacy/model/pharmacy_response_model.dart`
- [x] T007 [P] Define `PharmacyConstants` (e.g., status colors, default max quantities) in `lib/screens/pharmacy/utils/pharmacy_constants.dart`

**Checkpoint**: Foundation ready - user story implementation can now begin

---

## Phase 3: User Story 1 - Browse, Order, and Receive Over-the-Counter Products (Priority: P1) 🎯 MVP

**Goal**: Enable patients to browse products, add to cart, and place orders for non-prescription items.

**Independent Test**: A patient can navigate to the Pharmacy section, find an OTC product, add it to cart, select a pharmacy, and place an order successfully.

### Implementation for User Story 1

- [x] T008 [P] [US1] Create `PharmacyProduct` model in `lib/screens/pharmacy/model/pharmacy_product_model.dart`
- [x] T009 [P] [US1] Create `PharmacyCategory` model in `lib/screens/pharmacy/model/pharmacy_category_model.dart`
- [x] T010 [P] [US1] Create `PharmacyCart` and `PharmacyCartItem` models in `lib/screens/pharmacy/model/pharmacy_cart_model.dart`
- [x] T011 [P] [US1] Create `Pharmacy` model in `lib/screens/pharmacy/model/pharmacy_model.dart`
- [x] T012 [US1] Implement `PharmacyDashboardScreen` (Home) in `lib/screens/pharmacy/pharmacy_dashboard_screen.dart`
- [x] T013 [US1] Implement `ProductListScreen` with pagination and search in `lib/screens/pharmacy/product_list_screen.dart`
- [x] T014 [US1] Implement `ProductDetailScreen` in `lib/screens/pharmacy/product_detail_screen.dart`
- [x] T015 [US1] Implement `CartScreen` with quantity steppers in `lib/screens/pharmacy/cart/cart_screen.dart`
- [x] T016 [US1] Implement `AvailablePharmaciesScreen` for fulfillment matching in `lib/screens/pharmacy/cart/available_pharmacies_screen.dart`
- [x] T017 [US1] Implement `PharmacyCheckoutScreen` with address and payment selection in `lib/screens/pharmacy/cart/pharmacy_checkout_screen.dart`
- [x] T018 [US1] Implement order placement logic and success screen in `lib/screens/pharmacy/cart/order_success_screen.dart`
- [x] T019 [US1] Add Pharmacy entry point to `lib/screens/home/components/quick_service_card.dart`
- [x] T020 [US1] Add cart count badge to dashboard and pharmacy home screens

**Checkpoint**: MVP Complete - OTC shopping flow is functional and testable.

---

## Phase 4: User Story 2 - Order Prescription-Required Medications (Priority: P2)

**Goal**: Enable patients to upload prescriptions and order prescription-only items.

**Independent Test**: A patient can upload up to 5 images as a prescription and then place an order containing a prescription-required item by attaching said prescription.

### Implementation for User Story 2

- [x] T021 [P] [US2] Create `PharmacyPrescription` model in `lib/screens/pharmacy/model/pharmacy_prescription_model.dart`
- [x] T022 [US2] Implement `PrescriptionUploadScreen` (Camera/Gallery, max 5 images) in `lib/screens/pharmacy/prescription/prescription_upload_screen.dart`
- [x] T023 [US2] Implement `PrescriptionListScreen` showing statuses in `lib/screens/pharmacy/prescription/prescription_list_screen.dart`
- [x] T024 [US2] Implement `PrescriptionDetailScreen` with image carousel in `lib/screens/pharmacy/prescription/prescription_detail_screen.dart`
- [x] T025 [US2] Add "Prescription Required" badges to product lists and detail screens
- [x] T026 [US2] Implement prescription attachment logic in `PharmacyCheckoutScreen` (FR-026)

**Checkpoint**: Prescription support complete.

---

## Phase 5: User Story 3 - Track Orders, Cancel, and Request Refunds (Priority: P3)

**Goal**: Enable patients to monitor order status, cancel pending orders, and request refunds.

**Independent Test**: A patient can view their order history, see a status timeline for an order, cancel it if allowed, or request a refund for a delivered order.

### Implementation for User Story 3

- [x] T027 [P] [US3] Create `PharmacyOrder` model in `lib/screens/pharmacy/model/pharmacy_order_model.dart`
- [x] T028 [P] [US3] Create `PharmacyRefund` model in `lib/screens/pharmacy/model/pharmacy_refund_model.dart`
- [x] T029 [US3] Implement `PharmacyOrderListScreen` in `lib/screens/pharmacy/order/pharmacy_order_list_screen.dart`
- [x] T030 [US3] Implement `PharmacyOrderDetailScreen` with status timeline (Placed -> Delivered) in `lib/screens/pharmacy/order/pharmacy_order_detail_screen.dart`
- [x] T031 [US3] Implement order cancellation logic and confirmation dialog in order detail screen
- [x] T032 [US3] Implement `RefundRequestScreen` and submission logic in `lib/screens/pharmacy/order/refund_request_screen.dart`
- [x] T033 [US3] Implement `RefundListScreen` and detail view in `lib/screens/pharmacy/order/refund_list_screen.dart`

**Checkpoint**: Post-purchase management complete.

---

## Phase 6: User Story 4 - Filter and Sort Products to Find What I Need (Priority: P4)

**Goal**: Improve product discovery with advanced filtering and sorting.

**Independent Test**: A patient can apply multiple filters (brand, price, etc.) and see the product list update with a filter count badge.

### Implementation for User Story 4

- [x] T034 [US4] Implement `PharmacyFilterScreen` using `FilterParams` pattern in `lib/screens/pharmacy/filter/pharmacy_filter_screen.dart`
- [x] T035 [US4] Integrate `FilterCountBadge` in `ProductListScreen`
- [x] T036 [US4] Implement sorting logic (Price, Rating, Newest) in `ProductListScreen`

---

## Phase 7: User Story 5 - Apply Coupon Discounts at Checkout (Priority: P5)

**Goal**: Enable patients to use coupon codes for discounts.

**Independent Test**: A patient can enter a valid coupon at checkout and see the total price decrease.

### Implementation for User Story 5

- [x] T037 [US5] Implement coupon validation API call and UI in `PharmacyCheckoutScreen`
- [x] T038 [US5] Update order summary to show discount line and recalculated total

---

## Phase 8: User Story 6 - Stay Informed via In-App Notifications (Priority: P6)

**Goal**: Centralize pharmacy-related notifications within the module.

**Independent Test**: A patient sees an unread count badge on the pharmacy notifications bell and can view all events in a list.

### Implementation for User Story 6

- [x] T039 [P] [US6] Create `PharmacyNotification` model in `lib/screens/pharmacy/model/pharmacy_notification_model.dart`
- [x] T040 [US6] Implement `PharmacyNotificationScreen` in `lib/screens/pharmacy/notification/pharmacy_notification_screen.dart`
- [x] T041 [US6] Implement unread count badge and bell icon in `PharmacyDashboardScreen`
- [x] T042 [US6] Implement "Mark all as read" and deep-linking logic

---

## Phase 9: Polish & Cross-Cutting Concerns

**Purpose**: Improvements that affect multiple user stories

- [x] T043 [P] Ensure all user-facing strings are localized in `language_en.dart` and `language_ar.dart`
- [x] T044 [P] Verify RTL layout for all screens in Arabic mode
- [x] T045 [P] Verify Dark Mode contrast and legibility for all module components
- [x] T046 [P] Implement empty states and error/retry widgets for all list screens
- [x] T047 [P] Implement optimistic UI for cart quantity updates (FR-046)
- [x] T048 [P] Enforce maximum quantity caps in stepper and checkout (FR-013a)
- [x] T049 [P] Implement cart re-validation on fulfillment pharmacy selection (FR-019a)

---

## Dependencies & Execution Order

### Phase Dependencies

1. **Phase 1 & 2** are prerequisites for everything else.
2. **Phase 3 (MVP)** should be completed next.
3. **Phases 4-8** can be worked on in parallel or in priority order.
4. **Phase 9** should be ongoing but finalized at the end.

### Execution Order

- T001-T007 (Foundational)
- T008-T020 (US1 - MVP)
- T021-T026 (US2 - Prescriptions)
- T027-T033 (US3 - Orders & Refunds)
- T034-T036 (US4 - Filters)
- T037-T038 (US5 - Coupons)
- T039-T042 (US6 - Notifications)

---

## Notes

- [P] tasks = different files, no dependencies
- [Story] label maps task to specific user story for traceability
- Verify each user story independently after completion
- Adhere to design tokens (16px radius, navy shadows) from `CLAUDE.md`
