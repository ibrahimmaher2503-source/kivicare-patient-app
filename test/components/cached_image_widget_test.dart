import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kivicare_patient/components/cached_image_widget.dart';

void main() {
  testWidgets('empty image URLs render a placeholder without a network URI',
      (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: CachedImageWidget(url: '', height: 40, width: 40),
        ),
      ),
    );

    expect(tester.takeException(), isNull);
  });
}
