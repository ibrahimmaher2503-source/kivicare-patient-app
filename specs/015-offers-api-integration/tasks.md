# Tasks: Offers & Coupon System Integration

**Input**: Design documents from `/specs/015-offers-api-integration/`
**Prerequisites**: plan.md, spec.md, research.md, data-model.md, contracts/offers-api.md, quickstart.md

**Tests**: Not explicitly requested in specification - test tasks omitted.

**Organization**: Tasks are grouped by user story to enable independent implementation and testing of each story.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (e.g., US1, US2, US3)
- Include exact file paths in descriptions

## Path Conventions

- **Flutter Mobile App**: `lib/` for source, `test/` for tests
- Models: `lib/screens/{feature}/model/`
- API: `lib/api/`
- Utils: `lib/utils/`

---

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Project initialization and directory structure

- [X] T001 Create offers directory structure at lib/screens/offers/model/
- [X] T002 [P] Add offer API endpoints to lib/utils/api_end_points.dart

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Core models and API infrastructure that ALL user stories depend on

**⚠️ CRITICAL**: No user story work can begin until this phase is complete

### New Models (Required by All Stories)

- [X] T003 [P] Create ActiveOffer model in lib/screens/offers/model/active_offer_model.dart
- [X] T004 [P] Create Offer model in lib/screens/offers/model/offer_model.dart
- [X] T005 [P] Create DiscountBreakdownItem model in lib/screens/offers/model/discount_calculation_model.dart
- [X] T006 Create DiscountCalculation model in lib/screens/offers/model/discount_calculation_model.dart (depends on T005)
- [X] T007 [P] Create CouponValidation model in lib/screens/offers/model/coupon_validation_model.dart

### API Service Layer

- [X] T008 Create OffersApis class with endpoint methods in lib/api/offers_apis.dart (depends on T002-T007)

### Existing Model Updates

- [X] T009 [P] Add hasActiveOffer field to Doctor model in lib/screens/doctor/model/doctor_list_res.dart
- [X] T010 [P] Add activeOffers field and bestOffer getter to ServiceElement in lib/screens/service/model/service_list_model.dart
- [X] T011 [P] Add offer fields (offerId, offerDiscount, offerCode) to AppointmentData in lib/screens/booking/model/appointments_res_model.dart
- [X] T012 [P] Add offer fields (offerId, offerDiscount, offerCode) to AppointmentDetailData in lib/screens/booking/model/appointment_detail_res.dart

**Checkpoint**: Foundation ready - all models and API methods exist. User story implementation can begin.

---

## Phase 3: User Story 1 - Browse Available Offers (Priority: P1) 🎯 MVP

**Goal**: Patients see promotional offers displayed as badges on services and doctors

**Independent Test**: Browse doctor/service listings and verify offer badges display correctly with accurate discount information.

### Implementation for User Story 1

- [X] T013 [US1] Implement getServiceOffers API method in lib/api/offers_apis.dart
- [X] T014 [US1] Verify ActiveOffer.formattedDiscount getter returns "20%" or "EGP 50" format in lib/screens/offers/model/active_offer_model.dart
- [X] T015 [US1] Verify ServiceElement.bestOffer getter returns highest discountValue offer in lib/screens/service/model/service_list_model.dart
- [X] T016 [US1] Verify Doctor.hasActiveOffer flag parses correctly from API response in lib/screens/doctor/model/doctor_list_res.dart
- [X] T017 [US1] Verify localized display getters (displayTitle, displayLabel) work in both Arabic and English in lib/screens/offers/model/offer_model.dart
- [X] T018 [US1] Verify isExpired getter correctly identifies expired offers in lib/screens/offers/model/active_offer_model.dart

**Checkpoint**: User Story 1 complete. Services/doctors display offer badges with correct discount info in both languages.

---

## Phase 4: User Story 2 - Apply Coupon Code at Checkout (Priority: P1)

**Goal**: Patients enter coupon codes at checkout, system validates and shows updated price

