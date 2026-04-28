import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../components/app_scaffold.dart';
import '../../../components/cached_image_widget.dart';
import '../../../main.dart';
import '../../../utils/colors.dart';
import 'visit_request_form_controller.dart';

class VisitRequestFormScreen extends StatelessWidget {
  const VisitRequestFormScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(VisitRequestFormController(), permanent: false);

    return AppScaffold(
      appBartitleText: locale.value.newHomeVisitRequest,
      hasLeadingWidget: true,
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _SectionLabel(locale.value.visitReason),
                  8.height,
                  Obx(() => _ReasonField(controller: controller)),
                  24.height,
                  _SectionLabel(locale.value.preferredDate),
                  8.height,
                  Obx(() => _DatePickerField(controller: controller)),
                  24.height,
                  _SectionLabel(locale.value.contactPhone),
                  8.height,
                  Obx(() => _PhoneField(controller: controller)),
                  24.height,
                  _SectionLabel(locale.value.preferredDoctorOptional),
                  8.height,
                  Obx(() => _DoctorPickerField(
                        controller: controller,
                        onTap: () => _showDoctorPicker(context, controller),
                      )),
                  24.height,
                  _SectionLabel(locale.value.additionalNotesOptional),
                  8.height,
                  Obx(() => _NotesField(controller: controller)),
                  32.height,
                ],
              ),
            ),
          ),
          Obx(() => SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
                  child: SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed:
                          controller.isSubmitting.value ? null : controller.submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: gradientStart,
                        disabledBackgroundColor: Colors.grey.shade300,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: controller.isSubmitting.value
                          ? const CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white)
                          : Text(
                              locale.value.submitRequest,
                              style: boldTextStyle(color: Colors.white, size: 16),
                            ),
                    ),
                  ),
                ),
              )),
        ],
      ),
    );
  }

  void _showDoctorPicker(
      BuildContext context, VisitRequestFormController controller) {
    controller.loadDoctors();
    final searchController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setState) => DraggableScrollableSheet(
          initialChildSize: 0.75,
          maxChildSize: 0.95,
          minChildSize: 0.5,
          builder: (_, scrollController) => Container(
            decoration: BoxDecoration(
              color: context.scaffoldBackgroundColor,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              children: [
                const SizedBox(height: 12),
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    locale.value.selectPreferredDoctor,
                    style: boldTextStyle(size: 16),
                  ),
                ),
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: TextField(
                    controller: searchController,
                    decoration: InputDecoration(
                      hintText: locale.value.searchHere,
                      prefixIcon: const Icon(Icons.search, size: 20),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 10),
                    ),
                    onChanged: (val) => controller.loadDoctors(search: val),
                  ),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: Obx(() {
                    if (controller.isDoctorSearching.value &&
                        controller.doctorSearchResults.isEmpty) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (controller.doctorSearchResults.isEmpty) {
                      return Center(
                        child: Text(
                          locale.value.noDoctorAssignedYet,
                          style: secondaryTextStyle(),
                        ),
                      );
                    }
                    return ListView.builder(
                      controller: scrollController,
                      itemCount: controller.doctorSearchResults.length,
                      itemBuilder: (_, i) {
                        final doc = controller.doctorSearchResults[i];
                        return ListTile(
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(24),
                            child: CachedImageWidget(
                              url: doc.avatar ?? '',
                              height: 48,
                              width: 48,
                              fit: BoxFit.cover,
                            ),
                          ),
                          title: Text(doc.name, style: boldTextStyle(size: 14)),
                          subtitle: doc.specialty != null
                              ? Text(doc.specialty!,
                                  style: secondaryTextStyle(size: 12))
                              : null,
                          onTap: () {
                            controller.selectedDoctor.value = doc;
                            Get.back();
                          },
                        );
                      },
                    );
                  }),
                ),
              ],
            ),
          ),
        ),
      ),
    ).whenComplete(searchController.dispose);
  }
}

class _SectionLabel extends StatelessWidget {
  final String title;
  const _SectionLabel(this.title);

  @override
  Widget build(BuildContext context) {
    return Text(title, style: boldTextStyle(size: 14, color: appColorPrimary));
  }
}

