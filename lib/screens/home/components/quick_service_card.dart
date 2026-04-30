import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kivicare_patient/main.dart';
import 'package:kivicare_patient/utils/colors.dart';
import 'package:kivicare_patient/utils/common_base.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../nurse_request/nurse_request_list_screen.dart';
import '../../pharmacy/pharmacy_dashboard_screen.dart';

class QuickServicesComponent extends StatelessWidget {
  const QuickServicesComponent({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            16.height,
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                locale.value.pharmacy,
                style: boldTextStyle(size: 16),
              ),
            ),
            8.height,
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _PharmacyCard(),
            ),
            16.height,
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                locale.value.homeNursing,
                style: boldTextStyle(size: 16),
              ),
            ),
            8.height,
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _HomeNursingCard(),
            ),
            16.height,
          ],
        ));
  }
}

class _PharmacyCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => doIfLoggedIn(() => Get.to(() => PharmacyDashboardScreen())),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [gradientSecondaryStart, gradientSecondaryEnd],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: softShadowColor,
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.local_pharmacy_outlined,
                  color: Colors.white, size: 28),
            ),
            16.width,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Obx(() => Text(
                        locale.value.pharmacy,
                        style: boldTextStyle(color: Colors.white, size: 16),
                      )),
                  4.height,
                  Obx(() => Text(
                        'Order medicines and healthcare products',
                        style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.85),
                            fontSize: 13),
                      )),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 16),
          ],
        ),
      ),
    );
  }
}

class _HomeNursingCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Get.to(() => const NurseRequestListScreen()),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [gradientStart, gradientEnd],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: softShadowColor,
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.medical_services_outlined,
                  color: Colors.white, size: 28),
            ),
            16.width,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Obx(() => Text(
                        locale.value.quickServiceHomeNursing,
                        style: boldTextStyle(color: Colors.white, size: 16),
                      )),
                  4.height,
                  Obx(() => Text(
                        locale.value.requestHomeNursing,
                        style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.85),
                            fontSize: 13),
                      )),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 16),
          ],
        ),
      ),
    );
  }
}
