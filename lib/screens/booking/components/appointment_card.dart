import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kivicare_patient/generated/assets.dart';
import 'package:kivicare_patient/screens/booking/components/cancellations_booking_charge_dialog.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../components/cached_image_widget.dart';
import '../../../../utils/colors.dart';
import '../../../../utils/common_base.dart';
import '../../../main.dart';
import '../../../utils/app_common.dart';
import '../../../utils/constants.dart';
import '../../../utils/price_widget.dart';
import '../appointment_detail_screen.dart';
import '../appointments_controller.dart';
import '../model/appointments_res_model.dart';

class AppointmentCard extends StatelessWidget {
  final VoidCallback? onUpdateBooking;
  final AppointmentData appointment;

  AppointmentCard({
    super.key,
    required this.appointment,
    this.onUpdateBooking,
  });

  final AppointmentsController appointmentsController = Get.find();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        hideKeyboard(context);
        Get.to(() => AppointmentDetail(), arguments: appointment);
      },
      child: Stack(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: context.cardColor,
              borderRadius: BorderRadius.circular(16),
              border: Border(
                left: BorderSide(
                  color: getBookingStatusColor(status: appointment.status),
                  width: 4,
                ),
              ),
              boxShadow: [
                BoxShadow(
                  color: isDarkMode.value ? softShadowColorDark : softShadowColor,
                  spreadRadius: 0,
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
                BoxShadow(
                  color: isDarkMode.value ? softShadowColorDark : softShadowColorMedium,
                  spreadRadius: 0,
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                16.height,
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '${locale.value.appointment} #${appointment.id.toString()}',
                    style: boldTextStyle(size: 14, color: appColorPrimary),
                  ),
                ),
                8.height,
                Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: getBookingStatusColor(status: appointment.status).withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(
                        color: getBookingStatusColor(status: appointment.status).withValues(alpha: 0.15),
                        width: 0.5,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.calendar_today_rounded,
                          size: 13,
                          color: getBookingStatusColor(status: appointment.status),
                        ),
                        6.width,
                        Text(
                          appointment.appointmentDate.dateInDMMMMyyyyFormat,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: getBookingStatusColor(status: appointment.status),
                          ),
                        ),
                        8.width,
                        Container(
                          width: 4,
                          height: 4,
                          decoration: BoxDecoration(
                            color: getBookingStatusColor(status: appointment.status).withValues(alpha: 0.4),
                            shape: BoxShape.circle,
                          ),
                        ),
                        8.width,
                        Icon(
                          Icons.access_time_rounded,
                          size: 13,
                          color: getBookingStatusColor(status: appointment.status),
                        ),
                        4.width,
                        Text(
                          '${appointment.appointmentTime.format24HourtoAMPM} - ${appointment.endTime.format24HourtoAMPM}',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: getBookingStatusColor(status: appointment.status),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                16.height,
                Align(
                  alignment: Alignment.centerLeft,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        appointment.serviceName,
                        style: GoogleFonts.outfit(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.3,
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        appointment.clinicName,
                        style: primaryTextStyle(size: 14, color: secondaryTextColor),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ).paddingTop(8),
                      Text(
                        appointment.appointmentExtraInfo,
                        style: secondaryTextStyle(size: 12),
                      ).paddingTop(6).visible(appointment.appointmentExtraInfo.isNotEmpty),
                    ],
                  ),
                ),
                16.height,
                Align(
                  alignment: Alignment.centerLeft,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            getServiceType(serviceType: appointment.serviceType),
                            style: secondaryTextStyle(size: 12, color: secondaryTextColor),
                          ),
                          6.height,
                          Row(
                            children: [
                              Text(
                                '${locale.value.doctor}:',
                                style: primaryTextStyle(size: 12, color: secondaryTextColor),
                              ),
                              6.width,
                              Text(
                                appointment.doctorName,
                                overflow: TextOverflow.ellipsis,
                                style: boldTextStyle(size: 12),
                              ).expand(),
                            ],
                          ),
                        ],
                      ).expand(),
                      PriceWidget(
                        price: appointment.totalAmount,
                        color: appColorPrimary,
                        size: 18,
                        isBoldText: true,
                      ),
                    ],
                  ),
                ),
                24.height,
                _buildGradientDivider(),
                16.height,
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildStatusChip(
                      label: getBookingStatus(status: appointment.status),
                      color: getBookingStatusColor(status: appointment.status),
                    ),
                    8.width,
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        const CachedImageWidget(url: Assets.iconsIcTotalPayout, height: 15),
                        4.width,
                        Text("${locale.value.payment}:", style: secondaryTextStyle()),
                        4.width,
                        Flexible(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: getPriceStatusColor(paymentStatus: appointment.paymentStatus).withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              getBookingPaymentStatus(status: appointment.paymentStatus),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: getPriceStatusColor(paymentStatus: appointment.paymentStatus),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                if (appointment.bookForName.isNotEmpty) ...[
                  16.height,
                  _buildGradientDivider(),
                  16.height,
                  Row(
                    children: [
                      Text(
                        locale.value.bookedForWithColon,
                        style: secondaryTextStyle(size: 14), // Text style
                      ),
                      10.width,
                      TextIcon(
                        edgeInsets: EdgeInsets.zero,
                        prefix: CachedImageWidget(
                          url: appointment.booForImage,
                          height: 25,
                          width: 25,
                          fit: BoxFit.cover,
                          circle: true,
                        ),
                        text: appointment.bookForName,
                        expandedText: true,
                        useMarquee: true,
                        textStyle: boldTextStyle(),
                      ).expand(flex: 2),
                    ],
                  ),
                ],
                if (appointment.status.contains(StatusConst.pending)) ...[
                  24.height,
                  AppButton(
                    color: isDarkMode.value ? Colors.grey.withValues(alpha: 0.1) : extraLightPrimaryColor,
                    height: 48,
                    width: Get.width,
                    padding: EdgeInsets.zero,
                    shapeBorder: RoundedRectangleBorder(borderRadius: radius(defaultAppButtonRadius / 2)),
                    onTap: () {
                      Get.bottomSheet(
                        isScrollControlled: true,
                        Padding(
                          padding: EdgeInsets.only(
                            bottom: MediaQuery.of(context).viewInsets.bottom,
                          ),
                          child: CancellationsBookingChargeDialog(
                            appointmentData: appointment,
                            isDurationMode: checkTimeDifference(inputDateTime: DateTime.parse(appointment.appointmentDate.validate())),
                            loaderOnOFF: (p0) {
                              appointmentsController.isLoading(p0);
                            },
                            onCancelBooking: () {
                              appointmentsController.getAppointmentList();
                            },
                          ),
                        ),
                      );
                    },
                    text: locale.value.cancel,
                    textStyle: appButtonPrimaryColorText,
                  ),
                ],
                16.height,
              ],
            ),
          ),
          Positioned(
            top: 16,
            right: 16,
            height: 40,
            width: 40,
            child: GestureDetector(
              onTap: () {
                if (canLaunchVideoCall(status: appointment.status)) {
                  if (isOnlineService) {
                    if (appointment.googleLink.isNotEmpty) {
                      commonLaunchUrl(appointment.googleLink, launchMode: LaunchMode.externalApplication);
                    } else if (appointment.zoomLink.isNotEmpty) {
                      commonLaunchUrl(appointment.zoomLink, launchMode: LaunchMode.externalApplication);
                    } else {
                      toast(locale.value.videoCallLinkIsNotFound);
                    }
                  } else {
                    toast(locale.value.thisIsNotAOnlineService);
                  }
                } else {
                  if (appointment.status.toLowerCase().contains(StatusConst.pending)) {
                    toast(locale.value.oppsThisAppointmentIsNotConfirmedYet);
                  } else if (appointment.status.toLowerCase().contains(StatusConst.cancel) || appointment.status.toLowerCase().contains(BookingStatusConst.CANCELLED)) {
                    toast(locale.value.oppsThisAppointmentHasBeenCancelled);
                  } else if (appointment.status.toLowerCase().contains(StatusConst.completed)) {
                    toast(locale.value.oppsThisAppointmentHasBeenCompleted);
                  }
                }
              },
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [gradientSecondaryStart, gradientSecondaryEnd],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: gradientSecondaryStart.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(10),
                child: const CachedImageWidget(
                  url: Assets.imagesVideoCamera,
                  height: 22,
                  width: 22,
                  circle: true,
                  color: white,
                ),
              ),
            ).visible(appointment.isVideoConsultancy),
          ),
        ],
      ),
    );
  }

  Widget _buildGradientDivider() {
    final Color dividerTint = isDarkMode.value
        ? borderColor.withValues(alpha: 0.08)
        : borderColor.withValues(alpha: 0.25);
    return Container(
      height: 1,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.transparent,
            dividerTint,
            dividerTint,
            Colors.transparent,
          ],
          stops: const [0.0, 0.2, 0.8, 1.0],
        ),
      ),
    );
  }

  Widget _buildStatusChip({required String label, required Color color}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color.withValues(alpha: 0.15),
            color.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: color.withValues(alpha: 0.25),
          width: 0.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          6.width,
          Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: color,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }

  bool get isOnlineService => appointment.serviceType.toLowerCase() == ServiceTypeConst.online;
}