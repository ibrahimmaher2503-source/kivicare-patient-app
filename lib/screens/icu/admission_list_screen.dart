import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../components/app_scaffold.dart';
import '../../main.dart';

/// Stub screen for ICU admission request list.
/// Full implementation will be added in a subsequent task.
class AdmissionListScreen extends StatelessWidget {
  const AdmissionListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => AppScaffoldNew(
        appBartitleText: locale.value.myIcuRequests,
        hasLeadingWidget: true,
        appBarVerticalSize: Get.height * 0.12,
        body: const Center(
          child: Text('Coming soon'),
        ),
      ),
    );
  }
}
