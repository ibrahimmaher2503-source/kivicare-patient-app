import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:kivicare_patient/screens/labs_radiology/labs_radiology_common.dart';

class FacilityLocationMap extends StatelessWidget {
  final double latitude;
  final double longitude;
  final String facilityName;

  const FacilityLocationMap({
    super.key,
    required this.latitude,
    required this.longitude,
    required this.facilityName,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(locale.value.location, style: boldTextStyle()),
              TextButton(
                onPressed: () => openMap(latitude, longitude),
                child: Text(locale.value.openInMaps,
                    style: secondaryTextStyle(color: context.primaryColor)),
              ),
            ],
          ),
          8.height,
          Container(
            height: 150,
            width: double.infinity,
            decoration: boxDecorationDefault(
              color: context.dividerColor.withValues(alpha: 0.1),
              borderRadius: radius(12),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                const Icon(Icons.map_outlined,
                    size: 50, color: secondaryTextColor),
                Text(
                  facilityName,
                  style: secondaryTextStyle(size: 12),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ).paddingTop(80),
              ],
            ),
          ).onTap(() => openMap(latitude, longitude)),
        ],
      ),
    );
  }
}
