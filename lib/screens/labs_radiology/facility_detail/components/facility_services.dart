import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:kivicare_patient/screens/labs_radiology/labs_radiology_common.dart';

class FacilityServices extends StatelessWidget {
  final List<String> services;

  const FacilityServices({super.key, required this.services});

  @override
  Widget build(BuildContext context) {
    if (services.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(locale.value.servicesOffered, style: boldTextStyle()),
        ),
        12.height,
        HorizontalList(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: services.length,
          itemBuilder: (context, index) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: boxDecorationWithRoundedCorners(
                backgroundColor: context.dividerColor.withValues(alpha: 0.1),
                borderRadius: radius(20),
              ),
              child: Text(services[index], style: secondaryTextStyle(size: 12)),
            );
          },
        ),
      ],
    );
  }
}
