import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kivicare_patient/main.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../components/cached_image_widget.dart';
import '../../../generated/assets.dart';
import '../../../utils/app_common.dart';
import '../../../utils/colors.dart';
import '../../../utils/common_base.dart';
import '../../auth/model/login_response.dart';

class MemberComponent extends StatelessWidget {
  final double? width;
  final UserData memberData;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const MemberComponent({
    super.key,
    this.width,
    required this.memberData,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: Get.width,
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Column(
        spacing: 16,
        children: [
          Row(
            spacing: 16,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// Avatar with subtle border ring
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: appColorSecondary.withValues(alpha: 0.2),
                    width: 2,
                  ),
                ),
                child: CachedImageWidget(
                  url: memberData.profileImage,
                  circle: true,
                  height: 55,
                  width: 55,
                  fit: BoxFit.cover,
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 8,
                children: [
                  Text(
                    memberData.fullName,
                    style: GoogleFonts.outfit(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      letterSpacing: -0.3,
                      color: isDarkMode.value ? Colors.white : appColorPrimary,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: isDarkMode.value
                          ? appColorSecondary.withValues(alpha: 0.12)
                          : lightSecondaryColor,
                    ),
                    child: Text(
                      getOtherPatientRelation(relation: memberData.relation),
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: appColorSecondary,
                        letterSpacing: 0.1,
                      ),
                    ),
                  ),
                ],
              ).expand(),

              /// Action buttons with icon containers
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildActionButton(
                    onTap: onEdit,
                    imgPath: Assets.iconsIcEdit,
                    context: context,
                  ),
                  12.width,
                  _buildActionButton(
                    onTap: onDelete,
                    imgPath: Assets.iconsIcTrash,
                    context: context,
                  ),
                ],
              ),
            ],
          ),

          /// Details section with subtle background
          Container(
            width: Get.width,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color: isDarkMode.value
                  ? Colors.white.withValues(alpha: 0.04)
                  : inputFillColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (memberData.gender.isNotEmpty)
                  _buildDetailRow(
                    label: "${locale.value.genderWithColon} ",
                    value: getOtherPatientGender(gender: memberData.gender),
                  ).paddingBottom(4),
                if (memberData.contactNumber.isNotEmpty)
                  _buildDetailRow(
                    label: "${locale.value.contactNumberWithColon} ",
                    value: memberData.contactNumber,
                  ).paddingBottom(4).onTap(() {
                    launchCall(memberData.contactNumber);
                  }),
                if (memberData.birthDate.isNotEmpty)
                  _buildDetailRow(
                    label: "${locale.value.dobWithColon} ",
                    value: memberData.birthDate,
                  ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required VoidCallback? onTap,
    required String imgPath,
    required BuildContext context,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: isDarkMode.value
              ? Colors.white.withValues(alpha: 0.06)
              : inputFillColor,
          borderRadius: BorderRadius.circular(8),
        ),
        child: commonLeadingWid(
          imgPath: imgPath,
          color: isDarkMode.value ? secondaryTextColor : darkGrayGeneral,
          size: 16,
        ),
      ),
    );
  }

  Widget _buildDetailRow({required String label, required String value}) {
    return Row(
      children: [
        Expanded(
          flex: 1,
          child: Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              color: secondaryTextColor,
              letterSpacing: 0.1,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.1,
              color: isDarkMode.value ? Colors.white : appColorPrimary,
            ),
          ),
        ),
      ],
    );
  }
}
