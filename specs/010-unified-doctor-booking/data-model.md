# Data Model: Unified Doctor-First Booking Experience

**Branch**: `010-unified-doctor-booking` | **Date**: 2026-04-02

## Entity Overview

```
UnifiedDoctor (1) ──→ (0..*) BookingCapability
                              │
BookingCapability (1) ──→ (1..*) ServiceInfo
                              │
BookingCapability (1) ──→ (0..*) TimeSlot (fetched on demand)
```

## Entities

### UnifiedDoctor

Merges core identity from Doctor, CallDoctor, IndependentDoctor, and TopDoctor models. Serves as the single doctor representation across all UI contexts.

| Field | Type | Source | Notes |
|-------|------|--------|-------|
| id | int | All models | User account ID |
| doctorId | int | All models | Doctor profile ID (primary dedup key) |
| firstName | String | All models | |
| lastName | String | All models | |
| fullName | String | All models | Display name |
| email | String | All models | |
| mobile | String | All models | |
| gender | String | All models | |
| expert | String | All models | Specialty/expertise |
| profileImage | String | All models | URL |
| averageRating | double | All models | Standardized to double (Doctor uses num) |
| totalReviews | int | All models | |
| experience | String | Doctor, Call, Independent | Years of experience |
| description | String | Doctor, Independent | Bio/about |
| aboutSelf | String | Doctor, Call | Extended biography |
| address | String | Doctor, Independent, TopDoctor | |
| latitude | String | Doctor, Independent, TopDoctor | |
| longitude | String | Doctor, Independent, TopDoctor | |
| governorate | Governorate? | Doctor (search) | Location object |
| governorateCity | City? | Doctor (search) | City object |
| status | int | Doctor, Independent, TopDoctor | Active/inactive |
| totalAppointment | int | Doctor, Independent | |
| totalPatient | int | Independent only | |
| socialLinks | SocialLinks? | Doctor only | Facebook, Instagram, Twitter, Dribbble |
| clinics | List\<Clinic\> | Doctor only | Associated clinics |
| qualifications | List\<Qualification\> | Doctor only | Credentials |
| reviews | List\<ReviewData\> | Doctor only | Embedded reviews (also paginated separately) |
| bookingCapabilities | List\<BookingCapability\> | Aggregated | Loaded lazily on detail screen |

**Construction**: Factory constructors to create from each existing model type:
- `UnifiedDoctor.fromDoctor(Doctor d)` — from clinic/search endpoint
- `UnifiedDoctor.fromCallDoctor(CallDoctor d)` — from call endpoint
- `UnifiedDoctor.fromIndependentDoctor(IndependentDoctor d)` — from independent endpoint
- `UnifiedDoctor.fromTopDoctor(TopDoctor d)` — from dashboard popular doctors

**Deduplication**: By `doctorId`. When merging from multiple sources, keep the richest data (Doctor model has the most fields) and append booking capabilities.

---

### BookingCapability

Represents one way a patient can book this doctor. Attached to UnifiedDoctor after loading from the relevant API endpoint.

| Field | Type | Notes |
|-------|------|-------|
| type | BookingType (enum) | clinic, videoCall, phoneCall, inPerson |
| isAvailable | bool | Whether this booking type is currently active |
| startingPrice | double? | Lowest price across services for this type |
| services | List\<ServiceInfo\> | Available services for this booking type |

**Enum BookingType**:
- `clinic` — Book at a clinic (existing clinic-based flow)
- `videoCall` — Video consultation (from call booking, hasVideoCall=true)
- `phoneCall` — Phone consultation (from call booking, hasPhoneCall=true)
- `inPerson` — In-person visit (from independent booking)

**Loading strategy**: Capabilities are NOT loaded with the doctor list. They are fetched when the user opens the detail screen, via parallel API calls:
1. Clinic services: existing doctor services from `getDoctorDetails()`
2. Call services: `getCallDoctorServices(doctorId)`
3. Independent services: `getIndependentDoctorServices(doctorId)`

If an endpoint returns empty or errors (404), that capability is simply not shown.

---

### ServiceInfo

Unified service representation that wraps the 3 different service models. Each booking type has a different underlying service model, but they share enough for display.

| Field | Type | Notes |
|-------|------|-------|
| id | int | Service ID |
| name | String | Service name |
| description | String | Service description |
| durationMin | int | Duration in minutes |
| timeSlot | int | Slot interval in minutes |
| charges | double | Base price |
| discount | int | Discount percentage |
| finalPrice | double | Calculated: charges - (charges * discount / 100) |
| bookingType | BookingType | Which booking flow this service belongs to |
| rawService | dynamic | Original service object (ServiceElement, CallService, or IndependentService) for API calls |

**Construction**: Factory constructors:
- `ServiceInfo.fromClinicService(ServiceElement s)`
- `ServiceInfo.fromCallService(CallService s)`
- `ServiceInfo.fromIndependentService(IndependentService s)`

The `rawService` field preserves the original typed object needed when calling the booking API (each API expects different request fields).

---

### TimeSlot (reused)

Already shared between call and independent booking modules. No changes needed.

| Field | Type | Notes |
|-------|------|-------|
| value | String | 24h format: "09:00" |
| label | String | Display format: "9:00 AM" |

For clinic-based slots: The existing endpoint returns plain strings. Wrap them in TimeSlot objects for consistency.

---

## State Transitions

### Booking Flow State Machine

```
idle → loadingCapabilities → capabilitiesLoaded
                                    │
                          [user picks booking type]
                                    ▼
                            serviceSelection → dateSelection → loadingSlots → slotSelection
                                                                                    │
                                                                          [user picks slot]
                                                                                    ▼
                                                                              confirmBooking → booking → success
                                                                                                  │
                                                                                            [on error]
                                                                                                  ▼
                                                                                              bookingError
```

### BookingCapability Loading States

```
notLoaded → loading → loaded(capabilities)
                  │
                  └─→ error(message)
```

## Validation Rules

- `doctorId` must be > 0
- `averageRating` must be 0.0-5.0
- `BookingCapability.services` must have at least 1 service when `isAvailable` is true
- `TimeSlot.value` must match pattern `HH:mm`
- `ServiceInfo.charges` must be >= 0
- `ServiceInfo.discount` must be 0-100
- Date selection must be today or future (up to 90 days)
