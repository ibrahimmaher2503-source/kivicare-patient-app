import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../main.dart';
import '../../../utils/app_common.dart';
import '../../../utils/colors.dart';
import '../../../utils/constants.dart';
import '../../call_booking/book_call_screen.dart';
import '../../call_booking/components/time_slot_chip.dart';
import '../../call_booking/model/call_doctor_model.dart';
import '../../independent_booking/book_independent_screen.dart';
import '../../independent_booking/model/independent_doctor_model.dart';
import '../../service/model/service_list_model.dart';
import '../../slots/booking_form_screen.dart';
import '../model/unified_doctor_model.dart';
import '../unified_doctor_detail_controller.dart';

/// Expandable booking section for a single [BookingCapability].
/// Shows service selector, date picker, slot chips and "Book Now" button.
/// Clinic type delegates slot selection to [BookingFormScreen].
class BookingMethodSection extends StatelessWidget {
  final BookingCapability capability;
  final UnifiedDoctorDetailController controller;

  const BookingMethodSection({
    super.key,
    required this.capability,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final type = capability.type;

    return Obx(() {
      final bool dark = isDarkMode.value;
      final bool expanded = controller.isSectionExpanded[type]!.value;

      return Container(
        decoration: BoxDecoration(
          color: dark ? surfaceElevatedDark : surfaceElevated,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: dark ? softShadowColorDark : softShadowColor,
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            // ── Header ──────────────────────────────────────────────────────
            InkWell(
              onTap: () => controller.toggleSection(type),
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: _typeColor(type).withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(_typeIcon(type), color: _typeColor(type), size: 20),
                    ),
                    12.width,
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _typeLabel(type),
                            style: GoogleFonts.outfit(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: dark ? Colors.white : primaryTextColor,
                            ),
                          ),
                          if (capability.startingPrice > 0)
                            Text(
                              '${locale.value.startingFrom} ${capability.startingPrice.toStringAsFixed(0)}',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 12,
                                color: secondaryTextColor,
                              ),
                            ),
                        ],
                      ),
                    ),
                    AnimatedRotation(
                      turns: expanded ? 0.5 : 0.0,
                      duration: const Duration(milliseconds: 250),
                      child: Icon(Icons.keyboard_arrow_down_rounded, color: secondaryTextColor),
                    ),
                  ],
                ),
              ),
            ),

            // ── Expanded body ────────────────────────────────────────────────
            AnimatedCrossFade(
              duration: const Duration(milliseconds: 250),
              crossFadeState: expanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
              firstChild: const SizedBox.shrink(),
              secondChild: _ExpandedBody(
                capability: capability,
                controller: controller,
                typeColor: _typeColor(type),
              ),
            ),
          ],
        ),
      );
    });
  }

  IconData _typeIcon(BookingType type) {
    switch (type) {
      case BookingType.clinic:
        return Icons.local_hospital_rounded;
      case BookingType.videoCall:
        return Icons.video_call_rounded;
      case BookingType.phoneCall:
        return Icons.phone_rounded;
      case BookingType.inPerson:
        return Icons.person_pin_rounded;
    }
  }

  Color _typeColor(BookingType type) {
    switch (type) {
      case BookingType.clinic:
        return appColorPrimary;
      case BookingType.videoCall:
        return callTypeVideoColor;
      case BookingType.phoneCall:
        return callTypePhoneColor;
      case BookingType.inPerson:
        return const Color(0xFF00897B);
    }
  }

  String _typeLabel(BookingType type) {
    switch (type) {
      case BookingType.clinic:
        return locale.value.clinic;
      case BookingType.videoCall:
        return locale.value.videoConsult;
      case BookingType.phoneCall:
        return locale.value.phoneCallLabel;
      case BookingType.inPerson:
        return locale.value.bookADoctor;
    }
  }
}

// ─── Expanded body widget ────────────────────────────────────────────────────

class _ExpandedBody extends StatelessWidget {
  final BookingCapability capability;
  final UnifiedDoctorDetailController controller;
  final Color typeColor;

  const _ExpandedBody({
    required this.capability,
    required this.controller,
    required this.typeColor,
  });

  BookingType get type => capability.type;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Divider(),
          8.height,

