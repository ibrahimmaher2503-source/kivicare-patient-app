import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kivicare_patient/utils/common_base.dart';
import 'package:nb_utils/nb_utils.dart';
import '../../../utils/app_common.dart';
import '../../../utils/colors.dart';
import '../../../utils/price_widget.dart';
import '../model/patient_wallet_history_res.dart';

class WalletHistoryCardWid extends StatelessWidget {
  final WalletHistoryElement walletHistoryElement;
  const WalletHistoryCardWid({super.key, required this.walletHistoryElement});

  @override
  Widget build(BuildContext context) {
    final bool isDebit = walletHistoryElement.transactionType.toLowerCase().contains("debit");
    final Color amountColor = isDebit ? cancelStatusColor : completedStatusColor;

    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: isDarkMode.value ? surfaceElevatedDark : surfaceElevated,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: isDarkMode.value ? softShadowColorDark : softShadowColor,
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                walletHistoryElement.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: isDarkMode.value ? Colors.white : primaryTextColor,
                ),
              ).flexible(),
              8.width,
              // Status indicator chip
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isDebit
                      ? cancelStatusColor.withValues(alpha: isDarkMode.value ? 0.15 : 0.08)
                      : completedStatusColor.withValues(alpha: isDarkMode.value ? 0.15 : 0.08),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  walletHistoryElement.transactionType,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: amountColor,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          8.height,
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              PriceWidget(
                price: walletHistoryElement.creditDebitAmount,
                color: amountColor,
                size: 16,
                isBoldText: true,
              ).flexible(),
              Text(
                "${walletHistoryElement.date.dateInDMMMMyyyyFormat} ${walletHistoryElement.date.timeInHHmmAmPmFormat}",
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  color: secondaryTextColor,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
