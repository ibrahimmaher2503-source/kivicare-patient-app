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
    final bool darkMode = isDarkMode.value;

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
          color: darkMode ? surfaceElevatedDark : surfaceElevated,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: darkMode ? glassStrokeDark : glassStrokeLight,
            width: 0.5,
          ),
          boxShadow: [
            BoxShadow(
              color: darkMode ? softShadowColorDark : softShadowColor,
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
            /// Category avatar with gradient ring
            Hero(
              tag: category.categoryImage + category.id.toString(),
              child: Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      appColorSecondary.withValues(alpha: 0.6),
                      appColorAccent.withValues(alpha: 0.4),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: darkMode
                          ? softShadowColorDark
                          : appColorSecondary.withValues(alpha: 0.12),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: darkMode ? surfaceElevatedDark : surfaceElevated,
                  ),
                  padding: const EdgeInsets.all(2),
                  child: CachedImageWidget(
                    url: category.categoryImage,
                    fit: BoxFit.fitHeight,
                    circle: true,
                    height: 68,
                    width: 68,
                  ),
                ),
              ),
            ),
            12.height,

            /// Category name
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
                  color: darkMode ? Colors.white : primaryTextColor,
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
