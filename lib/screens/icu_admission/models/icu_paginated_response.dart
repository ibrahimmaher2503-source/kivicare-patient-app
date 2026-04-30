class IcuPaginatedResponse<T> {
  final List<T> data;
  final int currentPage;
  final int lastPage;
  final int total;

  IcuPaginatedResponse({
    required this.data,
    required this.currentPage,
    required this.lastPage,
    required this.total,
  });

  bool get hasMore => currentPage < lastPage;

  factory IcuPaginatedResponse.fromJson(Map<String, dynamic> json, T Function(Map<String, dynamic>) fromJson) {
    return IcuPaginatedResponse<T>(
      data: json['data'] != null ? (json['data'] as List).map((i) => fromJson(i)).toList() : [],
      currentPage: json['current_page'] ?? 1,
      lastPage: json['last_page'] ?? 1,
      total: json['total'] ?? 0,
    );
  }
}
