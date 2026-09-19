import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import '../../../../main.dart';
import '../../models/hospital_model.dart';

class HospitalLockField extends StatelessWidget {
  final Hospital hospital;
  final VoidCallback onChange;

  const HospitalLockField({super.key, required this.hospital, required this.onChange});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(defaultRadius),
        border: Border.all(color: context.dividerColor),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: context.primaryColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.local_hospital_rounded, color: context.primaryColor),
          ),
          12.width,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(locale.value.selectHospital, style: secondaryTextStyle(size: 12)),
                Text(hospital.name, style: boldTextStyle()),
              ],
            ),
          ),
          TextButton(
            onPressed: onChange,
            child: Text(locale.value.changeHospital, style: boldTextStyle(color: context.primaryColor)),
          ),
        ],
      ),
    );
  }
}
