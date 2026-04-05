/// FilterParams — Typed parameter class for filter screen navigation.
///
/// Replaces the fragile positional Get.arguments List pattern.
/// Passed when opening FilterScreen via Get.to(() => FilterScreen(), arguments: FilterParams(...))
class FilterParams {
  final int clinicId;
  final String serviceType;
  final String priceMin;
  final String priceMax;
  final String moduleType;
  final int categoryId;
  final int? governorateId;
  final int? cityId;
  final int? specialtyId;
  final String gender;
  final String ratingMin;
  final String ratingMax;

  FilterParams({
    this.clinicId = -1,
    this.serviceType = "",
    this.priceMin = "",
    this.priceMax = "",
    required this.moduleType,
    this.categoryId = -1,
    this.governorateId,
    this.cityId,
    this.specialtyId,
    this.gender = "",
    this.ratingMin = "",
    this.ratingMax = "",
  });

  /// Create a copy of this FilterParams with some fields replaced.
  FilterParams copyWith({
    int? clinicId,
    String? serviceType,
    String? priceMin,
    String? priceMax,
    String? moduleType,
    int? categoryId,
    int? governorateId,
    int? cityId,
    int? specialtyId,
    String? gender,
    String? ratingMin,
    String? ratingMax,
  }) {
    return FilterParams(
      clinicId: clinicId ?? this.clinicId,
      serviceType: serviceType ?? this.serviceType,
      priceMin: priceMin ?? this.priceMin,
      priceMax: priceMax ?? this.priceMax,
      moduleType: moduleType ?? this.moduleType,
      categoryId: categoryId ?? this.categoryId,
      governorateId: governorateId ?? this.governorateId,
      cityId: cityId ?? this.cityId,
      specialtyId: specialtyId ?? this.specialtyId,
      gender: gender ?? this.gender,
      ratingMin: ratingMin ?? this.ratingMin,
      ratingMax: ratingMax ?? this.ratingMax,
    );
  }

  @override
  String toString() {
    return 'FilterParams('
        'clinicId: $clinicId, '
        'serviceType: $serviceType, '
        'priceMin: $priceMin, '
        'priceMax: $priceMax, '
        'moduleType: $moduleType, '
        'categoryId: $categoryId, '
        'governorateId: $governorateId, '
        'cityId: $cityId, '
        'specialtyId: $specialtyId, '
        'gender: $gender, '
        'ratingMin: $ratingMin, '
        'ratingMax: $ratingMax)';
  }
}
