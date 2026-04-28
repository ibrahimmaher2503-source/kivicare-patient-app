import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../main.dart';
import '../../../utils/app_common.dart';
import '../../../utils/colors.dart';
import '../../../utils/view_all_label_component.dart';
import '../../doctor_visit/doctor_visit_list_screen.dart';
import 'clinic_list_screen.dart';
import 'doctor_list_screen.dart';

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
          onTap: () => toast('Coming soon'),
        ),
        _ServiceDef(
          label: locale.value.radiology,
          icon: Icons.biotech_outlined,
          iconBg: const Color(0xFFEDE7F6),
          iconBgDark: const Color(0x1A5C6BC0),
          iconColor: specialtyAccentIndigo,
          onTap: () => toast('Coming soon'),
        ),
        _ServiceDef(
          label: locale.value.pharmacy,
          icon: Icons.local_pharmacy_outlined,
          iconBg: const Color(0xFFE8F5E9),
          iconBgDark: const Color(0x1A27AE60),
          iconColor: specialtyAccentEmerald,
          onTap: () => toast('Coming soon'),
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
      ];

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final services = _buildServices();
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          16.height,
          ViewAllLabel(
            label: locale.value.quickServices,
            isShowAll: false,
          ).paddingOnly(left: 16, right: 8),
          8.height,
          SizedBox(
            height: 110,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              itemCount: services.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (_, i) => _ServiceCard(service: services[i]),
            ),
          ),
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
        width: 80,
        height: 90,
        decoration: BoxDecoration(
          color: dark ? surfaceElevatedDark : surfaceElevated,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: dark ? softShadowColorDark : softShadowColorMedium,
              blurRadius: 12,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: service.onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: dark ? service.iconBgDark : service.iconBg,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(service.icon, size: 20, color: service.iconColor),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    service.label,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: dark ? textPrimaryDark : primaryTextColor,
                      height: 1.3,
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
