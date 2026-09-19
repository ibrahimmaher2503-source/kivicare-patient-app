import 'governorate_model.dart';

class GovernoratesResponse {
  final bool status;
  final String message;
  final List<GovernorateModel> data;

  const GovernoratesResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory GovernoratesResponse.fromJson(Map<String, dynamic> json) {
    final raw = json['data'];
    final list = raw is List
        ? raw
            .whereType<Map>()
            .map((e) => GovernorateModel.fromJson(Map<String, dynamic>.from(e)))
            .toList()
        : <GovernorateModel>[];
    return GovernoratesResponse(
      status: json['status'] as bool? ?? false,
      message: (json['message'] as String?) ?? '',
      data: list,
    );
  }
}
