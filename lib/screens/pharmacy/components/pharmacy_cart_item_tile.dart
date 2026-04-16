import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nb_utils/nb_utils.dart';
import '../../../components/cached_image_widget.dart';
import '../../../main.dart';
import '../../../utils/colors.dart';
import '../../../utils/app_common.dart';
import '../model/pharmacy_cart_model.dart';
import '../pharmacy_cart_controller.dart';

class PharmacyCartItemTile extends StatelessWidget {
  final PharmacyCartItem item;
  final PharmacyCartController cartController;

  const PharmacyCartItemTile({
    super.key,
    required this.item,
    required this.cartController,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDarkMode.value ? surfaceElevatedDark : surfaceElevated,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: isDarkMode.value ? softShadowColorDark : softShadowColor,
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product image
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: item.product?.image != null &&
                    item.product!.image!.isNotEmpty
                ? CachedImageWidget(
                    url: item.product!.image!,
                    height: 72,
                    width: 72,
                    fit: BoxFit.cover,
                  )
                : Container(
                    height: 72,
                    width: 72,
                    color: isDarkMode.value
                        ? Colors.white10
                        : appColorPrimary.withValues(alpha: 0.06),
                    child: Icon(Icons.medication_outlined,
                        color: appColorPrimary.withValues(alpha: 0.4),
                        size: 32),
                  ),
          ),
          12.width,
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.product?.name ?? '',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isDarkMode.value ? Colors.white : primaryTextColor,
                  ),
                ),
                6.height,
                Text(
                  '${locale.value.priceFrom} ${item.product?.priceFrom.toStringAsFixed(2) ?? '0.00'}',
                  style: GoogleFonts.outfit(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: appColorPrimary,
                  ),
                ),
                10.height,
                Row(
                  children: [
                    // Quantity stepper
                    _quantityStepper(),
                    const Spacer(),
                    // Remove button
                    GestureDetector(
                      onTap: () {
                        showConfirmDialogCustom(
                          context,
                          dialogType: DialogType.DELETE,
                          title: locale.value.removeFromCart,
                          subTitle: item.product?.name ?? '',
                          positiveText: locale.value.yes,
                          negativeText: locale.value.no,
                          onAccept: (ctx) {
                            cartController.removeItem(item.id);
                          },
                        );
                      },
                      child: Icon(Icons.delete_outline_rounded,
                          color: Colors.red.shade400, size: 20),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _quantityStepper() {
    return Container(
      decoration: BoxDecoration(
        border:
            Border.all(color: appColorPrimary.withValues(alpha: 0.3)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: () {
              if (item.quantity > 1) {
                cartController.updateItem(item.id, item.quantity - 1);
              }
            },
            child: Container(
              padding: const EdgeInsets.all(6),
              child: const Icon(Icons.remove_rounded, size: 14),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Text(
              '${item.quantity}',
              style: GoogleFonts.outfit(
                  fontSize: 14, fontWeight: FontWeight.w700),
            ),
          ),
          GestureDetector(
            onTap: () {
              cartController.updateItem(item.id, item.quantity + 1);
            },
            child: Container(
              padding: const EdgeInsets.all(6),
              child: const Icon(Icons.add_rounded, size: 14),
            ),
          ),
        ],
      ),
    );
  }
}
