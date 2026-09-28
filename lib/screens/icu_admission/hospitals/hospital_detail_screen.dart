import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';
import '../../../components/cached_image_widget.dart';
import '../../../main.dart';
import '../../../utils/colors.dart';
import '../../../utils/common_base.dart';
import '../components/department_chip.dart';
import '../components/icu_empty_state.dart';
import '../components/icu_shimmer.dart';
import '../form/admission_request_form_screen.dart';
import 'hospital_detail_controller.dart';

class HospitalDetailScreen extends StatelessWidget {
  final int hospitalId;

  const HospitalDetailScreen({super.key, required this.hospitalId});

  @override
  Widget build(BuildContext context) {
    final controller =
        Get.put(HospitalDetailController(hospitalId: hospitalId));

    return Scaffold(
      appBar: AppBar(title: Text(locale.value.hospitalDetail)),
      body: Stack(
        children: [
          Obx(() {
            if (controller.isLoading.value &&
                controller.hospital.value == null) {
              return const IcuShimmer(itemCount: 1, height: 300);
            }
            if (controller.hospital.value == null) {
              return IcuEmptyState(onRetry: controller.getHospitalDetail);
            }

            final h = controller.hospital.value!;
            final location = h.formattedLocation;
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CachedImageWidget(
                    url: h.imageUrl.validate(),
                    height: 200,
                    width: Get.width,
                    fit: BoxFit.cover,
                    radius: defaultRadius,
                  ),
                  16.height,
                  Text(h.name, style: boldTextStyle(size: 20)),
                  8.height,
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined,
                          size: 16, color: secondaryTextColor),
                      4.width,
                      Text(
                          location.isEmpty
                              ? locale.value.locationUnavailable
                              : location,
                          style: secondaryTextStyle()),
                    ],
                  ),
                  24.height,
                  Text(locale.value.aboutHospital, style: boldTextStyle()),
                  8.height,
                  Text(h.description.validate(), style: secondaryTextStyle()),
                  24.height,
                  Text(locale.value.icuDepartments, style: boldTextStyle()),
                  8.height,
                  if (h.icuDepartments.isEmpty)
                    Text(locale.value.noBedsAvailable,
                        style: secondaryTextStyle())
                  else
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: h.icuDepartments
                          .map((e) => DepartmentChip(department: e))
                          .toList(),
                    ),
                  24.height,
                  Row(
                    children: [
                      AppButton(
                        text: locale.value.callHospital,
                        color: context.primaryColor,
                        onTap: controller.callPhone,
                      ).expand(),
                      16.width,
                      AppButton(
                        text: locale.value.callEmergency,
                        color: errorColor,
                        onTap: controller.callEmergencyPhone,
                      ).expand(),
                    ],
                  ),
                  if (h.latitude != null && h.longitude != null) ...[
                    16.height,
                    AppButton(
                      text: locale.value.openInMaps,
                      width: Get.width,
                      color: context.cardColor,
                      textColor: context.primaryColor,
                      onTap: controller.openInMaps,
                    ),
                  ],
                  32.height,
                  AppButton(
                    text: locale.value.requestIcuAdmissionHere,
                    width: Get.width,
                    color: appColorAccent,
                    onTap: () => doIfLoggedIn(() => Get.to(
                          () => const AdmissionRequestFormScreen(),
                          arguments: h,
                        )),
                  ),
                  50.height,
                ],
              ),
            );
          }),
          Obx(() => Loader().visible(controller.isLoading.value)),
        ],
      ),
    );
  }
}
