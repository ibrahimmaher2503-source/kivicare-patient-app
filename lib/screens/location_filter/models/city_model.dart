class CityModel {
  final int id;
  final int governorateId;
  final String name;
  final String? nameAr;
  final String? nameEn;
  final int doctorsCount;

  const CityModel({
    required this.id,
    required this.governorateId,
    required this.name,
    this.nameAr,
    this.nameEn,
    this.doctorsCount = 0,
  });

  factory CityModel.fromJson(Map<String, dynamic> json) {
    return CityModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      governorateId: (json['governorate_id'] as num?)?.toInt() ?? 0,
      name: (json['name'] ?? json['name_en'] ?? json['name_ar'] ?? '') as String,
      nameAr: json['name_ar'] as String?,
      nameEn: json['name_en'] as String?,
      doctorsCount: (json['doctors_count'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'governorate_id': governorateId,
        'name': name,
        'name_ar': nameAr,
        'name_en': nameEn,
        'doctors_count': doctorsCount,
      };

  String displayName(String localeCode) {
    if (localeCode == 'ar' && (nameAr ?? '').isNotEmpty) return nameAr!;
    if ((nameEn ?? '').isNotEmpty) return nameEn!;
    return name;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is CityModel && other.id == id);

  @override
  int get hashCode => id.hashCode;
}
