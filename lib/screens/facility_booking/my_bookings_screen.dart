import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kivicare_patient/screens/facility_booking/my_bookings_controller.dart';
import 'package:kivicare_patient/screens/facility_booking/booking_detail_screen.dart';
import 'package:kivicare_patient/screens/facility_booking/components/facility_booking_card.dart';
import 'package:kivicare_patient/utils/colors.dart';
import 'package:kivicare_patient/utils/common_base.dart';
import 'package:kivicare_patient/components/app_scaffold.dart';
import 'package:kivicare_patient/components/loader_widget.dart';
import 'package:kivicare_patient/utils/empty_error_state_widget.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../main.dart';
import '../../utils/app_common.dart';

class MyBookingsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final controller = Get.put(MyBookingsController());

    return AppScaffold(
      appBarTitle: Text(locale.value.myBookings),
      body: GetBuilder<MyBookingsController>(
        init: controller,
        builder: (controller) {
          return SingleChildScrollView(
            child: Column(
              children: [
                // Filter Tabs
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                  child: Row(
                    children: [
                      // Type Filter
                      Text(
                        locale.value.type,
                        style: secondaryTextStyle(size: 12),
                      ),
                      const SizedBox(width: 12.0),
                      Wrap(
                        spacing: 8.0,
                        children: [
                          _FilterChip(
                            label: locale.value.all,
                            selected: controller.selectedType.value == null,
                            onTap: () => controller.filterByType(null),
                          ),
                          _FilterChip(
                            label: locale.value.laboratory,
                            selected: controller.selectedType.value == 'lab',
                            onTap: () => controller.filterByType('lab'),
                          ),
                          _FilterChip(
                            label: locale.value.radiologyCenter,
                            selected: controller.selectedType.value == 'radiology',
                            onTap: () => controller.filterByType('radiology'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Status Filter
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Row(
                    children: [
                      Text(
                        locale.value.status,
                        style: secondaryTextStyle(size: 12),
                      ),
                      const SizedBox(width: 12.0),
                      Wrap(
                        spacing: 8.0,
                        children: [
                          _FilterChip(
                            label: locale.value.all,
                            selected: controller.selectedStatus.value == null,
                            onTap: () => controller.filterByStatus(null),
                          ),
                          _FilterChip(
                            label: locale.value.pending,
                            selected: controller.selectedStatus.value == 'pending',
                            onTap: () => controller.filterByStatus('pending'),
                          ),
                          _FilterChip(
                            label: locale.value.confirmed,
                            selected: controller.selectedStatus.value == 'confirmed',
                            onTap: () => controller.filterByStatus('confirmed'),
                          ),
                          _FilterChip(
                            label: locale.value.completed,
                            selected: controller.selectedStatus.value == 'completed',
                            onTap: () => controller.filterByStatus('completed'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24.0),

                // Bookings List
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Obx(
                    () => controller.isLoading.value
                        ? Center(child: LoaderWidget())
                        : controller.bookings.isEmpty
                            ? EmptyErrorStateWidget(
                                title: locale.value.noBookingsFound,
                                subTitle: locale.value.youHaveNoBookingsYet,
                                onRetry: controller.loadBookings,
                              )
                            : ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: controller.bookings.length,
                                itemBuilder: (context, index) {
                                  final booking = controller.bookings[index];
                                  return FacilityBookingCard(
                                    booking: booking,
                                    onTap: () {
                                      Get.to(() => BookingDetailScreen(bookingId: booking.id));
                                    },
                                    onCancel: controller.canCancelBooking(booking)
                                        ? () => controller.cancelBookingWithReason(booking.id, context)
                                        : null,
                                  );
                                },
                              ),
                  ),
                ),

                // Load More
                if (!controller.isLastPage.value && controller.bookings.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24.0),
                    child: Center(
                      child: ElevatedButton(
                        onPressed: () => controller.loadMoreBookings(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: appColorPrimary,
                          padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 12.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                        ),
                        child: Text(
                          locale.value.loadMore,
                          style: boldTextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ),

                const SizedBox(height: 24.0),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
        decoration: BoxDecoration(
          color: selected ? appColorPrimary : (isDarkMode.value ? cardDarkColor : gray100),
          border: Border.all(
            color: selected ? appColorPrimary : (isDarkMode.value ? gray700 : gray200),
          ),
          borderRadius: BorderRadius.circular(20.0),
        ),
        child: Text(
          label,
          style: boldTextStyle(
            size: 12,
            color: selected ? Colors.white : (isDarkMode.value ? whiteColor : blackColor),
          ),
        ),
      ),
    );
  }
}
