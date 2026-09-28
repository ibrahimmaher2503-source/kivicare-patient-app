import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kivicare_patient/main.dart';
import 'package:kivicare_patient/utils/colors.dart';
import 'package:nb_utils/nb_utils.dart';

import '../request_form/nurse_request_form_screen.dart';
import 'nurse_request_design.dart';

class EmptyNurseRequestsWidget extends StatelessWidget {
  const EmptyNurseRequestsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(22),
          decoration: nurseRequestCardDecoration(context, radius: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [gradientSecondaryStart, gradientSecondaryEnd],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.volunteer_activism_outlined,
                  color: whiteTextColor,
                  size: 30,
                ),
              ),
              18.height,
              Text(
                locale.value.emptyRequestsTitle,
                style: boldTextStyle(size: 18),
                textAlign: TextAlign.center,
              ),
              8.height,
              Text(
                locale.value.emptyRequestsSubtitle,
                style: secondaryTextStyle(
                  size: 13,
                  color: nurseRequestMutedColor(context),
                ),
                textAlign: TextAlign.center,
              ),
              22.height,
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: () => Get.to(() => const NurseRequestFormScreen()),
                  icon: const Icon(Icons.add, size: 20),
                  label: Text(locale.value.requestHomeNursing),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: gradientStart,
                    foregroundColor: whiteTextColor,
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
    );
  }
}
