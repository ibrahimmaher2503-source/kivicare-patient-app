import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import '../../../main.dart';

class IcuEmptyState extends StatelessWidget {
  final String? title;
  final String? subtitle;
  final IconData? icon;
  final VoidCallback? onRetry;

  const IcuEmptyState({
    super.key,
    this.title,
    this.subtitle,
    this.icon,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon ?? Icons.inbox_outlined, size: 80, color: context.dividerColor),
          16.height,
          Text(title ?? locale.value.noDataFound, style: boldTextStyle(size: 18)),
          8.height,
          Text(
            subtitle ?? '',
            style: secondaryTextStyle(),
            textAlign: TextAlign.center,
          ).paddingSymmetric(horizontal: 32),
          if (onRetry != null) ...[
            24.height,
            AppButton(
              text: locale.value.retry,
              onTap: onRetry,
              color: context.primaryColor,
              textStyle: boldTextStyle(color: Colors.white),
            ),
          ],
        ],
      ).paddingAll(16),
    );
  }
}
