import 'package:flutter/material.dart';
import 'package:kivicare_patient/components/cached_image_widget.dart';
import 'package:kivicare_patient/main.dart';
import 'package:kivicare_patient/utils/colors.dart';
import 'package:nb_utils/nb_utils.dart';

import '../models/assigned_nurse_model.dart';
import 'nurse_request_phone_actions.dart';
import 'nurse_request_design.dart';

class AssignedNurseCard extends StatelessWidget {
  final AssignedNurseModel nurse;

  const AssignedNurseCard({super.key, required this.nurse});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: nurseRequestCardDecoration(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              nurse.avatarUrl != null
                  ? CachedImageWidget(
                      url: nurse.avatarUrl!,
                      width: 56,
                      height: 56,
                      circle: true,
                      fit: BoxFit.cover,
                    )
                  : Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: gradientSecondaryStart.withValues(alpha: 0.13),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.person_outline,
                        color: gradientSecondaryStart,
                        size: 28,
                      ),
                    ),
              12.width,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(nurse.displayName, style: boldTextStyle(size: 15)),
                    if (nurse.rating != null)
                      Row(
                        children: [
                          const Icon(Icons.star, color: ratingColor, size: 16),
                          4.width,
                          Text(
                            nurse.rating!.toStringAsFixed(1),
                            style: secondaryTextStyle(
                              size: 12,
                              color: nurseRequestMutedColor(context),
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
              if (nurse.phone != null)
                IconButton(
                  constraints: const BoxConstraints(
                    minWidth: 44,
                    minHeight: 44,
                  ),
                  icon: Icon(Icons.call, color: gradientStart),
                  onPressed: () => launchDialer(nurse.phone!),
                  tooltip: locale.value.nursePhone,
                ),
            ],
          ),
          if (nurse.bio != null && nurse.bio!.isNotEmpty) ...[
            12.height,
            Text(
              nurse.bio!,
              style: secondaryTextStyle(
                size: 13,
                color: nurseRequestMutedColor(context),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
