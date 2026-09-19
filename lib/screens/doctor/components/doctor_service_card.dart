import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../utils/app_common.dart';
import '../../../utils/colors.dart';
import '../../service/model/service_list_model.dart';

class DoctorServiceCard extends StatelessWidget {
  final ServiceElement serviceElement;

  const DoctorServiceCard({super.key, required this.serviceElement});

  @override
  Widget build(BuildContext context) {
    final clinics = serviceElement.clinicName
        .where((c) => c.isNotEmpty)
        .toList();

    return Obx(
      () => Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: isDarkMode.value ? surfaceElevatedDark : surfaceElevated,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDarkMode.value
                ? const Color(0xFF243046)
                : const Color(0xFFEDF1F4),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isDarkMode.value
                    ? appColorSecondary.withValues(alpha: 0.12)
                    : lightSecondaryColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.medical_services_outlined,
                color: appColorSecondary,
                size: 18,
              ),
            ),
            12.width,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    serviceElement.serviceName.isNotEmpty
                        ? serviceElement.serviceName
                        : serviceElement.name,
                    style: TextStyle(
                      color: isDarkMode.value
                          ? textPrimaryDark
                          : appColorPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      height: 1.2,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (clinics.isNotEmpty) ...[
                    4.height,
                    Text(
                      clinics.join(', '),
                      style: TextStyle(
                        color: isDarkMode.value
                            ? textTertiaryDark
                            : const Color(0xFF75818A),
                        fontSize: 12,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            if (serviceElement.totalAppointments > 0) ...[
              8.width,
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                decoration: BoxDecoration(
                  color: isDarkMode.value
                      ? appColorSecondary.withValues(alpha: 0.12)
                      : lightSecondaryColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${serviceElement.totalAppointments}',
                  style: const TextStyle(
                    color: appColorSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
