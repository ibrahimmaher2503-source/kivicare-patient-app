import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../components/app_scaffold.dart';
import '../../components/loader_widget.dart';
import '../../main.dart';
import '../../utils/app_common.dart';
import '../../utils/colors.dart';
import '../../utils/constants.dart';
import '../../utils/price_widget.dart';
import '../call_booking/components/time_slot_chip.dart';
import 'book_independent_controller.dart';
import 'independent_booking_list_screen.dart';
import 'model/independent_booking_model.dart';
import 'model/independent_doctor_model.dart';

class BookIndependentScreen extends StatefulWidget {
  final IndependentDoctor doctor;
  final IndependentService service;

  const BookIndependentScreen({
    super.key,
    required this.doctor,
    required this.service,
  });

  @override
  State<BookIndependentScreen> createState() => _BookIndependentScreenState();
}

class _BookIndependentScreenState extends State<BookIndependentScreen> {
  late final BookIndependentController controller;

  static const Color _accentColor = Color(0xFF00897B);

  @override
  void initState() {
    super.initState();
    controller = Get.put(BookIndependentController());
    controller.initWith(widget.doctor, widget.service);
  }

  @override
  void dispose() {
    Get.delete<BookIndependentController>();
    super.dispose();
  }

  double get _finalPrice {
    final service = widget.service;
    if (service.discount > 0) {
      return service.charges - (service.charges * service.discount / 100);
    }
    return service.charges;
  }

