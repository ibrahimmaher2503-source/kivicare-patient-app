import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../main.dart';
import '../../../utils/colors.dart';
import '../../../utils/common_base.dart';
import '../../../utils/app_common.dart';
import '../../../utils/view_all_label_component.dart';
import '../../nurse/nurse_list_screen.dart';
import '../../nurse/nurse_request_list_screen.dart';
import '../../lab_test/lab_test_categories_screen.dart';
import '../../lab_test/test_order_list_screen.dart';
import '../../request_service/request_service_list_screen.dart';

class QuickServicesComponent extends StatelessWidget {
  const QuickServicesComponent({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ViewAllLabel(
          label: locale.value.requestNurse.split(' ').first == locale.value.requestNurse.split(' ').first
              ? 'Quick Services'
              : 'Quick Services',
          isShowAll: false,
        ).paddingOnly(left: 16, right: 8),
        8.height,

        /// Navigation cards row
        Obx(
          () => SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                _buildServiceCard(
                  context,
                  icon: Icons.medical_services_rounded,
                  label: locale.value.requestNurse,
                  gradient: const LinearGradient(
                    colors: [gradientSecondaryStart, gradientSecondaryEnd],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  onTap: () {
                    doIfLoggedIn(() {
                      Get.to(() => NurseListScreen());
                    });
                  },
                ),
                16.width,
                _buildServiceCard(
                  context,
                  icon: Icons.biotech_rounded,
                  label: locale.value.labTests,
                  gradient: const LinearGradient(
                    colors: [gradientStart, gradientEnd],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  onTap: () {
                    doIfLoggedIn(() {
                      Get.to(() => LabTestCategoriesScreen());
                    });
                  },
                ),
                16.width,
                _buildServiceCard(
                  context,
                  icon: Icons.room_service_rounded,
                  label: locale.value.requestService,
                  gradient: LinearGradient(
                    colors: [
                      appColorSecondary,
                      appColorSecondary.withValues(alpha: 0.7),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  onTap: () {
                    doIfLoggedIn(() {
                      Get.to(() => RequestServiceListScreen());
                    });
                  },
                ),
              ],
            ),
          ),
        ),
        24.height,

        /// My Requests section
        ViewAllLabel(
          label: 'My Requests',
          isShowAll: false,
        ).paddingOnly(left: 16, right: 8),
        8.height,
        Obx(
          () => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                _buildRequestTile(
                  context,
                  icon: Icons.medical_services_outlined,
                  label: locale.value.myNurseRequests,
                  onTap: () {
                    doIfLoggedIn(() {
                      Get.to(() => NurseRequestListScreen());
                    });
                  },
                ),
                12.height,
                _buildRequestTile(
                  context,
                  icon: Icons.science_outlined,
                  label: locale.value.myTestOrders,
                  onTap: () {
                    doIfLoggedIn(() {
                      Get.to(() => TestOrderListScreen());
                    });
                  },
                ),
                12.height,
                _buildRequestTile(
                  context,
                  icon: Icons.miscellaneous_services_outlined,
                  label: locale.value.myServiceRequests,
                  onTap: () {
                    doIfLoggedIn(() {
                      Get.to(() => RequestServiceListScreen());
                    });
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// Builds a gradient navigation card matching the app's clinical luxury style
  Widget _buildServiceCard(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Gradient gradient,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: Get.width / 3 - 24,
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 8),
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: isDarkMode.value ? softShadowColorDark : softShadowColorMedium,
              blurRadius: 16,
              offset: const Offset(0, 6),
              spreadRadius: 0,
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: glassTintLight,
                shape: BoxShape.circle,
                border: Border.all(
                  color: glassStrokeLight,
                  width: 1.5,
                ),
              ),
              child: Icon(icon, color: Colors.white, size: 28),
            ),
            12.height,
            Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                letterSpacing: -0.1,
                color: Colors.white,
                decoration: TextDecoration.none,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds a list tile for "My Requests" matching the app's elevated surface style
  Widget _buildRequestTile(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isDarkMode.value ? surfaceElevatedDark : surfaceElevated,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: isDarkMode.value ? softShadowColorDark : softShadowColor,
              blurRadius: 12,
              offset: const Offset(0, 4),
              spreadRadius: 0,
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isDarkMode.value ? glassTintDark : lightSecondaryColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: appColorSecondary, size: 22),
            ),
            12.width,
            Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                letterSpacing: -0.1,
                color: isDarkMode.value ? Colors.white : primaryTextColor,
              ),
            ).expand(),
            Icon(
              Icons.chevron_right_rounded,
              color: isDarkMode.value ? Colors.white54 : dividerColor,
              size: 22,
            ),
          ],
        ),
      ),
    );
  }
}
