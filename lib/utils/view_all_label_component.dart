import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:kivicare_patient/utils/colors.dart';
import 'package:kivicare_patient/utils/constants.dart';

import '../main.dart';

class ViewAllLabel extends StatelessWidget {
  final String label;
  final String? trailingText;
  final List? list;
  final VoidCallback? onTap;
  final int? labelSize;
  final bool isShowAll;
  final Color? trailingTextColor;
  final int? maxLines;
  final TextOverflow? textOverflow;
  final bool expandedText;

  const ViewAllLabel({
    super.key,
    required this.label,
    this.onTap,
    this.labelSize,
    this.list,
    this.isShowAll = true,
    this.trailingText,
    this.trailingTextColor,
    this.maxLines,
    this.textOverflow,
    this.expandedText = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Text(
            label,
            style: GoogleFonts.outfit(
              fontSize: (labelSize ?? Constants.labelTextSize).toDouble() + 2,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.3,
              color: Theme.of(context).textTheme.bodyLarge?.color,
            ),
            maxLines: maxLines ?? 1,
            overflow: textOverflow ?? TextOverflow.ellipsis,
          ),
        ),
        if (isShowAll)
          GestureDetector(
            onTap: (list == null ? true : isViewAllVisible(list!))
                ? () {
              onTap?.call();
            }
                : null,
            behavior: HitTestBehavior.translucent,
            child: (list == null ? true : isViewAllVisible(list!))
                ? Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: (trailingTextColor ?? appColorSecondary).withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          trailingText ?? locale.value.viewAll,
                          style: boldTextStyle(
                            color: trailingTextColor ?? appColorSecondary,
                            size: 13,
                          ),
                        ),
                        4.width,
                        Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 12,
                          color: trailingTextColor ?? appColorSecondary,
                        ),
                      ],
                    ),
                  )
                : const SizedBox(),
          )
        else
          46.height,
      ],
    );
  }
}

bool isViewAllVisible(List list) => list.length >= 4;
