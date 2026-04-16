import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../components/cached_image_widget.dart';
import '../../../components/loader_widget.dart';
import '../../../main.dart';
import '../../../utils/app_common.dart';
import '../../../utils/colors.dart';
import '../../../utils/constants.dart';
import '../../call_booking/components/time_slot_chip.dart';
import '../../doctor/model/unified_doctor_model.dart';
import 'doctor_quick_book_controller.dart';

/// Doctor-first QuickBook widget for the home screen.
/// Guides the user through: search doctor → pick booking type →
/// pick date → pick slot → Book Now.
class DoctorQuickBookComponent extends StatelessWidget {
  DoctorQuickBookComponent({super.key});

  final DoctorQuickBookController controller = Get.put(DoctorQuickBookController());

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final bool dark = isDarkMode.value;

      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: dark ? surfaceElevatedDark : surfaceElevated,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: dark ? softShadowColorDark : softShadowColor,
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                ShaderMask(
                  shaderCallback: (bounds) => const LinearGradient(
                    colors: [appColorPrimary, appColorSecondary],
                  ).createShader(bounds),
                  child: const Icon(Icons.medical_services_rounded,
                      color: Colors.white, size: 20),
                ),
                8.width,
                Expanded(
                  child: Text(
                    locale.value.bookADoctor,
                    style: GoogleFonts.outfit(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: dark ? Colors.white : primaryTextColor,
                    ),
                  ),
                ),
                if (controller.selectedDoctor.value != null)
                  GestureDetector(
                    onTap: controller.reset,
                    child: Text(
                      locale.value.reset,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        color: appColorPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
            16.height,

            // Step 1 — Doctor search
            _DoctorSearchField(controller: controller),
            _DoctorResultsList(controller: controller),

            // Step 2 — Booking type chips (shown once doctor selected)
            if (controller.selectedDoctor.value != null &&
                controller.selectedDoctor.value!.bookingCapabilities.isNotEmpty) ...[
              16.height,
              _CapabilityChips(controller: controller),
            ],

            // Step 3 — Date picker (shown once capability selected)
            if (controller.selectedCapability.value != null &&
                controller.selectedCapability.value!.type != BookingType.clinic) ...[
              16.height,
              _DatePickerRow(controller: controller),
            ],

            // Step 4 — Slot chips (shown once date selected)
            if (controller.selectedDate.value != null &&
                controller.selectedCapability.value!.type != BookingType.clinic) ...[
              16.height,
              _SlotChipsRow(controller: controller),
            ],

            // Step 5 — Book Now button (shown once doctor selected)
            if (controller.selectedDoctor.value != null) ...[
              20.height,
              _BookNowButton(controller: controller),
            ],
          ],
        ),
      );
    });
  }
}

// ─── Step 1: Doctor search field ─────────────────────────────────────────────

class _DoctorSearchField extends StatelessWidget {
  final DoctorQuickBookController controller;
  const _DoctorSearchField({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final bool dark = isDarkMode.value;
      return Container(
        height: 48,
        decoration: BoxDecoration(
          color: dark ? inputFillColorDark : inputFillColor,
          borderRadius: BorderRadius.circular(10),
        ),
        child: AppTextField(
          textStyle: GoogleFonts.plusJakartaSans(
            fontSize: 13,
            color: dark ? Colors.white : primaryTextColor,
          ),
          controller: controller.searchCont,
          textFieldType: TextFieldType.OTHER,
          onChanged: controller.onSearchChanged,
          decoration: InputDecoration(
            hintText: '${locale.value.searchHere}...',
            hintStyle: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              color: secondaryTextColor,
            ),
            prefixIcon: controller.isSearching.value
                ? Transform.scale(
                    scale: 0.5,
                    child: const CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.search_rounded, color: appColorPrimary, size: 20),
            filled: true,
            fillColor: dark ? inputFillColorDark : inputFillColor,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          ),
        ),
      );
    });
  }
}

// ─── Step 1b: Search results list ────────────────────────────────────────────

