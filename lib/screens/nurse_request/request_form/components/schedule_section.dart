import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:kivicare_patient/main.dart';
import 'package:kivicare_patient/utils/colors.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../components/cairo_time.dart';
import '../../components/nurse_request_design.dart';
import 'duration_stepper.dart';

class ScheduleSection extends StatelessWidget {
  final Rxn<DateTime> preferredDate;
  final Rxn<TimeOfDay> preferredTime;
  final RxInt durationHours;

  const ScheduleSection({
    super.key,
    required this.preferredDate,
    required this.preferredTime,
    required this.durationHours,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(locale.value.preferredDate, style: boldTextStyle()),
        8.height,
        Obx(
          () => _PickerTile(
            label: preferredDate.value != null
                ? DateFormat('yyyy-MM-dd').format(preferredDate.value!)
                : locale.value.preferredDate,
            icon: Icons.calendar_today_outlined,
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: preferredDate.value ?? cairoTodayMidnight(),
                firstDate: cairoTodayMidnight(),
                lastDate: cairoMaxBookableDate(),
                builder: (ctx, child) => Theme(
                  data: Theme.of(ctx).copyWith(
                    colorScheme: ColorScheme.fromSeed(
                      seedColor: gradientStart,
                      brightness: nurseRequestIsDark
                          ? Brightness.dark
                          : Brightness.light,
                    ),
                  ),
                  child: child!,
                ),
              );
              if (picked != null) preferredDate.value = picked;
            },
          ),
        ),
        12.height,
        Text(locale.value.preferredTime, style: boldTextStyle()),
        8.height,
        Obx(
          () => Row(
            children: [
              Expanded(
                child: _PickerTile(
                  label: preferredTime.value != null
                      ? preferredTime.value!.format(context)
                      : locale.value.preferredTime,
                  icon: Icons.access_time_outlined,
                  onTap: () async {
                    final picked = await showTimePicker(
                      context: context,
                      initialTime: preferredTime.value ?? TimeOfDay.now(),
                    );
                    if (picked != null) preferredTime.value = picked;
                  },
                ),
              ),
              if (preferredTime.value != null) ...[
                8.width,
                TextButton(
                  onPressed: () => preferredTime.value = null,
                  style: TextButton.styleFrom(
                    foregroundColor: gradientStart,
                    minimumSize: const Size(44, 44),
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                  ),
                  child: Text(
                    locale.value.clear,
                    style: TextStyle(color: gradientStart),
                  ),
                ),
              ],
            ],
          ),
        ),
        12.height,
        Text(locale.value.durationHours, style: boldTextStyle()),
        8.height,
        DurationStepper(value: durationHours),
      ],
    );
  }
}

class _PickerTile extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _PickerTile({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: nurseRequestSubtleSurface(context),
          border: Border.all(color: nurseRequestBorderColor(context)),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Icon(icon, color: gradientStart, size: 20),
            12.width,
            Expanded(
              child: Text(
                label,
                style: primaryTextStyle(),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
