import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kivicare_patient/main.dart';
import 'package:kivicare_patient/network/network_utils.dart';
import 'package:kivicare_patient/utils/api_end_points.dart';
import 'package:kivicare_patient/utils/colors.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../components/nurse_request_design.dart';

class _GovModel {
  final int id;
  final String name;
  _GovModel({required this.id, required this.name});
  factory _GovModel.fromJson(Map<String, dynamic> j) =>
      _GovModel(id: j['id'] ?? 0, name: j['name'] ?? '');
}

class _CityModel {
  final int id;
  final String name;
  _CityModel({required this.id, required this.name});
  factory _CityModel.fromJson(Map<String, dynamic> j) =>
      _CityModel(id: j['id'] ?? 0, name: j['name'] ?? '');
}

class GovernorateCityPicker extends StatefulWidget {
  final Rxn<int> governorateId;
  final Rxn<int> cityId;
  final RxString cityText;

  const GovernorateCityPicker({
    super.key,
    required this.governorateId,
    required this.cityId,
    required this.cityText,
  });

  @override
  State<GovernorateCityPicker> createState() => _GovernorateCityPickerState();
}

class _GovernorateCityPickerState extends State<GovernorateCityPicker> {
  List<_GovModel> _governorates = [];
  List<_CityModel> _cities = [];
  bool _cityLoading = false;
  bool _govFailed = false;
  bool _cityFailed = false;
  final _freeCityController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadGovernorates();
  }

  Future<void> _loadGovernorates() async {
    setState(() {
      _govFailed = false;
    });
    try {
      final data = await handleResponse(
        await buildHttpResponse(
          APIEndPoints.governorates,
          method: HttpMethodType.GET,
        ),
      );
      final list = (data['data'] as List<dynamic>? ?? [])
          .map((e) => _GovModel.fromJson(e as Map<String, dynamic>))
          .toList();
      if (!mounted) return;
      setState(() {
        _governorates = list;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _govFailed = true;
      });
    }
  }

  Future<void> _loadCities(int govId) async {
    setState(() {
      _cityLoading = true;
      _cityFailed = false;
      _cities = [];
    });
    try {
      final data = await handleResponse(
        await buildHttpResponse(
          endpointWithQuery(
            APIEndPoints.cities,
            {'governorate_id': govId},
          ),
          method: HttpMethodType.GET,
        ),
      );
      final list = (data['data'] as List<dynamic>? ?? [])
          .map((e) => _CityModel.fromJson(e as Map<String, dynamic>))
          .toList();
      if (!mounted) return;
      setState(() {
        _cities = list;
        _cityLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _cityFailed = true;
        _cityLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _freeCityController.dispose();
    super.dispose();
  }

  bool get _showFreeTextCity =>
      _govFailed || _governorates.isEmpty || _cities.isEmpty || _cityFailed;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!_govFailed && _governorates.isNotEmpty)
          DropdownButtonFormField<int>(
            initialValue: widget.governorateId.value,
            decoration: nurseRequestInputDecoration(
              context,
              labelText: locale.value.governorate,
            ),
            items: _governorates
                .map((g) => DropdownMenuItem(value: g.id, child: Text(g.name)))
                .toList(),
            onChanged: (val) {
              widget.governorateId.value = val;
              widget.cityId.value = null;
              widget.cityText.value = '';
              _freeCityController.clear();
              if (val != null) _loadCities(val);
            },
          )
        else
          _DisabledSelector(label: locale.value.governorate),
        12.height,
        if (_showFreeTextCity)
          TextFormField(
            controller: _freeCityController,
            maxLength: 100,
            decoration: nurseRequestInputDecoration(
              context,
              labelText: locale.value.city,
            ),
            onChanged: (val) {
              widget.cityText.value = val.trim();
              widget.cityId.value = null;
            },
          )
        else
          DropdownButtonFormField<int>(
            initialValue: widget.cityId.value,
            decoration: nurseRequestInputDecoration(
              context,
              labelText:
                  _cityLoading ? '${locale.value.city}...' : locale.value.city,
            ),
            items: _cities
                .map((c) => DropdownMenuItem(value: c.id, child: Text(c.name)))
                .toList(),
            onChanged: (val) {
              widget.cityId.value = val;
              final city = _cities.firstWhere(
                (c) => c.id == val,
                orElse: () => _CityModel(id: 0, name: ''),
              );
              widget.cityText.value = city.name;
            },
          ),
      ],
    );
  }
}

class _DisabledSelector extends StatelessWidget {
  final String label;

  const _DisabledSelector({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 52),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: nurseRequestSubtleSurface(context),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: nurseRequestBorderColor(context)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.location_city_outlined,
            color: gradientSecondaryStart,
            size: 20,
          ),
          12.width,
          Expanded(
            child: Text(
              label,
              style: primaryTextStyle(color: nurseRequestMutedColor(context)),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
