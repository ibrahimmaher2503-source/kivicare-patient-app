import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nb_utils/nb_utils.dart';
import '../../../components/cached_image_widget.dart';
import '../../../main.dart';
import '../../../utils/colors.dart';
import '../../../utils/app_common.dart';
import '../model/pharmacy_cart_model.dart';

class AvailablePharmacyCard extends StatelessWidget {
  final PharmacyAvailablePharmacy pharmacy;
  final bool isSelected;
  final VoidCallback onTap;

  const AvailablePharmacyCard({
    super.key,
    required this.pharmacy,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDarkMode.value ? surfaceElevatedDark : surfaceElevated,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? appColorPrimary : Colors.transparent,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: isDarkMode.value ? softShadowColorDark : softShadowColor,
              blurRadius: isSelected ? 18 : 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Logo
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: pharmacy.logo != null && pharmacy.logo!.isNotEmpty
                      ? CachedImageWidget(
                          url: pharmacy.logo!,
                          height: 48,
                          width: 48,
                          fit: BoxFit.cover,
                        )
                      : Container(
                          height: 48,
                          width: 48,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [gradientSecondaryStart, gradientSecondaryEnd],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.local_pharmacy_rounded,
                              color: Colors.white, size: 24),
                        ),
                ),
                12.width,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        pharmacy.name,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: isDarkMode.value ? Colors.white : primaryTextColor,
                        ),
                      ),
                      if (pharmacy.address != null && pharmacy.address!.isNotEmpty) ...[
                        4.height,
                        Text(
                          pharmacy.address!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11,
                            color: secondaryTextColor,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (isSelected)
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: appColorPrimary,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.check_rounded,
                        color: Colors.white, size: 14),
                  ),
              ],
            ),
            16.height,
            // Pricing breakdown
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDarkMode.value
                    ? Colors.white.withValues(alpha: 0.04)
                    : appColorPrimary.withValues(alpha: 0.04),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                children: [
                  _priceRow(locale.value.subtotal,
                      pharmacy.subtotal.toStringAsFixed(2)),
                  6.height,
                  _priceRow(locale.value.deliveryFee,
                      pharmacy.deliveryFee.toStringAsFixed(2)),
                  const Divider(height: 16),
                  _priceRow(
                    locale.value.total,
                    pharmacy.total.toStringAsFixed(2),
                    isBold: true,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _priceRow(String label, String amount, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 12,
            fontWeight: isBold ? FontWeight.w700 : FontWeight.w400,
            color: isBold
                ? (isDarkMode.value ? Colors.white : primaryTextColor)
                : secondaryTextColor,
          ),
        ),
        Text(
          amount,
          style: GoogleFonts.outfit(
            fontSize: isBold ? 15 : 13,
            fontWeight: isBold ? FontWeight.w800 : FontWeight.w500,
            color: isBold ? appColorPrimary : (isDarkMode.value ? Colors.white70 : primaryTextColor),
          ),
        ),
      ],
    );
  }
}
