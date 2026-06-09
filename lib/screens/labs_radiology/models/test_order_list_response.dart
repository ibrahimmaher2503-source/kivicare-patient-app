import 'test_order_model.dart';

class TestOrderListResponse {
  List<TestOrderModel> data;
  int currentPage;
  int lastPage;
  int total;

  TestOrderListResponse({
    this.data = const [],
    this.currentPage = 1,
    this.lastPage = 1,
    this.total = 0,
  });

  factory TestOrderListResponse.fromJson(Map<String, dynamic> json) {
    return TestOrderListResponse(
      data: (json['data'] as List?)
              ?.map((e) => TestOrderModel.fromJson(e))
              .toList() ??
          [],
      currentPage: json['current_page'] ?? 1,
      lastPage: json['last_page'] ?? 1,
      total: json['total'] ?? 0,
    );
  }

  bool get hasMore => currentPage < lastPage;
}
