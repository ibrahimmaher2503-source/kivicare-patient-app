import 'nurse_request_model.dart';

class NurseRequestListResponse {
  final List<NurseRequestModel> data;
  final int currentPage;
  final int lastPage;
  final int perPage;
  final int total;

  const NurseRequestListResponse({
    required this.data,
    required this.currentPage,
    required this.lastPage,
    required this.perPage,
    required this.total,
  });

  bool get hasMore => currentPage < lastPage;

  factory NurseRequestListResponse.fromJson(Map<String, dynamic> json) {
    final meta = json['meta'] as Map<String, dynamic>? ?? {};
    final dataList = json['data'] as List<dynamic>? ?? [];
    return NurseRequestListResponse(
      data: dataList.map((e) => NurseRequestModel.fromJson(e as Map<String, dynamic>)).toList(),
      currentPage: meta['current_page'] ?? 1,
      lastPage: meta['last_page'] ?? 1,
      perPage: meta['per_page'] ?? 15,
      total: meta['total'] ?? 0,
    );
  }
}
