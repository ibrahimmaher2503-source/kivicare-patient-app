import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';

import '../utils/empty_error_state_widget.dart';

class NoDataFoundWidget extends StatelessWidget {
  final String text;
  final String? subTitle;

  const NoDataFoundWidget({
    super.key,
    required this.text,
    this.subTitle,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: subTitle == null ? text : '$text. $subTitle',
      liveRegion: true,
      child: NoDataWidget(
        title: text,
        subTitle: subTitle,
        imageWidget: const EmptyStateWidget(),
      ).paddingSymmetric(horizontal: 24),
    );
  }
}
