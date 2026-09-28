import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:kivicare_patient/screens/labs_radiology/labs_radiology_common.dart';
import 'package:kivicare_patient/components/loader_widget.dart';
import 'package:kivicare_patient/utils/locale_formatters.dart';
import '../models/facility_model.dart';
import '../models/lab_test_model.dart';
import '../models/slot_model.dart';
import 'booking_confirmation_controller.dart';

class BookingConfirmationScreen extends StatelessWidget {
  final FacilityModel facility;
  final LabTestModel test;
  final DateTime selectedDate;
  final SlotModel selectedSlot;

  const BookingConfirmationScreen({
    super.key,
    required this.facility,
    required this.test,
    required this.selectedDate,
    required this.selectedSlot,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(BookingConfirmationController(
      facility: facility,
      test: test,
      selectedDate: selectedDate,
      selectedSlot: selectedSlot,
    ));

    return Scaffold(
      appBar: appBarWidget(
        locale.value.confirmBooking,
        textColor: Colors.white,
        systemUiOverlayStyle: defaultSystemUiOverlayStyle(context),
      ),
      body: Stack(
        children: [
          AnimatedScrollView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildSummaryCard(context),
              24.height,
              Text(locale.value.patientNotesOptional, style: boldTextStyle()),
              8.height,
              AppTextField(
                controller: controller.notesController,
                textFieldType: TextFieldType.MULTILINE,
                maxLines: 5,
                decoration: inputDecoration(context,
                    labelText: locale.value.patientNotesHint),
              ),
              80.height,
            ],
          ),
          Obx(() => const LoaderWidget()
              .center()
              .visible(controller.isLoading.value)),
        ],
      ),
      bottomNavigationBar: Obx(() => Container(
            padding: const EdgeInsets.all(16),
            decoration: boxDecorationDefault(
                color: context.cardColor, borderRadius: radius(0)),
            child: AppButton(
              text: locale.value.confirmAndBook,
              color: context.primaryColor,
              textStyle: boldTextStyle(color: Colors.white),
              width: double.infinity,
              onTap: () => controller.confirmBooking(),
            ),
          ).visible(!controller.isLoading.value)),
    );
  }

  Widget _buildSummaryCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: boxDecorationDefault(
          color: context.cardColor, borderRadius: radius(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(locale.value.bookingSummary, style: boldTextStyle(size: 18)),
          16.height,
          _buildSummaryRow(locale.value.service, test.name),
          8.height,
          _buildSummaryRow(locale.value.clinic, facility.name),
          Divider(height: 32, color: context.dividerColor),
          _buildSummaryRow(locale.value.date,
              formatLocalizedDate(selectedDate, 'EEEE, d MMMM yyyy')),
          8.height,
          _buildSummaryRow(locale.value.time,
              selectedSlot.formattedRange(selectedLanguageCode.value)),
          Divider(height: 32, color: context.dividerColor),
          _buildSummaryRow(
            locale.value.testPrice,
            formatLocalizedCurrency(test.price ?? 0, test.currency),
            valueColor: context.primaryColor,
            isBold: true,
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value,
      {Color? valueColor, bool isBold = false}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: secondaryTextStyle()).expand(flex: 2),
        Text(
          value,
          style: isBold
              ? boldTextStyle(color: valueColor, size: 14)
              : primaryTextStyle(color: valueColor, size: 14),
          textAlign: TextAlign.end,
        ).expand(flex: 3),
      ],
    );
  }
}
