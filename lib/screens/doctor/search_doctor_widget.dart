import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nb_utils/nb_utils.dart';
import '../../generated/assets.dart';
import '../../main.dart';
import '../../utils/app_common.dart';
import '../../utils/colors.dart';
import '../../utils/common_base.dart';
import 'doctor_list_controller.dart';

class SearchDoctorWidget extends StatelessWidget {
  final String? hintText;
  final Function(String)? onFieldSubmitted;
  final Function()? onTap;
  final Function()? onClearButton;
  final DoctorListController doctorListController;

  const SearchDoctorWidget({
    super.key,
    this.hintText,
    this.onTap,
    this.onFieldSubmitted,
    this.onClearButton,
    required this.doctorListController,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: isDarkMode.value ? surfaceElevatedDark : surfaceElevated,
        boxShadow: [
          BoxShadow(
            color: isDarkMode.value ? softShadowColorDark : softShadowColor,
            blurRadius: 16,
            offset: const Offset(0, 4),
            spreadRadius: 0,
          ),
        ],
      ),
      child: AppTextField(
        controller: doctorListController.searchDoctorCont,
        textFieldType: TextFieldType.OTHER,
        textInputAction: TextInputAction.done,
        textStyle: GoogleFonts.plusJakartaSans(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: isDarkMode.value ? Colors.white : appColorPrimary,
        ),
        onTap: onTap,
        onFieldSubmitted: onFieldSubmitted,
        onChanged: (p0) {
          doctorListController.isSearchDoctorText(doctorListController.searchDoctorCont.text.trim().isNotEmpty);
          doctorListController.searchDoctorStream.add(p0);
        },
        suffix: Obx(
              () => appCloseIconButton(
            context,
            onPressed: () {
              if (onClearButton != null) {
                onClearButton!.call();
              }
              hideKeyboard(context);
              doctorListController.searchDoctorCont.clear();
              doctorListController.isSearchDoctorText(doctorListController.searchDoctorCont.text.trim().isNotEmpty);
              doctorListController.page(1);
              doctorListController.getDoctors();
            },
            size: 11,
          ).visible(doctorListController.isSearchDoctorText.value),
        ),
        decoration: inputDecorationWithOutBorder(
          context,
          hintText: hintText ?? locale.value.searchDoctorHere,
          filled: true,
          fillColor: isDarkMode.value ? surfaceElevatedDark : surfaceElevated,
          prefixIcon: commonLeadingWid(imgPath: Assets.iconsIcSearch, size: 18).paddingAll(14),
        ),
      ),
    );
  }
}
