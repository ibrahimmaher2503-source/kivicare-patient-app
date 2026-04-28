import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kivicare_patient/main.dart';
import 'package:kivicare_patient/utils/colors.dart';
import 'package:nb_utils/nb_utils.dart';

import '../models/nurse_status.dart';

class NurseStatusFilterBar extends StatelessWidget {
  final Rxn<NurseStatus> selectedStatus;
  final void Function(NurseStatus?) onChanged;

  const NurseStatusFilterBar({
    super.key,
    required this.selectedStatus,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final statuses = [null, ...NurseStatus.values];
    return SizedBox(
      height: 44,
      child: Obx(() => ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: statuses.length,
        separatorBuilder: (_, __) => 8.width,
        itemBuilder: (context, i) {
          final s = statuses[i];
          final isSelected = selectedStatus.value == s;
          final label = s == null ? locale.value.filterAll : _label(s);
          return GestureDetector(
            onTap: () => onChanged(s),
            child: Container(
              constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                gradient: isSelected
                    ? LinearGradient(colors: [gradientSecondaryStart, gradientSecondaryEnd])
                    : null,
                color: isSelected ? null : surfaceSubtle,
                borderRadius: BorderRadius.circular(22),
              ),
              child: Text(
                label,
                style: TextStyle(
                  color: isSelected ? Colors.white : null,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  fontSize: 13,
                ),
              ),
            ),
          );
        },
      )),
    );
  }

  String _label(NurseStatus s) {
    switch (s) {
      case NurseStatus.pending:
        return locale.value.filterPending;
      case NurseStatus.assigned:
        return locale.value.filterAssigned;
      case NurseStatus.confirmed:
        return locale.value.filterConfirmed;
      case NurseStatus.inProgress:
        return locale.value.filterInProgress;
      case NurseStatus.completed:
        return locale.value.filterCompleted;
      case NurseStatus.cancelled:
        return locale.value.filterCancelled;
    }
  }
}
