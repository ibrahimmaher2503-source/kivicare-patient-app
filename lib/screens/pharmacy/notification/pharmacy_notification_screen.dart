import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';
import '../../../api/pharmacy_apis.dart';
import '../../../components/app_scaffold.dart';
import '../../../models/base_response_model.dart';
import '../../../main.dart';
import '../../../network/network_utils.dart';
import '../../../utils/colors.dart';
import '../model/pharmacy_notification_model.dart';
import '../model/pharmacy_parsers.dart';
import '../order/pharmacy_order_detail_screen.dart';
import '../pharmacy_controller.dart';
import '../utils/pharmacy_empty_state.dart';

class PharmacyNotificationController extends GetxController {
  RxBool isLoading = false.obs;
  RxList<PharmacyNotification> notifications = <PharmacyNotification>[].obs;
  RxInt page = 1.obs;
  RxBool isLastPage = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchNotifications();
  }

  Future<void> fetchNotifications() async {
    if (isLoading.value) return;
    isLoading(true);

    try {
      final res = await PharmacyApis.getNotifications(page: page.value);
      if (res != null && res['data'] != null) {
        final List<PharmacyNotification> newItems = (res['data'] as List)
            .map((e) => PharmacyNotification.fromJson(e))
            .toList();
        if (page.value == 1) {
          notifications(newItems);
        } else {
          notifications.addAll(newItems);
        }
        isLastPage(newItems.length < 10);
      }
    } catch (e) {
      log('Error fetching notifications: $e');
    } finally {
      isLoading(false);
    }
  }

  Future<void> markAllAsRead() async {
    isLoading(true);
    try {
      final res = await PharmacyApis.markAllNotificationsAsRead();
      if (res.status) {
        for (var n in notifications) {
          n.isRead = true;
        }
        notifications.refresh();
        Get.find<PharmacyController>().unreadNotificationsCount(0);
      }
    } catch (e) {
      toast(sanitizeBackendMessage(e, locale.value.somethingWentWrong));
    } finally {
      isLoading(false);
    }
  }

  void handleNotificationClick(PharmacyNotification notification) async {
    if (notification.isRead != true) {
      // Optimistic local update — no network round-trip for the count.
      // The server mark-read call fires in the background; the unread count
      // is synced with the server on the next pull-to-refresh (see refresh()).
      notification.isRead = true;
      notifications.refresh();
      final pharmacyController = Get.find<PharmacyController>();
      if (pharmacyController.unreadNotificationsCount.value > 0) {
        pharmacyController.unreadNotificationsCount.value--;
      }
      // Fire-and-forget: persist the read state on the server.
      PharmacyApis.markNotificationAsRead(notification.id!).catchError((e) {
        log('Error marking notification as read: $e');
        return BaseResponseModel();
      });
    }

    // Deep linking logic
    if (notification.type == 'order_update') {
      final orderId = pharmacyInt(notification.data?['order_id']);
      if (orderId != null) {
        Get.to(() => PharmacyOrderDetailScreen(orderId: orderId));
      }
    } else if (notification.type == 'prescription_update') {
      // Need a way to fetch prescription or pass it
      // For now, back to list or detail if ID is present
    }
  }

  Future<void> loadMore() async {
    if (!isLastPage.value && !isLoading.value) {
      page.value++;
      await fetchNotifications();
    }
  }

  @override
  Future<void> refresh() async {
    page(1);
    isLastPage(false);
    // Re-sync the unread count from the server when the user explicitly
    // pulls to refresh — this is the only network call for count updates.
    await Future.wait([
      fetchNotifications(),
      Get.find<PharmacyController>().updateUnreadNotificationsCount(),
    ]);
  }
}

class PharmacyNotificationScreen extends StatelessWidget {
  PharmacyNotificationScreen({super.key});

  final PharmacyNotificationController controller =
      Get.put(PharmacyNotificationController());

  @override
  Widget build(BuildContext context) {
    return AppScaffoldNew(
      appBartitleText: locale.value.notifications,
      isLoading: controller.isLoading,
      scaffoldBackgroundColor: appLayoutBackground,
      actions: [
        TextButton(
          onPressed: controller.markAllAsRead,
          child: Text(locale.value.markAllAsRead,
              style: boldTextStyle(color: appColorSecondary, size: 13)),
        ),
      ],
      body: Obx(
          () => controller.notifications.isEmpty && !controller.isLoading.value
              ? PharmacyEmptyState(
                  icon: Icons.notifications_none_outlined,
                  title: locale.value.pharmacyNoNotifications,
                )
              : AnimatedScrollView(
                  padding: const EdgeInsets.all(16),
                  onSwipeRefresh: () => controller.refresh(),
                  onNextPage: () => controller.loadMore(),
                  children: [
                    ...controller.notifications.map((notification) =>
                        _NotificationWidget(
                            notification: notification,
                            controller: controller)),
                  ],
                )),
    );
  }
}

class _NotificationWidget extends StatelessWidget {
  final PharmacyNotification notification;
  final PharmacyNotificationController controller;

  const _NotificationWidget(
      {required this.notification, required this.controller});

  @override
  Widget build(BuildContext context) {
    final bool unread = !(notification.isRead ?? false);
    return GestureDetector(
      onTap: () => controller.handleNotificationClick(notification),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: surfaceElevated,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
                color: softShadowColor,
                blurRadius: 16,
                offset: const Offset(0, 6))
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 44,
              width: 44,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(13),
                gradient: unread
                    ? const LinearGradient(
                        colors: [
                          gradientSecondaryStart,
                          gradientSecondaryEnd,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : null,
                color: unread ? null : surfaceSubtle,
                border: unread
                    ? null
                    : Border.all(color: whiteBorderColor, width: 1),
                boxShadow: unread
                    ? [
                        BoxShadow(
                          color: appColorSecondary.withValues(alpha: 0.22),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : null,
              ),
              child: Icon(
                _getIconForType(notification.type),
                color: unread ? Colors.white : appColorSecondary,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(notification.title ?? '',
                      style: boldTextStyle(size: 14, color: appColorPrimary)),
                  const SizedBox(height: 4),
                  Text(
                    notification.body ?? '',
                    style: primaryTextStyle(size: 13, color: gray500),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Text(notification.createdAt ?? '',
                      style: secondaryTextStyle(size: 12)),
                ],
              ),
            ),
            if (unread) ...[
              const SizedBox(width: 8),
              Container(
                height: 8,
                width: 8,
                decoration: const BoxDecoration(
                    color: appColorSecondary, shape: BoxShape.circle),
              ),
            ],
          ],
        ),
      ),
    );
  }

  IconData _getIconForType(String? type) {
    switch (type) {
      case 'order_update':
        return Icons.local_shipping_rounded;
      case 'prescription_update':
        return Icons.medical_information_rounded;
      case 'refund_update':
        return Icons.replay_rounded;
      default:
        return Icons.notifications_active_rounded;
    }
  }
}
