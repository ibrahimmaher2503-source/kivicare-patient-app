class PharmacyProductRef {
  int id;
  String name;

  PharmacyProductRef({this.id = -1, this.name = ''});

  factory PharmacyProductRef.fromJson(Map<String, dynamic> json) {
    return PharmacyProductRef(
      id: json['id'] is int ? json['id'] : -1,
      name: json['name'] is String ? json['name'] : '',
    );
  }
}

class PharmacyProduct {
  int id;
  String name;
  String nameAr;
  String nameEn;
  String? image;
  PharmacyProductRef? productType;
  PharmacyProductRef? brand;
  double priceFrom;
  bool isInStock;
  bool requiresPrescription;
  // Detail-only fields (null in list view)
  String? description;
  PharmacyProductRef? category;
  PharmacyProductRef? subcategory;

  PharmacyProduct({
    this.id = -1,
    this.name = '',
    this.nameAr = '',
    this.nameEn = '',
    this.image,
    this.productType,
    this.brand,
    this.priceFrom = 0.0,
    this.isInStock = true,
    this.requiresPrescription = false,
    this.description,
    this.category,
    this.subcategory,
  });

  factory PharmacyProduct.fromJson(Map<String, dynamic> json) {
    return PharmacyProduct(
      id: json['id'] is int ? json['id'] : -1,
      name: json['name'] is String ? json['name'] : '',
      nameAr: json['name_ar'] is String ? json['name_ar'] : '',
      nameEn: json['name_en'] is String ? json['name_en'] : '',
      image: json['image'] is String ? json['image'] : null,
      productType: json['product_type'] is Map
          ? PharmacyProductRef.fromJson(Map<String, dynamic>.from(json['product_type']))
          : null,
      brand: json['brand'] is Map
          ? PharmacyProductRef.fromJson(Map<String, dynamic>.from(json['brand']))
          : null,
      priceFrom: json['price_from'] != null ? (json['price_from'] as num).toDouble() : 0.0,
      isInStock: json['is_in_stock'] is bool ? json['is_in_stock'] : true,
      requiresPrescription: json['requires_prescription'] is bool ? json['requires_prescription'] : false,
      description: json['description'] is String ? json['description'] : null,
      category: json['category'] is Map
          ? PharmacyProductRef.fromJson(Map<String, dynamic>.from(json['category']))
          : null,
      subcategory: json['subcategory'] is Map
          ? PharmacyProductRef.fromJson(Map<String, dynamic>.from(json['subcategory']))
          : null,
    );
  }
}

class PharmacyProductListResponse {
  bool status;
  List<PharmacyProduct> data;
  int currentPage;
  int lastPage;
  int perPage;
  int total;

  PharmacyProductListResponse({
    this.status = false,
    this.data = const [],
    this.currentPage = 1,
    this.lastPage = 1,
    this.perPage = 15,
    this.total = 0,
  });

  factory PharmacyProductListResponse.fromJson(Map<String, dynamic> json) {
    List<dynamic> items = [];
    if (json['data'] is List) {
      items = json['data'];
    } else if (json['data'] is Map && json['data']['items'] is List) {
      items = json['data']['items'];
    }
    int currPage = 1;
    int lastPg = 1;
    int perPg = 15;
    int tot = 0;
    if (json['meta'] is Map) {
      currPage = json['meta']['current_page'] ?? 1;
      lastPg = json['meta']['last_page'] ?? 1;
      perPg = json['meta']['per_page'] ?? 15;
      tot = json['meta']['total'] ?? 0;
    }
    return PharmacyProductListResponse(
      status: json['status'] is bool ? json['status'] : false,
      data: items.map((x) => PharmacyProduct.fromJson(Map<String, dynamic>.from(x))).toList(),
      currentPage: currPage,
      lastPage: lastPg,
      perPage: perPg,
      total: tot,
    );
  }
}

class PharmacyProductDetailResponse {
  bool status;
  PharmacyProduct? data;

  PharmacyProductDetailResponse({this.status = false, this.data});

  factory PharmacyProductDetailResponse.fromJson(Map<String, dynamic> json) {
    return PharmacyProductDetailResponse(
      status: json['status'] is bool ? json['status'] : false,
      data: json['data'] is Map
          ? PharmacyProduct.fromJson(Map<String, dynamic>.from(json['data']))
          : null,
    );
  }
}
