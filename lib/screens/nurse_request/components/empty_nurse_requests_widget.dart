import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kivicare_patient/main.dart';
import 'package:nb_utils/nb_utils.dart';

import '../request_form/nurse_request_form_screen.dart';

class EmptyNurseRequestsWidget extends StatelessWidget {
  const EmptyNurseRequestsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return NoDataWidget(
      title: locale.value.emptyRequestsTitle,
      subTitle: locale.value.emptyRequestsSubtitle,
      retryText: locale.value.requestHomeNursing,
      onRetry: () => Get.to(() => const NurseRequestFormScreen()),
    );
  }
}
