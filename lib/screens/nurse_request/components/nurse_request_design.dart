import 'package:flutter/material.dart';
import 'package:kivicare_patient/utils/app_common.dart';
import 'package:kivicare_patient/utils/colors.dart';

bool get nurseRequestIsDark => isDarkMode.value;

Color nurseRequestSurface(BuildContext context) {
  return nurseRequestIsDark ? surfaceElevatedDark : surfaceElevated;
}

Color nurseRequestSubtleSurface(BuildContext context) {
  return nurseRequestIsDark ? inputFillColorDark : surfaceSubtle;
}

Color nurseRequestBorderColor(BuildContext context) {
  return nurseRequestIsDark ? borderColorDark : whiteBorderColor;
}

Color nurseRequestMutedColor(BuildContext context) {
  return nurseRequestIsDark ? textSecondaryDark : secondaryTextColor;
}

Color nurseRequestDisabledColor(BuildContext context) {
  return nurseRequestIsDark ? textTertiaryDark : gray400;
}

Color nurseRequestSkeletonColor(BuildContext context) {
  return nurseRequestIsDark ? shimmerBaseDark : shimmerBase;
}

Color nurseRequestSkeletonHighlightColor(BuildContext context) {
  return nurseRequestIsDark ? shimmerHighlightDark : shimmerHighlight;
}

BoxDecoration nurseRequestCardDecoration(
  BuildContext context, {
  double radius = 18,
  Color? color,
}) {
  return BoxDecoration(
    color: color ?? nurseRequestSurface(context),
    borderRadius: BorderRadius.circular(radius),
    border: Border.all(color: nurseRequestBorderColor(context)),
    boxShadow: nurseRequestIsDark
        ? const []
        : [
            BoxShadow(
              color: softShadowColor,
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
  );
}

InputDecoration nurseRequestInputDecoration(
  BuildContext context, {
  required String labelText,
  String? errorText,
  bool alignLabelWithHint = false,
  String counterText = '',
  Widget? prefixIcon,
}) {
  final radius = BorderRadius.circular(14);
  final enabledBorder = OutlineInputBorder(
    borderRadius: radius,
    borderSide: BorderSide(color: nurseRequestBorderColor(context)),
  );
  final focusedBorder = OutlineInputBorder(
    borderRadius: radius,
    borderSide: const BorderSide(color: gradientSecondaryStart, width: 1.4),
  );
  final errorBorder = OutlineInputBorder(
    borderRadius: radius,
    borderSide: BorderSide(color: cancelStatusColor.withValues(alpha: 0.62)),
  );

  return InputDecoration(
    labelText: labelText,
    errorText: errorText,
    alignLabelWithHint: alignLabelWithHint,
    counterText: counterText,
    prefixIcon: prefixIcon,
    filled: true,
    fillColor: nurseRequestSubtleSurface(context),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
    labelStyle: TextStyle(color: nurseRequestMutedColor(context), fontSize: 13),
    errorStyle: const TextStyle(color: cancelStatusColor, fontSize: 12),
    border: enabledBorder,
    enabledBorder: enabledBorder,
    focusedBorder: focusedBorder,
    errorBorder: errorBorder,
    focusedErrorBorder: errorBorder,
  );
}
