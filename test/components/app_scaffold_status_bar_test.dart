import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kivicare_patient/components/app_scaffold.dart';
import 'package:kivicare_patient/utils/colors.dart';

void main() {
  test('AppScaffoldNew chooses status-bar icons for its actual top-bar colour',
      () {
    expect(
      const AppScaffoldNew(body: SizedBox())
          .systemUiOverlayStyle
          .statusBarIconBrightness,
      Brightness.light,
    );
    expect(
      const AppScaffoldNew(
        body: SizedBox(),
        topBarBgColor: appScreenBackground,
      ).systemUiOverlayStyle.statusBarIconBrightness,
      Brightness.dark,
    );
  });
}
