import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kivicare_patient/screens/auth/model/common_model.dart';
import 'package:kivicare_patient/utils/common_base.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../api/core_apis.dart';
import '../../../main.dart';
import '../../../utils/app_common.dart';
import '../../../utils/colors.dart';
import '../../../utils/constants.dart';
import '../../booking/appointments_controller.dart';
import '../incident_detail_screen.dart';
import '../incident_management_controller.dart';
import '../model/incident_response_model.dart';

class IncidentManagementCard extends StatelessWidget {
  final VoidCallback? onUpdateBooking;
  final Incident incidentData;
  final IncidentManagement incidentController;

  IncidentManagementCard({
    super.key,
    required this.incidentData,
    this.onUpdateBooking,
    required this.incidentController,
  });

  final AppointmentsController appointmentsController = Get.find();

  bool get isClosed => incidentData.incidenceTypeName.toLowerCase().toString().contains("close");
  bool get isRejected => incidentData.incidenceTypeName.toLowerCase().toString().contains("reject");

  Color get _statusColor {
    if (isClosed) return completedStatusColor;
    if (isRejected) return cancelStatusColor;
    if (incidentData.incidenceTypeName.toLowerCase() == 'open') return confirmedStatusColor;
    return pendingStatusColor;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        hideKeyboard(context);
        Get.to(IncidentDetailScreen(
          incident: incidentData,
          incidentController: incidentController,
          isClosed: isClosed,
          isRejected: isRejected,
        ));
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDarkMode.value ? surfaceElevatedDark : surfaceElevated,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: isDarkMode.value ? softShadowColorDark : softShadowColor,
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  incidentData.incidentDate.toString().dateInDDMMYYYYFormat,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.1,
                    color: secondaryTextColor,
                  ),
                ),
                if (isClosed)
                  _buildStatusChip(locale.value.closed, completedStatusColor)
                else if (isRejected)
                  _buildStatusChip(locale.value.rejected, cancelStatusColor)
                else
                  DropdownButtonHideUnderline(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            _statusColor.withValues(alpha: 0.15),
                            _statusColor.withValues(alpha: 0.08),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: DropdownButton<String>(
                        elevation: 1,
                        dropdownColor: isDarkMode.value ? surfaceElevatedDark : surfaceElevated,
                        borderRadius: BorderRadius.circular(12),
                        isDense: true,
                        icon: Icon(Icons.arrow_drop_down, color: _statusColor, size: 20),
                        iconSize: 20,
                        value: incidentStatuses
                            .firstWhere(
                              (e) => incidentData.incidenceTypeName.toLowerCase().contains(e.slug),
                              orElse: () => CMNModel(slug: incidentData.incidenceTypeName.toLowerCase()),
                            )
                            .slug,
                        onChanged: (String? newValue) async {
                          if (newValue != null) {
                            incidentController.isLoading(true);

                            // Map selection value to status
                            final incidentTypeMap = {
                              "open": 1,
                              "closed": 2,
                              "reject": 3,
                            };

                            final incidentType = incidentTypeMap[newValue.toLowerCase().trim()];

                            if (incidentType != null) {
                              final request = {
                                "incident_type": incidentType,
                              };
                              incidentController.isLoading(true);
                              await CoreServiceApis.updateIncidentStatus(incidentId: incidentData.id, request: request).then((res) {
                                toast(res.message);
                                incidentController.incidencePage(1);
                                incidentController.getIncidents();
                              }).catchError((e) {
                                toast(e.toString());
                              }).whenComplete(() {
                                incidentController.isLoading(false);
                              });
                            } else {
                              incidentController.isLoading(false);
                              toast("Invalid incident type selected");
                            }
                          }
                        },
                        items: incidentStatusesDropDown.map((status) {
                          return DropdownMenuItem<String>(
                            value: status.slug,
                            child: Text(
                              status.name,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 13,
                                letterSpacing: 0.1,
                                color: isDarkMode.value ? Colors.white : primaryTextColor,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          );
                        }).toList(),
                        selectedItemBuilder: (BuildContext context) {
                          return incidentStatuses.map((status) {
                            return Text(
                              status.name,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.1,
                                color: _statusColor,
                              ),
                            );
                          }).toList();
                        },
                      ),
                    ),
                  ),
              ],
            ),
            16.height,
            Text(
              incidentData.title,
              style: GoogleFonts.outfit(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                letterSpacing: -0.3,
                color: isDarkMode.value ? Colors.white : primaryTextColor,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            8.height,
            Text(
              incidentData.description,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                letterSpacing: 0.1,
                color: secondaryTextColor,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            8.height,
            if (incidentData.incidentCloseDate.validate().isNotEmpty) ...[
              8.height,
              Container(
                height: 1,
                color: isDarkMode.value ? borderColor.withValues(alpha: 0.08) : borderColor.withValues(alpha: 0.2),
              ),
              8.height,
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${locale.value.closedOn} :',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.1,
                      color: completedStatusColor,
                    ),
                  ),
                  Text(
                    incidentData.incidentCloseDate.validate().dateInDDMMYYYYFormat,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      letterSpacing: 0.1,
                      color: secondaryTextColor,
                    ),
                  )
                ],
              ),
            ],
            12.height,
            GestureDetector(
              onTap: () => {
                Get.to(() => IncidentDetailScreen(
                      incident: incidentData,
                      incidentController: incidentController,
                      isClosed: isClosed,
                      isRejected: isRejected,
                    )),
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [gradientSecondaryStart, gradientSecondaryEnd]),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: appColorSecondary.withValues(alpha: 0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Text(
                  locale.value.viewDetail,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.1,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            if (isClosed) ...[
              16.height,
              commonDivider,
              16.height,
              Row(
                children: [
                  Text(
                    "${locale.value.closedOn}: ",
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      letterSpacing: 0.1,
                      color: secondaryTextColor,
                    ),
                  ),
                  8.width,
                  Text(
                    incidentData.updatedAt.toString().dateInDDMMYYYYFormat,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      letterSpacing: 0.1,
                      color: secondaryTextColor,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: LinearGradient(
          colors: [
            color.withValues(alpha: 0.15),
            color.withValues(alpha: 0.08),
          ],
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color,
            ),
          ),
          6.width,
          Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.1,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
