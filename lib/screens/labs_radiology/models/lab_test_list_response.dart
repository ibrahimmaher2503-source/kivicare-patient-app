import 'lab_test_model.dart';

class LabTestListResponse {
  List<LabTestModel> data;
  int currentPage;
  int lastPage;
  int total;

  LabTestListResponse({
    this.data = const [],
    this.currentPage = 1,
    this.lastPage = 1,
    this.total = 0,
  });

  factory LabTestListResponse.fromJson(Map<String, dynamic> json) {
    return LabTestListResponse(
      data: (json['data'] as List?)
              ?.map((e) => LabTestModel.fromJson(e))
              .toList() ??
          [],
      currentPage: json['current_page'] ?? 1,
      lastPage: json['last_page'] ?? 1,
      total: json['total'] ?? 0,
    );
  }

  bool get hasMore => currentPage < lastPage;
}
