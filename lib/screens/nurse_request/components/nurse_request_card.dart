import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kivicare_patient/main.dart';
import 'package:kivicare_patient/utils/colors.dart';
import 'package:kivicare_patient/utils/price_widget.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../utils/app_common.dart';
import '../models/nurse_request_model.dart';
import '../models/nurse_status.dart';
import 'nurse_request_design.dart';
import 'nurse_status_chip.dart';

class NurseRequestCard extends StatelessWidget {
  final NurseRequestModel request;
  final VoidCallback onTap;

  const NurseRequestCard({
    super.key,
    required this.request,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final localeCode = selectedLanguageCode.value;
    final description = request.serviceDescriptionLocalized(localeCode) ?? '';
    final dateStr =
        DateFormat('dd MMM yyyy', localeCode).format(request.preferredDate);
    final durationStr = locale.value.durationHoursValue(request.durationHours);
    final timeStr = request.preferredTime ?? '';
    final scheduleStr = [
      dateStr,
      if (timeStr.isNotEmpty) timeStr,
      durationStr,
    ].join(' | ');
    final status = NurseStatusExtension.fromString(request.status);
    final addressStr = [
      request.addressLine1,
      request.city,
    ].where((value) => value.trim().isNotEmpty).join(', ');

    return Semantics(
      button: true,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
        decoration: nurseRequestCardDecoration(context),
        child: Material(
          color: appTransparentColor,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(18),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              locale.value.referenceNumber,
                              style: secondaryTextStyle(
                                size: 12,
                                color: nurseRequestMutedColor(context),
                              ),
                            ),
                            3.height,
                            Text(
                              request.referenceNumber,
                              style: boldTextStyle(
                                size: 16,
                                color: gradientStart,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      12.width,
                      NurseStatusChip(status: status),
                    ],
                  ),
                  if (description.isNotEmpty) ...[
                    14.height,
                    Text(
                      description,
                      style: primaryTextStyle(size: 14),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  14.height,
                  _CardMetaRow(
                    icon: Icons.event_available_outlined,
                    label: scheduleStr,
                  ),
                  if (addressStr.isNotEmpty) ...[
                    8.height,
                    _CardMetaRow(
                      icon: Icons.location_on_outlined,
                      label: addressStr,
                    ),
                  ],
                  if (request.assignedNurse != null ||
                      request.totalAmount != null) ...[
                    14.height,
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: nurseRequestSubtleSurface(context),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: nurseRequestBorderColor(context),
                        ),
                      ),
                      child: Row(
                        children: [
                          if (request.assignedNurse != null)
                            Expanded(
                              child: _CompactValue(
                                label: locale.value.assignedNurse,
                                value: request.assignedNurse!.displayName,
                              ),
                            ),
                          if (request.assignedNurse != null &&
                              request.totalAmount != null)
                            12.width,
                          if (request.totalAmount != null)
                            PriceWidget(
                              price: request.totalAmount!,
                              currencyCode: request.currency,
                              size: 14,
                              color: appColorSecondary,
                            ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CardMetaRow extends StatelessWidget {
  final IconData icon;
  final String label;

  const _CardMetaRow({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: gradientSecondaryStart, size: 18),
        8.width,
        Expanded(
          child: Text(
            label,
            style: secondaryTextStyle(
              size: 12,
              color: nurseRequestMutedColor(context),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

class _CompactValue extends StatelessWidget {
  final String label;
  final String value;

  const _CompactValue({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: secondaryTextStyle(
            size: 12,
            color: nurseRequestMutedColor(context),
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        2.height,
        Text(
          value,
          style: primaryTextStyle(size: 13, color: gradientStart),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
