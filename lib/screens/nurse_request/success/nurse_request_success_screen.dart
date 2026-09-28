import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kivicare_patient/components/app_scaffold.dart';
import 'package:kivicare_patient/main.dart';
import 'package:kivicare_patient/utils/colors.dart';
import 'package:nb_utils/nb_utils.dart';

import '../components/nurse_request_design.dart';
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
      topBarBgColor: gradientStart,
      scaffoldBackgroundColor:
          nurseRequestIsDark ? appScreenBackgroundDark : appScreenBackground,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) => SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: IntrinsicHeight(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 22, 24, 24),
                  child: Column(
                    children: [
                      const Spacer(),
                      Container(
                        width: 88,
                        height: 88,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              gradientSecondaryStart,
                              gradientSecondaryEnd
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          shape: BoxShape.circle,
                          boxShadow: nurseRequestIsDark
                              ? const []
                              : [
                                  BoxShadow(
                                    color: gradientSecondaryStart.withValues(
                                      alpha: 0.22,
                                    ),
                                    blurRadius: 22,
                                    offset: const Offset(0, 10),
                                  ),
                                ],
                        ),
                        child: const Icon(Icons.check,
                            color: whiteTextColor, size: 44),
                      ),
                      24.height,
                      Text(
                        locale.value.requestSubmitted,
                        style: boldTextStyle(size: 24),
                        textAlign: TextAlign.center,
                      ),
                      10.height,
                      Text(
                        locale.value.notifyTeamWillAssign,
                        style: secondaryTextStyle(
                          size: 14,
                          color: nurseRequestMutedColor(context),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      28.height,
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: nurseRequestCardDecoration(context),
                        child: Column(
                          children: [
                            Text(
                              locale.value.referenceNumber,
                              style: secondaryTextStyle(
                                size: 12,
                                color: nurseRequestMutedColor(context),
                              ),
                            ),
                            10.height,
                            Material(
                              color: appTransparentColor,
                              child: InkWell(
                                onTap: () => copyReferenceToClipboard(
                                    request.referenceNumber),
                                borderRadius: BorderRadius.circular(14),
                                child: Container(
                                  constraints:
                                      const BoxConstraints(minHeight: 52),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12),
                                  decoration: BoxDecoration(
                                    color: nurseRequestSubtleSurface(context),
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(
                                      color: nurseRequestBorderColor(context),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Flexible(
                                        child: Text(
                                          request.referenceNumber,
                                          style: boldTextStyle(
                                            size: 20,
                                            color: gradientStart,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      10.width,
                                      const Icon(
                                        Icons.copy,
                                        color: gradientStart,
                                        size: 18,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            8.height,
                            Text(
                              locale.value.copyReferenceNumber,
                              style: secondaryTextStyle(
                                  size: 12, color: gradientStart),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Get.off(
                              () => NurseRequestDetailScreen(
                                  requestId: request.id),
                            );
                          },
                          icon: const Icon(Icons.visibility_outlined, size: 20),
                          label: Text(locale.value.viewRequest),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: gradientStart,
                            foregroundColor: whiteTextColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                        ),
                      ),
                      12.height,
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: OutlinedButton.icon(
                          onPressed: () =>
                              Get.offAll(() => const NurseRequestListScreen()),
                          icon: const Icon(Icons.list_alt_outlined, size: 20),
                          label: Text(locale.value.myRequests),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: gradientStart,
                            side: const BorderSide(color: gradientStart),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
