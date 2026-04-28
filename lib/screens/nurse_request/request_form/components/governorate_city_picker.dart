import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kivicare_patient/main.dart';
import 'package:kivicare_patient/network/network_utils.dart';
import 'package:kivicare_patient/utils/api_end_points.dart';
import 'package:nb_utils/nb_utils.dart';

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
      setState(() {
        _governorates = list;
      });
    } catch (_) {
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
          '${APIEndPoints.cities}?governorate_id=$govId',
          method: HttpMethodType.GET,
        ),
      );
      final list = (data['data'] as List<dynamic>? ?? [])
          .map((e) => _CityModel.fromJson(e as Map<String, dynamic>))
          .toList();
      setState(() {
        _cities = list;
        _cityLoading = false;
      });
    } catch (_) {
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
            decoration: InputDecoration(
              labelText: locale.value.governorate,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
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
          Text(locale.value.governorate, style: primaryTextStyle(color: Colors.grey)),
        12.height,
        if (_showFreeTextCity)
          TextFormField(
            controller: _freeCityController,
            maxLength: 100,
            decoration: InputDecoration(
              labelText: locale.value.city,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              counterText: '',
            ),
            onChanged: (val) {
              widget.cityText.value = val.trim();
              widget.cityId.value = null;
            },
          )
        else
          DropdownButtonFormField<int>(
            initialValue: widget.cityId.value,
            decoration: InputDecoration(
              labelText: _cityLoading
                  ? '${locale.value.city}...'
                  : locale.value.city,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
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
