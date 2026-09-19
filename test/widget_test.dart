import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:kivicare_patient/app_theme.dart';
import 'package:kivicare_patient/components/app_scaffold.dart';

void main() {
  tearDown(Get.reset);

  testWidgets('AppScaffold renders the app shell without network setup', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      GetMaterialApp(
        theme: AppTheme.lightTheme,
        home: const AppScaffold(
          hasLeadingWidget: false,
          appBartitleText: 'Audit shell',
          body: Center(child: Text('Ready')),
        ),
      ),
    );

    expect(find.text('Audit shell'), findsOneWidget);
    expect(find.text('Ready'), findsOneWidget);
  });
}
