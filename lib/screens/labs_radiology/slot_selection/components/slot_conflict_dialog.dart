import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:kivicare_patient/screens/labs_radiology/labs_radiology_common.dart';

class SlotConflictDialog extends StatelessWidget {
  const SlotConflictDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(locale.value.slotConflictTitle, style: boldTextStyle()),
      content: Text(locale.value.slotConflictBody, style: primaryTextStyle()),
      actions: [
        TextButton(
          onPressed: () => finish(context, true),
          child: Text(locale.value.ok,
              style: boldTextStyle(color: context.primaryColor)),
        ),
      ],
    );
  }
}
