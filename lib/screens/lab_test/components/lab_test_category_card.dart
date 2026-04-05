import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:kivicare_patient/models/lab_test_category_model.dart';
import 'package:kivicare_patient/utils/colors.dart';
import 'package:nb_utils/nb_utils.dart';

/// Card component for displaying a single lab test category
class LabTestCategoryCard extends StatelessWidget {
  final LabTestCategory category;
  final VoidCallback onTap;

  const LabTestCategoryCard({
    Key? key,
    required this.category,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: appStore.isDarkMode ? cardDarkColor : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: appStore.isDarkMode ? Colors.grey.shade800 : Colors.grey.shade200,
          ),
          boxShadow: [
            BoxShadow(
              color: softShadowColor.withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Category icon
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: appColorPrimary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.science,
                  color: appColorPrimary,
                  size: 32,
                ),
              ),
              const SizedBox(height: 12),
              
              // Category name
              Text(
                category.name,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: boldTextStyle(size: 14),
              ),
              const SizedBox(height: 8),
              
              // Test count
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: appColorPrimary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '${category.testCount} tests',
                  style: primaryTextStyle(
                    size: 12,
                    color: appColorPrimary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
