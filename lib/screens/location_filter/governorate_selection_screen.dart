import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../components/app_scaffold.dart';
import '../../main.dart';
import '../../utils/colors.dart';
import 'components/all_locations_tile.dart';
import 'components/governorate_list_tile.dart';
import 'components/location_search_bar.dart';
import 'components/location_shimmer.dart';
import 'governorate_selection_controller.dart';
import 'city_selection_screen.dart';
import 'models/governorate_model.dart';
import 'models/location_filter_result.dart';

class GovernorateSelectionScreen extends StatelessWidget {
  final int? initiallySelectedId;
  final int? initiallySelectedCityId;

  GovernorateSelectionScreen({
    super.key,
    this.initiallySelectedId,
    this.initiallySelectedCityId,
  });

  late final GovernorateSelectionController c = Get.put(
    GovernorateSelectionController(initiallySelectedId: initiallySelectedId),
    tag: 'governorate-selection',
  );

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBartitleText: locale.value.selectGovernorate,
      automaticallyImplyLeading: true,
      hasLeadingWidget: true,
      actions: [
        Obx(() {
          if (c.currentSelectedId.value == null) return const SizedBox.shrink();
          return TextButton(
            onPressed: () =>
                Get.back(result: const LocationFilterResult.cleared()),
            child: Text(
              locale.value.clear,
              style: boldTextStyle(size: 14, color: appColorSecondary),
            ),
          );
        }),
      ],
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          LocationSearchBar(
            hintText: locale.value.searchGovernorate,
            controller: c.searchTextController,
            onChanged: c.onSearchChanged,
          ),
          Expanded(
            child: Obx(() {
              if (c.isLoading.value && c.governorates.isEmpty) {
                return const LocationShimmer();
              }
              if (c.error.value.isNotEmpty && c.governorates.isEmpty) {
                return _ErrorView(
                  message: c.error.value,
                  onRetry: () => c.loadGovernorates(forceNetwork: true),
                );
              }
              return RefreshIndicator(
                onRefresh: () => c.loadGovernorates(forceNetwork: true),
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                  children: [
                    AllLocationsTile(
                      icon: Icons.public,
                      title: locale.value.allGovernorates,
                      subtitle: locale.value.showDoctorsFromAllGovernorates,
                      onTap: () =>
                          Get.back(result: const LocationFilterResult.cleared()),
                    ),
                    const SizedBox(height: 16),
                    if (c.filteredGovernorates.isEmpty)
                      _EmptySearchView(query: c.searchQuery.value, onClear: () {
                        c.searchTextController.clear();
                        c.onSearchChanged('');
                      })
                    else
                      SizedBox(
                        child: ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: c.filteredGovernorates.length,
                          itemBuilder: (_, i) {
                            final g = c.filteredGovernorates[i];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: GovernorateListTile(
                                governorate: g,
                                selected: c.currentSelectedId.value == g.id,
                                onTap: () => _onGovernorateTap(g),
                              ),
                            );
                          },
                        ),
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

  Future<void> _onGovernorateTap(GovernorateModel g) async {
    final result = await Get.to<LocationFilterResult>(
      () => CitySelectionScreen(
        governorate: g,
        initiallySelectedCityId:
            c.currentSelectedId.value == g.id ? initiallySelectedCityId : null,
      ),
    );
    if (result == null) return;
    Get.back(result: result);
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
              locale.value.failedToLoadGovernorates,
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
          Text(
            locale.value.noGovernoratesFound,
            style: boldTextStyle(size: 16),
          ),
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
