import 'package:flutter/material.dart';
import '../../../utils/colors.dart';

enum PharmacyIconStyle { tinted, solid, gradient, outline, soft }

enum PharmacyIconSize { sm, md, lg, xl }

class PharmacyIconBadge extends StatelessWidget {
  final IconData icon;
  final PharmacyIconSize size;
  final PharmacyIconStyle style;
  final Color? tone;
  final bool circular;
  final EdgeInsetsGeometry? margin;

  const PharmacyIconBadge({
    super.key,
    required this.icon,
    this.size = PharmacyIconSize.md,
    this.style = PharmacyIconStyle.tinted,
    this.tone,
    this.circular = false,
    this.margin,
  });

  double get _box {
    switch (size) {
      case PharmacyIconSize.sm:
        return 36;
      case PharmacyIconSize.md:
        return 44;
      case PharmacyIconSize.lg:
        return 56;
      case PharmacyIconSize.xl:
        return 72;
    }
  }

  double get _glyph {
    switch (size) {
      case PharmacyIconSize.sm:
        return 18;
      case PharmacyIconSize.md:
        return 22;
      case PharmacyIconSize.lg:
        return 28;
      case PharmacyIconSize.xl:
        return 34;
    }
  }

  double get _radius {
    if (circular) return _box / 2;
    switch (size) {
      case PharmacyIconSize.sm:
        return 10;
      case PharmacyIconSize.md:
        return 12;
      case PharmacyIconSize.lg:
        return 14;
      case PharmacyIconSize.xl:
        return 18;
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color base = tone ?? appColorSecondary;
    final BorderRadius radius = BorderRadius.circular(_radius);

    BoxDecoration decoration;
    Color glyphColor;

    switch (style) {
      case PharmacyIconStyle.tinted:
        decoration = BoxDecoration(
          color: base.withValues(alpha: 0.12),
          borderRadius: radius,
          border: Border.all(
            color: base.withValues(alpha: 0.18),
            width: 1,
          ),
        );
        glyphColor = base;
        break;
      case PharmacyIconStyle.solid:
        decoration = BoxDecoration(
          color: base,
          borderRadius: radius,
          boxShadow: [
            BoxShadow(
              color: base.withValues(alpha: 0.28),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        );
        glyphColor = Colors.white;
        break;
      case PharmacyIconStyle.gradient:
        decoration = BoxDecoration(
          gradient: const LinearGradient(
            colors: [gradientSecondaryStart, gradientSecondaryEnd],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: radius,
          boxShadow: [
            BoxShadow(
              color: softShadowColorMedium,
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
        );
        glyphColor = Colors.white;
        break;
      case PharmacyIconStyle.outline:
        decoration = BoxDecoration(
          color: Colors.transparent,
          borderRadius: radius,
          border: Border.all(color: base.withValues(alpha: 0.55), width: 1.4),
        );
        glyphColor = base;
        break;
      case PharmacyIconStyle.soft:
        decoration = BoxDecoration(
          color: surfaceSubtle,
          borderRadius: radius,
          border: Border.all(color: whiteBorderColor, width: 1),
        );
        glyphColor = base;
        break;
    }

    return Container(
      width: _box,
      height: _box,
      margin: margin,
      alignment: Alignment.center,
      decoration: decoration,
      child: Icon(icon, size: _glyph, color: glyphColor),
    );
  }
}
