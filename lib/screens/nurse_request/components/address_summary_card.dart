import 'package:flutter/material.dart';
import 'package:kivicare_patient/main.dart';
import 'package:nb_utils/nb_utils.dart';

import '../models/nurse_request_model.dart';
import 'nurse_request_design.dart';

class AddressSummaryCard extends StatelessWidget {
  final NurseRequestModel request;

  const AddressSummaryCard({super.key, required this.request});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: nurseRequestCardDecoration(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Row(locale.value.addressLine1, request.addressLine1),
          if (request.addressLine2 != null && request.addressLine2!.isNotEmpty)
            _Row(locale.value.addressLine2, request.addressLine2!),
          _Row(locale.value.city, request.city),
          if (request.state != null && request.state!.isNotEmpty)
            _Row(locale.value.stateLabel, request.state!),
          if (request.country != null && request.country!.isNotEmpty)
            _Row(locale.value.countryLabel, request.country!),
          if (request.postalCode != null && request.postalCode!.isNotEmpty)
            _Row(locale.value.postalCode, request.postalCode!),
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  final String label;
  final String value;

  const _Row(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              '$label:',
              style: secondaryTextStyle(
                size: 13,
                color: nurseRequestMutedColor(context),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: primaryTextStyle(size: 13),
              textAlign: TextAlign.start,
            ),
          ),
        ],
      ),
    );
  }
}
