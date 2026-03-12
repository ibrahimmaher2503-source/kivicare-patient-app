import 'package:flutter/material.dart';

import '../utils/app_common.dart';
import '../utils/colors.dart';
import 'cached_image_widget.dart';

class SocialMediaElement extends StatelessWidget {
  final void Function() onPressed;
  final String iconPath;

  const SocialMediaElement({super.key, required this.onPressed, required this.iconPath});

  @override
  Widget build(BuildContext context) {
    final bool dark = isDarkMode.value;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onPressed,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: dark ? surfaceElevatedDark : surfaceElevated,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: dark ? borderColorDark : borderColor.withValues(alpha: 0.2),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: dark ? softShadowColorDark : softShadowColor,
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: CachedImageWidget(
            url: iconPath,
            height: 20,
            width: 20,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}
