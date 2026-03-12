import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../components/cached_image_widget.dart';
import '../../../main.dart';
import '../../../utils/app_common.dart';
import '../../../utils/colors.dart';
import '../../home/model/system_service_res.dart';
import '../services_list_screen.dart';

class SystemServiceCard extends StatelessWidget {
  final SystemService systemServiceElement;

  const SystemServiceCard({super.key, required this.systemServiceElement});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        selectedSysService(systemServiceElement);
        Get.to(() => ServiceListScreen(), arguments: systemServiceElement);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDarkMode.value ? surfaceElevatedDark : surfaceElevated,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: isDarkMode.value ? softShadowColorDark : softShadowColor,
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Image with rounded container
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isDarkMode.value ? glassStrokeDark : appColorSecondary.withValues(alpha: 0.12),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: isDarkMode.value ? softShadowColorDark : appColorSecondary.withValues(alpha: 0.08),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: CachedImageWidget(
                  url: systemServiceElement.systemServiceImage,
                  fit: BoxFit.cover,
                  height: 60,
                  width: 60,
                ),
              ),
            ),
            16.width,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    systemServiceElement.name,
                    style: GoogleFonts.outfit(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.3,
                      color: isDarkMode.value ? Colors.white : primaryTextColor,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  6.height,
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: isDarkMode.value
                          ? appColorSecondary.withValues(alpha: 0.12)
                          : lightSecondaryColor,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '${locale.value.total} ${systemServiceElement.totalServices} ${locale.value.servicesAvailable}',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: appColorSecondary,
                        letterSpacing: 0.1,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: isDarkMode.value
                    ? appColorSecondary.withValues(alpha: 0.1)
                    : lightSecondaryColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.arrow_forward_ios_rounded,
                size: 14,
                color: appColorSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
