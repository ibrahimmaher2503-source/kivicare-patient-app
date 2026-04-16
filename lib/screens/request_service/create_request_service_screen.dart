import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../components/app_scaffold.dart';
import '../../components/loader_widget.dart';
import '../../main.dart';
import '../../utils/app_common.dart';
import '../../utils/colors.dart';
import '../../utils/common_base.dart';
import 'create_request_service_controller.dart';

class CreateRequestServiceScreen extends StatefulWidget {
  const CreateRequestServiceScreen({super.key});

  @override
  State<CreateRequestServiceScreen> createState() => _CreateRequestServiceScreenState();
}

class _CreateRequestServiceScreenState extends State<CreateRequestServiceScreen> {
  late final CreateRequestServiceController controller;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    controller = Get.put(CreateRequestServiceController());
  }

  @override
  void dispose() {
    Get.delete<CreateRequestServiceController>();
    super.dispose();
  }

  Widget _buildSectionLabel(String text, IconData icon) {
    return Row(
      children: [
        Container(
          width: 3,
          height: 20,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [appColorSecondary, appColorAccent],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        10.width,
        Icon(
          icon,
          size: 18,
          color: appColorSecondary,
        ),
        8.width,
        Text(
          text,
          style: GoogleFonts.outfit(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.3,
            color: isDarkMode.value ? Colors.white : primaryTextColor,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffoldNew(
      appBartitleText: locale.value.createServiceRequest,
      appBarVerticalSize: Get.mediaQuery.size.height * 0.12,
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Form(
                    key: formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        16.height,

                        // Decorative gradient header
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                appColorPrimary.withValues(alpha: isDarkMode.value ? 0.25 : 0.06),
                                appColorSecondary.withValues(alpha: isDarkMode.value ? 0.12 : 0.03),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isDarkMode.value
                                  ? Colors.white.withValues(alpha: 0.06)
                                  : appColorPrimary.withValues(alpha: 0.06),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [gradientSecondaryStart, gradientSecondaryEnd],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: appColorSecondary.withValues(alpha: 0.3),
                                      blurRadius: 8,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.add_circle_outline_rounded,
                                  color: Colors.white,
                                  size: 22,
                                ),
                              ),
                              16.width,
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      locale.value.createServiceRequest,
                                      style: GoogleFonts.outfit(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: -0.3,
                                        color: isDarkMode.value ? Colors.white : appColorPrimary,
                                      ),
                                    ),
                                    4.height,
                                    Text(
                                      locale.value.fillDetailsBelow,
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                        color: secondaryTextColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        24.height,

                        // Section: Service Details
                        _buildSectionLabel(locale.value.requestService, Icons.room_service_outlined),
                        16.height,

                        // Name (required) - with focus animation
                        TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0.0, end: 1.0),
                          duration: const Duration(milliseconds: 400),
                          curve: Curves.easeOutCubic,
                          builder: (context, value, child) {
                            return Transform.translate(
                              offset: Offset(0, 10 * (1 - value)),
                              child: Opacity(opacity: value, child: child),
                            );
                          },
                          child: AppTextField(
                            isValidationRequired: true,
                            textStyle: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              letterSpacing: 0.1,
                              color: isDarkMode.value ? Colors.white : primaryTextColor,
                            ),
                            textFieldType: TextFieldType.OTHER,
                            controller: controller.nameCont,
                            focus: controller.nameFocus,
                            nextFocus: controller.descriptionFocus,
                            errorThisFieldRequired: locale.value.thisFieldIsRequired,
                            decoration: inputDecoration(
                              context,
                              hintText: locale.value.serviceName,
                              fillColor: isDarkMode.value ? inputFillColorDark : inputFillColor,
                              filled: true,
                            ).copyWith(
                              prefixIcon: Icon(
                                Icons.badge_outlined,
                                size: 18,
                                color: secondaryTextColor,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: isDarkMode.value
                                      ? Colors.white.withValues(alpha: 0.06)
                                      : appColorPrimary.withValues(alpha: 0.06),
                                  width: 1,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: appColorSecondary,
                                  width: 1.5,
                                ),
                              ),
                            ),
                          ),
                        ),
                        16.height,

                        // Description (optional, multiline)
                        TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0.0, end: 1.0),
                          duration: const Duration(milliseconds: 500),
                          curve: Curves.easeOutCubic,
                          builder: (context, value, child) {
                            return Transform.translate(
                              offset: Offset(0, 10 * (1 - value)),
                              child: Opacity(opacity: value, child: child),
                            );
                          },
                          child: AppTextField(
                            isValidationRequired: false,
                            textStyle: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              letterSpacing: 0.1,
                              color: isDarkMode.value ? Colors.white : primaryTextColor,
                            ),
                            textFieldType: TextFieldType.MULTILINE,
                            controller: controller.descriptionCont,
                            focus: controller.descriptionFocus,
                            nextFocus: controller.typeFocus,
                            maxLength: 500,
                            minLines: 3,
                            decoration: inputDecoration(
                              context,
                              hintText: locale.value.description,
                              fillColor: isDarkMode.value ? inputFillColorDark : inputFillColor,
                              filled: true,
                            ).copyWith(
                              prefixIcon: Padding(
                                padding: const EdgeInsets.only(bottom: 40),
                                child: Icon(
                                  Icons.description_outlined,
                                  size: 18,
                                  color: secondaryTextColor,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: isDarkMode.value
                                      ? Colors.white.withValues(alpha: 0.06)
                                      : appColorPrimary.withValues(alpha: 0.06),
                                  width: 1,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: appColorSecondary,
                                  width: 1.5,
                                ),
                              ),
                            ),
                          ),
                        ),
                        16.height,

                        // Section: Service Type
                        _buildSectionLabel(locale.value.serviceType, Icons.category_outlined),
                        16.height,

                        // Type (optional)
                        TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0.0, end: 1.0),
                          duration: const Duration(milliseconds: 600),
                          curve: Curves.easeOutCubic,
                          builder: (context, value, child) {
                            return Transform.translate(
                              offset: Offset(0, 10 * (1 - value)),
                              child: Opacity(opacity: value, child: child),
                            );
                          },
                          child: AppTextField(
                            isValidationRequired: false,
                            textStyle: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              letterSpacing: 0.1,
                              color: isDarkMode.value ? Colors.white : primaryTextColor,
                            ),
                            textFieldType: TextFieldType.OTHER,
                            controller: controller.typeCont,
                            focus: controller.typeFocus,
                            decoration: inputDecoration(
                              context,
                              hintText: locale.value.serviceType,
                              fillColor: isDarkMode.value ? inputFillColorDark : inputFillColor,
                              filled: true,
                            ).copyWith(
                              prefixIcon: Icon(
                                Icons.label_outline_rounded,
                                size: 18,
                                color: secondaryTextColor,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: isDarkMode.value
                                      ? Colors.white.withValues(alpha: 0.06)
                                      : appColorPrimary.withValues(alpha: 0.06),
                                  width: 1,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: appColorSecondary,
                                  width: 1.5,
                                ),
                              ),
                            ),
                          ),
                        ),
                        16.height,
                      ],
                    ).paddingSymmetric(horizontal: 16),
                  ),
                ),
              ),

              // Submit Button with gradient and glow
              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0.95, end: 1.0),
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.easeOutBack,
                    builder: (context, scaleValue, child) {
                      return Transform.scale(scale: scaleValue, child: child);
                    },
                    child: GestureDetector(
                      onTap: () async {
                        if (formKey.currentState?.validate() ?? false) {
                          await controller.submitRequest();
                        }
                      },
                      child: Container(
                        width: Get.width,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [gradientSecondaryStart, Color(0xFF059E9A), gradientSecondaryEnd],
                            stops: [0.0, 0.5, 1.0],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                              color: appColorSecondary.withValues(alpha: 0.4),
                              blurRadius: 16,
                              offset: const Offset(0, 6),
                              spreadRadius: 0,
                            ),
                            BoxShadow(
                              color: appColorAccent.withValues(alpha: 0.2),
                              blurRadius: 24,
                              offset: const Offset(0, 8),
                              spreadRadius: -4,
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.send_rounded,
                              color: Colors.white,
                              size: 18,
                            ),
                            10.width,
                            Text(
                              locale.value.submit,
                              textAlign: TextAlign.center,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.2,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          Obx(() => const LoaderWidget().visible(controller.isLoading.value)),
        ],
      ),
    );
  }
}
