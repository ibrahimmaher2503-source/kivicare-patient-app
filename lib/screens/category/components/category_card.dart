import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:kivicare_patient/screens/service/services_list_screen.dart';
import 'package:kivicare_patient/utils/app_common.dart';
import 'package:kivicare_patient/utils/colors.dart';

import '../../../../components/cached_image_widget.dart';
import '../../service/system_service_list_screen.dart';
import '../model/category_list_model.dart';

class CategoryCard extends StatelessWidget {
  final CategoryElement category;

  const CategoryCard({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (appConfigs.value.isMultiVendor) {
          Get.to(() => SystemServiceListScreen(), arguments: category);
        } else {
          Get.to(() => ServiceListScreen(), arguments: category);
        }
      },
      child: Container(
        width: Get.width / 3 - 24,
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: BoxDecoration(
          color: isDarkMode.value ? surfaceElevatedDark : surfaceElevated,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: isDarkMode.value ? softShadowColorDark : softShadowColor,
              blurRadius: 16,
              offset: const Offset(0, 4),
              spreadRadius: 0,
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            /// Category avatar with subtle border and shadow
            Hero(
              tag: category.categoryImage + category.id.toString(),
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
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
                child: CachedImageWidget(
                  url: category.categoryImage,
                  fit: BoxFit.fitHeight,
                  circle: true,
                  height: 72,
                  width: 72,
                ),
              ),
            ),
            12.height,

            /// Category name with refined typography
            Hero(
              tag: category.name + category.id.toString(),
              child: Text(
                category.name,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.1,
                  color: isDarkMode.value ? Colors.white : primaryTextColor,
                  decoration: TextDecoration.none,
                ),
              ),
            ).paddingSymmetric(horizontal: 4),
          ],
        ),
      ),
    );
  }
}
