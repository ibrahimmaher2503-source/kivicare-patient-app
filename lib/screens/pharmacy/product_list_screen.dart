import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';
import '../../api/pharmacy_apis.dart';
import '../../components/app_scaffold.dart';
import '../../utils/empty_error_state_widget.dart';
import '../../main.dart';
import '../../utils/colors.dart';
import '../../utils/price_widget.dart';
import 'model/pharmacy_product_model.dart';
import 'product_detail_screen.dart';

import 'filter/pharmacy_filter_screen.dart';

class ProductListController extends GetxController {
  int? categoryId;
  int? brandId;
  String? initialTitle;

  RxBool isLoading = false.obs;
  RxList<PharmacyProduct> products = <PharmacyProduct>[].obs;
  RxInt page = 1.obs;
  RxBool isLastPage = false.obs;
  TextEditingController searchController = TextEditingController();
  RxString searchQuery = "".obs;

  // Filters
  RxMap filterParams = {}.obs;
  RxString currentSort = "newest".obs;
  RxInt activeFilterCount = 0.obs;
  int _requestGeneration = 0;

  static const int perPage = 10;

  // Getter so labels are re-evaluated from the current locale on every access,
  // keeping them correct after a language change.
  List<Map<String, String>> get sortOptions => [
        {'label': locale.value.sortNewest, 'value': 'newest'},
        {'label': locale.value.sortPriceAsc, 'value': 'price_asc'},
        {'label': locale.value.sortPriceDesc, 'value': 'price_desc'},
        {'label': locale.value.sortRating, 'value': 'rating'},
      ];

  ProductListController({this.categoryId, this.brandId, this.initialTitle});

  @override
  void onInit() {
    super.onInit();
    init();
    searchController.addListener(() {
      searchQuery(searchController.text);
    });
    debounce(searchQuery, (_) => init(),
        time: const Duration(milliseconds: 500));
  }

  Future<void> init() async {
    final generation = ++_requestGeneration;
    page(1);
    isLastPage(false);
    await fetchProducts(generation: generation);
  }

  Future<void> fetchProducts({int? generation}) async {
    final requestGeneration = generation ?? _requestGeneration;
    if (page.value > 1 && isLoading.value) return;
    isLoading(true);

    try {
      final res = await PharmacyApis.getPharmacyProducts(
        page: page.value,
        perPage: perPage,
        categoryId: categoryId,
        brandId: brandId ??
            (filterParams['brand_ids']?.isNotEmpty == true
                ? filterParams['brand_ids'][0]
                : null),
        search: searchQuery.value,
        productTypeId: filterParams['product_type_ids']?.isNotEmpty == true
            ? filterParams['product_type_ids'][0]
            : null,
        priceMin: filterParams['price_min'],
        priceMax: filterParams['price_max'],
        prescriptionRequired: filterParams['prescription_required'],
        sort: currentSort.value,
      );

      if (requestGeneration != _requestGeneration) return;
      if (res != null && res['data'] != null) {
        final List<PharmacyProduct> newProducts = (res['data'] as List)
            .map((e) => PharmacyProduct.fromJson(e))
            .toList();
        if (page.value == 1) {
          products(newProducts);
        } else {
          products.addAll(newProducts);
        }
        isLastPage(newProducts.length < perPage);
      }
    } catch (e) {
      if (requestGeneration == _requestGeneration) {
        log('Error fetching products: $e');
      }
    } finally {
      if (requestGeneration == _requestGeneration) {
        isLoading(false);
      }
    }
  }

  Future<void> openFilters() async {
    // Pre-populate the filter screen with the current filter selections so
    // reopening it doesn't reset choices the user already made.
    final List<int> currentBrandIds =
        List<int>.from(filterParams['brand_ids'] ?? <int>[]);
    final List<int> currentProductTypeIds =
        List<int>.from(filterParams['product_type_ids'] ?? <int>[]);
    final double priceMinVal =
        double.tryParse(filterParams['price_min'] ?? '0') ?? 0;
    final double priceMaxVal =
        double.tryParse(filterParams['price_max'] ?? '5000') ?? 5000;
    final bool currentPrescription =
        filterParams['prescription_required'] == true;

    final result = await Get.to(() => PharmacyFilterScreen(
          initialBrandIds: currentBrandIds,
          initialProductTypeIds: currentProductTypeIds,
          initialPriceRange: RangeValues(priceMinVal, priceMaxVal),
          initialPrescriptionRequired: currentPrescription,
        ));
    if (result != null) {
      filterParams(result);

      int count = 0;
      if (result['brand_ids']?.isNotEmpty == true) count++;
      if (result['product_type_ids']?.isNotEmpty == true) count++;
      if (result['price_min'] != '0' || result['price_max'] != '5000') count++;
      if (result['prescription_required'] == true) count++;
      activeFilterCount(count);

      init();
    }
  }

