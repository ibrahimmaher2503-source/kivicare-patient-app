import 'lab_test_category_model.dart';

class LabTestListResponse {
  bool status;
  List<LabTest> data;
  int currentPage;
  int lastPage;
  int perPage;
  int total;

  LabTestListResponse({
    this.status = false, this.data = const [],
    this.currentPage = 1, this.lastPage = 1, this.perPage = 15, this.total = 0,
  });

  factory LabTestListResponse.fromJson(Map<String, dynamic> json) {
    return LabTestListResponse(
      status: json["status"] is bool ? json["status"] : false,
      data: json["data"] is List ? List<LabTest>.from(json["data"].map((x) => LabTest.fromJson(x))) : [],
      currentPage: json["meta"] is Map ? (json["meta"]["current_page"] ?? 1) : 1,
      lastPage: json["meta"] is Map ? (json["meta"]["last_page"] ?? 1) : 1,
      perPage: json["meta"] is Map ? (json["meta"]["per_page"] ?? 15) : 15,
      total: json["meta"] is Map ? (json["meta"]["total"] ?? 0) : 0,
    );
  }
}

class LabTest {
  int id;
  String name;
  String code;
  String slug;
  LabTestCategory? category;
  String department;
  String sampleType;
  String description;
  String preparationInstructions;
  double defaultPrice;
  String turnaroundTime;
  bool status;

  LabTest({
    this.id = -1, this.name = "", this.code = "", this.slug = "",
    this.category, this.department = "", this.sampleType = "",
    this.description = "", this.preparationInstructions = "",
    this.defaultPrice = 0.0, this.turnaroundTime = "", this.status = true,
  });

  factory LabTest.fromJson(Map<String, dynamic> json) {
    return LabTest(
      id: json["id"] is int ? json["id"] : -1,
      name: json["name"] is String ? json["name"] : "",
      code: json["code"] is String ? json["code"] : "",
      slug: json["slug"] is String ? json["slug"] : "",
      category: json["category"] is Map<String, dynamic> ? LabTestCategory.fromJson(json["category"]) : null,
      department: json["department"] is String ? json["department"] : "",
      sampleType: json["sample_type"] is String ? json["sample_type"] : "",
      description: json["description"] is String ? json["description"] : "",
      preparationInstructions: json["preparation_instructions"] is String ? json["preparation_instructions"] : "",
      defaultPrice: json["default_price"] is num ? json["default_price"].toDouble() : 0.0,
      turnaroundTime: json["turnaround_time"] is String ? json["turnaround_time"] : "",
      status: json["status"] is bool ? json["status"] : true,
    );
  }

  Map<String, dynamic> toJson() => {
    "id": id, "name": name, "code": code, "slug": slug,
    "category": category?.toJson(), "department": department,
    "sample_type": sampleType, "description": description,
    "preparation_instructions": preparationInstructions,
    "default_price": defaultPrice, "turnaround_time": turnaroundTime, "status": status,
  };
}
