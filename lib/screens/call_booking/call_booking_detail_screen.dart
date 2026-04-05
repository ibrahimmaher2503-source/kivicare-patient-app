import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../components/app_scaffold.dart';
import '../../main.dart';
import '../../utils/app_common.dart';
import '../../utils/colors.dart';
import '../../utils/constants.dart';
import '../../utils/price_widget.dart';
import 'model/call_booking_model.dart';

class CallBookingDetailScreen extends StatelessWidget {
  final CallBooking booking;

  const CallBookingDetailScreen({
    super.key,
    required this.booking,
  });

  Color get _statusColor {
    switch (booking.status.toLowerCase()) {
      case 'confirmed':
        return callBookingConfirmedColor;
      case 'completed':
        return callBookingCompletedColor;
      case 'cancelled':
        return callBookingCancelledColor;
      case 'pending':
        return pendingStatusColor;
      default:
        return pendingStatusColor;
    }
  }

  String get _statusLabel {
    switch (booking.status.toLowerCase()) {
      case 'confirmed':
        return locale.value.confirm;
      case 'completed':
        return locale.value.completed;
      case 'cancelled':
        return locale.value.cancelled;
      case 'pending':
        return locale.value.pending;
      default:
        return booking.status;
    }
  }

  bool get _isVideo => booking.callType.toLowerCase() == 'video';
  bool get _hasMeetingLink => booking.meetingLink.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return AppScaffoldNew(
        appBartitleText: locale.value.bookingDetailsLabel,
        hasLeadingWidget: true,
        appBarVerticalSize: Get.height * 0.12,
        body: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Gradient Header with status + call type badges
              _buildHeader(),
              20.height,

              // Content sections
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Appointment Section
                    _buildSectionTitle(locale.value.appointmentDateLabel),
                    12.height,
                    _buildInfoContainer(children: [
                      _buildInfoRow(locale.value.appointmentDateLabel, _formatDate(booking.appointmentDate)),
                      _buildInfoRow(locale.value.appointmentTimeLabel, booking.appointmentTime),
                      if (booking.duration > 0) _buildInfoRow(locale.value.durationMinLabel, '${booking.duration} min'),
                    ]),
                    24.height,

                    // Call Type Section
                    _buildSectionTitle(locale.value.callTypeLabel),
                    12.height,
                    _buildInfoContainer(children: [
                      _buildInfoRow(
                        locale.value.callTypeLabel,
                        _isVideo ? locale.value.videoCallLabel : locale.value.phoneCallLabel,
                      ),
                    ]),
                    24.height,

                    // Meeting Link Section (video calls only)
                    if (_isVideo && _hasMeetingLink) ...[
                      _buildSectionTitle(locale.value.meetingLinkLabel),
                      12.height,
                      _buildMeetingLinkSection(),
                      24.height,
                    ],

                    // Payment Section
                    _buildSectionTitle(locale.value.paymentMethodLabel),
                    12.height,
                    _buildPaymentSection(),
                    24.height,

                    // Status & Timestamps
                    _buildSectionTitle(locale.value.bookingDetailsLabel),
                    12.height,
                    _buildInfoContainer(children: [
                      _buildInfoRow(locale.value.transactionTypeLabel, _statusLabel),
                      if (booking.createdAt.isNotEmpty) _buildInfoRow(locale.value.submit, _formatDate(booking.createdAt)),
                    ]),
                    32.height,
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  // ---------------------------------------------------------------------------
  // Header
  // ---------------------------------------------------------------------------
  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            appColorPrimary.withValues(alpha: isDarkMode.value ? 0.4 : 0.08),
            appColorSecondary.withValues(alpha: isDarkMode.value ? 0.2 : 0.04),
          ],
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: Column(
        children: [
          // Booking ID
          Text(
            '#${booking.id}',
            style: GoogleFonts.outfit(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.3,
              color: secondaryTextColor,
            ),
          ),
          12.height,

          // Status badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              color: _statusColor.withValues(alpha: 0.12),
              border: Border.all(color: _statusColor.withValues(alpha: 0.3)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _statusColor,
                    boxShadow: [
                      BoxShadow(
                        color: _statusColor.withValues(alpha: 0.5),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                ),
                8.width,
                Text(
                  _statusLabel,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.1,
                    color: _statusColor,
                  ),
                ),
              ],
            ),
          ),
          10.height,

