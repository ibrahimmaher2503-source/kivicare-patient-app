import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../components/app_scaffold.dart';
import '../../components/loader_widget.dart';
import '../../main.dart';
import '../../utils/colors.dart';
import 'components/doctor_visit_card.dart';
import 'doctor_visit_list_controller.dart';
import 'doctor_visit_request_screen.dart';

class DoctorVisitListScreen extends StatefulWidget {
  const DoctorVisitListScreen({super.key});

  @override
  State<DoctorVisitListScreen> createState() => _DoctorVisitListScreenState();
}

class _DoctorVisitListScreenState extends State<DoctorVisitListScreen> {
  late DoctorVisitListController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.put(DoctorVisitListController());
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBartitleText: locale.value.visitRequests,
      actions: [
        IconButton(
          icon: const Icon(Icons.add),
          onPressed: () async {
            final result = await Get.to(() => const DoctorVisitRequestScreen());
            if (result == true) controller.refreshRequests();
          },
        ),
      ],
      body: Column(
        children: [
          // Admin filter bar
          Obx(() {
            if (!controller.isAdminMode) return const SizedBox.shrink();
            return _buildFilterBar();
          }),

          // List
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value && controller.requests.isEmpty) {
                return const LoaderWidget();
              }

              if (controller.requests.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.medical_services_outlined, size: 64, color: Colors.grey.shade400),
                      const SizedBox(height: 16),
                      Text(locale.value.noVisitRequests, style: secondaryTextStyle(size: 16)),
                    ],
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: controller.refreshRequests,
                child: NotificationListener<ScrollNotification>(
                  onNotification: (notification) {
                    if (notification is ScrollEndNotification && notification.metrics.extentAfter < 100) {
                      controller.loadNextPage();
                    }
                    return false;
                  },
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: controller.requests.length + (controller.isLastPage.value ? 0 : 1),
                    itemBuilder: (context, index) {
                      if (index == controller.requests.length) {
                        return const Padding(
                          padding: EdgeInsets.all(16),
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }
                      return DoctorVisitCard(
                        request: controller.requests[index],
                        showPatientName: controller.isAdminMode,
                      );
                    },
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Obx(() => DropdownButtonFormField<String?>(
                  value: controller.selectedStatus.value,
                  isExpanded: true,
                  decoration: InputDecoration(
                    labelText: locale.value.filterByStatus,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    isDense: true,
                  ),
                  items: [
                    DropdownMenuItem(value: null, child: Text(locale.value.all)),
                    DropdownMenuItem(value: 'pending', child: Text(locale.value.statusPendingLabel)),
                    DropdownMenuItem(value: 'confirmed', child: Text(locale.value.statusConfirmedLabel)),
                    DropdownMenuItem(value: 'cancelled', child: Text(locale.value.statusCancelledLabel)),
                    DropdownMenuItem(value: 'completed', child: Text(locale.value.statusCompletedLabel)),
                  ],
                  onChanged: (value) {
                    controller.selectedStatus.value = value;
                    controller.applyFilters();
                  },
                )),
          ),
          const SizedBox(width: 8),
          Obx(() {
            if (controller.activeFilterCount == 0) return const SizedBox.shrink();
            return TextButton(
              onPressed: controller.clearFilters,
              child: Text(locale.value.reset, style: primaryTextStyle(size: 12, color: appColorPrimary)),
            );
          }),
        ],
      ),
    );
  }
}
