import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kivicare_patient/main.dart';
import 'package:kivicare_patient/utils/colors.dart';
import 'package:kivicare_patient/utils/empty_error_state_widget.dart';
import 'package:nb_utils/nb_utils.dart';

import 'components/empty_nurse_requests_widget.dart';
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
    final showVerifyBanner = Get.arguments is Map && (Get.arguments as Map)['showVerifyBanner'] == true;

    return Scaffold(
      backgroundColor: context.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Obx(() => Text(locale.value.myRequests, style: boldTextStyle(size: 18))),
        backgroundColor: gradientStart,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          TextButton.icon(
            onPressed: () => Get.to(() => const NurseRequestFormScreen()),
            icon: const Icon(Icons.add, color: Colors.white, size: 20),
            label: Obx(() => Text(locale.value.newRequest, style: const TextStyle(color: Colors.white))),
          ),
        ],
      ),
      body: Column(
        children: [
          if (showVerifyBanner)
            _VerifyBanner(),
          Obx(() => NurseStatusFilterBar(
            selectedStatus: controller.selectedStatus,
            onChanged: controller.applyStatusFilter,
          ).paddingSymmetric(vertical: 8)),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
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
                  itemCount: controller.items.length + (controller.isLoadingMore.value ? 1 : 0),
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
                      onTap: () => Get.to(() => NurseRequestDetailScreen(requestId: item.id)),
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
      color: Colors.amber.shade100,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          const Icon(Icons.warning_amber_rounded, color: Colors.orange),
          8.width,
          Expanded(
            child: Obx(() => Text(locale.value.unknownSubmitOutcomeBanner, style: primaryTextStyle(size: 13))),
          ),
          IconButton(
            icon: const Icon(Icons.close, size: 18),
            onPressed: () => setState(() => _dismissed = true),
          ),
        ],
      ),
    );
  }
}
