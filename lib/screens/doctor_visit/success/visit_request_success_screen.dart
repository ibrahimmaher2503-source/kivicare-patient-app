import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../components/app_scaffold.dart';
import '../../../main.dart';
import '../../../utils/colors.dart';
import '../detail/visit_request_detail_screen.dart';
import '../doctor_visit_list_screen.dart';
import '../models/visit_request_model.dart';

class VisitRequestSuccessScreen extends StatelessWidget {
  final VisitRequestModel request;

  const VisitRequestSuccessScreen({super.key, required this.request});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBartitleText: locale.value.requestSubmittedSuccessfully,
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
                locale.value.requestSubmittedSuccessfully,
                style: boldTextStyle(size: 22),
                textAlign: TextAlign.center,
              ),
              12.height,
              Text(
                locale.value.weWillGetBackToYouSoon,
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
                    Text(
                      locale.value.referenceNumber,
                      style: secondaryTextStyle(size: 12),
                    ),
                    8.height,
                    GestureDetector(
                      onTap: () {
                        Clipboard.setData(ClipboardData(text: request.referenceNumber));
                        toast(locale.value.referenceCopied);
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            request.referenceNumber,
                            style: boldTextStyle(size: 20, color: gradientStart),
                          ),
                          8.width,
                          Icon(Icons.copy_outlined, color: gradientStart, size: 18),
                        ],
                      ),
                    ),
                    4.height,
                    Text(
                      locale.value.referenceCopied,
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
                    Get.off(
                      () => VisitRequestDetailScreen(
                        referenceNumber: request.referenceNumber,
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: gradientStart,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
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
                  onPressed: () => Get.offAll(() => const DoctorVisitListScreen()),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: gradientStart),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
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