          // Call type badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: (_isVideo ? callTypeVideoColor : callTypePhoneColor).withValues(alpha: 0.12),
              border: Border.all(
                color: (_isVideo ? callTypeVideoColor : callTypePhoneColor).withValues(alpha: 0.2),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _isVideo ? Icons.videocam_rounded : Icons.phone_rounded,
                  size: 16,
                  color: _isVideo ? callTypeVideoColor : callTypePhoneColor,
                ),
                6.width,
                Text(
                  _isVideo ? locale.value.videoCallLabel : locale.value.phoneCallLabel,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.2,
                    color: _isVideo ? callTypeVideoColor : callTypePhoneColor,
                  ),
                ),
              ],
            ),
          ),
          if (booking.appointmentDate.isNotEmpty) ...[
            10.height,
            Text(
              _formatDate(booking.appointmentDate),
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                letterSpacing: 0.1,
                color: secondaryTextColor,
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Section Title
  // ---------------------------------------------------------------------------
  Widget _buildSectionTitle(String title) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 20,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [gradientSecondaryStart, gradientSecondaryEnd],
            ),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        10.width,
        Text(
          title,
          style: GoogleFonts.outfit(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.3,
            color: isDarkMode.value ? Colors.white : primaryTextColor,
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Info Container
  // ---------------------------------------------------------------------------
  Widget _buildInfoContainer({required List<Widget> children}) {
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
        children: children,
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
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

  Widget _buildInfoRowWidget(String label, Widget valueWidget) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
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
  // Meeting Link Section
  // ---------------------------------------------------------------------------
  Widget _buildMeetingLinkSection() {
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
          // Prominent Join Call button
          GestureDetector(
            onTap: () async {
              final uri = Uri.tryParse(booking.meetingLink);
              if (uri != null) {
                await launchUrl(uri, mode: LaunchMode.externalApplication);
              }
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [callTypeVideoColor, Color(0xFF7986CB)],
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: callTypeVideoColor.withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.videocam_rounded, color: Colors.white, size: 22),
                  8.width,
                  Text(
                    locale.value.joinCall,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.1,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
          12.height,

          // Link text below
          Text(
            booking.meetingLink,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              letterSpacing: 0.1,
              color: callTypeVideoColor,
              decoration: TextDecoration.underline,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Payment Section
  // ---------------------------------------------------------------------------
  Widget _buildPaymentSection() {
    final children = <Widget>[];

    // Show service price (original)
    if (booking.servicePrice > 0) {
      children.add(_buildInfoRowWidget(locale.value.originalPriceLabel, PriceWidget(
        price: booking.servicePrice,
        size: 14,
        isSemiBoldText: true,
        isBoldText: false,
        color: isDarkMode.value ? Colors.white : primaryTextColor,
      )));
    }

    // If discount exists (servicePrice != serviceAmount), show discount
    if (booking.servicePrice > 0 && booking.serviceAmount > 0 && booking.servicePrice != booking.serviceAmount) {
      final discountAmount = booking.servicePrice - booking.serviceAmount;
      children.add(_buildInfoRowWidget(locale.value.discountLabel, PriceWidget(
        price: discountAmount,
        size: 14,
        isDiscountedPrice: true,
        isSemiBoldText: true,
        isBoldText: false,
        color: isDarkMode.value ? Colors.white : primaryTextColor,
      )));
    }

    // Total amount
    children.add(
      Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 130,
              child: Text(
                locale.value.totalAmountLabel,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.1,
                  color: isDarkMode.value ? Colors.white : primaryTextColor,
                ),
              ),
            ),
            8.width,
            Expanded(
              child: PriceWidget(
                price: booking.totalAmount,
                size: 18,
                color: appColorSecondary,
              ),
            ),
          ],
        ),
      ),
    );

    return _buildInfoContainer(children: children);
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------
  String _formatDate(String rawDate) {
    final parsed = DateTime.tryParse(rawDate);
    if (parsed == null) return rawDate;
    return DateFormat(DateFormatConst.D_MMMM_yyyy).format(parsed.toLocal());
  }
}
