import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../api/location_apis.dart';
import '../../main.dart';
import '../../network/network_utils.dart';
import '../../utils/app_common.dart';
import 'models/governorate_model.dart';
import 'service/location_cache_service.dart';
import 'utils/location_text_utils.dart';

class GovernorateSelectionController extends GetxController {
  final int? initiallySelectedId;

  GovernorateSelectionController({this.initiallySelectedId});

  final RxList<GovernorateModel> governorates = <GovernorateModel>[].obs;
  final RxList<GovernorateModel> filteredGovernorates =
      <GovernorateModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;
  final RxString searchQuery = ''.obs;
  final Rxn<int> currentSelectedId = Rxn<int>();

  final TextEditingController searchTextController = TextEditingController();

  Timer? _searchDebounce;
  final LocationCacheService _cache = LocationCacheService();

  @override
  void onInit() {
    // LocationCacheService.init() must be awaited in main.dart before this controller is used.
    super.onInit();
    if (initiallySelectedId != null) {
      currentSelectedId.value = initiallySelectedId;
    } else {
      currentSelectedId.value = _cache.getLastSelectedGovernorateId();
    }
    loadGovernorates();
  }

  @override
  void onClose() {
    _searchDebounce?.cancel();
    searchTextController.dispose();
    super.onClose();
  }

  Future<void> loadGovernorates({bool forceNetwork = false}) async {
    error.value = '';
    final cached = _cache.getCachedGovernorates();
    if (!forceNetwork && cached != null && cached.isNotEmpty) {
      governorates.assignAll(cached);
      _applyFilter();
      _refreshFromNetworkSilently();
      return;
    }
    isLoading.value = true;
    try {
      final list = await LocationApis.getGovernorates();
      governorates.assignAll(list);
      _applyFilter();
      await _cache.cacheGovernorates(list);
    } catch (e) {
      error.value = sanitizeBackendMessage(e, locale.value.somethingWentWrong);
      log('GovernorateSelectionController.loadGovernorates: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _refreshFromNetworkSilently() async {
    try {
      final list = await LocationApis.getGovernorates();
      governorates.assignAll(list);
      _applyFilter();
      await _cache.cacheGovernorates(list);
    } catch (e) {
      log('GovernorateSelectionController.refreshSilently: $e');
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
      filteredGovernorates.assignAll(governorates);
      return;
    }
    final lang = selectedLanguageCode.value;
    filteredGovernorates.assignAll(
      governorates.where((g) {
        final display = normalizeLocationSearch(g.displayName(lang));
        final en = normalizeLocationSearch(g.nameEn ?? '');
        final ar = normalizeLocationSearch(g.nameAr ?? '');
        return display.contains(q) || en.contains(q) || ar.contains(q);
      }),
    );
  }
}
