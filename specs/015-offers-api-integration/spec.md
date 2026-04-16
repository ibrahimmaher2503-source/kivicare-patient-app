# Feature Specification: Offers & Coupon System Integration

**Feature Branch**: `015-offers-api-integration`
**Created**: 2026-04-16
**Status**: Draft
**Input**: User description: "Create Offer Models & Integrate active_offers into Existing Doctor/Service Models with API Integration"

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Browse Available Offers (Priority: P1)

A patient opens the app and sees promotional offers displayed on services and doctors. Active offers appear as badges or labels showing discount information (e.g., "20% OFF"), helping them identify cost-saving opportunities when booking appointments.

**Why this priority**: Core value proposition - users need to discover offers before they can use them. Without visibility, the entire offer system provides no value.

**Independent Test**: Can be fully tested by browsing doctor/service listings and verifying offer badges display correctly with accurate discount information.

**Acceptance Scenarios**:

1. **Given** a service has one or more active offers, **When** the user views the service listing, **Then** they see a discount badge showing the best available offer (highest discount value)
2. **Given** a doctor search returns doctors with active offers, **When** the user views search results, **Then** doctors with offers display a visual indicator (has_active_offer flag)
3. **Given** an offer has expired, **When** the user views the associated service/doctor, **Then** no offer badge is displayed
4. **Given** the app language is Arabic, **When** offers are displayed, **Then** Arabic title and label are shown

---

### User Story 2 - Apply Coupon Code at Checkout (Priority: P1)

A patient proceeds to book an appointment and enters a coupon code they received (via email, SMS, or promotion). The system validates the code and shows the updated price with the discount applied before final payment.

**Why this priority**: Direct revenue impact - coupon redemption is a key conversion driver and primary way users interact with the offer system.

**Independent Test**: Can be fully tested by entering a valid coupon code during booking flow and verifying price updates correctly.

**Acceptance Scenarios**:

1. **Given** a valid coupon code for the selected service, **When** the user enters the code at checkout, **Then** the system shows original price, discount amount, and final price
2. **Given** an expired coupon code, **When** the user enters the code, **Then** the system displays "This coupon has expired" with the failure reason
3. **Given** a coupon not applicable to the selected service, **When** the user enters the code, **Then** the system displays an appropriate error message
4. **Given** a coupon is successfully applied, **When** the user proceeds to payment, **Then** the booking request includes offer_id, offer_discount, and offer_code

---

### User Story 3 - Auto-Applied Offers (Priority: P2)

A patient books a service that has auto-apply offers configured. The system automatically applies the best available offer without requiring the user to enter any code, showing them the savings achieved.

**Why this priority**: Improves user experience by reducing friction, but requires core coupon validation infrastructure from P1 stories first.

**Independent Test**: Can be fully tested by booking a service with auto_apply=true offers and verifying discount is applied without user action.

**Acceptance Scenarios**:

1. **Given** a service has an auto-apply offer, **When** the user reaches checkout, **Then** the discount is automatically calculated and displayed
2. **Given** multiple auto-apply offers exist for a service, **When** checkout is reached, **Then** the system applies the best offer (highest discount value)
3. **Given** an auto-apply offer exists but user enters a manual coupon, **When** both are valid, **Then** the system applies whichever provides greater discount

---

### User Story 4 - View Discount Breakdown (Priority: P2)

A patient wants to understand exactly how their discount was calculated. They can view a detailed breakdown showing which offer was applied, the discount type (percentage or fixed), and the exact savings amount.

**Why this priority**: Builds trust and transparency, enhances user satisfaction, but not blocking for core functionality.

**Independent Test**: Can be fully tested by applying an offer and viewing the discount_breakdown list in the UI.

**Acceptance Scenarios**:

1. **Given** an offer has been applied, **When** the user views the price summary, **Then** they see offer title, discount type, and discount amount
2. **Given** a percentage discount of 20% on a 500 service charge, **When** discount is calculated, **Then** the breakdown shows discount_amount = 100

---

### User Story 5 - View Public Offers Page (Priority: P3)

A patient wants to browse all currently available public offers to find deals before deciding which service to book. They can view a dedicated offers page showing featured promotions with banner images, descriptions, and terms.

**Why this priority**: Discovery enhancement - nice to have for marketing but users can still discover offers through service/doctor listings.

**Independent Test**: Can be fully tested by navigating to offers page and verifying paginated list displays with all offer details.

**Acceptance Scenarios**:

1. **Given** public offers exist, **When** the user opens the offers page, **Then** they see a paginated list of active offers
2. **Given** an offer has a banner image, **When** displayed in the list, **Then** the image is shown with title, short_label, and discount information
3. **Given** the user taps an offer, **When** viewing details, **Then** they see full description, terms, validity dates, and applicable services count

---

### Edge Cases

