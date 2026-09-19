import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kivicare_patient/main.dart';
import 'package:kivicare_patient/utils/colors.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../components/nurse_request_design.dart';

class DurationStepper extends StatelessWidget {
  final RxInt value;
  final int min;
  final int max;

  const DurationStepper({
    super.key,
    required this.value,
    this.min = 1,
    this.max = 24,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _StepButton(
            icon: Icons.remove,
            onTap: () {
              if (value.value > min) value.value--;
            },
            enabled: value.value > min,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              locale.value.durationHoursValue(value.value),
              style: boldTextStyle(size: 16),
            ),
          ),
          _StepButton(
            icon: Icons.add,
            onTap: () {
              if (value.value < max) value.value++;
            },
            enabled: value.value < max,
          ),
        ],
      ),
    );
  }
}

class _StepButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool enabled;

  const _StepButton({
    required this.icon,
    required this.onTap,
    required this.enabled,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: enabled ? onTap : null,
      borderRadius: BorderRadius.circular(22),
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: enabled
              ? gradientStart.withValues(alpha: 0.15)
              : nurseRequestSubtleSurface(context),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: enabled ? gradientStart : nurseRequestBorderColor(context),
          ),
        ),
        child: Icon(
          icon,
          color: enabled ? gradientStart : nurseRequestDisabledColor(context),
          size: 20,
        ),
      ),
    );
  }
}
