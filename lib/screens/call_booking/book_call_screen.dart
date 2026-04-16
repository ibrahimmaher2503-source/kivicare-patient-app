import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../components/app_scaffold.dart';
import '../../components/loader_widget.dart';
import '../../main.dart';
import '../../utils/app_common.dart';
import '../../utils/colors.dart';
import '../../utils/constants.dart';
import '../../utils/price_widget.dart';
import 'book_call_controller.dart';
import 'call_booking_list_screen.dart';
import 'components/time_slot_chip.dart';
import 'model/call_booking_model.dart';
import 'model/call_doctor_model.dart';

class BookCallScreen extends StatefulWidget {
  final CallDoctor doctor;
  final CallService service;

  const BookCallScreen({
    super.key,
    required this.doctor,
    required this.service,
  });

  @override
  State<BookCallScreen> createState() => _BookCallScreenState();
}

class _BookCallScreenState extends State<BookCallScreen> {
  late final BookCallController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.put(BookCallController());
    controller.initWith(widget.doctor, widget.service);
  }

  @override
  void dispose() {
    Get.delete<BookCallController>();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffoldNew(
      appBartitleText: locale.value.videoConsult,
      appBarVerticalSize: Get.mediaQuery.size.height * 0.12,
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      16.height,

                      // Section 1: Selected Service (read-only info card)
                      _buildSectionHeader(
                        icon: Icons.medical_services_outlined,
                        title: locale.value.callServices,
                      ),
                      12.height,
                      _buildServiceInfoCard(),
                      24.height,

                      // Section 2: Select Date
                      _buildSectionHeader(
                        icon: Icons.calendar_today_outlined,
                        title: locale.value.selectDate,
                      ),
                      12.height,
                      Obx(() => _buildDatePicker()),
                      24.height,

                      // Section 3: Available Time Slots
                      _buildSectionHeader(
                        icon: Icons.access_time_outlined,
                        title: locale.value.availableSlots,
                      ),
                      12.height,
                      Obx(() => _buildTimeSlotsSection()),
                      24.height,

                      // Section 4: Payment Method
                      _buildSectionHeader(
                        icon: Icons.payment_outlined,
                        title: locale.value.paymentMethodLabel,
                      ),
                      12.height,
                      Obx(() => _buildPaymentMethodSection()),
                      24.height,

                      // Section 5: Booking Summary
                      Obx(() {
                        if (controller.selectedDate.value != null && controller.selectedSlot.value != null) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildSectionHeader(
                                icon: Icons.summarize_outlined,
                                title: locale.value.bookingDetailsLabel,
                              ),
                              12.height,
                              _buildBookingSummary(),
                              24.height,
                            ],
                          );
                        }
                        return const SizedBox.shrink();
                      }),
                    ],
                  ).paddingSymmetric(horizontal: 16),
                ),
              ),

              // Confirm Button
              Obx(() => _buildConfirmButton()),
            ],
          ),
          Obx(() => const LoaderWidget().visible(controller.isBooking.value)),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Section Header
  // ---------------------------------------------------------------------------
  Widget _buildSectionHeader({required IconData icon, required String title}) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: appColorSecondary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: appColorSecondary, size: 20),
        ),
        12.width,
        Expanded(
          child: Text(
            title,
            style: GoogleFonts.outfit(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.3,
              color: isDarkMode.value ? Colors.white : primaryTextColor,
            ),
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Section 1: Service Info Card
  // ---------------------------------------------------------------------------
  Widget _buildServiceInfoCard() {
    final service = widget.service;
    final isVideo = service.callType.toLowerCase() == 'video';

    return Container(
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
          // Service name
          Text(
            service.name,
            style: GoogleFonts.outfit(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.3,
              color: isDarkMode.value ? Colors.white : primaryTextColor,
            ),
          ),
          12.height,

          // Call type badge + duration
          Row(
            children: [
              // Call type badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: (isVideo ? callTypeVideoColor : callTypePhoneColor).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isVideo ? Icons.videocam_rounded : Icons.phone_rounded,
                      size: 14,
                      color: isVideo ? callTypeVideoColor : callTypePhoneColor,
                    ),
                    6.width,
                    Text(
                      isVideo ? locale.value.videoCallLabel : locale.value.phoneCallLabel,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.1,
                        color: isVideo ? callTypeVideoColor : callTypePhoneColor,
                      ),
                    ),
                  ],
                ),
              ),
              12.width,

              // Duration
              Icon(Icons.schedule_rounded, size: 14, color: secondaryTextColor),
              4.width,
              Text(
                '${service.durationMin} min',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.1,
                  color: secondaryTextColor,
                ),
              ),
            ],
          ),
          12.height,

          // Pricing
          Row(
            children: [
              // Show original price with strikethrough if discount exists
              if (service.discount > 0 && service.charges != service.finalPrice) ...[
                PriceWidget(
                  price: service.charges,
                  size: 14,
                  isBoldText: false,
                  color: secondaryTextColor,
                  isLineThroughEnabled: true,
                ),
                8.width,
              ],
              PriceWidget(
                price: service.finalPrice,
                size: 20,
                color: appColorSecondary,
              ),
              if (service.discount > 0) ...[
                8.width,
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4CAF50).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '-${service.discount}%',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.1,
                      color: const Color(0xFF4CAF50),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Section 2: Date Picker
  // ---------------------------------------------------------------------------
  Widget _buildDatePicker() {
    final selectedDate = controller.selectedDate.value;
    final dateText = selectedDate != null
        ? DateFormat(DateFormatConst.D_MMMM_yyyy).format(selectedDate)
        : locale.value.selectDate;

    return GestureDetector(
      onTap: () async {
        final now = DateTime.now();
        final picked = await showDatePicker(
          context: context,
          initialDate: selectedDate ?? now,
          firstDate: now,
          lastDate: now.add(const Duration(days: 90)),
          builder: (context, child) {
            return Theme(
              data: Theme.of(context).copyWith(
                colorScheme: isDarkMode.value
                    ? const ColorScheme.dark(
                        primary: appColorSecondary,
                        onPrimary: Colors.white,
                        surface: surfaceElevatedDark,
                        onSurface: Colors.white,
                      )
                    : const ColorScheme.light(
                        primary: appColorSecondary,
                        onPrimary: Colors.white,
                        surface: surfaceElevated,
                        onSurface: primaryTextColor,
                      ),
              ),
              child: child!,
            );
          },
        );
        if (picked != null) {
          controller.fetchSlots(picked);
        }
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isDarkMode.value ? inputFillColorDark : inputFillColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selectedDate != null
                ? appColorSecondary.withValues(alpha: 0.3)
                : (isDarkMode.value ? borderColorDark : borderColor),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.calendar_today_outlined,
              size: 20,
              color: selectedDate != null ? appColorSecondary : secondaryTextColor,
            ),
            12.width,
            Expanded(
              child: Text(
                dateText,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  fontWeight: selectedDate != null ? FontWeight.w600 : FontWeight.w500,
                  letterSpacing: 0.1,
                  color: selectedDate != null
                      ? (isDarkMode.value ? Colors.white : primaryTextColor)
                      : secondaryTextColor,
                ),
              ),
            ),
            Icon(
              Icons.arrow_drop_down_rounded,
              color: secondaryTextColor,
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Section 3: Time Slots
  // ---------------------------------------------------------------------------
  Widget _buildTimeSlotsSection() {
    // No date selected yet
    if (controller.selectedDate.value == null) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Text(
          locale.value.selectDate,
          textAlign: TextAlign.center,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 13,
            letterSpacing: 0.1,
            color: secondaryTextColor,
          ),
        ),
      );
    }

    // Loading
    if (controller.isLoadingSlots.value) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: const Center(child: LoaderWidget()),
      );
    }

    // No slots available
    if (controller.availableSlots.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
        decoration: BoxDecoration(
          color: isDarkMode.value ? surfaceElevatedDark : surfaceElevated,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: isDarkMode.value ? softShadowColorDark : softShadowColor,
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(
              Icons.event_busy_rounded,
              size: 40,
              color: secondaryTextColor.withValues(alpha: 0.5),
            ),
            12.height,
            Text(
              locale.value.noSlotsAvailable,
              style: GoogleFonts.outfit(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                letterSpacing: -0.3,
                color: isDarkMode.value ? Colors.white : primaryTextColor,
              ),
            ),
            4.height,
            Text(
              locale.value.tryAnotherDate,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                letterSpacing: 0.1,
                color: secondaryTextColor,
              ),
            ),
          ],
        ),
      );
    }

    // Slots available — Wrap of TimeSlotChip widgets
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: controller.availableSlots.map((slot) {
        final isSelected = controller.selectedSlot.value?.value == slot.value;
        return TimeSlotChip(
          label: slot.label,
          isSelected: isSelected,
          onTap: () => controller.selectSlot(slot),
        );
      }).toList(),
    );
  }

  // ---------------------------------------------------------------------------
  // Section 4: Payment Method
  // ---------------------------------------------------------------------------
  Widget _buildPaymentMethodSection() {
    final options = ['cash'];
    final labels = [locale.value.cashLabel];

    return Row(
      children: List.generate(options.length, (index) {
        final isSelected = controller.paymentMethod.value == options[index];
        return Expanded(
          child: GestureDetector(
            onTap: () => controller.paymentMethod(options[index]),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(vertical: 12),
              margin: EdgeInsets.only(
                right: index < options.length - 1 ? 8 : 0,
                left: index > 0 ? 8 : 0,
              ),
              decoration: BoxDecoration(
                color: isSelected
                    ? appColorSecondary.withValues(alpha: 0.12)
                    : (isDarkMode.value ? inputFillColorDark : inputFillColor),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected ? appColorSecondary : (isDarkMode.value ? borderColorDark : borderColor),
                  width: isSelected ? 1.5 : 1,
                ),
              ),
              child: Text(
                labels[index],
                textAlign: TextAlign.center,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  letterSpacing: 0.1,
                  color: isSelected ? appColorSecondary : secondaryTextColor,
                ),
              ),
            ),
          ),
        );
      }),
    );
  }

  // ---------------------------------------------------------------------------
  // Section 5: Booking Summary
  // ---------------------------------------------------------------------------
  Widget _buildBookingSummary() {
    final doctor = widget.doctor;
    final service = widget.service;
    final date = controller.selectedDate.value!;
    final slot = controller.selectedSlot.value!;

    return Container(
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
          _buildSummaryRow(locale.value.doctor, doctor.fullName.isNotEmpty ? doctor.fullName : '${doctor.firstName} ${doctor.lastName}'.trim()),
          _buildSummaryRow(locale.value.serviceNameLabel, service.name),
          _buildSummaryRow(locale.value.appointmentDateLabel, DateFormat(DateFormatConst.D_MMMM_yyyy).format(date)),
          _buildSummaryRow(locale.value.appointmentTimeLabel, slot.label),
          _buildSummaryRowWidget(locale.value.totalAmountLabel, PriceWidget(
            price: service.finalPrice,
            size: 14,
            isSemiBoldText: true,
            isBoldText: false,
            color: isDarkMode.value ? Colors.white : primaryTextColor,
          )),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                letterSpacing: 0.1,
                color: secondaryTextColor,
              ),
            ),
          ),
          8.width,
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.1,
                color: isDarkMode.value ? Colors.white : primaryTextColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRowWidget(String label, Widget valueWidget) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                letterSpacing: 0.1,
                color: secondaryTextColor,
              ),
            ),
          ),
          8.width,
          Expanded(child: valueWidget),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Confirm Button
  // ---------------------------------------------------------------------------
  Widget _buildConfirmButton() {
    final isEnabled = controller.selectedDate.value != null &&
        controller.selectedSlot.value != null &&
        !controller.isBooking.value;

    return Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GestureDetector(
          onTap: isEnabled
              ? () async {
                  final booking = await controller.confirmBooking();
                  if (booking != null) {
                    _showBookingConfirmationDialog(booking);
                  }
                }
              : null,
          child: AnimatedOpacity(
            opacity: isEnabled ? 1.0 : 0.5,
            duration: const Duration(milliseconds: 200),
            child: Container(
              width: Get.width,
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [gradientSecondaryStart, gradientSecondaryEnd]),
                borderRadius: BorderRadius.circular(12),
                boxShadow: isEnabled
                    ? [
                        BoxShadow(
                          color: appColorSecondary.withValues(alpha: 0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : [],
              ),
              child: Text(
                locale.value.confirmBooking,
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
    );
  }

  // ---------------------------------------------------------------------------
  // T028: Booking Confirmation Dialog
  // ---------------------------------------------------------------------------
  void _showBookingConfirmationDialog(CallBooking booking) {
    final service = widget.service;
    final isVideo = (booking.callType.isNotEmpty ? booking.callType : service.callType).toLowerCase() == 'video';
    final hasMeetingLink = booking.meetingLink.isNotEmpty;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return Dialog(
          backgroundColor: isDarkMode.value ? surfaceElevatedDark : surfaceElevated,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Success icon
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        const Color(0xFF4CAF50).withValues(alpha: 0.15),
                        appColorSecondary.withValues(alpha: 0.08),
                      ],
                    ),
                  ),
                  child: const Icon(
                    Icons.check_circle_rounded,
                    color: Color(0xFF4CAF50),
                    size: 40,
                  ),
                ),
                16.height,

                // Title
                Text(
                  locale.value.bookingConfirmed,
                  style: GoogleFonts.outfit(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.3,
                    color: isDarkMode.value ? Colors.white : primaryTextColor,
                  ),
                ),
                20.height,

                // Details
                _buildDialogRow(
                  locale.value.appointmentDateLabel,
                  booking.appointmentDate.isNotEmpty
                      ? _formatDate(booking.appointmentDate)
                      : (controller.selectedDate.value != null
                          ? DateFormat(DateFormatConst.D_MMMM_yyyy).format(controller.selectedDate.value!)
                          : ''),
                ),
                _buildDialogRow(
                  locale.value.appointmentTimeLabel,
                  booking.appointmentTime.isNotEmpty
                      ? booking.appointmentTime
                      : (controller.selectedSlot.value?.label ?? ''),
                ),
                _buildDialogRow(
                  locale.value.callTypeLabel,
                  isVideo ? locale.value.videoCallLabel : locale.value.phoneCallLabel,
                ),
                _buildDialogRow(
                  locale.value.durationMinLabel,
                  '${booking.duration > 0 ? booking.duration : service.durationMin} min',
                ),
                _buildDialogRowWidget(
                  locale.value.totalAmountLabel,
                  PriceWidget(
                    price: booking.totalAmount > 0 ? booking.totalAmount : service.finalPrice,
                    size: 13,
                    isSemiBoldText: true,
                    isBoldText: false,
                    color: isDarkMode.value ? Colors.white : primaryTextColor,
                  ),
                ),

                // Meeting link section for video calls
                if (isVideo && hasMeetingLink) ...[
                  16.height,
                  GestureDetector(
                    onTap: () async {
                      final uri = Uri.tryParse(booking.meetingLink);
                      if (uri != null) {
                        await launchUrl(uri, mode: LaunchMode.externalApplication);
                      }
                    },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: callTypeVideoColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: callTypeVideoColor.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.videocam_rounded, color: callTypeVideoColor, size: 20),
                          8.width,
                          Text(
                            locale.value.joinCall,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.1,
                              color: callTypeVideoColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
                24.height,

                // View My Bookings button
                GestureDetector(
                  onTap: () {
                    Navigator.pop(ctx);
                    Get.off(() => const CallBookingListScreen());
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 14),
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
                      locale.value.myCallBookings,
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
                12.height,

                // Done button
                GestureDetector(
                  onTap: () {
                    Navigator.pop(ctx);
                    Get.back();
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: isDarkMode.value ? inputFillColorDark : inputFillColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isDarkMode.value ? borderColorDark : borderColor,
                      ),
                    ),
                    child: Text(
                      locale.value.done,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.1,
                        color: isDarkMode.value ? Colors.white : primaryTextColor,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDialogRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                letterSpacing: 0.1,
                color: secondaryTextColor,
              ),
            ),
          ),
          6.width,
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.1,
                color: isDarkMode.value ? Colors.white : primaryTextColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDialogRowWidget(String label, Widget valueWidget) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                letterSpacing: 0.1,
                color: secondaryTextColor,
              ),
            ),
          ),
          6.width,
          Expanded(child: valueWidget),
        ],
      ),
    );
  }

  String _formatDate(String rawDate) {
    final parsed = DateTime.tryParse(rawDate);
    if (parsed == null) return rawDate;
    return DateFormat(DateFormatConst.D_MMMM_yyyy).format(parsed.toLocal());
  }
}
