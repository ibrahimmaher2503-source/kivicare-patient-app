import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../main.dart';
import '../../../utils/app_common.dart';
import '../../../utils/colors.dart';
import '../../../utils/price_widget.dart';
import '../model/independent_doctor_model.dart';

class IndependentServiceCard extends StatelessWidget {
  final IndependentService serviceData;
  final VoidCallback? onTap;

  const IndependentServiceCard({
    super.key,
    required this.serviceData,
    this.onTap,
  });

  static const Color _accentColor = Color(0xFF00897B); // Teal for in-person

  double get _finalPrice {
    if (serviceData.discount > 0) {
      return serviceData.charges - (serviceData.charges * serviceData.discount / 100);
    }
    return serviceData.charges;
  }

  List<Map<String, dynamic>> get _taxes {
    if (serviceData.isInclusiveTax == 1 && serviceData.inclusiveTax.isNotEmpty) {
      try {
        return List<Map<String, dynamic>>.from(jsonDecode(serviceData.inclusiveTax));
      } catch (_) {
        return [];
      }
    }
    return [];
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
          border: const Border(
            left: BorderSide(color: _accentColor, width: 3),
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
            // Service name and in-person badge row
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
                _buildInPersonBadge(),
              ],
            ),
            10.height,

            // Duration + slot interval row
            Row(
              children: [
                if (serviceData.durationMin > 0) ...[
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
                if (serviceData.durationMin > 0 && serviceData.timeSlot > 0) ...[
                  12.width,
                  Container(
                    width: 1,
                    height: 14,
                    color: secondaryTextColor.withValues(alpha: 0.3),
                  ),
                  12.width,
                ],
                if (serviceData.timeSlot > 0) ...[
                  Icon(Icons.schedule_rounded, size: 16, color: secondaryTextColor),
                  6.width,
                  Text(
                    '${serviceData.timeSlot} min ${locale.value.slotIntervalLabel.toLowerCase()}',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      letterSpacing: 0.1,
                      color: secondaryTextColor,
                    ),
                  ),
                ],
              ],
            ),

            // Description
            if (serviceData.description.isNotEmpty) ...[
              10.height,
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
            ],
            10.height,

            // Tax info badge
            if (serviceData.isInclusiveTax == 1) ...[
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: _accentColor.withValues(alpha: 0.1),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.receipt_long_rounded, size: 12, color: _accentColor),
                        4.width,
                        Text(
                          locale.value.taxIncludedLabel,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.1,
                            color: _accentColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (serviceData.inclusiveTaxPrice > 0) ...[
                    8.width,
                    PriceWidget(
                      price: serviceData.inclusiveTaxPrice,
                      size: 12,
                      isSemiBoldText: true,
                      isBoldText: false,
                      color: secondaryTextColor,
                    ),
                  ],
                ],
              ),
              // Individual tax items
              if (_taxes.isNotEmpty) ...[
                6.height,
                ..._taxes.map((tax) {
                  final title = tax['title'] ?? '';
                  final type = tax['type'] ?? '';
                  final value = tax['value'] ?? 0;
                  final suffix = type == 'percent' ? ' ($value%)' : '';
                  return Padding(
                    padding: const EdgeInsets.only(left: 4, bottom: 2),
                    child: Text(
                      '$title$suffix',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        letterSpacing: 0.1,
                        color: secondaryTextColor,
                      ),
                    ),
                  );
                }),
              ],
              10.height,
            ],

            // Pricing section
            _buildPricingSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildInPersonBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: [
            _accentColor.withValues(alpha: 0.18),
            _accentColor.withValues(alpha: 0.10),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: _accentColor.withValues(alpha: 0.15),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.person_pin_rounded, size: 14, color: _accentColor),
          4.width,
          Text(
            locale.value.inPersonConsultation,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.1,
              color: _accentColor,
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
          price: hasDiscount ? _finalPrice : serviceData.charges,
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
                _accentColor.withValues(alpha: 0.12),
                _accentColor.withValues(alpha: 0.06),
              ],
            ),
          ),
          child: Icon(
            Icons.arrow_forward_rounded,
            size: 18,
            color: _accentColor,
          ),
        ),
      ],
    );
  }
}
