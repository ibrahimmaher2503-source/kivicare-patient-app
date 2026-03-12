import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nb_utils/nb_utils.dart';
import '../../../../../utils/app_common.dart';
import '../../../../../utils/colors.dart';
import '../../filter_controller.dart';

class FilterServiceTypeComponent extends StatelessWidget {
  final FilterController filterCont = Get.put(FilterController());

  FilterServiceTypeComponent({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Obx(
          () => AnimatedWrap(
            spacing: 0,
            runSpacing: 0,
            children: List.generate(filterCont.serviceTypeList.length, (index) {
              var statusData = filterCont.serviceTypeList[index];
              final bool isSelected = filterCont.selectedServiceType == statusData['value'];
              return InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () {
                  filterCont.selectedServiceType(statusData['value']);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  margin: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? isDarkMode.value
                            ? appColorSecondary.withValues(alpha: 0.2)
                            : lightSecondaryColor
                        : isDarkMode.value
                            ? surfaceElevatedDark
                            : surfaceElevated,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected
                          ? appColorSecondary
                          : isDarkMode.value
                              ? glassStrokeDark
                              : whiteBorderColor,
                      width: isSelected ? 1.5 : 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (isSelected) ...[
                        Icon(Icons.check_circle, color: appColorSecondary, size: 16),
                        8.width,
                      ],
                      Text(
                        statusData['title'].toString(),
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                          color: isSelected
                              ? appColorSecondary
                              : isDarkMode.value
                                  ? Colors.white70
                                  : primaryTextColor,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ).paddingAll(16).expand(),
      ],
    );
  }
}
