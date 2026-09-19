import 'city_model.dart';

class CitiesResponse {
  final bool status;
  final String message;
  final List<CityModel> data;

  const CitiesResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory CitiesResponse.fromJson(Map<String, dynamic> json) {
    final raw = json['data'];
    final list = raw is List
        ? raw
            .whereType<Map>()
            .map((e) => CityModel.fromJson(Map<String, dynamic>.from(e)))
            .toList()
        : <CityModel>[];
    return CitiesResponse(
      status: json['status'] as bool? ?? false,
      message: (json['message'] as String?) ?? '',
      data: list,
    );
  }
}
