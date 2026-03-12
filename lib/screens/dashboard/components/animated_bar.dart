import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:kivicare_patient/utils/colors.dart';

class AnimatedBar extends StatelessWidget {
  const AnimatedBar({
    super.key,
    required this.isActive,
    required this.tabName,
  });

  final bool isActive;
  final String tabName;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      alignment: Alignment.center,
      margin: const EdgeInsets.only(bottom: 2),
      padding: const EdgeInsets.symmetric(horizontal: 10),
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOutCubic,
      height: isActive ? 28 : 0,
      width: isActive ? tabName.length * 9 + 20 : 0,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [gradientSecondaryStart, gradientSecondaryEnd],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.all(Radius.circular(14)),
        boxShadow: isActive
            ? [
                BoxShadow(
                  color: gradientSecondaryStart.withValues(alpha: 0.25),
                  offset: const Offset(0, 3),
                  blurRadius: 8,
                  spreadRadius: -1,
                ),
              ]
            : [],
      ),
      child: AnimatedOpacity(
        opacity: isActive ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
        child: Text(
          tabName,
          style: primaryTextStyle(
            color: white,
            size: 12,
            weight: FontWeight.w600,
            letterSpacing: 0.2,
          ),
        ),
      ),
    );
  }
}
