import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nb_utils/nb_utils.dart';
import '../../../main.dart';
import '../../../utils/colors.dart';
import '../../../utils/app_common.dart';
import '../model/pharmacy_order_model.dart';

class PharmacyOrderCard extends StatelessWidget {
  final PharmacyOrderSummary order;
  final VoidCallback onTap;

  const PharmacyOrderCard({
    super.key,
    required this.order,
    required this.onTap,
  });

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending': return Colors.orange.shade600;
      case 'confirmed': return Colors.blue.shade600;
      case 'out_for_delivery': return Colors.purple.shade600;
      case 'delivered': return Colors.green.shade600;
      case 'cancelled': return Colors.red.shade600;
      default: return secondaryTextColor;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  order.pharmacy?.name ?? locale.value.pharmacy,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: isDarkMode.value ? Colors.white : primaryTextColor,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _statusColor(order.status).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    order.status.replaceAll('_', ' ').toUpperCase(),
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: _statusColor(order.status),
                    ),
                  ),
                ),
              ],
            ),
            8.height,
            Row(
              children: [
                Icon(Icons.shopping_bag_outlined,
                    size: 14, color: secondaryTextColor),
                4.width,
                Text(
                  '${order.itemCount} ${locale.value.products}',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    color: secondaryTextColor,
                  ),
                ),
                const Spacer(),
                Text(
                  order.total.toStringAsFixed(2),
                  style: GoogleFonts.outfit(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: appColorPrimary,
                  ),
                ),
              ],
            ),
            8.height,
            Text(
              order.createdAt,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11,
                color: secondaryTextColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
