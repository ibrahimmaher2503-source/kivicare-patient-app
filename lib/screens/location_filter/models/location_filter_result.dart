import 'city_model.dart';
import 'governorate_model.dart';

class LocationFilterResult {
  final int? governorateId;
  final int? cityId;
  final GovernorateModel? governorate;
  final CityModel? city;
  final bool cleared;

  LocationFilterResult({
    this.governorateId,
    this.cityId,
    this.governorate,
    this.city,
    this.cleared = false,
  }) : assert(
          governorate == null || governorate.id == governorateId,
          'governorateId must match governorate.id',
        ),
        assert(
          city == null || city.id == cityId,
          'cityId must match city.id',
        );

  const LocationFilterResult.cleared()
      : governorateId = null,
        cityId = null,
        governorate = null,
        city = null,
        cleared = true;
}
