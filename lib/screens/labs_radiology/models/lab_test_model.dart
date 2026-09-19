import 'package:nb_utils/nb_utils.dart';
import 'facility_type.dart';
import 'lab_test_category_model.dart';

class LabTestModel {
  int id;
  String name;
  String? slug;
  LabTestCategoryModel? category;
  String? description;
  double? price;
  String currency;
  String? preparationInstructions;
  int? turnaroundHours;
  bool isImaging;
  FacilityType facilityType;

  LabTestModel({
    this.id = 0,
    this.name = '',
    this.slug,
    this.category,
    this.description,
    this.price,
    this.currency = 'EGP',
    this.preparationInstructions,
    this.turnaroundHours,
    this.isImaging = false,
    this.facilityType = FacilityType.lab,
  });

  factory LabTestModel.fromJson(Map<String, dynamic> json) {
    return LabTestModel(
      id: json['id'] is int ? json['id'] : json['id'].toString().toInt(),
      name: json['name'] ?? '',
      slug: json['slug'],
      category: json['category'] != null
          ? LabTestCategoryModel.fromJson(json['category'])
          : null,
      description: json['description'],
      // Backend sends the price under `default_price` (often a string like
      // "300.00"); older/other payloads use a numeric `price`. Support both.
      price: json['price'] is num
          ? (json['price'] as num).toDouble()
          : double.tryParse('${json['price'] ?? json['default_price'] ?? ''}'),
      currency: json['currency'] ?? 'EGP',
      preparationInstructions: json['preparation_instructions'],
      turnaroundHours: json['turnaround_hours']?.toInt(),
      isImaging: json['is_imaging'] ?? false,
      facilityType: FacilityType.fromString(json['facility_type']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'slug': slug,
      'category': category?.toJson(),
      'description': description,
      'price': price,
      'currency': currency,
      'preparation_instructions': preparationInstructions,
      'turnaround_hours': turnaroundHours,
      'is_imaging': isImaging,
      'facility_type': facilityType.apiValue,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LabTestModel &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
