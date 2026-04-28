import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kivicare_patient/components/app_scaffold.dart';
import 'package:kivicare_patient/main.dart';
import 'package:kivicare_patient/utils/colors.dart';
import 'package:nb_utils/nb_utils.dart';

import '../components/nurse_request_phone_actions.dart';
import '../detail/nurse_request_detail_screen.dart';
import '../models/nurse_request_model.dart';
import '../nurse_request_list_screen.dart';

class NurseRequestSuccessScreen extends StatelessWidget {
  final NurseRequestModel request;

  const NurseRequestSuccessScreen({super.key, required this.request});

  @override
  Widget build(BuildContext context) {
    return AppScaffoldNew(
      appBartitleText: locale.value.requestSubmitted,
      hasLeadingWidget: false,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [gradientStart, gradientEnd],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check, color: Colors.white, size: 56),
              ),
              24.height,
              Text(
                locale.value.requestSubmitted,
                style: boldTextStyle(size: 22),
                textAlign: TextAlign.center,
              ),
              12.height,
              Text(
                locale.value.notifyTeamWillAssign,
                style: secondaryTextStyle(size: 14),
                textAlign: TextAlign.center,
              ),
              24.height,
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: context.cardColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: gradientStart.withValues(alpha: 0.3)),
                ),
                child: Column(
                  children: [
                    Text(locale.value.referenceNumber, style: secondaryTextStyle(size: 12)),
                    8.height,
                    GestureDetector(
                      onTap: () => copyReferenceToClipboard(request.referenceNumber),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            request.referenceNumber,
                            style: boldTextStyle(size: 20, color: gradientStart),
                          ),
                          8.width,
                          Icon(Icons.copy, color: gradientStart, size: 18),
                        ],
                      ),
                    ),
                    4.height,
                    Text(
                      locale.value.copyReferenceNumber,
                      style: secondaryTextStyle(size: 11, color: gradientStart),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () {
                    Get.off(() => NurseRequestDetailScreen(requestId: request.id));
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: gradientStart,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(
                    locale.value.viewRequest,
                    style: boldTextStyle(color: Colors.white, size: 16),
                  ),
                ),
              ),
              12.height,
              SizedBox(
                width: double.infinity,
                height: 52,
                child: OutlinedButton(
                  onPressed: () => Get.offAll(() => const NurseRequestListScreen()),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: gradientStart),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(
                    locale.value.backToHome,
                    style: boldTextStyle(color: gradientStart, size: 16),
                  ),
                ),
              ),
              24.height,
            ],
          ),
        ),
      ),
    );
  }
}
