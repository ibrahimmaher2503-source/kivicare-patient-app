# Research: Unified Doctor-First Booking Experience

**Branch**: `010-unified-doctor-booking` | **Date**: 2026-04-02

## Research Questions & Findings

### R1: Can doctors be deduplicated across booking systems?

**Decision**: YES — deduplicate by `doctorId` field.

**Rationale**: All 4 doctor models (`Doctor`, `CallDoctor`, `IndependentDoctor`, `TopDoctor`) share the same `id` and `doctor_id` fields with identical JSON keys. A doctor available in multiple systems will have the same `doctorId` across all of them.

**Alternatives considered**:
- Match by `email` or `fullName` — rejected because `doctorId` is the canonical identifier and always present.

---

### R2: Can we unify the 4 doctor models?

**Decision**: Create a `UnifiedDoctor` model with a common core + optional booking capabilities.

**Rationale**: All 4 models share 12 core fields with identical JSON key names:

| Core Field | Doctor | CallDoctor | IndependentDoctor | TopDoctor |
|-----------|--------|-----------|-------------------|-----------|
| id | int | int | int | int |
| doctorId | int | int | int | int |
| firstName | String | String | String | String |
| lastName | String | String | String | String |
| fullName | String | String | String | String |
| email | String | String | String | String |
| mobile | String | String | String | String |
| gender | String | String | String | String |
| expert | String | String | String | String |
| profileImage | String | String | String | -- |
| averageRating | num | double | double | -- |
| totalReviews | int | int | int | -- |
| experience | String | String | String | -- |

Unique fields per model:
- **Doctor**: clinics, qualifications, reviews, social links, signature, commissions, governorate/city objects
- **CallDoctor**: `hasVideoCall`, `hasPhoneCall`, `callStartingPrice`, `callServices`
- **IndependentDoctor**: `totalPatient`, `totalAppointment`, `services` (IndependentService)
- **TopDoctor**: `playerId`, `services` (DoctorService with richer pricing)

**Type mismatch**: `averageRating` is `num` on Doctor, `double` on CallDoctor/IndependentDoctor. Unified model should use `double`.

**Alternatives considered**:
- Abstract base class with 3 subclasses — rejected; adds complexity without benefit since the unified card needs one concrete type to render.
- Keep 4 separate models — rejected; forces different card/detail implementations per type.

---

### R3: Is there a unified doctor search API endpoint?

**Decision**: YES — `doctors/search` endpoint already exists.

**Rationale**: The `searchDoctors()` method in `core_apis.dart` calls `GET doctors/search` with filters: name, governorate, city, specialty, gender, price range. Returns paginated `Doctor` list with governorate/city objects. This endpoint can serve as the primary doctor browsing API.

However, this endpoint returns the clinic-based `Doctor` model only — it does NOT include call/independent booking capabilities. To show booking badges on the unified card, we must supplement with data from the call and independent endpoints.

**Alternatives considered**:
- Request a new unified backend endpoint that returns all capabilities — ideal but requires backend work; defer to future.
- Call all 3 endpoints in parallel and merge — feasible for detail screen, too heavy for list browsing.

**Chosen approach**: Use `doctors/search` for primary browsing. Load booking capabilities lazily when the user opens a doctor's detail screen (parallel calls to call/independent service endpoints).

---

### R4: How do the 3 booking flows differ?

**Decision**: The unified Book tab must support 3 distinct API patterns.

| Aspect | Clinic | Call | Independent |
|--------|--------|------|-------------|
| **Slot endpoint** | `GET /get-time-slots` | `POST /v1/call-doctors/{id}/slots` | `POST /v1/independent-doctors/{id}/slots` |
| **Booking endpoint** | `POST /save-booking` (multipart) | `POST /v1/call-booking` (JSON) | `POST /v1/independent-booking` (JSON) |
| **Required inputs** | service, clinic, doctor, date, time | doctor, service, date, time, payment | doctor, service, date, time, payment |
| **Unique inputs** | clinic selection, file uploads, other patient | call type (video/phone) | none |
| **Payment flow** | Multi-step (summary → PaymentScreen) | Immediate (cash) | Immediate (cash) |
| **Service model** | `ServiceElement` | `CallService` | `IndependentService` |

**Shared minimum**: doctor + service + date + time slot. All 3 return time slots in a compatible format.

**Alternatives considered**:
- Single abstract booking service — rejected; the 3 APIs have different HTTP methods, content types, and response shapes. Abstraction would be leaky.

**Chosen approach**: The Book tab renders 3 expandable sections. Each section encapsulates its own controller logic and API calls but shares the date picker and slot grid UI components.

---

### R5: How should the unified doctor card show booking capabilities?

**Decision**: Show badges only for capabilities confirmed by data, load capabilities lazily.

**Rationale**: The primary doctor list endpoint (`doctors/search`) doesn't include call/independent data. Loading all 3 endpoints per card in a list would be O(N*3) API calls — unacceptable.

**Approach**:
1. **Doctor list**: Show core card (name, photo, specialty, rating). No booking badges on list cards — too many API calls.
2. **Doctor detail**: When user opens a profile, fire 3 parallel requests (clinic services, call services, independent services). Show booking method sections based on which return data.
3. **Popular doctors (home)**: Dashboard API could be extended, but for now, show a "Book" button that opens the detail screen.

**Alternatives considered**:
- Pre-fetch all capabilities for list — rejected; N*3 API calls for a paginated list is too heavy.
- Backend unified endpoint — ideal future state; not available now.
- Cache capabilities after first load — viable optimization for phase 2.

---

### R6: What existing components can be reused?

**Decision**: Reuse `TimeSlotChip`, date picker pattern, and review/qualification components.

**Reusable components**:
- `TimeSlotChip` (from `call_booking`) — already shared with independent booking
- `AboutDoctorComponent` — bio, contact, social links display
- `DoctorReviewCard` — review display with rating
- `DoctorQualificationCard` — qualification display
- `DoctorQualificationComponent` — qualification list with pagination
- `DoctorServicesComponent` — service list (needs adapter for different service types)
- Date picker pattern (standard Flutter `showDatePicker`)
- `PriceWidget` — price formatting

**Components to create new**:
- `UnifiedDoctorCard` — replaces 4 card variants
- `UnifiedDoctorDetailScreen` — replaces 3 detail screens
- `BookingMethodSection` — expandable booking section per type
- `DoctorQuickBookWidget` — replaces `QuickBookComponent`

---

### R7: Label renaming scope

**Decision**: Update locale keys, not variable names.

**Rationale**: Internal code can keep names like `independentBooking` and `callBooking` — only user-facing locale strings need updating. This minimizes code churn.

**Files requiring locale changes** (2 language files):
- `language_en.dart`, `language_ar.dart`

**Key renames**:
- `independentBooking` → "Book a Doctor" / "In-Person Visit"
- `callBooking` → "Video Consult"
- `myIndependentBookings` → "My Doctor Appointments"
- `myCallBookings` → "My Video Consults"
- `independentDoctors` → "Doctors" (on list screen title)
- `browseIndependentDoctors` → "Browse Doctors"