  void changeSort(String? value) {
    if (value != null) {
      currentSort(value);
      init();
    }
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }

  Future<void> loadMore() async {
    if (!isLastPage.value && !isLoading.value) {
      page.value++;
      await fetchProducts(generation: _requestGeneration);
    }
  }
}

class ProductListScreen extends StatelessWidget {
  final int? categoryId;
  final int? brandId;
  final String? title;

  const ProductListScreen(
      {super.key, this.categoryId, this.brandId, this.title});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(
        ProductListController(
            categoryId: categoryId, brandId: brandId, initialTitle: title),
        tag: '${categoryId}_${brandId}_$title');

    return AppScaffoldNew(
      appBartitleText: title ?? locale.value.pharmacy,
      isLoading: controller.isLoading,
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 12, top: 6, bottom: 6),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: controller.openFilters,
                  child: Container(
                    width: 44,
                    height: 44,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: appColorSecondary.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: appColorSecondary.withValues(alpha: 0.18),
                        width: 1,
                      ),
                    ),
                    child: const Icon(Icons.tune_rounded,
                        color: appColorSecondary, size: 20),
                  ),
                ),
              ),
              Obx(() => controller.activeFilterCount.value > 0
                  ? Positioned(
                      right: -4,
                      top: -4,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        constraints:
                            const BoxConstraints(minWidth: 18, minHeight: 18),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(colors: [
                            gradientSecondaryStart,
                            gradientSecondaryEnd,
                          ]),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                                color: softShadowColor,
                                blurRadius: 6,
                                offset: const Offset(0, 2)),
                          ],
                        ),
                        alignment: Alignment.center,
                        child: Text('${controller.activeFilterCount.value}',
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w700)),
                      ),
                    )
                  : const Offstage()),
            ],
          ),
        ),
      ],
      body: Column(
        children: [
          _buildSearchAndSort(controller, context),
          Expanded(
            child: Obx(() => controller.products.isEmpty &&
                    !controller.isLoading.value
                ? NoDataWidget(
                    title: locale.value.noProductsFound,
                    imageWidget: const ErrorStateWidget(),
                    onRetry: () => controller.init(),
                  ).paddingAll(16)
                : LayoutBuilder(
                    builder: (context, constraints) {
                      final columnCount = constraints.maxWidth >= 900
                          ? 5
                          : constraints.maxWidth >= 650
                              ? 3
                              : 2;
                      final textScale = MediaQuery.textScalerOf(context)
                          .scale(1)
                          .clamp(1.0, 2.0);
                      return RefreshIndicator(
                        onRefresh: controller.init,
                        child: CustomScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          slivers: [
                            SliverPadding(
                              padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                              sliver: SliverGrid.builder(
                                itemCount: controller.products.length,
                                gridDelegate:
                                    SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: columnCount,
                                  crossAxisSpacing: 16,
                                  mainAxisSpacing: 16,
                                  mainAxisExtent: 230 + ((textScale - 1) * 55),
                                ),
                                itemBuilder: (context, index) {
                                  if (index >= controller.products.length - 3) {
                                    controller.loadMore();
                                  }
                                  return _ProductCard(
                                    product: controller.products[index],
                                  );
                                },
                              ),
                            ),
                            if (controller.isLoading.value &&
                                controller.products.isNotEmpty)
                              const SliverToBoxAdapter(
                                child: Padding(
                                  padding: EdgeInsets.all(16),
                                  child: Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      );
                    },
                  )),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndSort(
      ProductListController controller, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            decoration: BoxDecoration(
              color: surfaceElevated,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                    color: softShadowColor,
                    blurRadius: 10,
                    offset: const Offset(0, 4)),
              ],
            ),
            child: AppTextField(
              controller: controller.searchController,
              textFieldType: TextFieldType.NAME,
              decoration: InputDecoration(
                hintText: locale.value.searchProducts,
                hintStyle: secondaryTextStyle(size: 14),
                prefixIcon: Padding(
                  padding: const EdgeInsetsDirectional.only(start: 10, end: 4),
                  child: Container(
                    width: 32,
                    height: 32,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: appColorSecondary.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(9),
                    ),
                    child: const Icon(Icons.search_rounded,
                        color: appColorSecondary, size: 18),
                  ),
                ),
                prefixIconConstraints:
                    const BoxConstraints(minWidth: 46, minHeight: 32),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear_rounded,
                      color: secondaryTextColor, size: 18),
                  onPressed: () {
                    controller.searchController.clear();
                  },
                ),
                filled: true,
                fillColor: Colors.transparent,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),
          Obx(() {
            final int count = controller.products.length;
            final bool loading = controller.isLoading.value;
            if (count == 0 && loading) return const SizedBox.shrink();
            return Padding(
              padding: const EdgeInsets.only(left: 4, bottom: 10),
              child: Text(
                '$count ${locale.value.items}',
                style: secondaryTextStyle(size: 12),
              ),
            );
          }),
          SizedBox(
            height: 38,
            child: Obx(() => ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: controller.sortOptions.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, i) {
                    final opt = controller.sortOptions[i];
                    final bool selected =
                        controller.currentSort.value == opt['value'];
                    return GestureDetector(
                      onTap: () => controller.changeSort(opt['value']),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color:
                              selected ? lightSecondaryColor : surfaceElevated,
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(
                              color: selected
                                  ? appColorSecondary
                                  : whiteBorderColor,
                              width: 1),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          opt['label']!,
                          style: selected
                              ? boldTextStyle(
                                  size: 13, color: appColorSecondary)
                              : primaryTextStyle(size: 13),
                        ),
                      ),
                    );
                  },
                )),
          ),
        ],
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  final PharmacyProduct product;

  const _ProductCard({required this.product});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Get.to(() => ProductDetailScreen(product: product)),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: surfaceElevated,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
                color: softShadowColor,
                blurRadius: 16,
                offset: const Offset(0, 6))
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                if (product.images.validate().isNotEmpty)
                  CachedNetworkImage(
                          imageUrl: product.images![0],
                          height: 140,
                          width: double.infinity,
                          fit: BoxFit.cover)
                      .cornerRadiusWithClipRRectOnly(topLeft: 16, topRight: 16)
                else
                  Container(
                    height: 140,
                    width: double.infinity,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          surfaceSubtle,
                          appColorSecondary.withValues(alpha: 0.06),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Container(
                      width: 56,
                      height: 56,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: appColorSecondary.withValues(alpha: 0.14),
                      ),
                      child: const Icon(Icons.medication_outlined,
                          color: appColorSecondary, size: 28),
                    ),
                  ).cornerRadiusWithClipRRectOnly(topLeft: 16, topRight: 16),
                if (product.isPrescriptionRequired ?? false)
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 9, vertical: 5),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(colors: [
                          gradientSecondaryStart,
                          gradientSecondaryEnd,
                        ]),
                        borderRadius: BorderRadius.circular(999),
                        boxShadow: [
                          BoxShadow(
                              color: softShadowColorMedium,
                              blurRadius: 8,
                              offset: const Offset(0, 3)),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(Icons.medical_information_rounded,
                              color: Colors.white, size: 12),
                          SizedBox(width: 4),
                          Text(
                            'Rx',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.4,
                              height: 1,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(product.name ?? '',
                      style: boldTextStyle(size: 14, color: appColorPrimary),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 2),
                  Text(product.brandName ?? '',
                      style: secondaryTextStyle(size: 12),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 8),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Flexible(
                        child: Text(formatCurrencyValue(product.price),
                            style:
                                boldTextStyle(size: 15, color: appColorPrimary),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis),
                      ),
                      if (product.referencePrice != null) ...[
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                              formatCurrencyValue(product.referencePrice),
                              style: secondaryTextStyle(
                                  decoration: TextDecoration.lineThrough,
                                  size: 12,
                                  color: gray400),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
