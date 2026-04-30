import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';
import '../../../api/icu_apis.dart';
import '../../../main.dart';
import '../../../utils/common_base.dart';
import '../../location_filter/governorate_selection_screen.dart';
import '../../location_filter/models/location_filter_result.dart';
import '../components/icu_shimmer.dart';
import '../models/icu_department_model.dart';
import 'hospital_filter_controller.dart';

class HospitalFilterScreen extends StatelessWidget {
  const HospitalFilterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HospitalFilterController>();

    return Scaffold(
      appBar: AppBar(
        title: Text(locale.value.filterBy),
        actions: [
          TextButton(
            onPressed: () => controller.clear(),
            child: Text(locale.value.reset, style: boldTextStyle(color: context.primaryColor)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(locale.value.location, style: boldTextStyle()),
            8.height,
            Obx(() => AppTextField(
                  readOnly: true,
                  controller: TextEditingController(
                      text: controller.selectedCityId.value != null
                          ? '${controller.selectedGovernorateName.value} > ${controller.selectedCityName.value}'
                          : controller.selectedGovernorateId.value != null
                              ? controller.selectedGovernorateName.value
                              : locale.value.allLocations),
                  textFieldType: TextFieldType.NAME,
                  decoration: inputDecoration(context, labelText: locale.value.location).copyWith(
                    suffixIcon: const Icon(Icons.location_on_outlined),
                  ),
                  onTap: () async {
                    final result = await Get.to<LocationFilterResult>(() => GovernorateSelectionScreen(
                          initiallySelectedId: controller.selectedGovernorateId.value,
                          initiallySelectedCityId: controller.selectedCityId.value,
                        ));
                    if (result != null) {
                      if (result.cleared) {
                        controller.setGovernorate(null, null);
                      } else {
                        controller.setGovernorate(result.governorateId, result.governorate?.name);
                        controller.setCity(result.cityId, result.city?.name);
                      }
                    }
                  },
                )),
            24.height,
            Text(locale.value.icuDepartments, style: boldTextStyle()),
            8.height,
            FutureBuilder<List<IcuDepartment>>(
              future: IcuApis.getDepartments(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return Obx(() => DropdownButtonFormField<int>(
                        // ignore: deprecated_member_use
                        value: controller.selectedDepartmentTypeId.value,
                        decoration: inputDecoration(context, labelText: locale.value.icuDepartments),
                        items: [
                          DropdownMenuItem(value: null, child: Text(locale.value.all)),
                          ...snapshot.data!.map((e) => DropdownMenuItem(value: e.id, child: Text(e.name))),
                        ],
                        onChanged: (val) {
                          controller.selectedDepartmentTypeId.value = val;
                          if (val != null) {
                            controller.selectedDepartmentTypeName.value = snapshot.data!.firstWhere((e) => e.id == val).name;
                          } else {
                            controller.selectedDepartmentTypeName.value = null;
                          }
                        },
                      ));
                }
                return const IcuShimmer(itemCount: 1, height: 60, padding: EdgeInsets.zero);
              },
            ),
            24.height,
            Obx(() => SettingItemWidget(
                  title: locale.value.hasAvailableBeds,
                  trailing: Switch.adaptive(
                    value: controller.hasAvailableBedsOnly.value,
                    onChanged: (val) => controller.hasAvailableBedsOnly.value = val,
                    activeTrackColor: context.primaryColor,
                  ),
                  padding: EdgeInsets.zero,
                )),
            40.height,
            AppButton(
              text: locale.value.apply,
              width: Get.width,
              color: context.primaryColor,
              onTap: () => finish(context),
            ),
          ],
        ),
      ),
    );
  }
}
