// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:kivicare_patient/utils/colors.dart';

enum AppShaderMode {
  primary,
  secondary,
  gradient,
}

class AppShaderWidget extends StatelessWidget {
  final Widget? child;
  final AppShaderMode mode;
  final Color? color;

  const AppShaderWidget({super.key, this.child, this.color, this.mode = AppShaderMode.primary});

  @override
  Widget build(BuildContext context) {
    List<Color> shaderColors;
    if (color != null) {
      shaderColors = [color!, color!];
    } else {
      switch (mode) {
        case AppShaderMode.gradient:
          // Use the navy-to-teal gradient for a rich Clinical Luxury effect
          shaderColors = [gradientStart, gradientSecondaryEnd];
          break;
        case AppShaderMode.secondary:
          // Use the teal gradient for secondary elements
          shaderColors = [gradientSecondaryStart, gradientSecondaryEnd];
          break;
        default:
          // Primary uses the navy gradient
          shaderColors = [gradientStart, gradientEnd];
      }
    }

    return ShaderMask(
      blendMode: BlendMode.srcIn,
      shaderCallback: (bounds) {
        return LinearGradient(
          colors: shaderColors,
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          stops: const [0.0, 1.0],
          tileMode: TileMode.mirror,
        ).createShader(Rect.fromLTWH(0, 0, bounds.width, bounds.height));
      },
      child: child,
    );
  }
}
