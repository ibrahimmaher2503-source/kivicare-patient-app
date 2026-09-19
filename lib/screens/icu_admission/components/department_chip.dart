import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import '../../../components/cached_image_widget.dart';
import '../../../utils/colors.dart';
import '../models/icu_department_model.dart';

class DepartmentChip extends StatelessWidget {
  final IcuDepartment department;

  const DepartmentChip({super.key, required this.department});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: context.dividerColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (department.iconUrl.validate().isNotEmpty)
            CachedImageWidget(url: department.iconUrl!, height: 20, width: 20).paddingRight(8),
          Text(department.name, style: boldTextStyle(size: 14)),
          if (department.availableBeds != null) ...[
            8.width,
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: (department.availableBeds! > 0 ? icuStatusAcceptedColor : grey).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                department.availableBeds.toString(),
                style: boldTextStyle(size: 12, color: department.availableBeds! > 0 ? icuStatusAcceptedColor : grey),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
