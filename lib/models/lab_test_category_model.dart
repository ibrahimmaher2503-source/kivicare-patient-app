class LabTestCategory {
  final int id;
  final String name;
  final String slug;
  final String description;
  final String icon;
  final int displayOrder;
  final int testCount;
  final int status;

  LabTestCategory({
    required this.id,
    required this.name,
    required this.slug,
    required this.description,
    required this.icon,
    required this.displayOrder,
    required this.testCount,
    required this.status,
  });

  factory LabTestCategory.fromJson(Map<String, dynamic> json) {
    return LabTestCategory(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      slug: json['slug'] ?? '',
      description: json['description'] ?? '',
      icon: json['icon'] ?? '',
      displayOrder: json['display_order'] ?? 0,
      testCount: json['test_count'] ?? 0,
      status: json['status'] ?? 1,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'slug': slug,
    'description': description,
    'icon': icon,
    'display_order': displayOrder,
    'test_count': testCount,
    'status': status,
  };
}
