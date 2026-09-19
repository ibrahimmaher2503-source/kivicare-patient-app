import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';
import '../../../components/accessible_filter_button.dart';
import '../../../main.dart';
import '../../../utils/common_base.dart';
import '../components/emergency_banner.dart';
import '../components/hospital_card.dart';
import '../components/icu_empty_state.dart';
import '../components/icu_shimmer.dart';
import '../filter/hospital_filter_screen.dart';
import 'hospital_detail_screen.dart';
import 'hospital_list_controller.dart';

class HospitalListScreen extends StatefulWidget {
  final bool selectionMode;

  const HospitalListScreen({
    super.key,
    this.selectionMode = false,
  });

  @override
  State<HospitalListScreen> createState() => _HospitalListScreenState();
}

class _HospitalListScreenState extends State<HospitalListScreen> {
  final controller = Get.put(HospitalListController());
  final scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    scrollController.addListener(() {
      if (scrollController.position.pixels ==
          scrollController.position.maxScrollExtent) {
        controller.loadNextPage();
      }
    });
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(locale.value.icuHospitals)),
      body: Column(
        children: [
          const EmergencyBanner(),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Semantics(
                  textField: true,
                  label: locale.value.searchHospitals,
                  child: AppTextField(
                    controller: controller.searchCont,
                    textFieldType: TextFieldType.NAME,
                    decoration: inputDecoration(context,
                            labelText: locale.value.searchHospitals)
                        .copyWith(
                      prefixIcon: const Icon(Icons.search),
                    ),
                    onChanged: (val) => controller.searchStream.value = val,
                  ),
                ).expand(),
                16.width,
                Obx(
                  () => AccessibleFilterButton(
                    count: controller.filter.activeFilterCount,
                    onPressed: () {
                      Get.to(() => const HospitalFilterScreen())
                          ?.then((_) => controller.loadFirstPage());
                    },
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value && controller.hospitals.isEmpty) {
                return const IcuShimmer(itemCount: 6, height: 110);
              }
              if (controller.hospitals.isEmpty) {
                return IcuEmptyState(
                  title: locale.value.noHospitalsFound,
                  onRetry: controller.loadFirstPage,
                );
              }
              return RefreshIndicator(
                onRefresh: controller.refreshData,
                child: ListView.builder(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: controller.hospitals.length +
                      (controller.isLoadingMore.value ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index < controller.hospitals.length) {
                      final hospital = controller.hospitals[index];
                      return HospitalCard(
                        hospital: hospital,
                        onTap: () {
                          if (widget.selectionMode) {
                            Get.back(result: hospital);
                          } else {
                            Get.to(() =>
                                HospitalDetailScreen(hospitalId: hospital.id));
                          }
                        },
                      );
                    } else {
                      return const Padding(
                        padding: EdgeInsets.all(16),
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }
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
