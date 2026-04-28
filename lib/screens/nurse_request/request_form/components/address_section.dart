import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kivicare_patient/main.dart';
import 'package:nb_utils/nb_utils.dart';

import 'governorate_city_picker.dart';

class AddressSection extends StatefulWidget {
  final TextEditingController addressLine1Controller;
  final TextEditingController addressLine2Controller;
  final TextEditingController stateController;
  final TextEditingController countryController;
  final TextEditingController postalCodeController;
  final Rxn<int> governorateId;
  final Rxn<int> cityId;
  final RxString cityText;

  const AddressSection({
    super.key,
    required this.addressLine1Controller,
    required this.addressLine2Controller,
    required this.stateController,
    required this.countryController,
    required this.postalCodeController,
    required this.governorateId,
    required this.cityId,
    required this.cityText,
  });

  @override
  State<AddressSection> createState() => _AddressSectionState();
}

class _AddressSectionState extends State<AddressSection> {
  bool _showMore = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: widget.addressLine1Controller,
          maxLength: 255,
          decoration: InputDecoration(
            labelText: '${locale.value.addressLine1} *',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            counterText: '',
          ),
        ),
        12.height,
        TextFormField(
          controller: widget.addressLine2Controller,
          maxLength: 255,
          decoration: InputDecoration(
            labelText: locale.value.addressLine2,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            counterText: '',
          ),
        ),
        12.height,
        GovernorateCityPicker(
          governorateId: widget.governorateId,
          cityId: widget.cityId,
          cityText: widget.cityText,
        ),
        4.height,
        TextButton.icon(
          onPressed: () => setState(() => _showMore = !_showMore),
          icon: Icon(
            _showMore ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
            size: 18,
          ),
          label: Text(locale.value.moreAddressDetails),
        ),
        if (_showMore) ...[
          TextFormField(
            controller: widget.stateController,
            maxLength: 100,
            decoration: InputDecoration(
              labelText: locale.value.stateLabel,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              counterText: '',
            ),
          ),
          12.height,
          TextFormField(
            controller: widget.countryController,
            maxLength: 100,
            decoration: InputDecoration(
              labelText: locale.value.countryLabel,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              counterText: '',
            ),
          ),
          12.height,
          TextFormField(
            controller: widget.postalCodeController,
            maxLength: 20,
            decoration: InputDecoration(
              labelText: locale.value.postalCode,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              counterText: '',
            ),
          ),
        ],
      ],
    );
  }
}
