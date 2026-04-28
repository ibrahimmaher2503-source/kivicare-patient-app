import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../components/cached_image_widget.dart';
import '../../../utils/colors.dart';
import '../models/visit_doctor_model.dart';

class DoctorInfoCard extends StatelessWidget {
  final VisitDoctorModel doctor;
  final String? subtitle;

  const DoctorInfoCard({super.key, required this.doctor, this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: softShadowColor,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(28),
            child: CachedImageWidget(
              url: doctor.avatar ?? '',
              height: 56,
              width: 56,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(doctor.name, style: boldTextStyle(size: 14)),
                if (doctor.specialty != null && doctor.specialty!.isNotEmpty)
                  Text(doctor.specialty!, style: secondaryTextStyle(size: 12)),
                if (subtitle != null)
                  Text(
                    subtitle!,
                    style: TextStyle(
                      fontSize: 11,
                      color: gradientSecondaryStart,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
              ],
            ),
          ),
          if (doctor.rating != null)
            Row(
              children: [
                const Icon(Icons.star_rounded, color: Colors.amber, size: 16),
                const SizedBox(width: 4),
                Text(
                  doctor.rating!.toStringAsFixed(1),
                  style: boldTextStyle(size: 12),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