class _ReasonField extends StatelessWidget {
  final VisitRequestFormController controller;
  const _ReasonField({required this.controller});

  @override
  Widget build(BuildContext context) {
    final errorText = controller.fieldErrors['reason'];
    return TextField(
      controller: controller.reasonController,
      maxLines: 4,
      maxLength: 1000,
      decoration: InputDecoration(
        hintText: locale.value.visitReasonHint,
        errorText: errorText,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      ),
    );
  }
}

class _DatePickerField extends StatelessWidget {
  final VisitRequestFormController controller;
  const _DatePickerField({required this.controller});

  @override
  Widget build(BuildContext context) {
    final errorText = controller.fieldErrors['date'];
    final selected = controller.preferredDate.value;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () async {
            final now = DateTime.now();
            final picked = await showDatePicker(
              context: context,
              initialDate: selected ?? now,
              firstDate: now,
              lastDate: now.add(const Duration(days: 365)),
            );
            if (picked != null) {
              controller.preferredDate.value = picked;
              controller.fieldErrors.remove('date');
            }
          },
          child: Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            decoration: BoxDecoration(
              border: Border.all(
                color: errorText != null ? Colors.red : Colors.grey.shade400,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.calendar_today_outlined,
                  size: 18,
                  color: errorText != null ? Colors.red : appColorSecondary,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    selected != null
                        ? DateFormat('EEEE, d MMMM yyyy').format(selected)
                        : locale.value.preferredDate,
                    style: selected != null
                        ? primaryTextStyle(size: 14)
                        : secondaryTextStyle(size: 14),
                  ),
                ),
                Icon(Icons.arrow_drop_down,
                    color: Colors.grey.shade500),
              ],
            ),
          ),
        ),
        if (errorText != null) ...[
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.only(left: 4),
            child: Text(
              errorText,
              style: const TextStyle(color: Colors.red, fontSize: 12),
            ),
          ),
        ],
      ],
    );
  }
}

class _PhoneField extends StatelessWidget {
  final VisitRequestFormController controller;
  const _PhoneField({required this.controller});

  @override
  Widget build(BuildContext context) {
    final errorText = controller.fieldErrors['phone'];
    return TextField(
      controller: controller.phoneController,
      keyboardType: TextInputType.phone,
      decoration: InputDecoration(
        prefixIcon:
            const Icon(Icons.phone_outlined, size: 20),
        hintText: '+201001234567',
        errorText: errorText,
        border:
            OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      ),
    );
  }
}

class _DoctorPickerField extends StatelessWidget {
  final VisitRequestFormController controller;
  final VoidCallback onTap;

  const _DoctorPickerField({
    required this.controller,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final selected = controller.selectedDoctor.value;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade400),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            const Icon(Icons.person_search_outlined,
                size: 20, color: appColorSecondary),
            const SizedBox(width: 10),
            Expanded(
              child: selected != null
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(selected.name,
                            style: primaryTextStyle(size: 14)),
                        if (selected.specialty != null)
                          Text(selected.specialty!,
                              style: secondaryTextStyle(size: 12)),
                      ],
                    )
                  : Text(
                      locale.value.selectPreferredDoctor,
                      style: secondaryTextStyle(size: 14),
                    ),
            ),
            if (selected != null)
              GestureDetector(
                onTap: () => controller.selectedDoctor.value = null,
                child: Icon(Icons.clear, size: 18, color: Colors.grey.shade500),
              )
            else
              Icon(Icons.arrow_drop_down, color: Colors.grey.shade500),
          ],
        ),
      ),
    );
  }
}

class _NotesField extends StatelessWidget {
  final VisitRequestFormController controller;
  const _NotesField({required this.controller});

  @override
  Widget build(BuildContext context) {
    final errorText = controller.fieldErrors['notes'];
    return TextField(
      controller: controller.notesController,
      maxLines: 3,
      maxLength: 2000,
      decoration: InputDecoration(
        hintText: locale.value.additionalNotesHint,
        errorText: errorText,
        border:
            OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      ),
    );
  }
}
