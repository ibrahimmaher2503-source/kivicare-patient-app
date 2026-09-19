import 'dart:async';

import 'package:get_storage/get_storage.dart';

import '../models/city_model.dart';
import '../models/governorate_model.dart';

class LocationCacheService {
  static const String _govKey = 'location_cache.governorates';
  static const String _govCachedAtKey = 'location_cache.governorates.cached_at';
  static String _citiesKey(int govId) => 'location_cache.cities.$govId';
  static String _citiesCachedAtKey(int govId) =>
      'location_cache.cities.$govId.cached_at';
  static const String _lastGovKey = 'location_cache.last_selected_governorate_id';
  static const String _lastCityKey = 'location_cache.last_selected_city_id';

  static const Duration _ttl = Duration(days: 7);

  late final GetStorage _box;
  bool _initialized = false;
  Completer<void>? _initCompleter;

  static final LocationCacheService _instance = LocationCacheService._();
  factory LocationCacheService() => _instance;
  LocationCacheService._();

  Future<void> init() async {
    if (_initialized) return;
    if (_initCompleter != null) {
      return _initCompleter!.future;
    }
    _initCompleter = Completer<void>();
    await GetStorage.init('location_cache');
    _box = GetStorage('location_cache');
    _initialized = true;
    _initCompleter!.complete();
  }

  bool _isFresh(int? cachedAtMillis) {
    if (cachedAtMillis == null) return false;
    final cachedAt = DateTime.fromMillisecondsSinceEpoch(cachedAtMillis);
    return DateTime.now().difference(cachedAt) < _ttl;
  }

  List<GovernorateModel>? getCachedGovernorates() {
    if (!_initialized) return null;
    final cachedAt = _box.read<int>(_govCachedAtKey);
    if (!_isFresh(cachedAt)) return null;
    final raw = _box.read<List>(_govKey);
    if (raw == null) return null;
    return raw
        .whereType<Map>()
        .map((e) => GovernorateModel.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  Future<void> cacheGovernorates(List<GovernorateModel> list) async {
    assert(_initialized, 'LocationCacheService.init() must be awaited before writing to the cache');
    if (!_initialized) return;
    await _box.write(_govKey, list.map((g) => g.toJson()).toList());
    await _box.write(_govCachedAtKey, DateTime.now().millisecondsSinceEpoch);
  }

  List<CityModel>? getCachedCitiesFor(int governorateId) {
    if (!_initialized) return null;
    final cachedAt = _box.read<int>(_citiesCachedAtKey(governorateId));
    if (!_isFresh(cachedAt)) return null;
    final raw = _box.read<List>(_citiesKey(governorateId));
    if (raw == null) return null;
    return raw
        .whereType<Map>()
        .map((e) => CityModel.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  Future<void> cacheCitiesFor(int governorateId, List<CityModel> list) async {
    assert(_initialized, 'LocationCacheService.init() must be awaited before writing to the cache');
    if (!_initialized) return;
    await _box.write(
        _citiesKey(governorateId), list.map((c) => c.toJson()).toList());
    await _box.write(
        _citiesCachedAtKey(governorateId), DateTime.now().millisecondsSinceEpoch);
  }

  int? getLastSelectedGovernorateId() {
    if (!_initialized) return null;
    return _box.read<int>(_lastGovKey);
  }

  int? getLastSelectedCityId() {
    if (!_initialized) return null;
    return _box.read<int>(_lastCityKey);
  }

  Future<void> saveLastSelection({int? governorateId, int? cityId}) async {
    assert(_initialized, 'LocationCacheService.init() must be awaited before writing to the cache');
    if (!_initialized) return;
    if (governorateId == null) {
      await _box.remove(_lastGovKey);
    } else {
      await _box.write(_lastGovKey, governorateId);
    }
    if (cityId == null) {
      await _box.remove(_lastCityKey);
    } else {
      await _box.write(_lastCityKey, cityId);
    }
  }

  Future<void> clearLastSelection() async {
    assert(_initialized, 'LocationCacheService.init() must be awaited before writing to the cache');
    if (!_initialized) return;
    await _box.remove(_lastGovKey);
    await _box.remove(_lastCityKey);
  }
}
