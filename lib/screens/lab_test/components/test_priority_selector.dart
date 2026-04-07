import 'package:flutter/material.dart';
import 'package:kivicare_patient/utils/app_common.dart';
import 'package:kivicare_patient/utils/colors.dart';
import 'package:kivicare_patient/utils/lab_test_constants.dart';
import 'package:nb_utils/nb_utils.dart';

class TestPrioritySelector extends StatelessWidget {
  final String selectedPriority;
  final Function(String) onPriorityChanged;

  const TestPrioritySelector({
    Key? key,
    required this.selectedPriority,
    required this.onPriorityChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isDarkMode.value ? cardDarkColor : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDarkMode.value ? Colors.grey.shade800 : Colors.grey.shade200,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Test Priority',
              style: boldTextStyle(size: 14),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _PriorityOption(
                    label: 'Routine',
                    value: Priority.routine.value,
                    isSelected: selectedPriority == Priority.routine.value,
                    color: Colors.blue,
                    onTap: () => onPriorityChanged(Priority.routine.value),
                    description: 'Standard processing',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _PriorityOption(
                    label: 'Urgent',
                    value: Priority.urgent.value,
                    isSelected: selectedPriority == Priority.urgent.value,
                    color: Colors.orange,
                    onTap: () => onPriorityChanged(Priority.urgent.value),
                    description: 'Expedited',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _PriorityOption(
                    label: 'STAT',
                    value: Priority.stat.value,
                    isSelected: selectedPriority == Priority.stat.value,
                    color: cancelStatusColor,
                    onTap: () => onPriorityChanged(Priority.stat.value),
                    description: 'Immediate',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _PriorityOption extends StatelessWidget {
  final String label;
  final String value;
  final bool isSelected;
  final Color color;
  final VoidCallback onTap;
  final String description;

  const _PriorityOption({
    required this.label,
    required this.value,
    required this.isSelected,
    required this.color,
    required this.onTap,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? color : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? color : Colors.transparent,
                border: Border.all(color: color),
              ),
              child: isSelected
                  ? const Center(
                      child: Icon(Icons.check, size: 12, color: Colors.white),
                    )
                  : null,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: boldTextStyle(size: 12),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              description,
              style: secondaryTextStyle(size: 10),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
