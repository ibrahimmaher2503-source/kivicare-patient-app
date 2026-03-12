import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nb_utils/nb_utils.dart';
import '../../generated/assets.dart';
import '../../main.dart';
import '../../utils/app_common.dart';
import '../../utils/colors.dart';
import '../../utils/common_base.dart';
import 'clinic_list_controller.dart';

class SearchClinicWidget extends StatelessWidget {
  final String? hintText;
  final Function(String)? onFieldSubmitted;
  final Function()? onTap;
  final Function()? onClearButton;
  final ClinicListController clinicListController;

  const SearchClinicWidget({
    super.key,
    this.hintText,
    this.onTap,
    this.onFieldSubmitted,
    this.onClearButton,
    required this.clinicListController,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isDarkMode.value ? surfaceElevatedDark : surfaceElevated,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: isDarkMode.value ? softShadowColorDark : softShadowColor,
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: AppTextField(
        controller: clinicListController.searchClinicCont,
        textFieldType: TextFieldType.OTHER,
        textInputAction: TextInputAction.done,
        textStyle: GoogleFonts.plusJakartaSans(
          fontSize: 14,
          color: isDarkMode.value ? Colors.white : appColorPrimary,
          decorationColor: appColorPrimary,
        ),
        onTap: onTap,
        onFieldSubmitted: onFieldSubmitted,
        onChanged: (p0) {
          clinicListController.isSearchClinicText(clinicListController.searchClinicCont.text.trim().isNotEmpty);
          clinicListController.searchClinicStream.add(p0);
        },
        suffix: Obx(
          () => appCloseIconButton(
            context,
            onPressed: () {
              if (onClearButton != null) {
                onClearButton!.call();
              }
              hideKeyboard(context);
              clinicListController.searchClinicCont.clear();
              clinicListController.isSearchClinicText(clinicListController.searchClinicCont.text.trim().isNotEmpty);
              clinicListController.page(1);
              clinicListController.getClinicList();
            },
            size: 11,
          ).visible(clinicListController.isSearchClinicText.value),
        ),
        decoration: inputDecorationWithOutBorder(
          context,
          hintText: hintText ?? locale.value.searchClinicHere,
          filled: true,
          fillColor: isDarkMode.value ? surfaceElevatedDark : surfaceElevated,
          prefixIcon: Container(
            margin: const EdgeInsets.all(10),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isDarkMode.value ? appColorSecondary.withValues(alpha: 0.15) : lightSecondaryColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: commonLeadingWid(imgPath: Assets.iconsIcSearch, size: 16, color: appColorSecondary),
          ),
        ),
      ),
    );
  }
}
