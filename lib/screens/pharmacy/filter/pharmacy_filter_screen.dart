import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';
import '../../../api/pharmacy_apis.dart';
import '../../../components/app_scaffold.dart';
import '../../../components/loader_widget.dart';
import '../../../main.dart';
import '../../../utils/colors.dart';
import '../../../utils/price_widget.dart';

class PharmacyFilterController extends GetxController {
  RxList<dynamic> brands = <dynamic>[].obs;
  RxList<dynamic> productTypes = <dynamic>[].obs;

  RxList<int> selectedBrandIds = <int>[].obs;
  RxList<int> selectedProductTypeIds = <int>[].obs;
  Rx<RangeValues> priceRange = const RangeValues(0, 5000).obs;
  RxBool prescriptionRequired = false.obs;

  // Loading / error state for initial filter data fetch
  RxBool isLoadingFilters = true.obs;
  RxBool hasFilterError = false.obs;

  // Pre-populated from ProductListController when reopening the filter screen
  PharmacyFilterController({
    List<int>? initialBrandIds,
    List<int>? initialProductTypeIds,
    RangeValues? initialPriceRange,
    bool? initialPrescriptionRequired,
  }) {
    if (initialBrandIds != null) selectedBrandIds.assignAll(initialBrandIds);
    if (initialProductTypeIds != null) {
      selectedProductTypeIds.assignAll(initialProductTypeIds);
    }
    if (initialPriceRange != null) priceRange(initialPriceRange);
    if (initialPrescriptionRequired != null) {
      prescriptionRequired(initialPrescriptionRequired);
    }
  }

  @override
  void onInit() {
    super.onInit();
    fetchFilters();
  }

  Future<void> fetchFilters() async {
    isLoadingFilters(true);
    hasFilterError(false);
    try {
      final resBrands = await PharmacyApis.getBrands();
      if (resBrands != null && resBrands['data'] != null) {
        brands(resBrands['data'] as List);
      }

      final resTypes = await PharmacyApis.getProductTypes();
      if (resTypes != null && resTypes['data'] != null) {
        productTypes(resTypes['data'] as List);
      }
    } catch (e) {
      log('Error fetching filters: $e');
      hasFilterError(true);
    } finally {
      isLoadingFilters(false);
    }
  }

  void reset() {
    selectedBrandIds.clear();
    selectedProductTypeIds.clear();
    priceRange(const RangeValues(0, 5000));
    prescriptionRequired(false);
  }

  void apply() {
    Get.back(result: {
      'brand_ids': selectedBrandIds.toList(),
      'product_type_ids': selectedProductTypeIds.toList(),
      'price_min': priceRange.value.start.toInt().toString(),
      'price_max': priceRange.value.end.toInt().toString(),
      'prescription_required': prescriptionRequired.value,
    });
  }
}

class PharmacyFilterScreen extends StatefulWidget {
  final List<int> initialBrandIds;
  final List<int> initialProductTypeIds;
  final RangeValues initialPriceRange;
  final bool initialPrescriptionRequired;

  const PharmacyFilterScreen({
    super.key,
    this.initialBrandIds = const [],
    this.initialProductTypeIds = const [],
    this.initialPriceRange = const RangeValues(0, 5000),
    this.initialPrescriptionRequired = false,
  });

  @override
  State<PharmacyFilterScreen> createState() => _PharmacyFilterScreenState();
}

class _PharmacyFilterScreenState extends State<PharmacyFilterScreen> {
  late final PharmacyFilterController controller;

  @override
  void initState() {
    super.initState();
    // Use a fresh instance every time the screen opens; delete on dispose.
    controller = Get.put(
      PharmacyFilterController(
        initialBrandIds: widget.initialBrandIds,
        initialProductTypeIds: widget.initialProductTypeIds,
        initialPriceRange: widget.initialPriceRange,
        initialPrescriptionRequired: widget.initialPrescriptionRequired,
      ),
    );
  }

