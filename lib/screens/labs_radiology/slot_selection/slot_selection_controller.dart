import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';
import '../../../api/labs_radiology_apis.dart';
import '../../../main.dart';
import '../../../network/network_utils.dart';
import '../models/facility_model.dart';
import '../models/facility_type.dart';
import '../models/slot_model.dart';
import '../models/slots_response.dart';

class SlotSelectionController extends GetxController {
  final FacilityModel facility;

  var isLoading = false.obs;
  var availableDates = <DateTime>[].obs;
  var selectedDate = Rxn<DateTime>();
  var slotsResponse = Rxn<SlotsResponse>();
  var selectedSlot = Rxn<SlotModel>();

  SlotSelectionController({required this.facility});

  @override
  void onInit() {
    super.onInit();
    fetchSlots();
  }

  Future<void> fetchSlots() async {
    isLoading.value = true;
    try {
      final res = facility.type == FacilityType.lab
          ? await LabsRadiologyApis.getLabSlots(facility.id)
          : await LabsRadiologyApis.getRadiologySlots(facility.id);

      slotsResponse.value = res;
      availableDates.assignAll(res.availableDates);

      if (availableDates.isNotEmpty) {
        onDateSelected(availableDates.first);
      }
    } catch (e) {
      toast(sanitizeBackendMessage(e, locale.value.somethingWentWrong));
    } finally {
      isLoading.value = false;
    }
  }

  void onDateSelected(DateTime date) {
    selectedDate.value = date;
    selectedSlot.value = null;
  }

  void onSlotSelected(SlotModel slot) {
    if (slot.available) {
      selectedSlot.value = slot;
    }
  }

  List<SlotModel> get currentSlots {
    if (selectedDate.value == null || slotsResponse.value == null) return [];
    return slotsResponse.value!.slotsFor(selectedDate.value!);
  }
}
