import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kivicare_patient/main.dart';
import 'package:kivicare_patient/utils/colors.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../components/nurse_request_design.dart';
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
          decoration: nurseRequestInputDecoration(
            context,
            labelText: '${locale.value.addressLine1} *',
          ),
        ),
        12.height,
        TextFormField(
          controller: widget.addressLine2Controller,
          maxLength: 255,
          decoration: nurseRequestInputDecoration(
            context,
            labelText: locale.value.addressLine2,
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
          style: TextButton.styleFrom(
            foregroundColor: gradientStart,
            minimumSize: const Size(44, 44),
            padding: const EdgeInsets.symmetric(horizontal: 8),
          ),
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
            decoration: nurseRequestInputDecoration(
              context,
              labelText: locale.value.stateLabel,
            ),
          ),
          12.height,
          TextFormField(
            controller: widget.countryController,
            maxLength: 100,
            decoration: nurseRequestInputDecoration(
              context,
              labelText: locale.value.countryLabel,
            ),
          ),
          12.height,
          TextFormField(
            controller: widget.postalCodeController,
            maxLength: 20,
            decoration: nurseRequestInputDecoration(
              context,
              labelText: locale.value.postalCode,
            ),
          ),
        ],
      ],
    );
  }
}
