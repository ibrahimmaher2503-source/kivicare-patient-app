import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../api/location_apis.dart';
import '../../utils/app_common.dart';
import 'models/city_model.dart';
import 'models/governorate_model.dart';
import 'service/location_cache_service.dart';
import 'utils/location_text_utils.dart';

class CitySelectionController extends GetxController {
  final GovernorateModel governorate;
  final int? initiallySelectedCityId;

  CitySelectionController({
    required this.governorate,
    this.initiallySelectedCityId,
  });

  final RxList<CityModel> cities = <CityModel>[].obs;
  final RxList<CityModel> filteredCities = <CityModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;
  final RxString searchQuery = ''.obs;
  final Rxn<int> currentSelectedCityId = Rxn<int>();

  final TextEditingController searchTextController = TextEditingController();

  Timer? _searchDebounce;
  final LocationCacheService _cache = LocationCacheService();

  @override
  void onInit() {
    // LocationCacheService.init() must be awaited in main.dart before this controller is used.
    super.onInit();
    if (initiallySelectedCityId != null) {
      currentSelectedCityId.value = initiallySelectedCityId;
    } else {
      final lastGov = _cache.getLastSelectedGovernorateId();
      if (lastGov == governorate.id) {
        currentSelectedCityId.value = _cache.getLastSelectedCityId();
      }
    }
    loadCities();
  }

  @override
  void onClose() {
    _searchDebounce?.cancel();
    searchTextController.dispose();
    super.onClose();
  }

  Future<void> loadCities({bool forceNetwork = false}) async {
    error.value = '';
    final cached = _cache.getCachedCitiesFor(governorate.id);
    if (!forceNetwork && cached != null && cached.isNotEmpty) {
      cities.assignAll(cached);
      _applyFilter();
      _refreshFromNetworkSilently();
      return;
    }
    isLoading.value = true;
    try {
      final list = await LocationApis.getCitiesByGovernorate(governorate.id);
      cities.assignAll(list);
      _applyFilter();
      await _cache.cacheCitiesFor(governorate.id, list);
    } catch (e) {
      error.value = e.toString();
      log('CitySelectionController.loadCities: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _refreshFromNetworkSilently() async {
    try {
      final list = await LocationApis.getCitiesByGovernorate(governorate.id);
      cities.assignAll(list);
      _applyFilter();
      await _cache.cacheCitiesFor(governorate.id, list);
    } catch (e) {
      log('CitySelectionController.refreshSilently: $e');
    }
  }

  void onSearchChanged(String query) {
    searchQuery.value = query;
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 200), _applyFilter);
  }

  void _applyFilter() {
    final q = normalizeLocationSearch(searchQuery.value);
    if (q.isEmpty) {
      filteredCities.assignAll(cities);
      return;
    }
    final lang = selectedLanguageCode.value;
    filteredCities.assignAll(
      cities.where((c) {
        final display = normalizeLocationSearch(c.displayName(lang));
        final en = normalizeLocationSearch(c.nameEn ?? '');
        final ar = normalizeLocationSearch(c.nameAr ?? '');
        return display.contains(q) || en.contains(q) || ar.contains(q);
      }),
    );
  }
}
