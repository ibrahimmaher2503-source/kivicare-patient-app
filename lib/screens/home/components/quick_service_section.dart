import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../main.dart';
import '../../../utils/app_common.dart';
import '../../../utils/colors.dart';
import '../../doctor_visit/doctor_visit_list_screen.dart';
import 'clinic_list_screen.dart';
import 'doctor_list_screen.dart';
import '../../icu_admission/hospitals/hospital_list_screen.dart';
import '../../labs_radiology/hub/labs_radiology_hub_screen.dart';
import '../../nurse_request/nurse_request_list_screen.dart';
import '../../pharmacy/pharmacy_dashboard_screen.dart';

class QuickServiceSection extends StatelessWidget {
  const QuickServiceSection({super.key});

  List<_ServiceDef> _buildServices() => [
        _ServiceDef(
          label: locale.value.doctor,
          icon: Icons.medical_services_outlined,
          iconBg: const Color(0xFFE8EEF7),
          iconBgDark: const Color(0x1A4B7CC4),
          iconColor: appColorPrimary,
          onTap: () => Get.to(() => DoctorViewListScreen(isFromDashboard: true)),
        ),
        _ServiceDef(
          label: locale.value.labs,
          icon: Icons.science_outlined,
          iconBg: lightSecondaryColor,
          iconBgDark: const Color(0x1A037F7C),
          iconColor: appColorSecondary,
          onTap: () => Get.to(() => LabsRadiologyHubScreen()),
        ),
        _ServiceDef(
          label: locale.value.radiology,
          icon: Icons.biotech_outlined,
          iconBg: const Color(0xFFEDE7F6),
          iconBgDark: const Color(0x1A5C6BC0),
          iconColor: specialtyAccentIndigo,
          onTap: () => Get.to(() => LabsRadiologyHubScreen()),
        ),
        _ServiceDef(
          label: locale.value.pharmacy,
          icon: Icons.local_pharmacy_outlined,
          iconBg: const Color(0xFFE8F5E9),
          iconBgDark: const Color(0x1A27AE60),
          iconColor: specialtyAccentEmerald,
          onTap: () => Get.to(() => PharmacyDashboardScreen()),
        ),
        _ServiceDef(
          label: locale.value.clinic,
          icon: Icons.local_hospital_outlined,
          iconBg: const Color(0xFFE3F2FD),
          iconBgDark: const Color(0x1A2980B9),
          iconColor: specialtyAccentOcean,
          onTap: () => Get.to(() => ClinicListComponent(isFromDashboard: true)),
        ),
        _ServiceDef(
          label: locale.value.homeVisit,
          icon: Icons.home_outlined,
          iconBg: const Color(0xFFFFF3E0),
          iconBgDark: const Color(0x1AE67E22),
          iconColor: specialtyAccentOrange,
          onTap: () => Get.to(() => const DoctorVisitListScreen()),
        ),
        _ServiceDef(
          label: locale.value.homeNursing,
          icon: Icons.elderly_outlined,
          iconBg: const Color(0xFFFCE4EC),
          iconBgDark: const Color(0x1AC0392B),
          iconColor: const Color(0xFFC0392B),
          onTap: () => Get.to(() => const NurseRequestListScreen()),
        ),
        _ServiceDef(
          label: locale.value.icuAdmission,
          icon: Icons.monitor_heart_outlined,
          iconBg: const Color(0xFFFFEBEE),
          iconBgDark: const Color(0x1AE53935),
          iconColor: const Color(0xFFE53935),
          onTap: () => Get.to(() => HospitalListScreen()),
        ),
      ];

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final services = _buildServices();
      final rowCount = (services.length / 2).ceil();
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          16.height,
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              locale.value.quickServices,
              style: boldTextStyle(size: 16),
            ),
          ),
          12.height,
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: List.generate(rowCount, (rowIndex) {
                final left = rowIndex * 2;
                final right = left + 1;
                return Padding(
                  padding: EdgeInsets.only(bottom: rowIndex < rowCount - 1 ? 12 : 0),
                  child: Row(
                    children: [
                      Expanded(child: _ServiceCard(service: services[left])),
                      const SizedBox(width: 12),
                      if (right < services.length)
                        Expanded(child: _ServiceCard(service: services[right]))
                      else
                        const Expanded(child: SizedBox()),
                    ],
                  ),
                );
              }),
            ),
          ),
          8.height,
        ],
      );
    });
  }
}

class _ServiceCard extends StatelessWidget {
  final _ServiceDef service;

  const _ServiceCard({required this.service});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final dark = isDarkMode.value;
      return Container(
        decoration: BoxDecoration(
          color: dark ? surfaceElevatedDark : surfaceElevated,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: dark ? softShadowColorDark : softShadowColorMedium,
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(14),
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: service.onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: dark ? service.iconBgDark : service.iconBg,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(service.icon, size: 19, color: service.iconColor),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      service.label,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: dark ? textPrimaryDark : primaryTextColor,
                        height: 1.3,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }
}

class _ServiceDef {
  final String label;
  final IconData icon;
  final Color iconBg;
  final Color iconBgDark;
  final Color iconColor;
  final VoidCallback onTap;

  _ServiceDef({
    required this.label,
    required this.icon,
    required this.iconBg,
    required this.iconBgDark,
    required this.iconColor,
    required this.onTap,
  });
}