**Independent Test**: Enter a valid coupon code during booking flow and verify price updates correctly.

### Implementation for User Story 2

- [X] T019 [US2] Implement validateCoupon API method in lib/api/offers_apis.dart
- [X] T020 [US2] Implement applyOffer API method in lib/api/offers_apis.dart
- [X] T021 [US2] Implement removeOffer API method in lib/api/offers_apis.dart
- [X] T022 [US2] Verify CouponValidation.failureReason maps to user-friendly error messages in lib/screens/offers/model/coupon_validation_model.dart
- [X] T023 [US2] Verify AppointmentData correctly includes offerId, offerDiscount, offerCode when submitted in lib/screens/booking/model/appointments_res_model.dart

**Checkpoint**: User Story 2 complete. Users can enter coupon codes, see validation feedback, and discounts are applied to bookings.

---

## Phase 5: User Story 3 - Auto-Applied Offers (Priority: P2)

**Goal**: System automatically applies best available offer when auto_apply=true

**Independent Test**: Book a service with auto_apply=true offers and verify discount is applied without user action.

### Implementation for User Story 3

- [X] T024 [US3] Implement calculateDiscount API method in lib/api/offers_apis.dart
- [X] T025 [US3] Verify ActiveOffer.autoApply flag parses correctly in lib/screens/offers/model/active_offer_model.dart
- [X] T026 [US3] Verify DiscountCalculation model correctly parses discount_breakdown array in lib/screens/offers/model/discount_calculation_model.dart

**Checkpoint**: User Story 3 complete. Auto-apply offers are automatically applied at checkout without user action.

---

## Phase 6: User Story 4 - View Discount Breakdown (Priority: P2)

**Goal**: Patients see detailed breakdown of how their discount was calculated

**Independent Test**: Apply an offer and view the discount_breakdown list showing offer details.

### Implementation for User Story 4

- [X] T027 [US4] Verify DiscountBreakdownItem model parses all fields (offerId, title, code, discountType, discountAmount) in lib/screens/offers/model/discount_calculation_model.dart
- [X] T028 [US4] Verify DiscountCalculation.discountBreakdown list handles multiple offers in lib/screens/offers/model/discount_calculation_model.dart

**Checkpoint**: User Story 4 complete. Users can view detailed discount breakdown showing offer title, type, and amount.

---

## Phase 7: User Story 5 - View Public Offers Page (Priority: P3)

**Goal**: Patients browse all public offers with banner images, descriptions, and terms

**Independent Test**: Navigate to offers page and verify paginated list displays with all offer details.

### Implementation for User Story 5

- [X] T029 [US5] Implement getPublicOffers API method with pagination in lib/api/offers_apis.dart
- [X] T030 [US5] Implement getOfferBySlug API method in lib/api/offers_apis.dart
- [X] T031 [US5] Verify Offer model parses all fields including bannerImage, bannerText, terms (ar/en) in lib/screens/offers/model/offer_model.dart
- [X] T032 [US5] Verify Offer.displayTerms and Offer.displayDescription getters return localized content in lib/screens/offers/model/offer_model.dart
- [X] T033 [US5] Verify Offer.isActive getter correctly checks startsAt and endsAt dates in lib/screens/offers/model/offer_model.dart
- [X] T034 [US5] Verify Offer.timeRemaining getter returns Duration for countdown display in lib/screens/offers/model/offer_model.dart

**Checkpoint**: User Story 5 complete. Offers page displays paginated list with full offer details.

---

## Phase 8: Polish & Cross-Cutting Concerns

**Purpose**: Final validation and cleanup

