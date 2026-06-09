import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:kivicare_patient/screens/labs_radiology/labs_radiology_common.dart';
import '../../models/facility_model.dart';

class FacilityInfo extends StatelessWidget {
  final FacilityModel facility;

  const FacilityInfo({super.key, required this.facility});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(locale.value.about, style: boldTextStyle()),
          16.height,
          _buildInfoRow(Icons.location_on_outlined,
              locale.value.facilityAddress, facility.address),
          if (facility.phone.validate().isNotEmpty) ...[
            12.height,
            _buildInfoRow(Icons.phone_outlined, locale.value.contactNumber,
                facility.phone!),
          ],
          if (facility.email.validate().isNotEmpty) ...[
            12.height,
            _buildInfoRow(Icons.email_outlined, 'Email', facility.email!),
          ],
          16.height,
          AppButton(
            width: double.infinity,
            text: locale.value.contactFacility,
            color: context.primaryColor,
            textStyle: boldTextStyle(color: Colors.white),
            onTap: () {
              if (facility.phone.validate().isNotEmpty) {
                launchCall(facility.phone!);
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: secondaryTextColor),
        12.width,
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: secondaryTextStyle(size: 12)),
            4.height,
            Text(value, style: primaryTextStyle(size: 14)),
          ],
        ).expand(),
      ],
    );
  }
}
