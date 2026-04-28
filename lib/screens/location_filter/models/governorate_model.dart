class GovernorateModel {
  final int id;
  final String name;
  final String? nameAr;
  final String? nameEn;
  final int doctorsCount;
  final int citiesCount;

  const GovernorateModel({
    required this.id,
    required this.name,
    this.nameAr,
    this.nameEn,
    this.doctorsCount = 0,
    this.citiesCount = 0,
  });

  factory GovernorateModel.fromJson(Map<String, dynamic> json) {
    return GovernorateModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: (json['name'] ?? json['name_en'] ?? json['name_ar'] ?? '') as String,
      nameAr: json['name_ar'] as String?,
      nameEn: json['name_en'] as String?,
      doctorsCount: (json['doctors_count'] as num?)?.toInt() ?? 0,
      citiesCount: (json['cities_count'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'name_ar': nameAr,
        'name_en': nameEn,
        'doctors_count': doctorsCount,
        'cities_count': citiesCount,
      };

  String displayName(String localeCode) {
    if (localeCode == 'ar' && (nameAr ?? '').isNotEmpty) return nameAr!;
    if ((nameEn ?? '').isNotEmpty) return nameEn!;
    return name;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is GovernorateModel && other.id == id);

  @override
  int get hashCode => id.hashCode;
}
