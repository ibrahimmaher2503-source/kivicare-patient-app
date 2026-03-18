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

class CreateRequestServiceScreen extends StatelessWidget {
  CreateRequestServiceScreen({super.key});

  final CreateRequestServiceController controller = Get.put(CreateRequestServiceController());
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

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

                        // Section: Service Details
                        Text(
                          locale.value.requestService,
                          style: GoogleFonts.outfit(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            letterSpacing: -0.3,
                            color: isDarkMode.value ? Colors.white : primaryTextColor,
                          ),
                        ),
                        16.height,

                        // Name (required)
                        AppTextField(
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
                            hintText: locale.value.name,
                            fillColor: isDarkMode.value ? inputFillColorDark : inputFillColor,
                            filled: true,
                          ),
                        ),
                        16.height,

                        // Description (optional, multiline)
                        AppTextField(
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
                          ),
                        ),
                        16.height,

                        // Type (optional)
                        AppTextField(
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
                            hintText: locale.value.type,
                            fillColor: isDarkMode.value ? inputFillColorDark : inputFillColor,
                            filled: true,
                          ),
                        ),
                        16.height,
                      ],
                    ).paddingSymmetric(horizontal: 16),
                  ),
                ),
              ),

              // Submit Button
              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: GestureDetector(
                    onTap: () async {
                      if (formKey.currentState!.validate()) {
                        await controller.submitRequest();
                      }
                    },
                    child: Container(
                      width: Get.width,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: [gradientSecondaryStart, gradientSecondaryEnd]),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: appColorSecondary.withValues(alpha: 0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Text(
                        locale.value.submit,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.1,
                          color: Colors.white,
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
