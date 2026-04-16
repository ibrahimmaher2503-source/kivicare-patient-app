import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../components/app_scaffold.dart';
import '../../main.dart';
import '../../utils/colors.dart';
import 'doctor_visit_request_controller.dart';

class DoctorVisitRequestScreen extends StatefulWidget {
  const DoctorVisitRequestScreen({super.key});

  @override
  State<DoctorVisitRequestScreen> createState() => _DoctorVisitRequestScreenState();
}

class _DoctorVisitRequestScreenState extends State<DoctorVisitRequestScreen> {
  late DoctorVisitRequestController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.put(DoctorVisitRequestController());
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBartitleText: locale.value.submitVisitRequest,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: controller.formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Visit Reason
              Text(locale.value.visitReason, style: boldTextStyle(size: 14)),
              const SizedBox(height: 8),
              TextFormField(
                controller: controller.visitReasonCont,
                maxLines: 4,
                maxLength: 1000,
                validator: controller.validateVisitReason,
                decoration: InputDecoration(
                  hintText: locale.value.visitReason,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 16),

              // Preferred Date
              Text(locale.value.preferredDate, style: boldTextStyle(size: 14)),
              const SizedBox(height: 8),
              Obx(() => InkWell(
                    onTap: () => controller.pickDate(context),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade400),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              controller.preferredDate.value != null
                                  ? '${controller.preferredDate.value!.year}-${controller.preferredDate.value!.month.toString().padLeft(2, '0')}-${controller.preferredDate.value!.day.toString().padLeft(2, '0')}'
                                  : locale.value.preferredDate,
                              style: controller.preferredDate.value != null
                                  ? primaryTextStyle()
                                  : secondaryTextStyle(),
                            ),
                          ),
                          Icon(Icons.calendar_today, color: appColorPrimary, size: 20),
                        ],
                      ),
                    ),
                  )),
              const SizedBox(height: 16),

              // Contact Phone
              Text(locale.value.contactPhone, style: boldTextStyle(size: 14)),
              const SizedBox(height: 8),
              TextFormField(
                controller: controller.contactPhoneCont,
                keyboardType: TextInputType.phone,
                maxLength: 20,
                validator: controller.validateContactPhone,
                decoration: InputDecoration(
                  hintText: locale.value.contactPhone,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  prefixIcon: const Icon(Icons.phone),
                ),
              ),
              const SizedBox(height: 16),

              // Additional Notes
              Text(locale.value.additionalNotes, style: boldTextStyle(size: 14)),
              const SizedBox(height: 8),
              TextFormField(
                controller: controller.additionalNotesCont,
                maxLines: 3,
                maxLength: 2000,
                decoration: InputDecoration(
                  hintText: '${locale.value.additionalNotes} (${locale.value.optional})',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 24),

              // Submit Button
              Obx(() => SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: controller.isLoading.value ? null : controller.submitRequest,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: appColorPrimary,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: controller.isLoading.value
                          ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : Text(locale.value.submitVisitRequest, style: boldTextStyle(color: Colors.white)),
                    ),
                  )),
            ],
          ),
        ),
      ),
    );
  }
}
