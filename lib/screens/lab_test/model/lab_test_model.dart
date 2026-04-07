import 'lab_test_category_model.dart';
import '../../../models/governorate_model.dart';
import '../../../models/city_model.dart';

class LabTestListResponse {
  bool status;
  List<LabTest> data;
  int currentPage;
  int lastPage;
  int perPage;
  int total;

  LabTestListResponse({
    this.status = false, this.data = const [],
    this.currentPage = 1, this.lastPage = 1, this.perPage = 20, this.total = 0,
  });

  factory LabTestListResponse.fromJson(Map<String, dynamic> json) {
    List<dynamic> items = [];
    if (json["data"] is List) {
      items = json["data"];
    } else if (json["data"] is Map && json["data"]["items"] is List) {
      items = json["data"]["items"];
    }
    int currPage = 1;
    int lastPg = 1;
    int perPg = 20;
    int tot = 0;
    if (json["meta"] is Map) {
      currPage = json["meta"]["current_page"] ?? 1;
      lastPg = json["meta"]["last_page"] ?? 1;
      perPg = json["meta"]["per_page"] ?? 20;
      tot = json["meta"]["total"] ?? 0;
    } else if (json["data"] is Map && json["data"]["pagination"] is Map) {
      final p = json["data"]["pagination"];
      currPage = p["current_page"] ?? 1;
      lastPg = p["last_page"] ?? 1;
      perPg = p["per_page"] ?? 20;
      tot = p["total"] ?? 0;
    }
    return LabTestListResponse(
      status: json["status"] is bool ? json["status"] : false,
      data: items.map((x) => LabTest.fromJson(Map<String, dynamic>.from(x))).toList(),
      currentPage: currPage,
      lastPage: lastPg,
      perPage: perPg,
      total: tot,
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
  String referenceRange;
  bool status;
  Governorate? governorate;
  City? city;

  LabTest({
    this.id = -1, this.name = "", this.code = "", this.slug = "",
    this.category, this.department = "", this.sampleType = "",
    this.description = "", this.preparationInstructions = "",
    this.defaultPrice = 0.0, this.turnaroundTime = "", this.referenceRange = "",
    this.status = true,
    this.governorate,
    this.city,
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
      referenceRange: json["reference_range"] is String ? json["reference_range"] : "",
      status: json["status"] is bool ? json["status"] : true,
      governorate: json['governorate'] is Map
          ? Governorate.fromJson(Map<String, dynamic>.from(json['governorate']))
          : null,
      city: json['city'] is Map ? City.fromJson(Map<String, dynamic>.from(json['city'])) : null,
    );
  }

  Map<String, dynamic> toJson() => {
    "id": id, "name": name, "code": code, "slug": slug,
    "category": category?.toJson(), "department": department,
    "sample_type": sampleType, "description": description,
    "preparation_instructions": preparationInstructions,
    "default_price": defaultPrice, "turnaround_time": turnaroundTime, "reference_range": referenceRange, "status": status,
  };
}
