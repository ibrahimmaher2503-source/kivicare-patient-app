import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import '../../../utils/colors.dart';

class PasswordRuleItem extends StatelessWidget {
  final bool isValid;
  final String text;

  const PasswordRuleItem({super.key, required this.isValid, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: Icon(
            isValid ? Icons.check_circle_rounded : Icons.circle_outlined,
            key: ValueKey(isValid),
            size: 16,
            color: isValid ? completedStatusColor : secondaryTextColor.withValues(alpha: 0.4),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: secondaryTextStyle(
              size: 11,
              color: isValid ? completedStatusColor : null,
            ),
          ),
        ),
      ],
    );
  }
}
