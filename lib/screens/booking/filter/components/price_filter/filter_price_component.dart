import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kivicare_patient/main.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:kivicare_patient/utils/colors.dart';

import '../../../../../utils/app_common.dart';
import '../../../../../utils/price_widget.dart';
import '../../filter_controller.dart';

class FilterPriceComponent extends StatelessWidget {
  final FilterController filterCont = Get.put(FilterController());

  FilterPriceComponent({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Column(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                locale.value.priceRange,
                style: GoogleFonts.outfit(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isDarkMode.value ? whiteTextColor : appColorPrimary,
                ),
              ).paddingAll(16),
              Obx(
                () => SliderTheme(
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
                    max: 5000,
                    divisions: 5000 ~/ 10,
                    labels: RangeLabels(filterCont.rangeValues.value.start.toInt().toString(), filterCont.rangeValues.value.end.toInt().toString()),
                    values: filterCont.rangeValues.value,
                    onChanged: (values) {
                      filterCont.rangeValues(values);
                      filterCont.setMaxPrice(values.end);
                      filterCont.setMinPrice(values.start);
                    },
                  ),
                ),
              ),
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
                    PriceWidget(
                      price: filterCont.rangeValues.value.start.toInt(),
                      isBoldText: true,
                      color: appColorSecondary,
                      size: 14,
                    ),
                    Text(
                      " - ",
                      style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w600, color: secondaryTextColor),
                    ),
                    PriceWidget(
                      price: filterCont.rangeValues.value.end.toInt(),
                      isBoldText: true,
                      color: appColorSecondary,
                      size: 14,
                    ),
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