  @override
  void dispose() {
    Get.delete<PharmacyFilterController>();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffoldNew(
      appBartitleText: locale.value.filter,
      body: Obx(() {
        if (controller.isLoadingFilters.value) {
          return const LoaderWidget().center();
        }

        if (controller.hasFilterError.value) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(locale.value.loadFailed, style: primaryTextStyle()),
              const SizedBox(height: 16),
              AppButton(
                text: locale.value.retry,
                color: appColorPrimary,
                textColor: Colors.white,
                onTap: controller.fetchFilters,
              ),
            ],
          ).center();
        }

        return Container(
          color: appLayoutBackground,
          child: Stack(
            children: [
              SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionTitle(locale.value.priceRange),
                    _buildPriceSlider(context),
                    const SizedBox(height: 24),
                    _buildSectionTitle(locale.value.brands),
                    _buildBrandsGrid(context),
                    const SizedBox(height: 24),
                    _buildSectionTitle(locale.value.productTypes),
                    _buildProductTypesList(context),
                    const SizedBox(height: 24),
                    _buildPrescriptionToggle(context),
                  ],
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  padding: EdgeInsets.fromLTRB(
                      16, 16, 16, 16 + MediaQuery.paddingOf(context).bottom),
                  decoration: BoxDecoration(color: surfaceElevated, boxShadow: [
                    BoxShadow(
                        color: softShadowColor,
                        blurRadius: 16,
                        offset: const Offset(0, -4))
                  ]),
                  child: Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: controller.reset,
                          child: Container(
                            height: 52,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: surfaceElevated,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                  color: appColorPrimary, width: 1.4),
                            ),
                            child: Text(
                              locale.value.reset,
                              style: boldTextStyle(
                                  color: appColorPrimary, size: 15),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: GestureDetector(
                          onTap: controller.apply,
                          child: Container(
                            height: 52,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                                colors: [
                                  gradientSecondaryStart,
                                  gradientSecondaryEnd
                                ],
                              ),
                              borderRadius: BorderRadius.circular(14),
                              boxShadow: [
                                BoxShadow(
                                    color: softShadowColor,
                                    blurRadius: 12,
                                    offset: const Offset(0, 4)),
                              ],
                            ),
                            child: Text(
                              locale.value.apply,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.2,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child:
          Text(title, style: boldTextStyle(size: 16, color: appColorPrimary)),
    );
  }

  Widget _buildPriceSlider(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      decoration: BoxDecoration(
        color: surfaceElevated,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: softShadowColor,
              blurRadius: 16,
              offset: const Offset(0, 6)),
        ],
      ),
      child: Obx(() => Column(
            children: [
              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  activeTrackColor: appColorSecondary,
                  inactiveTrackColor: lightSecondaryColor,
                  thumbColor: appColorSecondary,
                  overlayColor: appColorSecondary.withValues(alpha: 0.12),
                  trackHeight: 4,
                  rangeThumbShape: const RoundRangeSliderThumbShape(
                      enabledThumbRadius: 9, elevation: 2),
                ),
                child: RangeSlider(
                  values: controller.priceRange.value,
                  min: 0,
                  max: 5000,
                  divisions: 50,
                  labels: RangeLabels(
                    formatCurrencyValue(controller.priceRange.value.start),
                    formatCurrencyValue(controller.priceRange.value.end),
                  ),
                  onChanged: (val) => controller.priceRange(val),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(formatCurrencyValue(controller.priceRange.value.start),
                        style:
                            boldTextStyle(size: 13, color: appColorSecondary)),
                    Text(formatCurrencyValue(controller.priceRange.value.end),
                        style:
                            boldTextStyle(size: 13, color: appColorSecondary)),
                  ],
                ),
              ),
            ],
          )),
    );
  }

  Widget _buildPillChip({
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? lightSecondaryColor : surfaceElevated,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
              color: selected ? appColorSecondary : whiteBorderColor, width: 1),
        ),
        child: Text(
          label,
          style: selected
              ? boldTextStyle(size: 13, color: appColorSecondary)
              : primaryTextStyle(size: 13),
        ),
      ),
    );
  }

  Widget _buildBrandsGrid(BuildContext context) {
    return Obx(() => Wrap(
          spacing: 8,
          runSpacing: 8,
          children: controller.brands.map((brand) {
            final brandId = brand['id'] is int
                ? brand['id'] as int
                : int.tryParse(brand['id']?.toString() ?? '');
            if (brandId == null || brandId <= 0) {
              return const SizedBox.shrink();
            }
            bool isSelected = controller.selectedBrandIds.contains(brandId);
            return _buildPillChip(
              label: brand['name'] ?? '',
              selected: isSelected,
              onTap: () {
                controller.selectedBrandIds.assignAll(
                  isSelected ? const <int>[] : <int>[brandId],
                );
              },
            );
          }).toList(),
        ));
  }

  Widget _buildProductTypesList(BuildContext context) {
    return Obx(() => Wrap(
          spacing: 8,
          runSpacing: 8,
          children: controller.productTypes.map((type) {
            final typeId = type['id'] is int
                ? type['id'] as int
                : int.tryParse(type['id']?.toString() ?? '');
            if (typeId == null || typeId <= 0) {
              return const SizedBox.shrink();
            }
            bool isSelected =
                controller.selectedProductTypeIds.contains(typeId);
            return _buildPillChip(
              label: type['name']?.toString() ?? '',
              selected: isSelected,
              onTap: () {
                controller.selectedProductTypeIds.assignAll(
                  isSelected ? const <int>[] : <int>[typeId],
                );
              },
            );
          }).toList(),
        ));
  }

  Widget _buildPrescriptionToggle(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: surfaceElevated,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: softShadowColor,
              blurRadius: 16,
              offset: const Offset(0, 6)),
        ],
      ),
      child: Obx(() => SwitchListTile(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            title: Text(locale.value.prescriptionRequired,
                style: boldTextStyle(size: 14, color: appColorPrimary)),
            value: controller.prescriptionRequired.value,
            onChanged: (val) => controller.prescriptionRequired(val),
            activeThumbColor: appColorSecondary,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          )),
    );
  }
}
