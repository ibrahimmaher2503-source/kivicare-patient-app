// ignore_for_file: no_leading_underscores_for_local_identifiers

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nb_utils/nb_utils.dart';

import 'app_common.dart';
import 'colors.dart';

class PriceWidget extends StatelessWidget {
  final num price;
  final String? priceText;
  final double? size;
  final Color? color;
  final Color? hourlyTextColor;
  final bool isBoldText;
  final bool isSemiBoldText;
  final bool isLineThroughEnabled;
  final bool isDiscountedPrice;
  final bool isHourlyService;
  final bool isFreeService;

  final FontStyle? fontStyle;

  const PriceWidget({
    super.key,
    required this.price,
    this.size = 16.0,
    this.color,
    this.hourlyTextColor,
    this.isLineThroughEnabled = false,
    this.isBoldText = true,
    this.isSemiBoldText = false,
    this.isDiscountedPrice = false,
    this.isHourlyService = false,
    this.isFreeService = false,
    this.priceText,
    this.fontStyle,
  });

  @override
  Widget build(BuildContext context) {
    TextDecoration? textDecoration() => isLineThroughEnabled ? TextDecoration.lineThrough : null;

    // Determine the effective color: default to teal for price emphasis
    final Color effectiveColor = color ?? appColorSecondary;

    // Currency symbol style: smaller and slightly muted
    TextStyle _currencyStyle() {
      final double currencySize = (size ?? 16.0) * 0.75;
      return GoogleFonts.plusJakartaSans(
        fontSize: currencySize,
        fontWeight: isBoldText ? FontWeight.w600 : FontWeight.w400,
        color: effectiveColor.withValues(alpha: 0.7),
        decoration: textDecoration(),
        fontStyle: fontStyle,
        letterSpacing: 0.1,
      );
    }

    // Amount text style: Outfit font for numerical emphasis
    TextStyle _amountStyle() {
      FontWeight weight;
      if (isSemiBoldText) {
        weight = FontWeight.w600;
      } else if (isBoldText) {
        weight = FontWeight.w700;
      } else {
        weight = FontWeight.w400;
      }

      return GoogleFonts.outfit(
        fontSize: size,
        fontWeight: weight,
        color: effectiveColor,
        decoration: textDecoration(),
        fontStyle: fontStyle,
        letterSpacing: -0.3,
      );
    }

    // Build the formatted price string
    final String formattedPrice = priceText ??
        price.validate().toStringAsFixed(appCurrency.value.noOfDecimal).formatNumberWithComma(seperator: appCurrency.value.thousandSeparator);

    // Determine left/right currency symbols
    final String leftCurrency = leftCurrencyFormat();
    final String rightCurrency = rightCurrencyFormat();

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        if (isDiscountedPrice)
          Text(
            ' -',
            style: _amountStyle(),
          ),
        if (leftCurrency.isNotEmpty)
          Text(
            leftCurrency,
            style: _currencyStyle(),
          ),
        Text(
          priceText != null ? formattedPrice : formattedPrice,
          style: _amountStyle(),
        ),
        if (rightCurrency.isNotEmpty)
          Text(
            rightCurrency,
            style: _currencyStyle(),
          ),
      ],
    );
  }
}

String leftCurrencyFormat() {
  if (isCurrencyPositionLeft || isCurrencyPositionLeftWithSpace) {
    return isCurrencyPositionLeftWithSpace ? '${appCurrency.value.currencySymbol} ' : appCurrency.value.currencySymbol;
  }
  return '';
}

String rightCurrencyFormat() {
  if (isCurrencyPositionRight || isCurrencyPositionRightWithSpace) {
    return isCurrencyPositionRightWithSpace ? ' ${appCurrency.value.currencySymbol}' : appCurrency.value.currencySymbol;
  }
  return '';
}
