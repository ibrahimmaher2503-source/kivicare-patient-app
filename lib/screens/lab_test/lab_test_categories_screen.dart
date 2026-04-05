import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../components/app_scaffold.dart';
import '../../components/loader_widget.dart';
import '../../main.dart';
import '../../utils/app_common.dart';
import '../../utils/colors.dart';
import 'components/lab_test_category_card.dart';
import 'lab_test_categories_controller.dart';

class LabTestCategoriesScreen extends StatefulWidget {
  const LabTestCategoriesScreen({super.key});

  @override
  State<LabTestCategoriesScreen> createState() => _LabTestCategoriesScreenState();
}

class _LabTestCategoriesScreenState extends State<LabTestCategoriesScreen> {
  late final LabTestCategoriesController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.put(LabTestCategoriesController());
  }

  @override
  void dispose() {
    Get.delete<LabTestCategoriesController>();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => AppScaffoldNew(
        appBartitleText: locale.value.labTestCategories,
        hasLeadingWidget: true,
        appBarVerticalSize: Get.height * 0.12,
        isLoading: controller.isLoading,
        body: Obx(
          () => SnapHelperWidget(
            future: controller.categoriesFuture.value,
            initialData: controller.categories.isNotEmpty ? controller.categories.toList() : null,
            errorBuilder: (error) {
              return _buildEmptyState();
            },
            loadingWidget: controller.isLoading.value ? const Offstage() : const LoaderWidget(),
            onSuccess: (_) {
              if (controller.categories.isEmpty) {
                return _buildEmptyState().paddingTop(Get.height * 0.1);
              }

              return AnimatedScrollView(
                listAnimationType: ListAnimationType.FadeIn,
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(24),
                onSwipeRefresh: () async {
                  return await controller.getCategories();
                },
                children: [
                  // Decorative header with gradient
                  _buildDecorativeHeader(),
                  20.height,

                  // Staggered grid: first card full width, rest in 2-column
                  _buildStaggeredGrid(),
                ],
              ).paddingOnly(bottom: 10);
            },
          ),
        ).paddingTop(16),
      ),
    );
  }

  Widget _buildDecorativeHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDarkMode.value
              ? [
                  appColorPrimary.withValues(alpha: 0.4),
                  appColorSecondary.withValues(alpha: 0.2),
                ]
              : [
                  appColorPrimary.withValues(alpha: 0.08),
                  appColorSecondary.withValues(alpha: 0.05),
                ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDarkMode.value
              ? glassStrokeDark
              : appColorSecondary.withValues(alpha: 0.1),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [gradientSecondaryStart, gradientSecondaryEnd],
              ),
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: appColorSecondary.withValues(alpha: 0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(Icons.biotech, size: 24, color: Colors.white),
          ),
          16.width,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  locale.value.labTestCategories,
                  style: GoogleFonts.outfit(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.3,
                    color: isDarkMode.value ? Colors.white : primaryTextColor,
                  ),
                ),
                4.height,
                Text(
                  '${controller.categories.length} ${locale.value.categoriesAvailable}',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    letterSpacing: 0.1,
                    color: secondaryTextColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStaggeredGrid() {
    final categories = controller.categories;
    if (categories.isEmpty) return const SizedBox.shrink();

    Widget animatedCard(int index) {
      return TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.0, end: 1.0),
        duration: Duration(milliseconds: 400 + (index * 100)),
        builder: (context, value, child) {
          return Opacity(
            opacity: value,
            child: Transform.translate(
              offset: Offset(0, 20 * (1 - value)),
              child: child,
            ),
          );
        },
        child: LabTestCategoryCard(categoryData: categories[index]),
      );
    }

    final List<Widget> children = [];

    // First card spans full width
    if (categories.isNotEmpty) {
      children.add(SizedBox(height: 170, child: animatedCard(0)));
      children.add(16.height);
    }

    // Remaining cards in 2-column grid (indices 1,2 then 3,4 then 5,6 ...)
    int i = 1;
    while (i < categories.length) {
      final hasSecond = (i + 1) < categories.length;
      children.add(
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(child: animatedCard(i)),
              16.width,
              Expanded(
                child: hasSecond ? animatedCard(i + 1) : const SizedBox(),
              ),
            ],
          ),
        ),
      );
      children.add(16.height);
      i += 2;
    }

    return Column(children: children);
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Floating animation for empty state icon
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: const Duration(milliseconds: 800),
            builder: (context, value, child) {
              return Transform.translate(
                offset: Offset(0, -8 * value),
                child: Opacity(
                  opacity: value,
                  child: child,
                ),
              );
            },
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    appColorPrimary.withValues(alpha: 0.1),
                    appColorSecondary.withValues(alpha: 0.05),
                  ],
                ),
              ),
              child: Icon(
                Icons.category_outlined,
                size: 48,
                color: appColorPrimary.withValues(alpha: 0.3),
              ),
            ),
          ),
          30.height,
          Text(
            locale.value.noDataFound,
            style: GoogleFonts.outfit(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.5,
              color: isDarkMode.value ? Colors.white : primaryTextColor,
            ),
          ),
          10.height,
          Text(
            locale.value.noTestCategoriesAvailable,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              letterSpacing: 0.1,
              color: darkGrayGeneral,
            ),
            textAlign: TextAlign.center,
          ).paddingOnly(left: 12, right: 12),
        ],
      ),
    );
  }
}
