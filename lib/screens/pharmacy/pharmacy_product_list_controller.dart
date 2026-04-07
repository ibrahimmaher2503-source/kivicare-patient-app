import 'dart:async';
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';
import '../../api/core_apis.dart';
import 'model/pharmacy_product_model.dart';
import 'model/pharmacy_filter_model.dart';

class PharmacyProductListController extends GetxController {
  RxList<PharmacyProduct> products = <PharmacyProduct>[].obs;
  RxBool isLoading = false.obs;
  RxBool isLoadingMore = false.obs;
  RxString searchQuery = ''.obs;
  RxList<int> selectedBrandIds = <int>[].obs;
  RxList<int> selectedProductTypeIds = <int>[].obs;
  RxList<PharmacyFilterOption> availableBrands = <PharmacyFilterOption>[].obs;
  RxList<PharmacyFilterOption> availableProductTypes = <PharmacyFilterOption>[].obs;

  int currentPage = 1;
  bool isLastPage = false;
  int subCategoryId = -1;
  Timer? _searchDebounce;

  int get activeFilterCount {
    int count = 0;
    if (searchQuery.value.isNotEmpty) count++;
    count += selectedBrandIds.length;
    count += selectedProductTypeIds.length;
    return count;
  }

  void init(int subCategoryId) {
    this.subCategoryId = subCategoryId;
    loadProducts();
    loadFilterOptions(subCategoryId);
  }

  Future<void> loadProducts({bool isRefresh = false}) async {
    if (isRefresh) {
      currentPage = 1;
      isLastPage = false;
    }
    isLoading(true);
    try {
      await CoreServiceApis.getPharmacyProducts(
        subCategoryId: subCategoryId,
        list: products,
        search: searchQuery.value,
        brandIds: selectedBrandIds.toList(),
        productTypeIds: selectedProductTypeIds.toList(),
        page: currentPage,
        lastPageCallback: (isLast) => isLastPage = isLast,
      );
    } catch (e) {
      toast(e.toString());
    } finally {
      isLoading(false);
    }
  }

  Future<void> loadMore() async {
    if (isLastPage || isLoadingMore.value) return;
    isLoadingMore(true);
    currentPage++;
    try {
      await CoreServiceApis.getPharmacyProducts(
        subCategoryId: subCategoryId,
        list: products,
        search: searchQuery.value,
        brandIds: selectedBrandIds.toList(),
        productTypeIds: selectedProductTypeIds.toList(),
        page: currentPage,
        lastPageCallback: (isLast) => isLastPage = isLast,
      );
    } catch (e) {
      currentPage--;
      toast(e.toString());
    } finally {
      isLoadingMore(false);
    }
  }

  void onSearchChanged(String value) {
    searchQuery(value);
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 500), () {
      currentPage = 1;
      isLastPage = false;
      loadProducts(isRefresh: true);
    });
  }

  @override
  void onClose() {
    _searchDebounce?.cancel();
    super.onClose();
  }

  Future<void> loadFilterOptions(int subCategoryId) async {
    try {
      final brandsRes = await CoreServiceApis.getPharmacyFilterBrands(subCategoryId);
      availableBrands.assignAll(brandsRes.data);
      final typesRes = await CoreServiceApis.getPharmacyFilterProductTypes(subCategoryId);
      availableProductTypes.assignAll(typesRes.data);
    } catch (_) {}
  }

  void applyFilters() {
    currentPage = 1;
    isLastPage = false;
    loadProducts(isRefresh: true);
  }

  void clearFilters() {
    selectedBrandIds.clear();
    selectedProductTypeIds.clear();
    searchQuery('');
    currentPage = 1;
    isLastPage = false;
    loadProducts(isRefresh: true);
  }
}
