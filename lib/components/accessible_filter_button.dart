import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';

import '../generated/assets.dart';
import '../main.dart';
import '../utils/colors.dart';
import 'cached_image_widget.dart';

class AccessibleFilterButton extends StatelessWidget {
  final int count;
  final VoidCallback onPressed;

  const AccessibleFilterButton({
    super.key,
    required this.count,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final label =
        count > 0 ? '${locale.value.filter}: $count' : locale.value.filter;

    return Semantics(
      container: true,
      button: true,
      label: label,
      onTap: onPressed,
      child: ExcludeSemantics(
        child: Tooltip(
          message: label,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onPressed,
              borderRadius: BorderRadius.circular(12),
              child: SizedBox.square(
                dimension: 48,
                child: Stack(
                  alignment: AlignmentDirectional.topEnd,
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      alignment: Alignment.center,
                      decoration: boxDecorationDefault(
                        color: appColorPrimary,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const CachedImageWidget(
                        url: Assets.iconsIcFilter,
                        height: 26,
                        color: white,
                      ),
                    ),
                    if (count > 0)
                      PositionedDirectional(
                        top: -4,
                        end: -2,
                        child: Container(
                          constraints: const BoxConstraints(
                            minWidth: 22,
                            minHeight: 22,
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 5),
                          alignment: Alignment.center,
                          decoration: const BoxDecoration(
                            color: errorColor,
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            count > 99 ? '99+' : '$count',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
