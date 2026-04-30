# Localization Keys Contract

All keys MUST be added to **both** `lib/locale/language_en.dart` and `lib/locale/language_ar.dart`. UI access is via `locale.value.<key>` only — no hardcoded strings (FR per spec §13 and Constitution V).

If an Arabic translation is unknown at implementation time, use the English string as a placeholder with a `// TODO: translate` comment per Constitution V.

## Keys grouped by surface

### Module entry
```
labsAndRadiology
labs
radiology
radiologyCenters
```

### Hub
```
searchLabs
searchRadiologyCenters
allLocations
viewTests
startingFrom
xReviews                  // pluralizable: "{count} reviews"
nearby
browseTestCategories
allTests
myTestOrders
noFacilitiesFound
```

### Categories
```
testCategories
xTests                    // pluralizable
noCategoriesFound
```

### Tests
```
tests
allTestsTitle
testDetails
preparationInstructions
turnaroundTime
xHoursTurnaround          // pluralizable: "Results in {h}h"
imaging
bookTest
bookThisTest
testCategoryLabel
priceLabel
```

### Facility detail
```
about
servicesOffered
availableTests
viewAll
facilityAddress
contactFacility
bookAppointment
```

### Slot selection
```
selectTime
selectDate
availableSlots
noSlotsAvailable
tryAnotherDate
continueToConfirm
selectASlot
slotConflictTitle         // R-4 dialog title
slotConflictBody          // R-4 dialog body
```

### Booking confirmation
```
confirmBooking
bookingSummary
testPrice
total
patientNotes
patientNotesOptional
patientNotesHint
confirmAndBook
bookingSubmitted
```

### Booking success
```
bookingSuccessful
yourTestIsBooked
referenceNumber
referenceCopied
viewOrder
backToLabs
```

### Orders
```
myOrders
orderDetails
orderRef
status
bookedOn
slotDate
slotTime
notes
pricing
totalAmount
paymentStatus
paid
unpaid
refunded
cancellationReason
downloadReport
downloadingReport
downloadFailed
reportNotReady
cancelOrder
cancelOrderTitle
cancelOrderConfirm
cancelReasonOptional
keepOrder
statusHistory
```

### Status display labels
```
statusPending
statusConfirmed
statusSampleCollected
statusInProgress
statusCompleted
statusCancelled
statusRejected
```

### Generic (only add if not already present)
```
all
search
filter
refresh
retry
somethingWentWrong
clearFilters
```

## Pluralization

Arabic plural forms differ for 0/1/2/3-10/11+. For `xReviews`, `xTests`, `xHoursTurnaround`, use `intl`'s `Intl.plural()` rather than `printf`-style replacement. Helper functions live alongside their controllers (not in `BaseLanguage`).

## Total

Approximately **80 keys** added per language × **2 languages** = **160 string entries** total.

## Test guard (recommended)

A trivial test in `test/locale/labs_radiology_keys_test.dart` can:

1. Build a `BaseLanguage` instance for `en` and one for `ar`.
2. Reflectively (or via a hand-maintained list) confirm both expose every key from the master list above.
3. Fail if either language is missing a key.

This is RECOMMENDED, not mandatory (Constitution VI).
