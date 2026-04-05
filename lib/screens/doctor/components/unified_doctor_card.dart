import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../components/cached_image_widget.dart';
import '../../../main.dart';
import '../../../utils/app_common.dart';
import '../../../utils/colors.dart';
import '../model/unified_doctor_model.dart';
import '../unified_doctor_detail_screen.dart';

class UnifiedDoctorCard extends StatelessWidget {
  final UnifiedDoctor doctor;
  final VoidCallback? onTap;

  const UnifiedDoctorCard({
    super.key,
    required this.doctor,
    this.onTap,
  });

  Color get _accentColor {
    if (doctor.bookingCapabilities.isEmpty) return appColorPrimary;
    final type = doctor.bookingCapabilities.first.type;
    switch (type) {
      case BookingType.videoCall:
        return callTypeVideoColor;
      case BookingType.phoneCall:
        return callTypePhoneColor;
      case BookingType.inPerson:
        return appColorSecondary;
      case BookingType.clinic:
        return appColorPrimary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool dark = isDarkMode.value;
    final double rating = doctor.averageRating;

    return GestureDetector(
      onTap: onTap ??
          () {
            hideKeyboard(context);
            Get.to(() => UnifiedDoctorDetailScreen(doctor: doctor));
          },
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Main card body with start accent border (RTL-aware)
          Container(
            margin: EdgeInsetsDirectional.only(start: 28),
            padding: EdgeInsetsDirectional.only(start: 68, top: 14, bottom: 14, end: 14),
            decoration: BoxDecoration(
              color: dark ? surfaceElevatedDark : surfaceElevated,
              borderRadius: BorderRadius.circular(16),
              border: BorderDirectional(
                start: BorderSide(color: _accentColor, width: 3),
              ),
              boxShadow: [
                BoxShadow(
                  color: dark ? softShadowColorDark : softShadowColor,
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Name row
                Text(
                  doctor.fullName,
                  style: GoogleFonts.outfit(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.3,
                    color: dark ? Colors.white : primaryTextColor,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                2.height,
                // Specialty
                Text(
                  doctor.expert,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: dark ? bodyWhite : secondaryTextColor,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                8.height,
                // Star rating + review count
                Row(
                  children: [
                    ...List.generate(5, (i) {
                      if (i < rating.floor()) {
                        return const Icon(Icons.star_rounded, color: appColorAccent, size: 14);
                      } else if (i < rating && rating - i >= 0.5) {
                        return const Icon(Icons.star_half_rounded, color: appColorAccent, size: 14);
                      } else {
                        return Icon(Icons.star_outline_rounded,
                            color: dark ? Colors.grey[600] : Colors.grey[300], size: 14);
                      }
                    }),
                    4.width,
                    Text(
                      '(${doctor.totalReviews})',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: dark ? bodyWhite : secondaryTextColor,
                      ),
                    ),
                  ],
                ),
                // Booking badges (only if capabilities known)
                if (doctor.bookingCapabilities.isNotEmpty) ...[
                  8.height,
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: doctor.bookingCapabilities
                        .where((c) => c.isAvailable)
                        .map((cap) => _CapabilityBadge(capability: cap))
                        .toList(),
                  ),
                ],
              ],
            ),
          ),
          // Circular avatar floating on the start side (RTL-aware)
          PositionedDirectional(
            start: 0,
            top: 0,
            bottom: 0,
            child: Center(
              child: Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: _accentColor, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: _accentColor.withValues(alpha: 0.25),
                      blurRadius: 8,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: ClipOval(
                  child: CachedImageWidget(
                    url: doctor.profileImage,
                    height: 56,
                    width: 56,
                    fit: BoxFit.cover,
                    circle: true,
                    firstName: doctor.firstName,
                    lastName: doctor.lastName,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CapabilityBadge extends StatelessWidget {
  final BookingCapability capability;

  const _CapabilityBadge({required this.capability});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: _badgeColor.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: _badgeColor.withValues(alpha: 0.4), width: 0.8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_badgeIcon, color: _badgeColor, size: 12),
          3.width,
          Text(
            _badgeLabel,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: _badgeColor,
            ),
          ),
        ],
      ),
    );
  }

  Color get _badgeColor {
    switch (capability.type) {
      case BookingType.clinic:
        return appColorPrimary;
      case BookingType.videoCall:
        return callTypeVideoColor;
      case BookingType.phoneCall:
        return callTypePhoneColor;
      case BookingType.inPerson:
        return appColorSecondary;
    }
  }

  IconData get _badgeIcon {
    switch (capability.type) {
      case BookingType.clinic:
        return Icons.local_hospital_rounded;
      case BookingType.videoCall:
        return Icons.video_call_rounded;
      case BookingType.phoneCall:
        return Icons.phone_rounded;
      case BookingType.inPerson:
        return Icons.person_pin_rounded;
    }
  }

  String get _badgeLabel {
    switch (capability.type) {
      case BookingType.clinic:
        return locale.value.clinic;
      case BookingType.videoCall:
        return locale.value.videoConsult;
      case BookingType.phoneCall:
        return locale.value.phoneCallLabel;
      case BookingType.inPerson:
        return locale.value.bookADoctor;
    }
  }
}
