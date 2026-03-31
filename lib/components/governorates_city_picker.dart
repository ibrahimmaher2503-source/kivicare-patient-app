import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';

import '../api/core_apis.dart';
import '../main.dart';
import '../models/governorate_model.dart';
import '../models/city_model.dart';
import '../utils/app_common.dart';
import '../utils/colors.dart';

// Session-level cache — filled once per app launch
final RxList<Governorate> _cachedGovernorates = RxList<Governorate>();
final Map<int, List<City>> _citiesCache = {};

class GovernoratesCityPicker extends StatefulWidget {
  final int? selectedGovernorateId;
  final int? selectedCityId;
  final void Function(int? governorateId) onGovernorateChanged;
  final void Function(int? cityId) onCityChanged;
  final EdgeInsetsGeometry? padding;

  const GovernoratesCityPicker({
    super.key,
    this.selectedGovernorateId,
    this.selectedCityId,
    required this.onGovernorateChanged,
    required this.onCityChanged,
    this.padding,
  });

  @override
  State<GovernoratesCityPicker> createState() => _GovernoratesCityPickerState();
}

class _GovernoratesCityPickerState extends State<GovernoratesCityPicker> {
  bool _isLoadingGovernorates = false;
  bool _isLoadingCities = false;
  List<City> _cities = [];

  @override
  void initState() {
    super.initState();
    _loadGovernorates();
    if (widget.selectedGovernorateId != null) {
      _loadCities(widget.selectedGovernorateId!);
    }
  }

  Future<void> _loadGovernorates() async {
    if (_cachedGovernorates.isNotEmpty) return;
    setState(() => _isLoadingGovernorates = true);
    try {
      final list = await CoreServiceApis.getGovernorates();
      _cachedGovernorates.assignAll(list);
    } catch (e) {
      log('GovernoratesCityPicker: error loading governorates: $e');
    } finally {
      if (mounted) setState(() => _isLoadingGovernorates = false);
    }
  }

  Future<void> _loadCities(int governorateId) async {
    if (_citiesCache.containsKey(governorateId)) {
      if (mounted) setState(() => _cities = _citiesCache[governorateId]!);
      return;
    }
    setState(() => _isLoadingCities = true);
    try {
      final list = await CoreServiceApis.getCities(governorateId: governorateId);
      _citiesCache[governorateId] = list;
      if (mounted) setState(() => _cities = list);
    } catch (e) {
      log('GovernoratesCityPicker: error loading cities: $e');
    } finally {
      if (mounted) setState(() => _isLoadingCities = false);
    }
  }

  void _onGovernorateChanged(int? id) {
    setState(() => _cities = []);
    widget.onGovernorateChanged(id);
    if (id != null) _loadCities(id);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: widget.padding ?? EdgeInsets.zero,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDarkMode.value ? inputFillColorDark : inputFillColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDarkMode.value ? glassStrokeDark : glassStrokeLight,
          ),
        ),
        child: Obx(() => Row(
          children: [
            Expanded(child: _buildGovernorateDropdown()),
            const SizedBox(width: 12),
            Expanded(child: _buildCityDropdown()),
          ],
        )),
      ),
    );
  }

  Widget _buildGovernorateDropdown() {
    if (_isLoadingGovernorates) {
      return const SizedBox(height: 40, child: Center(child: LinearProgressIndicator()));
    }
    final items = <DropdownMenuItem<int?>>[
      DropdownMenuItem<int?>(
        value: null,
        child: Text(locale.value.allGovernorates, style: secondaryTextStyle(size: 13)),
      ),
      ..._cachedGovernorates.map((g) => DropdownMenuItem<int?>(
        value: g.id,
        child: Text(g.name, style: primaryTextStyle(size: 13)),
      )),
    ];
    return DropdownButtonFormField<int?>(
      value: widget.selectedGovernorateId,
      items: items,
      onChanged: _onGovernorateChanged,
      decoration: InputDecoration(
        labelText: locale.value.governorate,
        labelStyle: secondaryTextStyle(size: 12),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        isDense: true,
      ),
      isExpanded: true,
    );
  }

  Widget _buildCityDropdown() {
    if (_isLoadingCities) {
      return const SizedBox(height: 40, child: Center(child: LinearProgressIndicator()));
    }
    final isEnabled = widget.selectedGovernorateId != null && _cities.isNotEmpty;
    final items = <DropdownMenuItem<int?>>[
      DropdownMenuItem<int?>(
        value: null,
        child: Text(locale.value.allCities, style: secondaryTextStyle(size: 13)),
      ),
      ..._cities.map((c) => DropdownMenuItem<int?>(
        value: c.id,
        child: Text(c.name, style: primaryTextStyle(size: 13)),
      )),
    ];
    return DropdownButtonFormField<int?>(
      value: widget.selectedCityId,
      items: isEnabled ? items : null,
      onChanged: isEnabled ? widget.onCityChanged : null,
      decoration: InputDecoration(
        labelText: locale.value.city,
        labelStyle: secondaryTextStyle(size: 12),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        isDense: true,
      ),
      isExpanded: true,
      disabledHint: Text(locale.value.selectGovernorate, style: secondaryTextStyle(size: 12)),
    );
  }
}
