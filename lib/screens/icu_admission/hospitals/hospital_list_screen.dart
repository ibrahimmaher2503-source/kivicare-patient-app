import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';
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
  const HospitalListScreen({super.key});

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
      if (scrollController.position.pixels == scrollController.position.maxScrollExtent) {
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
                AppTextField(
                  controller: controller.searchCont,
                  textFieldType: TextFieldType.NAME,
                  decoration: inputDecoration(context, labelText: locale.value.searchHospitals).copyWith(
                    prefixIcon: const Icon(Icons.search),
                  ),
                  onChanged: (val) => controller.searchStream.value = val,
                ).expand(),
                16.width,
                Obx(() => Stack(
                      children: [
                        IconButton(
                          onPressed: () {
                            Get.to(() => const HospitalFilterScreen())?.then((_) => controller.loadFirstPage());
                          },
                          icon: const Icon(Icons.filter_list_rounded),
                        ),
                        if (controller.filter.activeFilterCount > 0)
                          Positioned(
                            right: 8,
                            top: 8,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(color: errorColor, shape: BoxShape.circle),
                              child: Text(
                                controller.filter.activeFilterCount.toString(),
                                style: boldTextStyle(color: Colors.white, size: 10),
                              ),
                            ),
                          ),
                      ],
                    )),
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
                  itemCount: controller.hospitals.length + (controller.isLoadingMore.value ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index < controller.hospitals.length) {
                      final hospital = controller.hospitals[index];
                      return HospitalCard(
                        hospital: hospital,
                        onTap: () {
                          Get.to(() => HospitalDetailScreen(hospitalId: hospital.id));
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
