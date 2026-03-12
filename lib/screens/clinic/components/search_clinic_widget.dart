import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kivicare_patient/main.dart';
import 'package:kivicare_patient/utils/app_common.dart';
import 'package:kivicare_patient/utils/colors.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../generated/assets.dart';
import '../../../utils/common_base.dart';
import '../clinic_list_controller.dart';

class SearchClinicWidget extends StatelessWidget {
  final String? hintText;
  final Function(String)? onFieldSubmitted;
  final Function()? onTap;
  final Function()? onClearButton;
  final ClinicListController clinicController;

  const SearchClinicWidget({
    super.key,
    this.hintText,
    this.onTap,
    this.onFieldSubmitted,
    this.onClearButton,
    required this.clinicController,
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
        controller: clinicController.searchClinicCont,
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
          clinicController.isSearchText(clinicController.searchClinicCont.text.trim().isNotEmpty);
          clinicController.searchClinicStream.add(p0);
        },
        suffix: Obx(
          () => appCloseIconButton(
            context,
            onPressed: () {
              if (onClearButton != null) {
                onClearButton!.call();
              }
              hideKeyboard(context);
              clinicController.searchClinicCont.clear();
              clinicController.isSearchText(clinicController.searchClinicCont.text.trim().isNotEmpty);
              clinicController.page(1);
              clinicController.getClinicList();
            },
            size: 11,
          ).visible(clinicController.isSearchText.value),
        ),
        decoration: inputDecorationWithOutBorder(
          context,
          hintText: hintText ?? locale.value.searchHere,
          filled: true,
          fillColor: isDarkMode.value ? surfaceElevatedDark : surfaceElevated,
          prefixIcon: Container(
            margin: const EdgeInsets.all(10),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isDarkMode.value ? appColorSecondary.withValues(alpha: 0.15) : lightSecondaryColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: commonLeadingWid(imgPath: Assets.iconsIcSearch, icon: Icons.search_outlined, size: 16, color: appColorSecondary),
          ),
        ),
      ),
    );
  }
}