          // Service dropdown
          if (capability.services.isNotEmpty) ...[
            Obx(() {
              final bool dark = isDarkMode.value;
              return InputDecorator(
                decoration: InputDecoration(
                  filled: true,
                  fillColor: dark ? inputFillColorDark : inputFillColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<ServiceInfo>(
                    value: controller.selectedService[type]!.value,
                    hint: Text(
                      locale.value.selectService,
                      style: GoogleFonts.plusJakartaSans(fontSize: 13, color: secondaryTextColor),
                    ),
                    isExpanded: true,
                    items: capability.services
                        .map((s) => DropdownMenuItem<ServiceInfo>(
                              value: s,
                              child: Text(
                                s.name,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 13,
                                  color: dark ? Colors.white : primaryTextColor,
                                ),
                              ),
                            ))
                        .toList(),
                    onChanged: (s) => controller.setService(type, s),
                  ),
                ),
              );
            }),
            12.height,
          ],

          // Date picker + slot chips (non-clinic only)
          if (type != BookingType.clinic) ...[
            _DatePickerField(controller: controller, type: type),
            12.height,
            _SlotChips(controller: controller, type: type),
            12.height,
          ],

          // Book Now button
          _BookNowButton(
            controller: controller,
            capability: capability,
            typeColor: typeColor,
          ),
        ],
      ),
    );
  }
}

// ─── Date picker field ───────────────────────────────────────────────────────

class _DatePickerField extends StatelessWidget {
  final UnifiedDoctorDetailController controller;
  final BookingType type;

  const _DatePickerField({required this.controller, required this.type});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final bool dark = isDarkMode.value;
      final selectedDate = controller.selectedDate[type]!.value;

      return InkWell(
        onTap: () async {
          final picked = await showDatePicker(
            context: context,
            initialDate: DateTime.now().add(const Duration(days: 1)),
            firstDate: DateTime.now().add(const Duration(days: 1)),
            lastDate: DateTime.now().add(const Duration(days: 90)),
          );
          if (picked != null) controller.setDate(type, picked);
        },
        borderRadius: BorderRadius.circular(10),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          decoration: BoxDecoration(
            color: dark ? inputFillColorDark : inputFillColor,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              Icon(Icons.calendar_today_rounded, size: 18, color: secondaryTextColor),
              8.width,
              Text(
                selectedDate != null
                    ? DateFormat(DateFormatConst.yyyy_MM_dd).format(selectedDate)
                    : locale.value.selectDate,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  color: selectedDate != null
                      ? (dark ? Colors.white : primaryTextColor)
                      : secondaryTextColor,
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}

// ─── Slot chips ──────────────────────────────────────────────────────────────

class _SlotChips extends StatelessWidget {
  final UnifiedDoctorDetailController controller;
  final BookingType type;

  const _SlotChips({required this.controller, required this.type});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final dateSelected = controller.selectedDate[type]!.value;
      if (dateSelected == null) return const SizedBox.shrink();

      final loading = controller.isLoadingSlots[type]!.value;
      if (loading) {
        return const Center(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        );
      }

      final slotList = controller.slots[type]!;
      if (slotList.isEmpty) {
        return Text(
          locale.value.noDataFound,
          style: GoogleFonts.plusJakartaSans(fontSize: 12, color: secondaryTextColor),
        );
      }

      final selectedSlotValue = controller.selectedSlot[type]!.value?.value;
      return Wrap(
        spacing: 8,
        runSpacing: 8,
        children: slotList.map((slot) {
          return TimeSlotChip(
            label: slot.label,
            isSelected: selectedSlotValue == slot.value,
            onTap: () => controller.setSlot(type, slot),
          );
        }).toList(),
      );
    });
  }
}

// ─── Book Now button ─────────────────────────────────────────────────────────

class _BookNowButton extends StatelessWidget {
  final UnifiedDoctorDetailController controller;
  final BookingCapability capability;
  final Color typeColor;

  const _BookNowButton({
    required this.controller,
    required this.capability,
    required this.typeColor,
  });

  BookingType get type => capability.type;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final canBook = controller.canBook(type);
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: canBook ? () => _navigate(type) : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: typeColor,
            disabledBackgroundColor: typeColor.withValues(alpha: 0.35),
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 0,
          ),
          child: Text(
            locale.value.bookNow,
            style: GoogleFonts.outfit(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ),
      );
    });
  }

  void _navigate(BookingType type) {
    switch (type) {
      case BookingType.clinic:
        final service = controller.selectedService[type]!.value;
        currentSelectedDoctor.value = controller.doctor.toDoctor();
        if (service?.rawService is ServiceElement) {
          currentSelectedService.value = service!.rawService as ServiceElement;
        }
        Get.to(() => BookingFormScreen());
        break;

      case BookingType.videoCall:
      case BookingType.phoneCall:
        final service = controller.selectedService[type]!.value;
        if (service?.rawService is CallService) {
          Get.to(() => BookCallScreen(
                doctor: controller.doctor.toCallDoctor(),
                service: service!.rawService as CallService,
              ));
        }
        break;

      case BookingType.inPerson:
        final service = controller.selectedService[type]!.value;
        if (service?.rawService is IndependentService) {
          Get.to(() => BookIndependentScreen(
                doctor: controller.doctor.toIndependentDoctor(),
                service: service!.rawService as IndependentService,
              ));
        }
        break;
    }
  }
}
