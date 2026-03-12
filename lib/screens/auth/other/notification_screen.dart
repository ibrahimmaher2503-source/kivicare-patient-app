import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kivicare_patient/screens/auth/profile/patient_wallet_history_screen.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:kivicare_patient/components/loader_widget.dart';
import '../../../components/app_scaffold.dart';
import '../../../components/cached_image_widget.dart';
import '../../../generated/assets.dart';
import '../../../main.dart';
import '../../../utils/app_common.dart';
import '../../../utils/colors.dart';
import '../../../utils/common_base.dart';
import '../../../utils/empty_error_state_widget.dart';
import '../../booking/appointment_detail_screen.dart';
import '../../booking/model/appointments_res_model.dart';
import '../model/notification_model.dart';
import 'notification_screen_controller.dart';

class NotificationScreen extends StatelessWidget {
  NotificationScreen({super.key});
  final NotificationScreenController notificationScreenController = Get.put(NotificationScreenController());

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => AppScaffoldNew(
        appBartitleText: locale.value.notifications,
        hasLeadingWidget: true,
        appBarVerticalSize: Get.height * 0.12,
        isLoading: notificationScreenController.isLoading,
        body: Obx(
          () => SnapHelperWidget(
            future: notificationScreenController.getNotifications.value,
            errorBuilder: (error) {
              return NoDataWidget(
                title: error,
                retryText: locale.value.reload,
                imageWidget: const ErrorStateWidget(),
                onRetry: () {
                  notificationScreenController.page(1);
                  notificationScreenController.isLoading(true);
                  notificationScreenController.init();
                },
              ).paddingSymmetric(horizontal: 32);
            },
            loadingWidget: notificationScreenController.isLoading.value ? const Offstage() : const LoaderWidget(),
            onSuccess: (notifications) {
              return AnimatedListView(
                shrinkWrap: true,
                padding: const EdgeInsets.all(16),
                itemCount: notifications.length,
                physics: const AlwaysScrollableScrollPhysics(),
                emptyWidget: NoDataWidget(
                  title: locale.value.stayTunedNoNew,
                  subTitle: locale.value.noNewNotificationsAt,
                  titleTextStyle: primaryTextStyle(),
                  imageWidget: const EmptyStateWidget(),
                  retryText: locale.value.reload,
                  onRetry: () {
                    notificationScreenController.page(1);
                    notificationScreenController.isLoading(true);
                    notificationScreenController.init();
                  },
                ).paddingSymmetric(horizontal: 32).paddingBottom(Get.height * 0.1),
                itemBuilder: (context, index) {
                  NotificationData notification = notificationScreenController.notificationDetail[index];
                  final bool isUnread = notification.readAt.trim().isEmpty;

                  return GestureDetector(
                    onTap: () async {
                      if (notification.data.notificationDetail.type == "wallet_refund") {
                        Get.to(() => PatientWalletHistory());
                      } else if (notification.data.notificationDetail.id > 0) {
                        await Get.to(
                          () => AppointmentDetail(),
                          arguments: AppointmentData(
                            id: notification.data.notificationDetail.id,
                            notificationId: notification.readAt.trim().isEmpty ? notification.id : "",
                          ),
                        );
                        notificationScreenController.page(1);
                        notificationScreenController.init();
                      }
                    },
                    behavior: HitTestBehavior.translucent,
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isUnread
                            ? (isDarkMode.value
                                ? appColorSecondary.withValues(alpha: 0.08)
                                : lightSecondaryColor.withValues(alpha: 0.5))
                            : (isDarkMode.value ? surfaceElevatedDark : surfaceElevated),
                        borderRadius: BorderRadius.circular(16),
                        border: isUnread
                            ? Border.all(
                                color: appColorSecondary.withValues(alpha: isDarkMode.value ? 0.15 : 0.12),
                                width: 1,
                              )
                            : null,
                        boxShadow: [
                          BoxShadow(
                            color: isDarkMode.value ? softShadowColorDark : softShadowColor,
                            blurRadius: 16,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Icon container with status indicator
                          Stack(
                            children: [
                              Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: isDarkMode.value
                                      ? appColorPrimary.withValues(alpha: 0.12)
                                      : lightPrimaryColor,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                alignment: Alignment.center,
                                child: CachedImageWidget(
                                  url: Assets.assetsAppLogo,
                                  height: 22,
                                  width: 22,
                                  firstName: "#${notification.data.notificationDetail.id}",
                                  fit: BoxFit.cover,
                                  color: appColorPrimary,
                                ),
                              ),
                              // Unread dot indicator
                              if (isUnread)
                                Positioned(
                                  top: -2,
                                  right: -2,
                                  child: Container(
                                    width: 10,
                                    height: 10,
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                        colors: [gradientSecondaryStart, gradientSecondaryEnd],
                                      ),
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: isDarkMode.value ? surfaceElevatedDark : surfaceElevated,
                                        width: 1.5,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          16.width,
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Notification type label
                              if (notification.data.notificationDetail.type.isNotEmpty)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  margin: const EdgeInsets.only(bottom: 6),
                                  decoration: BoxDecoration(
                                    color: _getNotificationTypeColor(notification.data.notificationDetail.type)
                                        .withValues(alpha: isDarkMode.value ? 0.15 : 0.08),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    getAppointmentNotification(notification: notification.data.notificationDetail.type),
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: _getNotificationTypeColor(notification.data.notificationDetail.type),
                                      letterSpacing: 0.1,
                                    ),
                                  ),
                                ),
                              // Notification message
                              RichText(
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                text: TextSpan(
                                  children: [
                                    TextSpan(
                                      text: notification.data.notificationDetail.id > 0 ? '#${notification.data.notificationDetail.id} - ' : "",
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                        color: appColorSecondary,
                                        letterSpacing: 0.1,
                                      ),
                                    ),
                                    TextSpan(
                                      text: notification.data.notificationDetail.notificationMsg.trim().isNotEmpty
                                          ? notification.data.notificationDetail.notificationMsg
                                          : notification.data.notificationDetail.appointmentServicesNames,
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 13,
                                        fontWeight: isUnread ? FontWeight.w600 : FontWeight.w400,
                                        color: isDarkMode.value ? Colors.white : primaryTextColor,
                                        letterSpacing: 0.1,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              8.height,
                              // Timestamp
                              Text(
                                notification.createdAt.dateInyyyyMMddHHmmFormat.timeAgoWithLocalization,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 12,
                                  color: secondaryTextColor,
                                  letterSpacing: 0.1,
                                ),
                              ),
                            ],
                          ).flexible(),
                        ],
                      ),
                    ),
                  );
                },
                onNextPage: () async {
                  if (!notificationScreenController.isLastPage.value) {
                    notificationScreenController.page(notificationScreenController.page.value + 1);
                    notificationScreenController.isLoading(true);
                    notificationScreenController.init();
                    return await Future.delayed(const Duration(seconds: 2), () {
                      notificationScreenController.isLoading(false);
                    });
                  }
                },
                onSwipeRefresh: () async {
                  notificationScreenController.page(1);
                  return await notificationScreenController.init();
                },
              );
            },
          ),
        ),
      ),
    );
  }

  Color _getNotificationTypeColor(String type) {
    final lower = type.toLowerCase();
    if (lower.contains('cancel')) return cancelStatusColor;
    if (lower.contains('confirm')) return confirmedStatusColor;
    if (lower.contains('complete')) return completedStatusColor;
    if (lower.contains('check_in') || lower.contains('checkin')) return checkInStatusColor;
    if (lower.contains('pending')) return pendingStatusColor;
    if (lower.contains('wallet')) return appColorSecondary;
    return defaultStatusColor;
  }
}
