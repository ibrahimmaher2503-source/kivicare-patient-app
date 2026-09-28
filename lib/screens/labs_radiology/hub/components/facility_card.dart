import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:kivicare_patient/main.dart';
import 'package:kivicare_patient/utils/app_common.dart';
import 'package:kivicare_patient/utils/colors.dart';
import 'package:kivicare_patient/components/cached_image_widget.dart';
import '../../models/facility_model.dart';
import '../../shared/components/facility_type_badge.dart';
import '../../shared/components/facility_rating_badge.dart';
import '../../shared/components/distance_badge.dart';

class FacilityCard extends StatelessWidget {
  final FacilityModel facility;
  final VoidCallback onTap;

  const FacilityCard({super.key, required this.facility, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final dark = isDarkMode.value;
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          color: dark ? surfaceElevatedDark : surfaceElevated,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: dark ? softShadowColorDark : softShadowColor,
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CachedImageWidget(
              url: facility.logo.validate(),
              height: 76,
              width: 76,
              fit: BoxFit.cover,
              radius: 14,
            ),
            14.width,
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    FacilityTypeBadge(type: facility.type),
                    FacilityRatingBadge(rating: facility.rating ?? 0.0),
                  ],
                ),
                8.height,
                Text(facility.name,
                    style: boldTextStyle(size: 15),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis),
                4.height,
                Row(
                  children: [
                    const Icon(Icons.location_on_outlined,
                        size: 14, color: secondaryTextColor),
                    4.width,
                    Text(facility.address,
                            style: secondaryTextStyle(),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis)
                        .expand(),
                  ],
                ),
                12.height,
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    DistanceBadge(distanceKm: facility.distanceKm),
                    if (facility.priceFrom != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: appColorSecondary.withValues(alpha: 0.10),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          '${locale.value.startingFrom} ${facility.priceFrom!.toStringAsFixed(0)} EGP',
                          style: primaryTextStyle(
                              size: 12,
                              color: appColorSecondary,
                              weight: FontWeight.bold),
                        ),
                      ),
                  ],
                ),
              ],
            ).expand(),
          ],
        ),
      ).onTap(onTap, borderRadius: radius(16));
    });
  }
}