  List<Map<String, dynamic>> get _taxes {
    final service = widget.service;
    if (service.isInclusiveTax == 1 && service.inclusiveTax.isNotEmpty) {
      try {
        return List<Map<String, dynamic>>.from(jsonDecode(service.inclusiveTax));
      } catch (_) {
        return [];
      }
    }
    return [];
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffoldNew(
      appBartitleText: locale.value.bookADoctor,
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
                        title: locale.value.independentServices,
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
                                title: locale.value.pricingBreakdownLabel,
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
            color: _accentColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: _accentColor, size: 20),
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

          // In-person badge + duration + slot interval
          Row(
            children: [
              // In-person badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _accentColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.person_pin_rounded, size: 14, color: _accentColor),
                    6.width,
                    Text(
                      locale.value.inPersonConsultation,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.1,
                        color: _accentColor,
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

          if (service.timeSlot > 0) ...[
            8.height,
            Row(
              children: [
                Icon(Icons.timelapse_rounded, size: 14, color: secondaryTextColor),
                4.width,
                Text(
                  '${service.timeSlot} min ${locale.value.slotIntervalLabel.toLowerCase()}',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.1,
                    color: secondaryTextColor,
                  ),
                ),
              ],
            ),
          ],
          12.height,

          // Pricing with tax breakdown
          _buildServicePricing(service),
        ],
      ),
    );
  }

  Widget _buildServicePricing(IndependentService service) {
    final hasDiscount = service.discount > 0;
    final taxes = _taxes;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            // Show original price with strikethrough if discount exists
            if (hasDiscount && service.charges != _finalPrice) ...[
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
              price: _finalPrice,
              size: 20,
              color: appColorSecondary,
            ),
            if (hasDiscount) ...[
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

        // Tax info
        if (service.isInclusiveTax == 1) ...[
          8.height,
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: _accentColor.withValues(alpha: 0.1),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.receipt_long_rounded, size: 12, color: _accentColor),
                    4.width,
                    Text(
                      locale.value.taxIncludedLabel,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.1,
                        color: _accentColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (taxes.isNotEmpty) ...[
            6.height,
            ...taxes.map((tax) {
              final title = tax['title'] ?? '';
              final type = tax['type'] ?? '';
              final value = tax['value'] ?? 0;
              final suffix = type == 'percent' ? ' ($value%)' : '';
              return Padding(
                padding: const EdgeInsets.only(left: 4, bottom: 2),
                child: Text(
                  '$title$suffix',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    letterSpacing: 0.1,
                    color: secondaryTextColor,
                  ),
                ),
              );
            }),
          ],
        ],
      ],
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
                    ? ColorScheme.dark(
                        primary: _accentColor,
                        onPrimary: Colors.white,
                        surface: surfaceElevatedDark,
                        onSurface: Colors.white,
                      )
                    : ColorScheme.light(
                        primary: _accentColor,
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
                ? _accentColor.withValues(alpha: 0.3)
                : (isDarkMode.value ? borderColorDark : borderColor),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.calendar_today_outlined,
              size: 20,
              color: selectedDate != null ? _accentColor : secondaryTextColor,
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

    // Slots available - Wrap of TimeSlotChip widgets (IMPORTED from call_booking)
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
                    ? _accentColor.withValues(alpha: 0.12)
                    : (isDarkMode.value ? inputFillColorDark : inputFillColor),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected ? _accentColor : (isDarkMode.value ? borderColorDark : borderColor),
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
                  color: isSelected ? _accentColor : secondaryTextColor,
                ),
              ),
            ),
          ),
        );
      }),
    );
  }

  // ---------------------------------------------------------------------------
  // Section 5: Booking Summary with Pricing Breakdown
  // ---------------------------------------------------------------------------
  Widget _buildBookingSummary() {
    final doctor = widget.doctor;
    final service = widget.service;
    final date = controller.selectedDate.value!;
    final slot = controller.selectedSlot.value!;
    final taxes = _taxes;
    final hasDiscount = service.discount > 0;

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
          _buildSummaryRow(locale.value.durationMinLabel, '${service.durationMin} min'),

          // Divider
          Container(
            height: 1,
            margin: const EdgeInsets.symmetric(vertical: 8),
            color: isDarkMode.value ? borderColorDark : borderColor,
          ),

          // Pricing breakdown
          _buildSummaryRowWidget(locale.value.originalPriceLabel, PriceWidget(
            price: service.charges,
            size: 14,
            isSemiBoldText: true,
            isBoldText: false,
            color: isDarkMode.value ? Colors.white : primaryTextColor,
          )),

          if (hasDiscount) ...[
            _buildSummaryRowWidget(
              locale.value.discountLabel,
              Row(
                children: [
                  PriceWidget(
                    price: service.charges - _finalPrice,
                    size: 14,
                    isDiscountedPrice: true,
                    isSemiBoldText: true,
                    isBoldText: false,
                    color: const Color(0xFF4CAF50),
                  ),
                  Text(
                    ' (${service.discount}%)',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.1,
                      color: const Color(0xFF4CAF50),
                    ),
                  ),
                ],
              ),
            ),
          ],

          // Tax items
          if (service.isInclusiveTax == 1 && taxes.isNotEmpty) ...[
            ...taxes.map((tax) {
              final title = tax['title'] ?? '';
              final type = tax['type'] ?? '';
              final value = tax['value'] ?? 0;
              final suffix = type == 'percent' ? ' ($value%)' : '';
              // Calculate tax amount on the final price
              double taxAmount = 0;
              if (type == 'percent') {
                taxAmount = _finalPrice * (value as num).toDouble() / 100;
              } else {
                taxAmount = (value as num).toDouble();
              }
              return _buildSummaryRowWidget(
                '$title$suffix',
                PriceWidget(
                  price: taxAmount,
                  size: 14,
                  isSemiBoldText: true,
                  isBoldText: false,
                  color: secondaryTextColor,
                ),
              );
            }),
          ],

          // Total divider
          Container(
            height: 1,
            margin: const EdgeInsets.symmetric(vertical: 8),
            color: isDarkMode.value ? borderColorDark : borderColor,
          ),

          // Total
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 120,
                  child: Text(
                    locale.value.totalAmountLabel,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.1,
                      color: isDarkMode.value ? Colors.white : primaryTextColor,
                    ),
                  ),
                ),
                8.width,
                Expanded(
                  child: PriceWidget(
                    price: _finalPrice,
                    size: 20,
                    color: _accentColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {Color? valueColor}) {
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
                color: valueColor ?? (isDarkMode.value ? Colors.white : primaryTextColor),
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
                gradient: const LinearGradient(colors: [Color(0xFF00897B), Color(0xFF26A69A)]),
                borderRadius: BorderRadius.circular(12),
                boxShadow: isEnabled
                    ? [
                        BoxShadow(
                          color: _accentColor.withValues(alpha: 0.3),
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
  // Booking Confirmation Dialog (NO meeting link, In-Person label)
  // ---------------------------------------------------------------------------
  void _showBookingConfirmationDialog(IndependentBooking booking) {
    final service = widget.service;

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
                        _accentColor.withValues(alpha: 0.08),
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
                  locale.value.independentBookingConfirmed,
                  style: GoogleFonts.outfit(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.3,
                    color: isDarkMode.value ? Colors.white : primaryTextColor,
                  ),
                  textAlign: TextAlign.center,
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
                  locale.value.inPersonConsultation,
                  locale.value.independentBooking,
                ),
                _buildDialogRow(
                  locale.value.durationMinLabel,
                  '${booking.duration > 0 ? booking.duration : service.durationMin} min',
                ),

                // Pricing breakdown in dialog
                Container(
                  height: 1,
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  color: isDarkMode.value ? borderColorDark : borderColor,
                ),
                _buildDialogRowWidget(
                  locale.value.originalPriceLabel,
                  PriceWidget(
                    price: service.charges,
                    size: 13,
                    isSemiBoldText: true,
                    isBoldText: false,
                    color: isDarkMode.value ? Colors.white : primaryTextColor,
                  ),
                ),
                if (service.discount > 0) ...[
                  _buildDialogRow(
                    locale.value.discountLabel,
                    '-${service.discount}%',
                  ),
                ],
                _buildDialogRowWidget(
                  locale.value.totalAmountLabel,
                  PriceWidget(
                    price: booking.totalAmount > 0 ? booking.totalAmount : _finalPrice,
                    size: 13,
                    isSemiBoldText: true,
                    isBoldText: false,
                    color: isDarkMode.value ? Colors.white : primaryTextColor,
                  ),
                ),

                24.height,

                // View My Bookings button
                GestureDetector(
                  onTap: () {
                    Navigator.pop(ctx);
                    Get.off(() => const IndependentBookingListScreen());
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [Color(0xFF00897B), Color(0xFF26A69A)]),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: _accentColor.withValues(alpha: 0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Text(
                      locale.value.myIndependentBookings,
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
