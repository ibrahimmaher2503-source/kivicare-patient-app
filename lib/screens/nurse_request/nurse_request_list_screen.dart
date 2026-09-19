import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kivicare_patient/main.dart';
import 'package:kivicare_patient/utils/colors.dart';
import 'package:kivicare_patient/utils/empty_error_state_widget.dart';
import 'package:nb_utils/nb_utils.dart';

import 'components/empty_nurse_requests_widget.dart';
import 'components/nurse_request_design.dart';
import 'components/nurse_request_card.dart';
import 'components/nurse_status_filter_bar.dart';
import 'detail/nurse_request_detail_screen.dart';
import 'nurse_request_list_controller.dart';
import 'request_form/nurse_request_form_screen.dart';

class NurseRequestListScreen extends StatelessWidget {
  const NurseRequestListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(NurseRequestListController(), permanent: false);
    final showVerifyBanner =
        Get.arguments is Map &&
        (Get.arguments as Map)['showVerifyBanner'] == true;

    return Scaffold(
      backgroundColor: context.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Obx(
          () => Text(
            locale.value.myRequests,
            style: boldTextStyle(size: 18, color: whiteTextColor),
          ),
        ),
        backgroundColor: gradientStart,
        foregroundColor: whiteTextColor,
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Get.to(() => const NurseRequestFormScreen()),
        backgroundColor: gradientStart,
        foregroundColor: whiteTextColor,
        icon: const Icon(Icons.add, size: 22),
        label: Obx(() => Text(locale.value.newRequest, style: boldTextStyle(color: whiteTextColor, size: 14))),
        elevation: 3,
      ),
      body: Column(
        children: [
          if (showVerifyBanner) _VerifyBanner(),
          NurseStatusFilterBar(
            selectedStatus: controller.selectedStatus,
            onChanged: controller.applyStatusFilter,
          ).paddingSymmetric(vertical: 8),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const _NurseRequestsLoadingState();
              }
              if (controller.error.value != null && controller.items.isEmpty) {
                return NoDataWidget(
                  title: controller.error.value!,
                  retryText: locale.value.retry,
                  imageWidget: const ErrorStateWidget(),
                  onRetry: controller.refresh,
                ).paddingSymmetric(horizontal: 16);
              }
              if (controller.items.isEmpty) {
                return const EmptyNurseRequestsWidget();
              }
              return RefreshIndicator(
                onRefresh: controller.refresh,
                child: ListView.builder(
                  controller: controller.scrollController,
                  padding: const EdgeInsets.only(top: 8, bottom: 24),
                  itemCount:
                      controller.items.length +
                      (controller.isLoadingMore.value ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == controller.items.length) {
                      return const Padding(
                        padding: EdgeInsets.all(16),
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }
                    final item = controller.items[index];
                    return NurseRequestCard(
                      request: item,
                      onTap: () => Get.to(
                        () => NurseRequestDetailScreen(requestId: item.id),
                      ),
                    );
                  },
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _VerifyBanner extends StatefulWidget {
  @override
  State<_VerifyBanner> createState() => _VerifyBannerState();
}

class _VerifyBannerState extends State<_VerifyBanner> {
  bool _dismissed = false;

  @override
  Widget build(BuildContext context) {
    if (_dismissed) return const SizedBox.shrink();
    return Container(
      decoration: BoxDecoration(
        color: pendingStatusColor.withValues(alpha: 0.13),
        border: Border(
          bottom: BorderSide(color: pendingStatusColor.withValues(alpha: 0.24)),
        ),
      ),
      padding: const EdgeInsetsDirectional.fromSTEB(16, 10, 8, 10),
      child: Row(
        children: [
          const Icon(
            Icons.warning_amber_rounded,
            color: pendingStatusColor,
            size: 20,
          ),
          10.width,
          Expanded(
            child: Obx(
              () => Text(
                locale.value.unknownSubmitOutcomeBanner,
                style: primaryTextStyle(size: 13),
              ),
            ),
          ),
          IconButton(
            constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
            icon: const Icon(Icons.close, size: 18, color: pendingStatusColor),
            onPressed: () => setState(() => _dismissed = true),
          ),
        ],
      ),
    );
  }
}

class _NurseRequestsLoadingState extends StatelessWidget {
  const _NurseRequestsLoadingState();

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      itemCount: 4,
      itemBuilder: (context, index) => Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: nurseRequestCardDecoration(context),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const _SkeletonLine(width: 132, height: 16),
                const Spacer(),
                const _SkeletonLine(width: 82, height: 28, radius: 14),
              ],
            ),
            14.height,
            const _SkeletonLine(width: double.infinity, height: 14),
            8.height,
            const _SkeletonLine(width: 220, height: 14),
            16.height,
            const _SkeletonLine(width: 180, height: 13),
            8.height,
            const _SkeletonLine(width: 240, height: 13),
          ],
        ),
      ),
    );
  }
}

class _SkeletonLine extends StatelessWidget {
  final double width;
  final double height;
  final double radius;

  const _SkeletonLine({
    required this.width,
    required this.height,
    this.radius = 8,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: nurseRequestSkeletonColor(context),
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}
