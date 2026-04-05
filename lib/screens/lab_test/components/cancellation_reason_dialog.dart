import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kivicare_patient/utils/colors.dart';
import 'package:kivicare_patient/utils/common_base.dart';
import 'package:nb_utils/nb_utils.dart';

class CancellationReasonDialog extends StatefulWidget {
  final Function(String reason) onConfirm;

  const CancellationReasonDialog({required this.onConfirm});

  @override
  State<CancellationReasonDialog> createState() => _CancellationReasonDialogState();
}

class _CancellationReasonDialogState extends State<CancellationReasonDialog> {
  late TextEditingController reasonController;
  final FocusNode focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    reasonController = TextEditingController();
    // Focus on text field after build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(focusNode);
    });
  }

  @override
  void dispose() {
    reasonController.dispose();
    focusNode.dispose();
    super.dispose();
  }

  bool get isReasonValid => reasonController.text.trim().isNotEmpty;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: isDarkMode.value ? cardDarkColor : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.w)),
      title: Text(
        locale.value.cancellationReason,
        style: boldTextStyle(size: 18),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 8.w),
          Text(
            locale.value.pleaseProvideReasonForCancellation,
            style: secondaryTextStyle(size: 13),
          ),
          SizedBox(height: 16.w),
          Container(
            decoration: BoxDecoration(
              color: isDarkMode.value ? gray800 : gray50,
              border: Border.all(color: isDarkMode.value ? gray700 : gray200),
              borderRadius: BorderRadius.circular(12.w),
            ),
            child: TextField(
              controller: reasonController,
              focusNode: focusNode,
              maxLines: 4,
              maxLength: 500,
              decoration: InputDecoration(
                hintText: locale.value.enterCancellationReason,
                hintStyle: secondaryTextStyle(color: gray400),
                border: InputBorder.none,
                contentPadding: EdgeInsets.all(12.w),
                counterText: '',
              ),
              style: primaryTextStyle(size: 13),
              onChanged: (_) => setState(() {}),
            ),
          ),
          SizedBox(height: 4.w),
          Align(
            alignment: Alignment.bottomRight,
            child: Text(
              '${reasonController.text.length}/500',
              style: secondaryTextStyle(size: 11),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Get.back(),
          child: Text(
            locale.value.cancel,
            style: boldTextStyle(color: gray500),
          ),
        ),
        ElevatedButton(
          onPressed: isReasonValid
              ? () {
                  widget.onConfirm(reasonController.text.trim());
                  Get.back();
                }
              : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryColor,
            disabledBackgroundColor: gray300,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.w)),
          ),
          child: Text(
            locale.value.confirm,
            style: boldTextStyle(color: Colors.white),
          ),
        ),
      ],
    );
  }
}

/// Show cancellation reason dialog
Future<void> showCancellationReasonDialog(
  BuildContext context,
  Function(String reason) onConfirm,
) {
  return showDialog(
    context: context,
    barrierDismissible: true,
    builder: (context) => CancellationReasonDialog(onConfirm: onConfirm),
  );
}
