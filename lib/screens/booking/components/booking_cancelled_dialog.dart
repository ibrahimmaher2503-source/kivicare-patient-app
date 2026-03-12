import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kivicare_patient/generated/assets.dart';
import 'package:kivicare_patient/main.dart';
import 'package:kivicare_patient/screens/booking/model/appointments_res_model.dart';
import 'package:kivicare_patient/utils/app_common.dart';
import 'package:kivicare_patient/utils/colors.dart';
import 'package:nb_utils/nb_utils.dart';

class BookingCancelledDialog extends StatelessWidget {
  final AppointmentData status;
  final String? currentStatus;

  const BookingCancelledDialog({
    super.key,
    required this.status,
    this.currentStatus,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: context.width(),
          decoration: BoxDecoration(
            color: isDarkMode.value ? surfaceElevatedDark : surfaceElevated,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
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
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    16.height,
                    /// Icon with gradient circle background
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            completedStatusColor.withValues(alpha: 0.15),
                            completedStatusColor.withValues(alpha: 0.05),
                          ],
                        ),
                        border: Border.all(
                          color: completedStatusColor.withValues(alpha: 0.2),
                          width: 1,
                        ),
                      ),
                      child: Center(
                        child: Image.asset(Assets.iconsIcCheck, height: 40),
                      ),
                    ),
                    24.height,
                    Text(
                      locale.value.yourAppointmentHasBeenSuccessfullyCancelled,
                      style: GoogleFonts.outfit(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.3,
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    8.height,
                    Text(
                      locale.value.appointmentRefundWillBeProcessedWithingHoursIfApplicable,
                      textAlign: TextAlign.center,
                      style: secondaryTextStyle(size: 13),
                    ),
                    24.height,
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: appColorSecondary.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: appColorSecondary.withValues(alpha: 0.3), width: 1),
                      ),
                      child: Text(
                        locale.value.noteCheckYourAppointmentHistoryForRefundDetailsIfApplicable,
                        style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w600, color: appColorSecondary),
                      ),
                    ),
                    32.height,
                    GestureDetector(
                      onTap: () {
                        finish(context, true);
                      },
                      child: Container(
                        width: context.width() * 0.5,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [gradientSecondaryStart, gradientSecondaryEnd],
                          ),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: gradientSecondaryStart.withValues(alpha: 0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Text(
                          locale.value.ok,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white),
                        ),
                      ),
                    ),
                    16.height,
                  ],
                ).paddingAll(16),
              ],
            ),
          ),
        ),
      ],
    );
  }
}