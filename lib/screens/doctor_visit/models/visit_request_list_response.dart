import 'visit_request_model.dart';

class VisitRequestListResponse {
  final List<VisitRequestModel> data;
  final int currentPage;
  final int lastPage;
  final int total;
  final bool hasMore;

  VisitRequestListResponse({
    this.data = const [],
    this.currentPage = 1,
    this.lastPage = 1,
    this.total = 0,
    this.hasMore = false,
  });

  factory VisitRequestListResponse.fromJson(Map<String, dynamic> json) {
    // Handle both wrapped {"data": {"data": [...], ...}} and flat {"data": [...], ...}
    final Map<String, dynamic> payload =
        json['data'] is Map<String, dynamic> ? json['data'] as Map<String, dynamic> : json;

    final List<VisitRequestModel> items = payload['data'] is List
        ? List<VisitRequestModel>.from(
            (payload['data'] as List).map(
              (e) => VisitRequestModel.fromJson(e as Map<String, dynamic>),
            ),
          )
        : [];

    final int currentPage = payload['current_page'] is int ? payload['current_page'] : 1;
    final int lastPage = payload['last_page'] is int ? payload['last_page'] : 1;
    final int total = payload['total'] is int ? payload['total'] : items.length;

    return VisitRequestListResponse(
      data: items,
      currentPage: currentPage,
      lastPage: lastPage,
      total: total,
      hasMore: currentPage < lastPage,
    );
  }
}