- What happens when an offer's end_date passes while the user is in checkout? System should re-validate before final booking submission
- How does the system handle offers with maximum usage limits? Backend validates, app displays "Offer no longer available" message
- What happens when minimum_order_amount is not met? System displays "Minimum order of X required" and doesn't apply discount
- How does the system handle network errors during coupon validation? Display retry option with cached price (no discount shown)
- What happens when a flash offer (is_flash=true) expires mid-session? Offer badge should reflect real-time status via timeRemaining getter

## Requirements *(mandatory)*

### Functional Requirements

**Offer Data Models:**
- **FR-001**: System MUST create an Offer model with fields: id, slug, title (ar/en), shortLabel (ar/en), description (ar/en), terms (ar/en), discountType, discountValue, code, autoApply, startsAt, endsAt, isFlash, bannerText, bannerImage, servicesCount, branchesCount, maxDiscountAmount, minimumOrderAmount
- **FR-002**: System MUST create an ActiveOffer model (lightweight) with fields: id, title, label, discountType, discountValue, code, autoApply, endsAt
- **FR-003**: System MUST create a DiscountCalculation model with fields: originalPrice, discountAmount, discountedPrice, appliedOfferId, appliedOfferCode, appliedOfferTitle, discountBreakdown (list)
- **FR-004**: System MUST create a CouponValidation model with fields: offerId, code, title, discountType, discountValue, originalPrice, discountAmount, finalPrice, terms, success, failureReason

**Localization Getters:**
- **FR-005**: Offer model MUST provide displayTitle getter returning Arabic or English title based on current locale
- **FR-006**: Offer model MUST provide displayLabel getter returning Arabic or English shortLabel based on current locale
- **FR-007**: Offer model MUST provide isExpired getter returning true if endsAt is before current time
- **FR-008**: Offer model MUST provide timeRemaining getter returning Duration until offer expires (null if no end date)

**Existing Model Updates:**
- **FR-009**: Doctor model MUST include hasActiveOffer boolean field (from /doctors/search endpoint)
- **FR-010**: Service model MUST include activeOffers list field (List<ActiveOffer>)
- **FR-011**: Service model MUST provide bestOffer getter returning the ActiveOffer with highest discountValue
- **FR-012**: Booking/Appointment response models MUST include offerId, offerDiscount, and offerCode fields

**API Integration:**
- **FR-013**: System MUST provide getPublicOffers API method with pagination support (page, perPage)
- **FR-014**: System MUST provide getOfferBySlug API method to fetch single offer details
- **FR-015**: System MUST provide getServiceOffers API method to fetch eligible offers for a specific service
- **FR-016**: System MUST provide validateCoupon API method accepting code, serviceId, serviceCharge, branchId, clinicId
- **FR-017**: System MUST provide calculateDiscount API method accepting serviceId, serviceCharge, couponCode, offerId, branchId
- **FR-018**: System MUST provide applyOffer API method accepting offerId, serviceId, serviceCharge
- **FR-019**: System MUST provide removeOffer API method to clear applied offer

**Parsing Requirements:**
- **FR-020**: All activeOffers parsing MUST use null-safe pattern: `(json['active_offers'] as List?)?.map(...).toList() ?? []`
- **FR-021**: Model updates MUST NOT break existing fromJson signatures - only additive changes allowed
- **FR-022**: All API methods MUST follow existing core_apis.dart patterns for consistency

### Key Entities

- **Offer**: Full promotional offer with all marketing content (banner, description, terms) and business rules (discount type/value, validity dates, usage limits). Used for public offer listings and detail pages.

- **ActiveOffer**: Lightweight offer representation embedded in doctor/service responses. Contains only essential display data (title, label, discount info) to minimize API payload size.

- **DiscountCalculation**: Result of discount calculation showing price breakdown. Used to display savings to user before confirming booking.

- **CouponValidation**: Result of coupon code validation. Contains success/failure status with reason, enabling clear user feedback on invalid codes.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Users can see offer badges on services/doctors within 100ms of data load (no visible delay after content appears)
- **SC-002**: Coupon validation provides feedback to users within 2 seconds of code submission
- **SC-003**: 95% of users who apply a valid coupon successfully complete their booking with the discount applied
- **SC-004**: Offer information displays correctly in both Arabic and English based on user's language preference
- **SC-005**: All existing doctor/service/booking screens continue to function without regression after model updates
- **SC-006**: Zero parsing errors when API responses include or exclude active_offers array (graceful null handling)

## Assumptions

- The backend API endpoints for offers are implemented and follow the documented contract (sections 4 and 5 of API spec)
- Discount calculation logic is handled server-side; the app displays server-calculated values without client-side recalculation
- Flash offers (is_flash=true) do not require real-time countdown UI in initial implementation - static badge is sufficient
- The bestOffer getter selects purely by discountValue; complex eligibility rules are handled server-side
- Offer banners use standard cached image loading patterns already established in the app
