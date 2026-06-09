import 'package:nb_utils/nb_utils.dart';

class LabTestCategoryModel {
  int id;
  String name;
  String? icon;
  String? description;
  int testsCount;

  LabTestCategoryModel({
    this.id = 0,
    this.name = '',
    this.icon,
    this.description,
    this.testsCount = 0,
  });

  factory LabTestCategoryModel.fromJson(Map<String, dynamic> json) {
    return LabTestCategoryModel(
      id: json['id'] is int ? json['id'] : json['id'].toString().toInt(),
      name: json['name'] ?? '',
      icon: json['icon'],
      description: json['description'],
      testsCount: json['tests_count'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'icon': icon,
      'description': description,
      'tests_count': testsCount,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LabTestCategoryModel &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
