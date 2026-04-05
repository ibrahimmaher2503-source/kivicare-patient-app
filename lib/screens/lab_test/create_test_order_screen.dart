import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../components/app_scaffold.dart';
import '../../main.dart';
import '../../utils/app_common.dart';
import '../../utils/colors.dart';
import '../../utils/price_widget.dart';
import 'create_test_order_controller.dart';
import 'lab_test_list_screen.dart';
import 'model/lab_test_model.dart';

class CreateTestOrderScreen extends StatefulWidget {
  const CreateTestOrderScreen({super.key});

  @override
  State<CreateTestOrderScreen> createState() => _CreateTestOrderScreenState();
}

class _CreateTestOrderScreenState extends State<CreateTestOrderScreen> {
  late final CreateTestOrderController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.put(CreateTestOrderController());
  }

  @override
  void dispose() {
    Get.delete<CreateTestOrderController>();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => AppScaffoldNew(
        appBartitleText: locale.value.createTestOrder,
        hasLeadingWidget: true,
        appBarVerticalSize: Get.height * 0.12,
        isLoading: controller.isLoading,
        body: AnimatedScrollView(
          listAnimationType: ListAnimationType.FadeIn,
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(24),
          children: [
            16.height,

            // Add Tests Button
            GestureDetector(
              onTap: () {
                Get.to(() => LabTestListScreen(
                  selectionMode: true,
                  onTestSelected: (labTest) {
                    if (labTest is LabTest) {
                      controller.addTest(labTest);
                    }
                  },
                ));
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: appColorSecondary,
                    width: 1.5,
                  ),
                  color: isDarkMode.value
                      ? appColorSecondary.withValues(alpha: 0.1)
                      : appColorSecondary.withValues(alpha: 0.05),
                ),
                child: Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.add_circle_outline, color: appColorSecondary, size: 20),
                      8.width,
                      Text(
                        locale.value.addTest,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.1,
                          color: appColorSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            20.height,

            // Selected Tests List
            Obx(() {
              if (controller.selectedTests.isEmpty) {
                return Center(
                  child: Column(
                    children: [
                      40.height,
                      Icon(
                        Icons.science_outlined,
                        size: 60,
                        color: appColorPrimary.withValues(alpha: 0.2),
                      ),
                      16.height,
                      Text(
                        locale.value.selectTests,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          color: secondaryTextColor,
                        ),
                      ),
                      40.height,
                    ],
                  ),
                );
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle('${locale.value.labTests} (${controller.selectedTests.length})'),
                  12.height,
                  ...controller.selectedTests.map((test) => _buildSelectedTestItem(test).paddingBottom(10)),
                ],
              );
            }),
            20.height,

            // Clinical Notes
            _buildSectionTitle(locale.value.clinicalNotes),
            12.height,
            Container(
              decoration: BoxDecoration(
                color: isDarkMode.value ? inputFillColorDark : inputFillColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: AppTextField(
                textStyle: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  letterSpacing: 0.1,
                  color: isDarkMode.value ? Colors.white : primaryTextColor,
                ),
                controller: controller.clinicalNotesCont,
                textFieldType: TextFieldType.OTHER,
                maxLines: 4,
                maxLength: 2000,
                decoration: InputDecoration(
                  hintText: '${locale.value.clinicalNotes}...',
                  hintStyle: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    letterSpacing: 0.1,
                    color: secondaryTextColor,
                  ),
                  filled: true,
                  fillColor: isDarkMode.value ? inputFillColorDark : inputFillColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.all(16),
                ),
              ),
            ),
            20.height,

            // Priority Selection
            _buildSectionTitle(locale.value.priority),
            12.height,
            Obx(() => AnimatedWrap(
              spacing: 12,
              runSpacing: 8,
              children: controller.priorityOptions.map((option) {
                final isSelected = controller.priority.value == option['key'];
                return GestureDetector(
                  onTap: () => controller.onPriorityChanged(option['key']!),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(
                      gradient: isSelected
                          ? const LinearGradient(colors: [gradientStart, gradientEnd])
                          : null,
                      color: isSelected ? null : (isDarkMode.value ? surfaceElevatedDark : surfaceElevated),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: isSelected
                              ? appColorPrimary.withValues(alpha: 0.3)
                              : (isDarkMode.value ? softShadowColorDark : softShadowColor),
                          blurRadius: isSelected ? 12 : 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Text(
                      option['label']!,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.1,
                        color: isSelected
                            ? Colors.white
                            : (isDarkMode.value ? Colors.white70 : primaryTextColor),
                      ),
                    ),
                  ),
                );
              }).toList(),
            )),
            24.height,

            // Order Summary
            Obx(() {
              if (controller.selectedTests.isEmpty) return const SizedBox.shrink();

              return Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionTitle(locale.value.totalAmount),
                    16.height,
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${controller.selectedTests.length} ${locale.value.testCount}',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 14,
                            color: secondaryTextColor,
                          ),
                        ),
                        PriceWidget(
                          price: controller.totalAmount.value,
                          size: 20,
                          color: isDarkMode.value ? Colors.white : primaryTextColor,
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }),
            24.height,

            // Submit Button
            Obx(() => GestureDetector(
              onTap: controller.selectedTests.isNotEmpty && !controller.isLoading.value
                  ? () => controller.submitOrder()
                  : null,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  gradient: controller.selectedTests.isNotEmpty
                      ? const LinearGradient(colors: [gradientSecondaryStart, gradientSecondaryEnd])
                      : null,
                  color: controller.selectedTests.isEmpty
                      ? (isDarkMode.value ? surfaceElevatedDark : const Color(0xFFE0E0E0))
                      : null,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: controller.selectedTests.isNotEmpty
                      ? [
                          BoxShadow(
                            color: appColorSecondary.withValues(alpha: 0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ]
                      : null,
                ),
                child: Center(
                  child: Text(
                    locale.value.createTestOrder,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.1,
                      color: controller.selectedTests.isNotEmpty
                          ? Colors.white
                          : secondaryTextColor,
                    ),
                  ),
                ),
              ),
            )),
            16.height,
          ],
        ).paddingTop(16),
      ),
    );
  }

  Widget _buildSelectedTestItem(LabTest test) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDarkMode.value ? surfaceElevatedDark : surfaceElevated,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: isDarkMode.value ? softShadowColorDark : softShadowColor,
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  test.name,
                  style: GoogleFonts.outfit(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.3,
                    color: isDarkMode.value ? Colors.white : primaryTextColor,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                4.height,
                PriceWidget(
                  price: test.defaultPrice,
                  size: 13,
                  color: appColorSecondary,
                ),
              ],
            ),
          ),
          8.width,
          GestureDetector(
            onTap: () => controller.removeTest(test),
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: labStatusCancelledColor.withValues(alpha: 0.1),
              ),
              child: const Icon(
                Icons.close,
                size: 18,
                color: labStatusCancelledColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.outfit(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.3,
        color: isDarkMode.value ? Colors.white : primaryTextColor,
      ),
    );
  }
}
