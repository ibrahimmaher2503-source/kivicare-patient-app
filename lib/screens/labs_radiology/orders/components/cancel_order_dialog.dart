import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:kivicare_patient/screens/labs_radiology/labs_radiology_common.dart';

class CancelOrderDialog extends StatefulWidget {
  const CancelOrderDialog({super.key});

  @override
  State<CancelOrderDialog> createState() => _CancelOrderDialogState();
}

class _CancelOrderDialogState extends State<CancelOrderDialog> {
  final reasonController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(locale.value.cancelOrderTitle, style: boldTextStyle()),
      content: Form(
        key: formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(locale.value.cancelOrderConfirm, style: primaryTextStyle()),
            16.height,
            AppTextField(
              controller: reasonController,
              textFieldType: TextFieldType.MULTILINE,
              maxLines: 3,
              decoration: inputDecoration(context,
                  labelText: locale.value.cancelReasonOptional),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => finish(context),
          child: Text(locale.value.keepOrder,
              style: boldTextStyle(color: secondaryTextColor)),
        ),
        AppButton(
          text: locale.value.cancel,
          color: Colors.red,
          textStyle: boldTextStyle(color: Colors.white),
          onTap: () {
            finish(context, reasonController.text.trim());
          },
        ),
      ],
    );
  }
}
