import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:kivicare_patient/screens/labs_radiology/labs_radiology_common.dart';
import '../models/facility_model.dart';
import '../models/lab_test_model.dart';
import '../shared/components/labs_shimmer.dart';
import 'facility_detail_controller.dart';
import 'components/facility_header.dart';
import 'components/facility_services.dart';
import 'components/facility_info.dart';
import 'components/test_detail_bottom_sheet.dart';
import '../slot_selection/slot_selection_screen.dart'; // Will be created in US3

class FacilityDetailScreen extends StatelessWidget {
  final FacilityModel facility;

  const FacilityDetailScreen({super.key, required this.facility});

  @override
  Widget build(BuildContext context) {
    final controller =
        Get.put(FacilityDetailController(initialFacility: facility));

    return Scaffold(
      body: Obx(() {
        final currentFacility = controller.facility.value ?? facility;

        return Stack(
          children: [
            AnimatedScrollView(
              children: [
                FacilityHeader(facility: currentFacility),
                24.height,
                FacilityServices(services: currentFacility.services),
                24.height,
                FacilityInfo(facility: currentFacility),
                24.height,
                _buildAvailableTests(context, controller),
                80.height,
              ],
            ),
            Positioned(
              top: context.statusBarHeight + 8,
              left: 16,
              child: Container(
                decoration: boxDecorationDefault(
                    shape: BoxShape.circle, color: context.cardColor),
                child: const BackButton(),
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildAvailableTests(
      BuildContext context, FacilityDetailController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(locale.value.availableTests, style: boldTextStyle()),
        ),
        16.height,
        Obx(() {
          if (controller.isLoading.value && controller.availableTests.isEmpty) {
            return const LabsTestShimmer();
          }

          if (controller.availableTests.isEmpty) {
            return Text(locale.value.noDataFound, style: secondaryTextStyle())
                .center()
                .paddingBottom(24);
          }

          return ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: controller.availableTests.length,
            itemBuilder: (context, index) {
              final test = controller.availableTests[index];
              return _buildTestItem(context, test, () {
                _showTestDetail(context, test);
              });
            },
          );
        }),
      ],
    );
  }

  Widget _buildTestItem(
      BuildContext context, LabTestModel test, VoidCallback onTap) {
    return Obx(() {
      final dark = isDarkMode.value;
      final hasPrice = test.price != null;
      return Container(
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: dark ? surfaceElevatedDark : surfaceElevated,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: dark ? softShadowColorDark : softShadowColor,
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(test.name,
                    style: boldTextStyle(size: 14),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis),
                if (hasPrice) ...[
                  6.height,
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        test.price!.toStringAsFixed(0),
                        style: primaryTextStyle(
                            size: 16,
                            color: appColorSecondary,
                            weight: FontWeight.bold),
                      ),
                      2.width,
                      Text(test.currency,
                          style: secondaryTextStyle(
                              size: 11, color: appColorSecondary)),
                    ],
                  ),
                ],
              ],
            ).expand(),
            16.width,
            AppButton(
              text: locale.value.bookNow,
              color: appColorSecondary,
              textStyle: boldTextStyle(color: Colors.white, size: 12),
              shapeBorder: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              onTap: () {
                Get.to(
                    () => SlotSelectionScreen(facility: facility, test: test));
              },
            ),
          ],
        ),
      ).onTap(onTap, borderRadius: radius(16));
    });
  }

  void _showTestDetail(BuildContext context, LabTestModel test) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => TestDetailBottomSheet(
        test: test,
        onBook: () {
          Get.to(() => SlotSelectionScreen(facility: facility, test: test));
        },
      ),
    );
  }
}
