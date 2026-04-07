/// Lab Test Filter Model
/// Represents filter state for browsing and searching lab tests

class LabTestFilter {
  final int? categoryId; // Filter by category (nullable = no category filter)
  final String? department; // Filter by department: 'laboratory' or 'radiology' (nullable = both)
  final String? searchQuery; // Search term in name, code, or description
  final int currentPage; // Current pagination page (1-based)
  final int perPage; // Number of results per page

  LabTestFilter({
    this.categoryId,
    this.department,
    this.searchQuery,
    this.currentPage = 1,
    this.perPage = 15,
  });

  /// Create a copy of this filter with optional field overrides
  LabTestFilter copyWith({
    int? categoryId,
    String? department,
    String? searchQuery,
    int? currentPage,
    int? perPage,
  }) {
    return LabTestFilter(
      categoryId: categoryId ?? this.categoryId,
      department: department ?? this.department,
      searchQuery: searchQuery ?? this.searchQuery,
      currentPage: currentPage ?? this.currentPage,
      perPage: perPage ?? this.perPage,
    );
  }

  /// Create a new filter with reset pagination
  LabTestFilter resetPagination() {
    return copyWith(currentPage: 1);
  }

  /// Create a new filter with pagination incremented
  LabTestFilter nextPage() {
    return copyWith(currentPage: currentPage + 1);
  }

  /// Check if any filters are applied (besides pagination)
  bool get hasActiveFilters => categoryId != null || department != null || (searchQuery?.isNotEmpty ?? false);

  /// Get query parameters for API calls
  Map<String, dynamic> toQueryParams() {
    final params = <String, dynamic>{};

    if (categoryId != null) {
      params['category_id'] = categoryId;
    }
    if (department != null) {
      params['department'] = department;
    }
    if (searchQuery != null && searchQuery!.isNotEmpty) {
      params['search'] = searchQuery;
    }
    params['page'] = currentPage;
    params['per_page'] = perPage;

    return params;
  }

  /// Create from JSON (for persistence)
  factory LabTestFilter.fromJson(Map<String, dynamic> json) {
    return LabTestFilter(
      categoryId: json['category_id'],
      department: json['department'],
      searchQuery: json['search_query'],
      currentPage: json['current_page'] ?? 1,
      perPage: json['per_page'] ?? 15,
    );
  }

  /// Convert to JSON (for persistence)
  Map<String, dynamic> toJson() => {
    'category_id': categoryId,
    'department': department,
    'search_query': searchQuery,
    'current_page': currentPage,
    'per_page': perPage,
  };

  /// Default filter (no filters applied)
  static LabTestFilter get empty => LabTestFilter();

  @override
  String toString() => 'LabTestFilter(categoryId: $categoryId, department: $department, searchQuery: $searchQuery, page: $currentPage/$perPage)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LabTestFilter &&
          runtimeType == other.runtimeType &&
          categoryId == other.categoryId &&
          department == other.department &&
          searchQuery == other.searchQuery &&
          currentPage == other.currentPage &&
          perPage == other.perPage;

  @override
  int get hashCode =>
      categoryId.hashCode ^
      department.hashCode ^
      searchQuery.hashCode ^
      currentPage.hashCode ^
      perPage.hashCode;
}