class _DoctorResultsList extends StatelessWidget {
  final DoctorQuickBookController controller;
  const _DoctorResultsList({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final results = controller.doctorResults;
      if (results.isEmpty) return const SizedBox.shrink();

      final bool dark = isDarkMode.value;
      return Container(
        margin: const EdgeInsets.only(top: 6),
        decoration: BoxDecoration(
          color: dark ? surfaceElevatedDark : Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: dark ? softShadowColorDark : softShadowColor,
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: results.take(6).map((doc) {
            return InkWell(
              onTap: () => controller.onDoctorSelected(doc),
              borderRadius: BorderRadius.circular(10),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: CachedImageWidget(
                        url: doc.profileImage,
                        height: 36,
                        width: 36,
                        fit: BoxFit.cover,
                      ),
                    ),
                    10.width,
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            doc.fullName,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: dark ? Colors.white : primaryTextColor,
                            ),
                          ),
                          if (doc.expert.isNotEmpty)
                            Text(
                              doc.expert,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 11,
                                color: secondaryTextColor,
                              ),
                            ),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right_rounded,
                        color: appColorPrimary, size: 18),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      );
    });
  }
}

// ─── Step 2: Booking type chips ───────────────────────────────────────────────

class _CapabilityChips extends StatelessWidget {
  final DoctorQuickBookController controller;
  const _CapabilityChips({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final caps =
          controller.selectedDoctor.value?.bookingCapabilities ?? [];
      final selected = controller.selectedCapability.value;
      final bool dark = isDarkMode.value;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            locale.value.bookingInfo,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: secondaryTextColor,
            ),
          ),
          8.height,
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: caps.map((cap) {
              final isSelected = selected?.type == cap.type;
              final color = _capColor(cap.type);
              return GestureDetector(
                onTap: () => controller.onCapabilitySelected(cap),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? color : color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _capIcon(cap.type),
                        size: 14,
                        color: isSelected ? Colors.white : color,
                      ),
                      6.width,
                      Text(
                        _capLabel(cap.type),
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isSelected
                              ? Colors.white
                              : (dark ? Colors.white70 : color),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      );
    });
  }

  IconData _capIcon(BookingType type) {
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

  Color _capColor(BookingType type) {
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

  String _capLabel(BookingType type) {
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

// ─── Step 3: Date picker row ──────────────────────────────────────────────────

class _DatePickerRow extends StatelessWidget {
  final DoctorQuickBookController controller;
  const _DatePickerRow({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final bool dark = isDarkMode.value;
      final selectedDate = controller.selectedDate.value;

      return InkWell(
        onTap: () async {
          final picked = await showDatePicker(
            context: context,
            initialDate: DateTime.now().add(const Duration(days: 1)),
            firstDate: DateTime.now().add(const Duration(days: 1)),
            lastDate: DateTime.now().add(const Duration(days: 90)),
          );
          if (picked != null) controller.onDateSelected(picked);
        },
        borderRadius: BorderRadius.circular(10),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 13),
          decoration: BoxDecoration(
            color: dark ? inputFillColorDark : inputFillColor,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              const Icon(Icons.calendar_today_rounded,
                  size: 16, color: appColorPrimary),
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

// ─── Step 4: Slot chips ───────────────────────────────────────────────────────

class _SlotChipsRow extends StatelessWidget {
  final DoctorQuickBookController controller;
  const _SlotChipsRow({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoadingSlots.value) {
        return const Center(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: LoaderWidget(),
          ),
        );
      }
      final slotList = controller.slots;
      if (slotList.isEmpty) {
        return Text(
          locale.value.noDataFound,
          style: GoogleFonts.plusJakartaSans(fontSize: 12, color: secondaryTextColor),
        );
      }
      final selectedValue = controller.selectedSlot.value?.value;
      return Wrap(
        spacing: 8,
        runSpacing: 8,
        children: slotList.map((slot) {
          return TimeSlotChip(
            label: slot.label,
            isSelected: selectedValue == slot.value,
            onTap: () => controller.onSlotSelected(slot),
          );
        }).toList(),
      );
    });
  }
}

// ─── Step 5: Book Now button ──────────────────────────────────────────────────

class _BookNowButton extends StatelessWidget {
  final DoctorQuickBookController controller;
  const _BookNowButton({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final canBook = controller.canBook;
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: canBook ? controller.navigateToBooking : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: appColorPrimary,
            disabledBackgroundColor: appColorPrimary.withValues(alpha: 0.35),
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
}
