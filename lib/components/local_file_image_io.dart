import 'dart:io';

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
  return Image.file(
    File(path),
    height: height,
    width: width,
    fit: fit,
    color: color,
    alignment: alignment,
    errorBuilder: errorBuilder,
  );
}
