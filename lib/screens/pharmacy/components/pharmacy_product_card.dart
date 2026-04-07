import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nb_utils/nb_utils.dart';
import '../../../components/cached_image_widget.dart';
import '../../../main.dart';
import '../../../utils/colors.dart';
import '../../../utils/app_common.dart';
import '../model/pharmacy_product_model.dart';

class PharmacyProductCard extends StatelessWidget {
  final PharmacyProduct product;
  final VoidCallback onTap;

  const PharmacyProductCard({
    super.key,
    required this.product,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: isDarkMode.value ? surfaceElevatedDark : surfaceElevated,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: isDarkMode.value ? softShadowColorDark : softShadowColor,
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product image with badges
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  child: product.image != null && product.image!.isNotEmpty
                      ? CachedImageWidget(
                          url: product.image!,
                          height: 110,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        )
                      : Container(
                          height: 110,
                          width: double.infinity,
                          color: isDarkMode.value ? Colors.white10 : appColorPrimary.withValues(alpha: 0.06),
                          child: Icon(
                            Icons.medication_outlined,
                            size: 40,
                            color: appColorPrimary.withValues(alpha: 0.4),
                          ),
                        ),
                ),
                if (!product.isInStock)
                  Positioned(
                    top: 6,
                    left: 6,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.red.shade600,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        locale.value.outOfStock,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                if (product.requiresPrescription)
                  Positioned(
                    top: 6,
                    right: 6,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade700,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Icon(Icons.medical_information_outlined, color: Colors.white, size: 12),
                    ),
                  ),
              ],
            ),
            // Product info
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isDarkMode.value ? Colors.white : primaryTextColor,
                      height: 1.3,
                    ),
                  ),
                  4.height,
                  Row(
                    children: [
                      Text(
                        '${locale.value.priceFrom} ',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 10,
                          color: isDarkMode.value ? Colors.white54 : secondaryTextColor,
                        ),
                      ),
                      Text(
                        product.priceFrom.toStringAsFixed(2),
                        style: GoogleFonts.outfit(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: appColorPrimary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
