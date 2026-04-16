import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../main.dart';
import '../../../utils/app_common.dart';
import '../../../utils/colors.dart';
import '../../../utils/constants.dart';
import '../../../utils/price_widget.dart';
import '../model/call_doctor_model.dart';

class CallServiceCard extends StatelessWidget {
  final CallService serviceData;
  final VoidCallback? onTap;

  const CallServiceCard({
    super.key,
    required this.serviceData,
    this.onTap,
  });

  Color get _callTypeColor {
    switch (serviceData.callType.toLowerCase()) {
      case CallTypeConst.video:
        return callTypeVideoColor;
      case CallTypeConst.phone:
        return callTypePhoneColor;
      default:
        return appColorSecondary;
    }
  }

  IconData get _callTypeIcon {
    switch (serviceData.callType.toLowerCase()) {
      case CallTypeConst.video:
        return Icons.videocam_rounded;
      case CallTypeConst.phone:
        return Icons.phone_rounded;
      default:
        return Icons.call_rounded;
    }
  }

  String get _callTypeLabel {
    switch (serviceData.callType.toLowerCase()) {
      case CallTypeConst.video:
        return locale.value.videoCallLabel;
      case CallTypeConst.phone:
        return locale.value.phoneCallLabel;
      default:
        return serviceData.callType;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDarkMode.value ? surfaceElevatedDark : surfaceElevated,
          borderRadius: BorderRadius.circular(16),
          border: Border(
            left: BorderSide(color: _callTypeColor, width: 3),
          ),
          boxShadow: [
            BoxShadow(
              color: isDarkMode.value ? softShadowColorDark : softShadowColor,
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Service name and call type badge row
            Row(
              children: [
                Expanded(
                  child: Text(
                    serviceData.name,
                    style: GoogleFonts.outfit(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      letterSpacing: -0.3,
                      color: isDarkMode.value ? Colors.white : primaryTextColor,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                8.width,
                _buildCallTypeBadge(),
              ],
            ),
            10.height,

            // Duration row
            if (serviceData.durationMin > 0) ...[
              Row(
                children: [
                  Icon(Icons.timer_outlined, size: 16, color: secondaryTextColor),
                  6.width,
                  Text(
                    '${serviceData.durationMin} min',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      letterSpacing: 0.1,
                      color: secondaryTextColor,
                    ),
                  ),
                ],
              ),
              10.height,
            ],

            // Description
            if (serviceData.description.isNotEmpty) ...[
              Text(
                serviceData.description,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  letterSpacing: 0.1,
                  color: secondaryTextColor,
                  height: 1.5,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              10.height,
            ],

            // Pricing section
            _buildPricingSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildCallTypeBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: [
            _callTypeColor.withValues(alpha: 0.18),
            _callTypeColor.withValues(alpha: 0.10),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: _callTypeColor.withValues(alpha: 0.15),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_callTypeIcon, size: 14, color: _callTypeColor),
          4.width,
          Text(
            _callTypeLabel,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.1,
              color: _callTypeColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPricingSection() {
    final bool hasDiscount = serviceData.discount > 0;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Final price (or charges if no discount)
        PriceWidget(
          price: hasDiscount ? serviceData.finalPrice : serviceData.charges,
          size: 18,
          color: isDarkMode.value ? Colors.white : primaryTextColor,
        ),

        if (hasDiscount) ...[
          10.width,
          // Original price with strikethrough
          PriceWidget(
            price: serviceData.charges,
            size: 13,
            color: secondaryTextColor,
            isLineThroughEnabled: true,
            isBoldText: false,
          ),
          8.width,
          // Discount badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              gradient: LinearGradient(
                colors: [
                  appColorSecondary.withValues(alpha: 0.18),
                  appColorSecondary.withValues(alpha: 0.10),
                ],
              ),
            ),
            child: Text(
              '${serviceData.discount}% ${locale.value.off}',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.1,
                color: appColorSecondary,
              ),
            ),
          ),
        ],

        const Spacer(),

        // Select arrow
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            gradient: LinearGradient(
              colors: [
                _callTypeColor.withValues(alpha: 0.12),
                _callTypeColor.withValues(alpha: 0.06),
              ],
            ),
          ),
          child: Icon(
            Icons.arrow_forward_rounded,
            size: 18,
            color: _callTypeColor,
          ),
        ),
      ],
    );
  }
}
