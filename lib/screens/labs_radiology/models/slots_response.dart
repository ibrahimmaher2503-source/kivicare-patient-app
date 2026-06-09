import 'package:intl/intl.dart';
import 'package:nb_utils/nb_utils.dart';
import 'facility_type.dart';
import 'slot_model.dart';

class SlotsResponse {
  int facilityId;
  FacilityType facilityType;
  List<DateTime> availableDates;
  Map<String, List<SlotModel>> slotsByDate;

  SlotsResponse({
    this.facilityId = 0,
    this.facilityType = FacilityType.lab,
    this.availableDates = const [],
    this.slotsByDate = const {},
  });

  factory SlotsResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] ?? {};
    final dates = (data['available_dates'] as List?)
            ?.map((e) => DateTime.parse(e))
            .toList() ??
        [];
    final slots = (data['slots_by_date'] as Map?)?.map(
          (key, value) => MapEntry(
            key.toString(),
            (value as List).map((e) => SlotModel.fromJson(e)).toList(),
          ),
        ) ??
        {};

    return SlotsResponse(
      facilityId: data['facility_id'] is int
          ? data['facility_id']
          : data['facility_id'].toString().toInt(),
      facilityType: FacilityType.fromString(data['facility_type']),
      availableDates: dates,
      slotsByDate: slots,
    );
  }

  List<SlotModel> slotsFor(DateTime date) {
    final key = DateFormat('yyyy-MM-dd').format(date);
    return slotsByDate[key] ?? const [];
  }
}
