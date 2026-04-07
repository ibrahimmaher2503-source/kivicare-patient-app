import 'package:kivicare_patient/models/lab_test_category_model.dart';

class LabTest {
  final int id;
  final String name;
  final String code;
  final String slug;
  final int categoryId;
  final LabTestCategory? category;
  final String department; // 'laboratory' or 'radiology'
  final String sampleType; // blood, urine, stool, tissue, imaging, swab, other
  final String description;
  final String preparationInstructions;
  final double defaultPrice;
  final String turnaroundTime;
  final String referenceRange;
  final int status;

  LabTest({
    required this.id,
    required this.name,
    required this.code,
    required this.slug,
    required this.categoryId,
    this.category,
    required this.department,
    required this.sampleType,
    required this.description,
    required this.preparationInstructions,
    required this.defaultPrice,
    required this.turnaroundTime,
    required this.referenceRange,
    required this.status,
  });

  factory LabTest.fromJson(Map<String, dynamic> json) {
    return LabTest(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      code: json['code'] ?? '',
      slug: json['slug'] ?? '',
      categoryId: json['category_id'] ?? 0,
      category: json['category'] != null ? LabTestCategory.fromJson(json['category']) : null,
      department: json['department'] ?? 'laboratory',
      sampleType: json['sample_type'] ?? 'blood',
      description: json['description'] ?? '',
      preparationInstructions: json['preparation_instructions'] ?? '',
      defaultPrice: (json['default_price'] as num?)?.toDouble() ?? 0.0,
      turnaroundTime: json['turnaround_time'] ?? '',
      referenceRange: json['reference_range'] ?? '',
      status: json['status'] ?? 1,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'code': code,
    'slug': slug,
    'category_id': categoryId,
    'category': category?.toJson(),
    'department': department,
    'sample_type': sampleType,
    'description': description,
    'preparation_instructions': preparationInstructions,
    'default_price': defaultPrice,
    'turnaround_time': turnaroundTime,
    'reference_range': referenceRange,
    'status': status,
  };
}
