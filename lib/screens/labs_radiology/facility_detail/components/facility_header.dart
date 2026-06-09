import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:kivicare_patient/components/cached_image_widget.dart';
import '../../models/facility_model.dart';
import '../../shared/components/facility_type_badge.dart';
import '../../shared/components/facility_rating_badge.dart';

class FacilityHeader extends StatelessWidget {
  final FacilityModel facility;

  const FacilityHeader({super.key, required this.facility});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            CachedImageWidget(
              url: facility.coverImage.validate(),
              height: 200,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
            Positioned(
              bottom: -40,
              left: 16,
              child: Container(
                decoration: boxDecorationDefault(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 4),
                ),
                child: CachedImageWidget(
                  url: facility.logo.validate(),
                  height: 80,
                  width: 80,
                  fit: BoxFit.cover,
                  radius: 40,
                ),
              ),
            ),
          ],
        ),
        50.height,
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
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
              Text(facility.name, style: boldTextStyle(size: 20)),
              if (facility.description.validate().isNotEmpty) ...[
                8.height,
                Text(facility.description!, style: secondaryTextStyle()),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
