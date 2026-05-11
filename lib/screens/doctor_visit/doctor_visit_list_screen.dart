import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../components/app_scaffold.dart';
import '../../main.dart';
import '../../utils/app_common.dart';
import '../../utils/colors.dart';
import 'components/visit_request_card.dart';
import 'detail/visit_request_detail_screen.dart';
import 'doctor_visit_list_controller.dart';
import 'models/visit_status.dart';
import 'request_form/visit_request_form_screen.dart';

class DoctorVisitListScreen extends StatelessWidget {
  const DoctorVisitListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(DoctorVisitListController());

    return AppScaffold(
      appBartitleText: locale.value.homeVisitRequests,
      hasLeadingWidget: true,
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh_outlined),
          onPressed: controller.refresh,
          tooltip: locale.value.refresh,
        ),
      ],
      body: Column(
        children: [
          _FilterChipsRow(controller: controller),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value && controller.requests.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }

              if (controller.error.value.isNotEmpty &&
                  controller.requests.isEmpty) {
                return _ErrorState(controller: controller);
              }

              if (controller.requests.isEmpty) {
                return _EmptyState();
              }

              return RefreshIndicator(
                onRefresh: controller.refresh,
                child: ListView.builder(
                  controller: controller.scrollController,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: controller.requests.length +
                      (controller.isLoadingMore.value ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == controller.requests.length) {
                      return const Padding(
                        padding: EdgeInsets.all(16),
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }
                    final req = controller.requests[index];
                    return VisitRequestCard(
                      request: req,
                      onTap: () => Get.to(
                        () => VisitRequestDetailScreen(
                          referenceNumber: req.referenceNumber,
                        ),
                      ),
                    );
                  },
                ),
              );
            }),
          ),
        ],
      ),
      fabWidget: FloatingActionButton.extended(
        onPressed: () async {
          await Get.to(() => const VisitRequestFormScreen());
          controller.refresh();
        },
        backgroundColor: gradientStart,
        foregroundColor: whiteTextColor,
        icon: const Icon(Icons.add, size: 22),
        label: Text(
          locale.value.newRequest,
          style: boldTextStyle(color: whiteTextColor, size: 14),
        ),
        elevation: 3,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}

class _FilterChipsRow extends StatelessWidget {
  final DoctorVisitListController controller;

  const _FilterChipsRow({required this.controller});

  @override
  Widget build(BuildContext context) {
    final filters = <VisitStatus?>[
      null,
      VisitStatus.pending,
      VisitStatus.confirmed,
      VisitStatus.completed,
      VisitStatus.cancelled,
    ];

    final labels = {
      null: locale.value.all,
      VisitStatus.pending: locale.value.pending,
      VisitStatus.confirmed: locale.value.confirmed,
      VisitStatus.completed: locale.value.completed,
      VisitStatus.cancelled: locale.value.cancelled,
    };

    return Obx(() {
      final dark = isDarkMode.value;
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: filters.map((status) {
            final isSelected = controller.statusFilter.value == status;
            return GestureDetector(
              onTap: () => controller.setFilter(status),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.only(right: 8),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected
                      ? gradientStart
                      : (dark ? surfaceElevatedDark : surfaceSubtle),
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(
                    color: isSelected
                        ? gradientStart
                        : (dark ? borderColorDark : whiteBorderColor),
                  ),
                ),
                child: Text(
                  labels[status] ?? locale.value.all,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight:
                        isSelected ? FontWeight.w600 : FontWeight.w400,
                    color: isSelected
                        ? whiteTextColor
                        : (dark ? textSecondaryDark : secondaryTextColor),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      );
    });
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [gradientSecondaryStart, gradientSecondaryEnd],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.medical_services_outlined,
                size: 36,
                color: whiteTextColor,
              ),
            ),
            18.height,
            Text(
              locale.value.noVisitRequestsTitle,
              style: boldTextStyle(size: 16),
              textAlign: TextAlign.center,
            ),
            8.height,
            Text(
              locale.value.requestYourFirstVisit,
              style: secondaryTextStyle(size: 13),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final DoctorVisitListController controller;

  const _ErrorState({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            size: 48,
            color: cancelStatusColor,
          ),
          12.height,
          Text(locale.value.somethingWentWrong, style: boldTextStyle()),
          8.height,
          TextButton(
            onPressed: controller.fetchRequests,
            child: Text(
              locale.value.retry,
              style: TextStyle(color: gradientStart),
            ),
          ),
        ],
      ),
    );
  }
}
