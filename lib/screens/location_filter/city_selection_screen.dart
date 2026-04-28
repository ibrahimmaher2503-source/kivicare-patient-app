import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../components/app_scaffold.dart';
import '../../main.dart';
import '../../utils/colors.dart';
import 'city_selection_controller.dart';
import 'components/all_locations_tile.dart';
import 'components/city_list_tile.dart';
import 'components/empty_cities_widget.dart';
import 'components/location_search_bar.dart';
import 'components/location_shimmer.dart';
import 'components/selected_governorate_header.dart';
import 'models/city_model.dart';
import 'models/governorate_model.dart';
import 'models/location_filter_result.dart';

class CitySelectionScreen extends StatelessWidget {
  final GovernorateModel governorate;
  final int? initiallySelectedCityId;

  CitySelectionScreen({
    super.key,
    required this.governorate,
    this.initiallySelectedCityId,
  });

  late final CitySelectionController c = Get.put(
    CitySelectionController(
      governorate: governorate,
      initiallySelectedCityId: initiallySelectedCityId,
    ),
    tag: 'city-selection-${governorate.id}',
  );

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBartitleText: locale.value.selectCity,
      automaticallyImplyLeading: true,
      hasLeadingWidget: true,
      actions: [
        TextButton(
          onPressed: () => Get.back(),
          child: Text(
            locale.value.change,
            style: boldTextStyle(size: 14, color: appColorSecondary),
          ),
        ),
      ],
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SelectedGovernorateHeader(governorate: governorate),
          LocationSearchBar(
            hintText: locale.value.searchCity,
            controller: c.searchTextController,
            onChanged: c.onSearchChanged,
          ),
          Expanded(
            child: Obx(() {
              if (c.isLoading.value && c.cities.isEmpty) {
                return const LocationShimmer();
              }
              if (c.error.value.isNotEmpty && c.cities.isEmpty) {
                return _ErrorView(
                  message: c.error.value,
                  onRetry: () => c.loadCities(forceNetwork: true),
                );
              }
              if (c.cities.isEmpty) {
                return EmptyCitiesWidget(
                  onApplyGovernorateOnly: () => Get.back(
                    result: LocationFilterResult(
                      governorateId: governorate.id,
                      governorate: governorate,
                    ),
                  ),
                  onChangeGovernorate: () => Get.back(),
                );
              }
              return RefreshIndicator(
                onRefresh: () => c.loadCities(forceNetwork: true),
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                  children: [
                    AllLocationsTile(
                      icon: Icons.location_city,
                      title: locale.value.allCities,
                      subtitle: locale.value.showAllCitiesInGovernorate,
                      onTap: () => Get.back(
                        result: LocationFilterResult(
                          governorateId: governorate.id,
                          governorate: governorate,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (c.filteredCities.isEmpty)
                      _EmptySearchView(
                        query: c.searchQuery.value,
                        onClear: () {
                          c.searchTextController.clear();
                          c.onSearchChanged('');
                        },
                      )
                    else
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: c.filteredCities.length,
                        itemBuilder: (_, i) {
                          final city = c.filteredCities[i];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: CityListTile(
                              city: city,
                              selected: c.currentSelectedCityId.value == city.id,
                              onTap: () => _onCityTap(city),
                            ),
                          );
                        },
                      ),
                  ],
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  void _onCityTap(CityModel city) {
    Get.back(
      result: LocationFilterResult(
        governorateId: governorate.id,
        cityId: city.id,
        governorate: governorate,
        city: city,
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.cloud_off, color: appBodyColor, size: 48),
            const SizedBox(height: 12),
            Text(
              locale.value.failedToLoadCities,
              style: boldTextStyle(size: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Text(
              message,
              style: secondaryTextStyle(size: 13),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: appColorSecondary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(locale.value.retry),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptySearchView extends StatelessWidget {
  final String query;
  final VoidCallback onClear;
  const _EmptySearchView({required this.query, required this.onClear});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
      child: Column(
        children: [
          Icon(Icons.search_off, color: appBodyColor, size: 48),
          const SizedBox(height: 12),
          Text(locale.value.noCitiesFound, style: boldTextStyle(size: 16)),
          const SizedBox(height: 4),
          Text(
            locale.value.noResultsFor.replaceAll('{query}', query),
            style: secondaryTextStyle(size: 13),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          TextButton(onPressed: onClear, child: Text(locale.value.clearSearch)),
        ],
      ),
    );
  }
}
