import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:nb_utils/nb_utils.dart';
import '../../../generated/assets.dart';
import '../../../main.dart';
import '../../dashboard/dashboard_screen.dart';
import '../components/reference_number_card.dart';
import '../requests/admission_request_detail_screen.dart';

class AdmissionSuccessScreen extends StatelessWidget {
  final int requestId;
  final String referenceNumber;

  const AdmissionSuccessScreen({
    super.key,
    required this.requestId,
    required this.referenceNumber,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.sizeOf(context).height -
                  MediaQuery.paddingOf(context).vertical -
                  48,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Lottie.asset(Assets.lottieEmptyLottie,
                    height: 200, repeat: false),
                24.height,
                Text(
                  locale.value.requestSubmitted,
                  style: boldTextStyle(size: 22),
                  textAlign: TextAlign.center,
                ),
                16.height,
                ReferenceNumberCard(referenceNumber: referenceNumber),
                40.height,
                AppButton(
                  text: locale.value.trackRequest,
                  width: Get.width,
                  color: context.primaryColor,
                  onTap: () {
                    Get.off(() =>
                        AdmissionRequestDetailScreen(requestId: requestId));
                  },
                ),
                16.height,
                TextButton(
                  onPressed: () {
                    Get.offAll(() => DashboardScreen());
                  },
                  child: Text(locale.value.goBackToHome,
                      style: boldTextStyle(color: context.primaryColor)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
