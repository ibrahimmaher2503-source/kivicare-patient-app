import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../main.dart';
import '../../../utils/colors.dart';

class EmptyCitiesWidget extends StatelessWidget {
  final VoidCallback onApplyGovernorateOnly;
  final VoidCallback onChangeGovernorate;

  const EmptyCitiesWidget({
    super.key,
    required this.onApplyGovernorateOnly,
    required this.onChangeGovernorate,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.location_off, color: appBodyColor, size: 56),
            const SizedBox(height: 12),
            Text(
              locale.value.noCitiesAvailable,
              style: boldTextStyle(size: 18),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Text(
              locale.value.showAllCitiesInGovernorate,
              style: secondaryTextStyle(size: 14),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onApplyGovernorateOnly,
                style: ElevatedButton.styleFrom(
                  backgroundColor: appColorSecondary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(locale.value.applyGovernorateOnly),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: onChangeGovernorate,
                style: OutlinedButton.styleFrom(
                  foregroundColor: appColorSecondary,
                  side: BorderSide(color: appColorSecondary),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(locale.value.changeGovernorate),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
