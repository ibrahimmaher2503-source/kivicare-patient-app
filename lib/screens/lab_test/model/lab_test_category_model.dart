class LabTestCategoryListResponse {
  bool status;
  List<LabTestCategory> data;

  LabTestCategoryListResponse({this.status = false, this.data = const []});

  factory LabTestCategoryListResponse.fromJson(Map<String, dynamic> json) {
    return LabTestCategoryListResponse(
      status: json["status"] is bool ? json["status"] : false,
      data: json["data"] is List ? List<LabTestCategory>.from(json["data"].map((x) => LabTestCategory.fromJson(x))) : [],
    );
  }
}

class LabTestCategory {
  int id;
  String name;
  String slug;
  String description;
  String icon;
  int displayOrder;
  int testCount;
  bool status;

  LabTestCategory({
    this.id = -1,
    this.name = "",
    this.slug = "",
    this.description = "",
    this.icon = "",
    this.displayOrder = 0,
    this.testCount = 0,
    this.status = true,
  });

  factory LabTestCategory.fromJson(Map<String, dynamic> json) {
    return LabTestCategory(
      id: json["id"] is int ? json["id"] : -1,
      name: json["name"] is String ? json["name"] : "",
      slug: json["slug"] is String ? json["slug"] : "",
      description: json["description"] is String ? json["description"] : "",
      icon: json["icon"] is String ? json["icon"] : "",
      displayOrder: json["display_order"] is int ? json["display_order"] : 0,
      testCount: json["test_count"] is int ? json["test_count"] : 0,
      status: json["status"] is bool ? json["status"] : true,
    );
  }

  Map<String, dynamic> toJson() => {
    "id": id, "name": name, "slug": slug, "description": description,
    "icon": icon, "display_order": displayOrder, "test_count": testCount, "status": status,
  };
}
