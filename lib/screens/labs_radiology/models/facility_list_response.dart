import 'facility_model.dart';
import 'facility_type.dart';

class FacilityListResponse {
  List<FacilityModel> data;
  int currentPage;
  int lastPage;
  int total;

  FacilityListResponse({
    this.data = const [],
    this.currentPage = 1,
    this.lastPage = 1,
    this.total = 0,
  });

  factory FacilityListResponse.fromJson(
    Map<String, dynamic> json, {
    FacilityType? fallbackType,
  }) {
    final payload =
        json['data'] is Map ? Map<String, dynamic>.from(json['data']) : json;
    final pagination = payload['pagination'] is Map
        ? Map<String, dynamic>.from(payload['pagination'])
        : payload;
    final dataList = payload['items'] is List
        ? payload['items'] as List
        : payload['data'] is List
            ? payload['data'] as List
            : const [];

    return FacilityListResponse(
      data: dataList
          .whereType<Map>()
          .map((e) => FacilityModel.fromJson(
                Map<String, dynamic>.from(e),
                fallbackType: fallbackType,
              ))
          .toList(),
      currentPage: _readInt(pagination['current_page'], fallback: 1),
      lastPage: _readInt(pagination['last_page'], fallback: 1),
      total: _readInt(pagination['total'], fallback: dataList.length),
    );
  }

  bool get hasMore => currentPage < lastPage;
}

int _readInt(dynamic value, {required int fallback}) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '') ?? fallback;
}
