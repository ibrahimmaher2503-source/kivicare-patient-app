# Routing Contract

Internal navigation graph for the module. Other parts of the app may push these routes; the module guarantees they remain stable.

| From | Action | To |
|---|---|---|
| Dashboard tile | tap | `Get.to(() => const LabsRadiologyHubScreen())` |
| Hub tabs | tap "Labs" / "Radiology" | reload list (no nav) |
| Hub card | tap | `Get.to(() => FacilityDetailScreen(facility: f))` |
| Hub quick action | "Browse Test Categories" | `Get.to(() => const TestCategoriesScreen())` |
| Hub quick action | "All Tests" | `Get.to(() => const LabTestsListScreen())` |
| Hub quick action | "My Test Orders" | `Get.to(() => const TestOrdersListScreen())` |
| Categories grid | tap category | `Get.to(() => LabTestsListScreen(categoryId: c.id))` |
| Tests list | tap test | `Get.bottomSheet(() => LabTestDetailSheet(test: t))` |
| Test detail sheet | "Book Test" (no facility ctx) | `Get.to(() => LabsRadiologyHubScreen(prefilterTestId: t.id))` |
| Test detail sheet | "Book Test" (facility ctx set) | `Get.to(() => SlotSelectionScreen(facility: f, labTest: t))` |
| Facility detail | "Book Appointment" | `Get.to(() => SlotSelectionScreen(facility: f, labTest: optionalTest))` |
| Facility detail | "Book this test" tile CTA | `Get.to(() => SlotSelectionScreen(facility: f, labTest: t))` |
| Slot selection | "Continue" | `Get.to(() => BookingConfirmationScreen(facility, labTest, slot, slotDate))` |
| Confirmation | submit success | `Get.off(() => BookingSuccessScreen(order: result))` |
| Booking success | "View Order" | `Get.off(() => TestOrderDetailScreen(orderId: o.id))` |
| Booking success | "Back to Home" | `Get.until((r) => r.isFirst)` |
| Orders list | tap order | `Get.to(() => TestOrderDetailScreen(orderId: o.id))` |
| Order detail | "Cancel Order" → confirm | API call + `controller.refresh()` (no nav) |
| Order detail | "Download Report" | `ReportDownloadService.download(...)` (no nav) |
| Push notification | `type == 'test_order_status_changed'` + `order_id` | Deep link to `TestOrderDetailScreen(orderId: <payload>)` |

**Use of `Get.off()`** is intentional after submit and on success-screen actions — these prevent users from navigating back into a stale confirmation screen.

**Constructor params** are the only public surface other modules may rely on. Adding optional named parameters is non-breaking; removing or renaming is breaking and requires a contract update.

## Public screen constructors (binding signatures)

```dart
LabsRadiologyHubScreen({Key? key, int? prefilterTestId});
TestCategoriesScreen({Key? key});
LabTestsListScreen({Key? key, int? categoryId, int? facilityId});
LabTestDetailSheet({Key? key, required LabTestModel test});
FacilityDetailScreen({Key? key, required FacilityModel facility});
SlotSelectionScreen({Key? key, required FacilityModel facility, LabTestModel? labTest});
BookingConfirmationScreen({
  Key? key,
  required FacilityModel facility,
  LabTestModel? labTest,
  required SlotModel slot,
  required DateTime slotDate,
});
BookingSuccessScreen({Key? key, required TestOrderModel order});
TestOrdersListScreen({Key? key, TestOrderStatus? initialStatusFilter});
TestOrderDetailScreen({Key? key, required int orderId});
```