- [X] T035 [P] Verify null-safe parsing: activeOffers parses to empty list when API returns null
- [X] T036 [P] Verify existing doctor/service screens work without regression after model updates
- [X] T037 [P] Verify existing booking flow works without regression after appointment model updates
- [X] T038 Run all API methods against backend to validate contract compliance
- [X] T039 Verify offer badges render within 100ms of data load (SC-001)
- [X] T040 Verify coupon validation responds within 2 seconds (SC-002)

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies - can start immediately
- **Foundational (Phase 2)**: Depends on Setup completion - BLOCKS all user stories
- **User Stories (Phase 3-7)**: All depend on Foundational phase completion
  - US1 and US2 (both P1) can proceed in parallel
  - US3 and US4 (both P2) can proceed in parallel after P1 stories
  - US5 (P3) can proceed after P2 stories
- **Polish (Phase 8)**: Depends on all user stories being complete

### User Story Dependencies

- **User Story 1 (P1)**: Can start after Foundational (Phase 2) - No dependencies on other stories
- **User Story 2 (P1)**: Can start after Foundational (Phase 2) - No dependencies on other stories
- **User Story 3 (P2)**: Can start after Foundational (Phase 2) - Builds on coupon infrastructure
- **User Story 4 (P2)**: Can start after Foundational (Phase 2) - Uses DiscountCalculation model
- **User Story 5 (P3)**: Can start after Foundational (Phase 2) - Independent public offers feature

### Within Each User Story

- Models before services
- Services before endpoints
- Verification tasks after implementation
- Story complete before moving to next priority

### Parallel Opportunities

**Phase 1 (Setup)**:
- T001, T002 can run in parallel

**Phase 2 (Foundational)**:
- T003, T004, T005, T007 can run in parallel (independent models)
- T009, T010, T011, T012 can run in parallel (different existing files)

**User Stories**:
- US1 and US2 can run in parallel (both P1, different API methods)
- US3 and US4 can run in parallel (both P2, different concerns)

---

## Parallel Example: Foundational Phase

```bash
# Launch all new models together (different files):
Task: "Create ActiveOffer model in lib/screens/offers/model/active_offer_model.dart"
Task: "Create Offer model in lib/screens/offers/model/offer_model.dart"
Task: "Create DiscountBreakdownItem model in lib/screens/offers/model/discount_calculation_model.dart"
Task: "Create CouponValidation model in lib/screens/offers/model/coupon_validation_model.dart"

# Launch all existing model updates together (different files):
Task: "Add hasActiveOffer field to Doctor model in lib/screens/doctor/model/doctor_list_res.dart"
Task: "Add activeOffers field to ServiceElement in lib/screens/service/model/service_list_model.dart"
Task: "Add offer fields to AppointmentData in lib/screens/booking/model/appointments_res_model.dart"
Task: "Add offer fields to AppointmentDetailData in lib/screens/booking/model/appointment_detail_res.dart"
```

---

## Implementation Strategy

### MVP First (User Stories 1 + 2)

1. Complete Phase 1: Setup
2. Complete Phase 2: Foundational (CRITICAL - blocks all stories)
3. Complete Phase 3: User Story 1 (Browse Offers)
4. Complete Phase 4: User Story 2 (Apply Coupon)
5. **STOP and VALIDATE**: Test offer display and coupon application independently
6. Deploy/demo if ready - core offer functionality is complete

### Incremental Delivery

1. Complete Setup + Foundational → Foundation ready
2. Add US1 + US2 → Test independently → Deploy/Demo (MVP!)
3. Add US3 + US4 → Test independently → Deploy/Demo (Auto-apply + Breakdown)
4. Add US5 → Test independently → Deploy/Demo (Public Offers Page)
5. Each story adds value without breaking previous stories

### Single Developer Strategy

1. Complete Setup + Foundational
2. US1 → Verify offer badges display
3. US2 → Verify coupon validation works
4. US3 → Verify auto-apply works
5. US4 → Verify breakdown displays
6. US5 → Verify offers page works
7. Polish → Final validation

---

## Notes

- [P] tasks = different files, no dependencies
- [Story] label maps task to specific user story for traceability
- Each user story should be independently completable and testable
- Commit after each task or logical group
- Stop at any checkpoint to validate story independently
- All model parsing uses null-safe defensive patterns per research.md
- Localization getters use `locale.value.languageCode` per codebase conventions
