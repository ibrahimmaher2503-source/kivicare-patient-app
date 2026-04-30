import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';
import '../../../api/pharmacy_apis.dart';
import '../../../components/app_scaffold.dart';
import '../../../components/loader_widget.dart';
import '../../../main.dart';
import '../../../utils/colors.dart';

class PharmacyFilterController extends GetxController {
  RxList<dynamic> brands = <dynamic>[].obs;
  RxList<dynamic> productTypes = <dynamic>[].obs;

  RxList<int> selectedBrandIds = <int>[].obs;
  RxList<String> selectedProductTypes = <String>[].obs;
  Rx<RangeValues> priceRange = const RangeValues(0, 5000).obs;
  RxBool prescriptionRequired = false.obs;

  // Loading / error state for initial filter data fetch
  RxBool isLoadingFilters = true.obs;
  RxBool hasFilterError = false.obs;

  // Pre-populated from ProductListController when reopening the filter screen
  PharmacyFilterController({
    List<int>? initialBrandIds,
    List<String>? initialProductTypes,
    RangeValues? initialPriceRange,
    bool? initialPrescriptionRequired,
  }) {
    if (initialBrandIds != null) selectedBrandIds.assignAll(initialBrandIds);
    if (initialProductTypes != null) {
      selectedProductTypes.assignAll(initialProductTypes);
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
    selectedProductTypes.clear();
    priceRange(const RangeValues(0, 5000));
    prescriptionRequired(false);
  }

  void apply() {
    Get.back(result: {
      'brand_ids': selectedBrandIds.toList(),
      'product_types': selectedProductTypes.toList(),
      'price_min': priceRange.value.start.toInt().toString(),
      'price_max': priceRange.value.end.toInt().toString(),
      'prescription_required': prescriptionRequired.value,
    });
  }
}

class PharmacyFilterScreen extends StatefulWidget {
  final List<int> initialBrandIds;
  final List<String> initialProductTypes;
  final RangeValues initialPriceRange;
  final bool initialPrescriptionRequired;

  const PharmacyFilterScreen({
    super.key,
    this.initialBrandIds = const [],
    this.initialProductTypes = const [],
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
        initialProductTypes: widget.initialProductTypes,
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
      actions: [
        TextButton(
          onPressed: controller.reset,
          child:
              Text(locale.value.reset, style: boldTextStyle(color: Colors.red)),
        ),
      ],
      body: Obx(() {
        if (controller.isLoadingFilters.value) {
          return const LoaderWidget().center();
        }

        if (controller.hasFilterError.value) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Failed to load filters', style: primaryTextStyle()),
              const SizedBox(height: 16),
              AppButton(
                text: 'Retry',
                color: appColorPrimary,
                textColor: Colors.white,
                onTap: controller.fetchFilters,
              ),
            ],
          ).center();
        }

        return Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
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
                padding: const EdgeInsets.all(16),
                decoration: boxDecorationDefault(
                    color: context.cardColor,
                    boxShadow: [
                      BoxShadow(
                          color: softShadowColor,
                          blurRadius: 10,
                          offset: const Offset(0, -4))
                    ]),
                child: AppButton(
                  text: locale.value.apply,
                  color: appColorPrimary,
                  textColor: Colors.white,
                  width: Get.width,
                  onTap: controller.apply,
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(title, style: boldTextStyle(size: 16)).paddingOnly(bottom: 12);
  }

  Widget _buildPriceSlider(BuildContext context) {
    return Obx(() => Column(
          children: [
            RangeSlider(
              values: controller.priceRange.value,
              min: 0,
              max: 5000,
              divisions: 50,
              activeColor: appColorSecondary,
              inactiveColor: gray200,
              labels: RangeLabels(
                '${controller.priceRange.value.start.toInt()} LE',
                '${controller.priceRange.value.end.toInt()} LE',
              ),
              onChanged: (val) => controller.priceRange(val),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('${controller.priceRange.value.start.toInt()} LE',
                    style: secondaryTextStyle()),
                Text('${controller.priceRange.value.end.toInt()} LE',
                    style: secondaryTextStyle()),
              ],
            ),
          ],
        ));
  }

  Widget _buildBrandsGrid(BuildContext context) {
    return Obx(() => Wrap(
          spacing: 8,
          runSpacing: 8,
          children: controller.brands.map((brand) {
            bool isSelected = controller.selectedBrandIds.contains(brand['id']);
            return ChoiceChip(
              label: Text(brand['name'] ?? ''),
              selected: isSelected,
              selectedColor: appColorSecondary.withValues(alpha: 0.2),
              onSelected: (val) {
                if (val) {
                  controller.selectedBrandIds.add(brand['id']);
                } else {
                  controller.selectedBrandIds.remove(brand['id']);
                }
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
            bool isSelected = controller.selectedProductTypes.contains(type);
            return ChoiceChip(
              label: Text(type.toString().capitalizeFirstLetter()),
              selected: isSelected,
              selectedColor: appColorSecondary.withValues(alpha: 0.2),
              onSelected: (val) {
                if (val) {
                  controller.selectedProductTypes.add(type);
                } else {
                  controller.selectedProductTypes.remove(type);
                }
              },
            );
          }).toList(),
        ));
  }

  Widget _buildPrescriptionToggle(BuildContext context) {
    return Obx(() => SwitchListTile(
          title: Text(locale.value.prescriptionRequired,
              style: primaryTextStyle()),
          value: controller.prescriptionRequired.value,
          onChanged: (val) => controller.prescriptionRequired(val),
          activeColor: appColorSecondary,
        ));
  }
}
