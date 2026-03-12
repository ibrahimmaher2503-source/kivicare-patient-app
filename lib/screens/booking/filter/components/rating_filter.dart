import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:kivicare_patient/utils/colors.dart';
import 'package:kivicare_patient/utils/app_common.dart';
import '../filter_controller.dart';

class FilterRatingComponent extends StatelessWidget {
  final FilterController filterCont = Get.put(FilterController());

  FilterRatingComponent({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(
          () => Column(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Rating",
                style: GoogleFonts.outfit(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isDarkMode.value ? Colors.white : appColorPrimary,
                ),
              ).paddingAll(16),
              Obx(() => SliderTheme(
                data: SliderThemeData(
                  activeTrackColor: appColorSecondary,
                  inactiveTrackColor: isDarkMode.value ? glassStrokeDark : whiteBorderColor,
                  thumbColor: appColorSecondary,
                  overlayColor: appColorSecondary.withValues(alpha: 0.15),
                  trackHeight: 4,
                  rangeThumbShape: const RoundRangeSliderThumbShape(enabledThumbRadius: 8),
                ),
                child: RangeSlider(
                  min: 1,
                  max: 5,
                  divisions: 4,
                  labels: RangeLabels(filterCont.rangeRatingValues.value.start.toInt().toString(), filterCont.rangeRatingValues.value.end.toInt().toString()),
                  values: filterCont.rangeRatingValues.value,
                  onChanged: (values) {
                    filterCont.rangeRatingValues(values);
                    filterCont.setMaxRating(values.end);
                    filterCont.setMinRating(values.start);
                  },
                ),
              )),
              16.height,
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: isDarkMode.value ? surfaceElevatedDark : surfaceSubtle,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: isDarkMode.value ? glassStrokeDark : whiteBorderColor),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.star_rounded, color: ratingColor, size: 18),
                    6.width,
                    Text(
                      filterCont.rangeRatingValues.value.start.toStringAsFixed(0),
                      style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w700, color: appColorSecondary),
                    ),
                    Text(
                      " - ",
                      style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w600, color: secondaryTextColor),
                    ),
                    Text(
                      filterCont.rangeRatingValues.value.end.toStringAsFixed(0),
                      style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w700, color: appColorSecondary),
                    ),
                    6.width,
                    Icon(Icons.star_rounded, color: ratingColor, size: 18),
                  ],
                ),
              ),
            ],
          ).expand(),
        ],
      ),
    );
  }
}
