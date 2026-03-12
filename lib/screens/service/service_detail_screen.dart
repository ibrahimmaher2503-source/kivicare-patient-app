import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kivicare_patient/screens/service/service_list_controller.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../components/app_custom_dialog.dart';
import '../../components/app_scaffold.dart';
import '../../components/cached_image_widget.dart';
import '../../components/loader_widget.dart';
import '../../main.dart';
import '../../utils/app_common.dart';
import '../../utils/colors.dart';
import '../../utils/constants.dart';
import '../../utils/empty_error_state_widget.dart';
import '../../utils/price_widget.dart';
import '../clinic/clinic_detail_screen.dart';
import '../clinic/clinics_list_screen.dart';
import '../clinic/model/clinic_detail_model.dart';
import '../clinic/model/clinics_res_model.dart';
import '../doctor/doctor_list_screen.dart';
import 'components/service_detail_clinics_component.dart';
import 'service_detail_controller.dart';

class ServiceDetailScreen extends StatelessWidget {
  final bool isFromClinicDetail;

  ServiceDetailScreen({super.key, this.isFromClinicDetail = false});

  final ServiceDetailController serviceDetailController = Get.put(ServiceDetailController());

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return AppScaffoldNew(
        isLoading: serviceDetailController.isLoading,
        appBartitleText: serviceDetailController.serviceData.value.name,
        appBarVerticalSize: Get.height * 0.12,
        body: RefreshIndicator(
          onRefresh: () {
            return serviceDetailController.init(showLoader: false);
          },
          child: Obx(
            () => SnapHelperWidget(
              future: serviceDetailController.getServiceDetails.value,
              errorBuilder: (error) {
                return NoDataWidget(
                  title: error,
                  retryText: locale.value.reload,
                  imageWidget: const ErrorStateWidget(),
                  onRetry: () {
                    serviceDetailController.init();
                  },
                ).paddingSymmetric(horizontal: 16);
              },
              loadingWidget: const LoaderWidget(),
              onSuccess: (serviceDetailRes) {
                return AnimatedScrollView(
                  listAnimationType: ListAnimationType.FadeIn,
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.only(top: 16, bottom: 80),
                  children: [
                    // Service image with rounded corners
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: isDarkMode.value ? softShadowColorDark : softShadowColor,
                            blurRadius: 16,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Hero(
                          tag: serviceDetailController.serviceData.value.serviceImage.trim().isNotEmpty
                              ? "${serviceDetailController.serviceData.value.id}${serviceDetailController.serviceData.value.serviceImage}"
                              : UniqueKey(),
                          child: CachedImageWidget(
                            url: serviceDetailController.serviceData.value.serviceImage,
                            fit: BoxFit.cover,
                            width: Get.width,
                            height: 230,
                          ),
                        ),
                      ),
                    ),
                    20.height,
                    // Service info card
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16),
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
                          Text(
                            serviceDetailController.serviceData.value.name,
                            style: GoogleFonts.outfit(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.3,
                              color: isDarkMode.value ? Colors.white : primaryTextColor,
                            ),
                          ),
                          12.height,
                          // Category chip
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: isDarkMode.value
                                  ? appColorSecondary.withValues(alpha: 0.12)
                                  : lightSecondaryColor,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  '${locale.value.category} : ',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 12,
                                    color: secondaryTextColor,
                                    letterSpacing: 0.1,
                                  ),
                                ),
                                Text(
                                  serviceDetailController.serviceData.value.categoryName,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: appColorSecondary,
                                    letterSpacing: 0.1,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          16.height,
                          // Price section with teal accent
                          Marquee(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                if (serviceDetailController.serviceData.value.charges != serviceDetailController.serviceData.value.payableAmount)
                                  PriceWidget(
                                    price: serviceDetailController.serviceData.value.payableAmount,
                                    size: 22,
                                    color: appColorSecondary,
                                  ).paddingRight(8),
                                if (!serviceDetailController.serviceData.value.isInclusiveTaxesAvailable)
                                  PriceWidget(
                                    price: serviceDetailController.serviceData.value.charges,
                                    isLineThroughEnabled: serviceDetailController.serviceData.value.isDiscount ? true : false,
                                    size: serviceDetailController.serviceData.value.isDiscount ? 14 : 22,
                                    color: serviceDetailController.serviceData.value.isDiscount ? textSecondaryColorGlobal : appColorSecondary,
                                  ),
                                if (serviceDetailController.serviceData.value.isDiscount)
                                  if (serviceDetailController.serviceData.value.discountType == TaxType.PERCENTAGE)
                                    Container(
                                      margin: const EdgeInsets.only(left: 8),
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: completedStatusColor.withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        '${serviceDetailController.serviceData.value.discountValue}%  ${locale.value.off}',
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w700,
                                          color: completedStatusColor,
                                        ),
                                      ),
                                    )
                                  else if (serviceDetailController.serviceData.value.discountType == TaxType.FIXED)
                                    PriceWidget(
                                      price: serviceDetailController.serviceData.value.discountValue,
                                      color: greenColor,
                                      size: 14,
                                      isDiscountedPrice: true,
                                    ).paddingLeft(6),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (serviceDetailController.serviceData.value.isInclusiveTaxesAvailable) ...[
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Text(
                          locale.value.includesInclusiveTax,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            color: appColorSecondary,
                            fontStyle: FontStyle.italic,
                            letterSpacing: 0.1,
                          ),
                        ),
                      ),
                    ],
                    // Description section
                    if (serviceDetailController.serviceData.value.description.isNotEmpty) ...[
                      24.height,
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 16),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isDarkMode.value ? surfaceElevatedDark : surfaceSubtle,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Description',
                              style: GoogleFonts.outfit(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                letterSpacing: -0.3,
                                color: isDarkMode.value ? Colors.white : primaryTextColor,
                              ),
                            ),
                            8.height,
                            Text(
                              serviceDetailController.serviceData.value.description,
                              textAlign: TextAlign.justify,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 13,
                                color: secondaryTextColor,
                                letterSpacing: 0.1,
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    ServiceDetailClinicsComponent(
                      serviceDetailController: serviceDetailController,
                      onCardTap: (clinicData) {
                        if (clinicData.id == serviceDetailController.selectedClinic.value.id) {
                          serviceDetailController.selectedClinic(Clinic(clinicSession: ClinicSession()));
                          currentSelectedClinic(serviceDetailController.selectedClinic.value);
                        } else {
                          serviceDetailController.selectedClinic(clinicData);
                          currentSelectedClinic(serviceDetailController.selectedClinic.value);
                        }
                      },
                      onClickViewDetail: (clinicData) {
                        currentSelectedClinic(clinicData);
                        Get.delete<ServiceListController>();
                        Get.to(() => ClinicDetailScreen(), arguments: clinicData);
                      },
                    ),
                    32.height,
                  ],
                );
              },
            ),
          ),
        ),
        widgetsStackedOverBody: [
          Positioned(
            bottom: 16,
            width: Get.width,
            child: GestureDetector(
              onTap: () {
                if (isFromClinicDetail) {
                  showInDialog(
                    context,
                    contentPadding: EdgeInsets.zero,
                    builder: (context) {
                      return AppCustomDialog(
                        title: locale.value.doYouWantToReplaceThePreviousServiceWithTheCu,
                        negativeText: locale.value.no,
                        positiveText: locale.value.yes,
                        onTap: () {
                          currentSelectedService(serviceDetailController.serviceData.value);
                          Get.back();
                          Get.to(() => DoctorsListScreen(), arguments: currentSelectedClinic.value.id);
                        },
                      );
                    },
                  );
                } else {
                  currentSelectedService(serviceDetailController.serviceData.value);

                  if (!currentSelectedClinic.value.id.isNegative) {
                    Get.to(() => DoctorsListScreen(), arguments: currentSelectedClinic.value.id);
                  } else {
                    Get.to(() => ClinicListScreen(), arguments: serviceDetailController.serviceData.value);
                  }
                }
              },
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.symmetric(vertical: 16),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [gradientSecondaryStart, gradientSecondaryEnd]),
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
                  locale.value.bookNow,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: 0.1,
                  ),
                ),
              ),
            ),
          )
        ],
      );
    });
  }
}
