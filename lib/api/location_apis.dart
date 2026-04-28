import 'package:nb_utils/nb_utils.dart';

import '../network/network_utils.dart';
import '../screens/location_filter/models/cities_response.dart';
import '../screens/location_filter/models/city_model.dart';
import '../screens/location_filter/models/governorate_model.dart';
import '../screens/location_filter/models/governorates_response.dart';
import '../utils/api_end_points.dart';

class LocationApis {
  static Future<List<GovernorateModel>> getGovernorates() async {
    final res = GovernoratesResponse.fromJson(
      await handleResponse(
        await buildHttpResponse(
          APIEndPoints.governorates,
          method: HttpMethodType.GET,
        ),
      ),
    );
    return res.data;
  }

  static Future<List<CityModel>> getCitiesByGovernorate(
    int governorateId, {
    String? search,
  }) async {
    final searchQ = (search ?? '').trim();
    final searchPart = searchQ.isEmpty ? '' : '&search=${Uri.encodeQueryComponent(searchQ)}';
    final endpoint =
        '${APIEndPoints.cities}?governorate_id=$governorateId$searchPart';
    final res = CitiesResponse.fromJson(
      await handleResponse(
        await buildHttpResponse(endpoint, method: HttpMethodType.GET),
      ),
    );
    return res.data;
  }
}
