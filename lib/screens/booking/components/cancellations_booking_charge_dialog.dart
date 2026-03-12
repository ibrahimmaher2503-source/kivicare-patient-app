import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kivicare_patient/api/core_apis.dart';
import 'package:kivicare_patient/generated/assets.dart';
import 'package:kivicare_patient/main.dart';
import 'package:kivicare_patient/screens/booking/components/booking_cancelled_dialog.dart';
import 'package:kivicare_patient/screens/booking/model/appointments_res_model.dart';
import 'package:kivicare_patient/utils/app_common.dart';
import 'package:kivicare_patient/utils/colors.dart';
import 'package:kivicare_patient/utils/common_base.dart';
import 'package:kivicare_patient/utils/constants.dart';
import 'package:kivicare_patient/utils/price_widget.dart';
import 'package:nb_utils/nb_utils.dart';

class CancellationsBookingChargeDialog extends StatelessWidget {
  final AppointmentData appointmentData;
  final bool isDurationMode;

  final Function(bool) loaderOnOFF;

  final VoidCallback onCancelBooking;

  CancellationsBookingChargeDialog({
    super.key,
    required this.appointmentData,
    required this.isDurationMode,
    required this.loaderOnOFF,
    required this.onCancelBooking,
  });

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final TextEditingController textFieldReason = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.9,
          ),
          child: SingleChildScrollView(
            child: Container(
              decoration: BoxDecoration(
                color: isDarkMode.value ? surfaceElevatedDark : surfaceElevated,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
                boxShadow: [
                  BoxShadow(
                    color: isDarkMode.value ? softShadowColorDark : softShadowColorMedium,
                    blurRadius: 20,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  /// Handle indicator
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(top: 12, bottom: 8),
                      decoration: BoxDecoration(
                        color: isDarkMode.value ? Colors.white24 : Colors.black12,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  16.height,
                  /// Icon with gradient circle background
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          cancelStatusColor.withValues(alpha: 0.15),
                          cancelStatusColor.withValues(alpha: 0.05),
                        ],
                      ),
                      border: Border.all(
                        color: cancelStatusColor.withValues(alpha: 0.2),
                        width: 1,
                      ),
                    ),
                    child: Center(
                      child: Image.asset(Assets.iconsIcCancel, height: 32, width: 32),
                    ),
                  ),
                  24.height,
                  Text(
                    locale.value.cancelAppointment,
                    style: GoogleFonts.outfit(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.3,
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                  ),
                  8.height,
                  Text(
                    locale.value.cancellationFeesWillBeAppliedIfYouCancelWithinHoursOfScheduledTime(appConfigs.value.cancellationChargeHours.toString(), appConfigs.value.isCancellationChargeEnabled),
                    textAlign: TextAlign.center,
                    style: secondaryTextStyle(size: 13),
                  ),
                  24.height,
                  if (appConfigs.value.isCancellationChargeEnabled && appointmentData.cancellationChargeAmount > 0) ...[
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isDarkMode.value ? inputFillColorDark : inputFillColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(locale.value.cancellationFee.suffixText(value: ": "), style: boldTextStyle()).expand(),
                          10.width,
                          PriceWidget(price: appointmentData.cancellationChargeAmount, color: cancelStatusColor),
                        ],
                      ),
                    ),
                    24.height,
                  ],
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text: locale.value.reason,
                              style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w600),
                            ),
                            TextSpan(
                              text: "*",
                              style: boldTextStyle(color: redColor, size: 12, weight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),
                      8.height,
                      Form(
                        key: formKey,
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        child: AppTextField(
                          controller: textFieldReason,
                          textFieldType: TextFieldType.MULTILINE,
                          minLines: 1,
                          maxLines: 10,
                          decoration: InputDecoration(
                            labelText: locale.value.reason,
                            hintText: locale.value.hintReason,
                            fillColor: isDarkMode.value ? inputFillColorDark : inputFillColor,
                            filled: true,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: appColorSecondary, width: 1),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  24.height,
                  Row(
                    children: [
                      AppButton(
                        color: isDarkMode.value ? surfaceElevatedDark : surfaceSubtle,
                        height: 48,
                        text: locale.value.goBack,
                        textStyle: boldTextStyle(weight: FontWeight.w600, size: 13),
                        width: MediaQuery.of(context).size.width - context.navigationBarHeight,
                        shapeBorder: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(color: isDarkMode.value ? borderColorDark : whiteBorderColor),
                        ),
                        onTap: () {
                          finish(context);
                        },
                      ).expand(),
                      12.width,
                      GestureDetector(
                        onTap: () {
                          handleClick();
                        },
                        child: Container(
                          height: 48,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [gradientStart, gradientEnd],
                            ),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: gradientStart.withValues(alpha: 0.2),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Text(
                            locale.value.cancelAppointment,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white),
                          ),
                        ),
                      ).expand(),
                    ],
                  ),
                  16.height,
                ],
              ).paddingAll(16),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> updateStatus({required int appointmentId, required String status}) async {
    loaderOnOFF.call(true);
    Map<String, dynamic> req = {
      CancellationStatusKeys.status: appointmentData.status,
      BookingUpdateKeys.startAt: appointmentData.startDateTime,
      BookingUpdateKeys.endAt: formatBookingDate(DateTime.now().toString(), format: DateFormatConst.BOOKING_SAVE_FORMAT, isLanguageNeeded: false),
      BookingUpdateKeys.durationDiff: appointmentData.duration.validate(),
      CancellationStatusKeys.reason: textFieldReason.text,
      CancellationStatusKeys.status: BookingStatusConst.CANCELLED,
      CancellationStatusKeys.advancePaidAmount: appointmentData.advancePaidAmount,
      CancellationStatusKeys.cancellationCharge: appointmentData.cancellationCharges,
      CancellationStatusKeys.cancellationChargeAmount: appointmentData.cancellationChargeAmount,
      CancellationStatusKeys.cancellationType: appointmentData.cancellationType,
      BookingUpdateKeys.paymentStatus: appointmentData.isAdvancePaymentDone ? SERVICE_PAYMENT_STATUS_ADVANCE_PAID : appointmentData.paymentStatus.validate(),
    };

    await CoreServiceApis.updateStatus(request: req, appointmentId: appointmentId).then((value) async {
      await handleBookingCancelledBottomSheet();
      onCancelBooking.call();
    }).catchError((e) {
      toast(e.toString(), print: true);
    }).whenComplete(
      () {
        loaderOnOFF.call(false);
      },
    );
  }

  Future<void> handleBookingCancelledBottomSheet() async {
    Get.bottomSheet(
      backgroundColor: Get.context != null
          ? Get.context!.scaffoldBackgroundColor
          : isDarkMode.value
              ? scaffoldDarkColor
              : scaffoldLightColor,
      BookingCancelledDialog(status: appointmentData),
    );
  }

  Future<void> handleClick() async {
    if (formKey.currentState!.validate()) {
      formKey.currentState!.save();
      if (appointmentData.status == StatusConst.pending || appointmentData.status == StatusConst.hold || appointmentData.status == StatusConst.accepted) {
        Get.back();
        await updateStatus(
          appointmentId: appointmentData.id.validate(),
          status: appointmentData.status.validate(),
        );
      }
    }
  }
}