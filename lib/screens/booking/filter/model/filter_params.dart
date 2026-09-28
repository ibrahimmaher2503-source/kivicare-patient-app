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

  const FilterParams({
    this.clinicId = -1,
    this.serviceType = '',
    this.priceMin = '',
    this.priceMax = '',
    required this.moduleType,
    this.categoryId = -1,
    this.governorateId,
    this.cityId,
    this.specialtyId,
    this.gender = '',
    this.ratingMin = '',
    this.ratingMax = '',
  });
}
