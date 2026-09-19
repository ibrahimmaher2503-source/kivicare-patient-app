import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:kivicare_patient/screens/labs_radiology/labs_radiology_common.dart';
import 'package:kivicare_patient/components/cached_image_widget.dart';
import '../../models/lab_test_category_model.dart';

class TestCategoryCard extends StatelessWidget {
  final LabTestCategoryModel category;
  final VoidCallback onTap;

  const TestCategoryCard(
      {super.key, required this.category, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: boxDecorationDefault(
        color: context.cardColor,
        borderRadius: radius(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CachedImageWidget(
            url: category.icon.validate(),
            height: 40,
            width: 40,
            fit: BoxFit.contain,
          ),
          12.height,
          Text(
            category.name,
            style: boldTextStyle(size: 14),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          4.height,
          Text(
            locale.value.xTests(category.testsCount),
            style: secondaryTextStyle(size: 12),
          ),
        ],
      ),
    ).onTap(onTap, borderRadius: radius(12));
  }
}
