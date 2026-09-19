import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kivicare_patient/locale/languages.dart';
import 'package:kivicare_patient/main.dart';
import 'package:kivicare_patient/utils/colors.dart';
import 'package:nb_utils/nb_utils.dart';

import '../models/nurse_status.dart';
import 'nurse_request_design.dart';

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
      child: Obx(() {
        final currentStatus = selectedStatus.value;
        final language = locale.value;

        return ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: statuses.length,
          separatorBuilder: (_, __) => 8.width,
          itemBuilder: (context, i) {
            final s = statuses[i];
            final isSelected = currentStatus == s;
            final label = s == null ? language.filterAll : _label(language, s);
            return GestureDetector(
              onTap: () => onChanged(s),
              child: Container(
                constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
                alignment: Alignment.center,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? gradientStart
                      : nurseRequestSubtleSurface(context),
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(
                    color: isSelected
                        ? gradientStart
                        : nurseRequestBorderColor(context),
                  ),
                ),
                child: Text(
                  label,
                  style: TextStyle(
                    color: isSelected
                        ? whiteTextColor
                        : nurseRequestMutedColor(context),
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                    fontSize: 13,
                  ),
                ),
              ),
            );
          },
        );
      }),
    );
  }

  String _label(BaseLanguage language, NurseStatus s) {
    switch (s) {
      case NurseStatus.pending:
        return language.filterPending;
      case NurseStatus.assigned:
        return language.filterAssigned;
      case NurseStatus.confirmed:
        return language.filterConfirmed;
      case NurseStatus.inProgress:
        return language.filterInProgress;
      case NurseStatus.completed:
        return language.filterCompleted;
      case NurseStatus.cancelled:
        return language.filterCancelled;
    }
  }
}
