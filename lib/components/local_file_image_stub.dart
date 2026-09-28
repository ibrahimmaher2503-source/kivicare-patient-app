import 'package:flutter/material.dart';

Widget buildLocalFileImage({
  required String path,
  double? height,
  double? width,
  BoxFit? fit,
  Color? color,
  Alignment alignment = Alignment.center,
  ImageErrorWidgetBuilder? errorBuilder,
}) {
  if (errorBuilder != null) {
    return Builder(
      builder: (context) => errorBuilder(
        context,
        UnsupportedError('Local file images are unavailable on this platform'),
        StackTrace.empty,
      ),
    );
  }
  return SizedBox(height: height, width: width);
}
