class PharmacyOrderPharmacyRef {
  int id;
  String name;
  String? phone;
  String? address;

  PharmacyOrderPharmacyRef({this.id = -1, this.name = '', this.phone, this.address});

  factory PharmacyOrderPharmacyRef.fromJson(Map<String, dynamic> json) {
    return PharmacyOrderPharmacyRef(
      id: json['id'] is int ? json['id'] : -1,
      name: json['name'] is String ? json['name'] : '',
      phone: json['phone'] is String ? json['phone'] : null,
      address: json['address'] is String ? json['address'] : null,
    );
  }
}

class PharmacyOrderSummary {
  int id;
  PharmacyOrderPharmacyRef? pharmacy;
  double total;
  String status;
  int itemCount;
  String createdAt;

  PharmacyOrderSummary({
    this.id = -1,
    this.pharmacy,
    this.total = 0.0,
    this.status = '',
    this.itemCount = 0,
    this.createdAt = '',
  });

  factory PharmacyOrderSummary.fromJson(Map<String, dynamic> json) {
    return PharmacyOrderSummary(
      id: json['id'] is int ? json['id'] : -1,
      pharmacy: json['pharmacy'] is Map
          ? PharmacyOrderPharmacyRef.fromJson(Map<String, dynamic>.from(json['pharmacy']))
          : null,
      total: json['total'] != null ? (json['total'] as num).toDouble() : 0.0,
      status: json['status'] is String ? json['status'] : '',
      itemCount: json['item_count'] is int ? json['item_count'] : 0,
      createdAt: json['created_at'] is String ? json['created_at'] : '',
    );
  }
}

class PharmacyOrderItem {
  int id;
  int productId;
  String productName;
  int quantity;
  double price;
  double lineTotal;

  PharmacyOrderItem({
    this.id = -1,
    this.productId = -1,
    this.productName = '',
    this.quantity = 1,
    this.price = 0.0,
    this.lineTotal = 0.0,
  });

  factory PharmacyOrderItem.fromJson(Map<String, dynamic> json) {
    return PharmacyOrderItem(
      id: json['id'] is int ? json['id'] : -1,
      productId: json['product_id'] is int ? json['product_id'] : -1,
      productName: json['product_name'] is String ? json['product_name'] : '',
      quantity: json['quantity'] is int ? json['quantity'] : 1,
      price: json['price'] != null ? (json['price'] as num).toDouble() : 0.0,
      lineTotal: json['line_total'] != null ? (json['line_total'] as num).toDouble() : 0.0,
    );
  }
}

class PharmacyOrderAddress {
  String? addressLine1;
  String? city;

  PharmacyOrderAddress({this.addressLine1, this.city});

  factory PharmacyOrderAddress.fromJson(Map<String, dynamic> json) {
    return PharmacyOrderAddress(
      addressLine1: json['address_line1'] is String ? json['address_line1'] : null,
      city: json['city'] is String ? json['city'] : null,
    );
  }
}

class PharmacyOrderDetail {
  int id;
  String status;
  PharmacyOrderPharmacyRef? pharmacy;
  List<PharmacyOrderItem> items;
  double subtotal;
  double deliveryFee;
  double total;
  String paymentMethod;
  PharmacyOrderAddress? address;
  String createdAt;
  String updatedAt;

  PharmacyOrderDetail({
    this.id = -1,
    this.status = '',
    this.pharmacy,
    this.items = const [],
    this.subtotal = 0.0,
    this.deliveryFee = 0.0,
    this.total = 0.0,
    this.paymentMethod = '',
    this.address,
    this.createdAt = '',
    this.updatedAt = '',
  });

  factory PharmacyOrderDetail.fromJson(Map<String, dynamic> json) {
    List<dynamic> rawItems = json['items'] is List ? json['items'] : [];
    return PharmacyOrderDetail(
      id: json['id'] is int ? json['id'] : -1,
      status: json['status'] is String ? json['status'] : '',
      pharmacy: json['pharmacy'] is Map
          ? PharmacyOrderPharmacyRef.fromJson(Map<String, dynamic>.from(json['pharmacy']))
          : null,
      items: rawItems.map((x) => PharmacyOrderItem.fromJson(Map<String, dynamic>.from(x))).toList(),
      subtotal: json['subtotal'] != null ? (json['subtotal'] as num).toDouble() : 0.0,
      deliveryFee: json['delivery_fee'] != null ? (json['delivery_fee'] as num).toDouble() : 0.0,
      total: json['total'] != null ? (json['total'] as num).toDouble() : 0.0,
      paymentMethod: json['payment_method'] is String ? json['payment_method'] : '',
      address: json['address'] is Map
          ? PharmacyOrderAddress.fromJson(Map<String, dynamic>.from(json['address']))
          : null,
      createdAt: json['created_at'] is String ? json['created_at'] : '',
      updatedAt: json['updated_at'] is String ? json['updated_at'] : '',
    );
  }
}

class PharmacyOrderDetailResponse {
  bool status;
  PharmacyOrderDetail? data;

  PharmacyOrderDetailResponse({this.status = false, this.data});

  factory PharmacyOrderDetailResponse.fromJson(Map<String, dynamic> json) {
    return PharmacyOrderDetailResponse(
      status: json['status'] is bool ? json['status'] : false,
      data: json['data'] is Map
          ? PharmacyOrderDetail.fromJson(Map<String, dynamic>.from(json['data']))
          : null,
    );
  }
}

class PharmacyOrderListResponse {
  bool status;
  List<PharmacyOrderSummary> data;
  int currentPage;
  int lastPage;
  int perPage;
  int total;

  PharmacyOrderListResponse({
    this.status = false,
    this.data = const [],
    this.currentPage = 1,
    this.lastPage = 1,
    this.perPage = 15,
    this.total = 0,
  });

  factory PharmacyOrderListResponse.fromJson(Map<String, dynamic> json) {
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
    return PharmacyOrderListResponse(
      status: json['status'] is bool ? json['status'] : false,
      data: items.map((x) => PharmacyOrderSummary.fromJson(Map<String, dynamic>.from(x))).toList(),
      currentPage: currPage,
      lastPage: lastPg,
      perPage: perPg,
      total: tot,
    );
  }
}

class PharmacyOrderPlacedResponse {
  bool status;
  PharmacyOrderSummary? data;
  String? message;

  PharmacyOrderPlacedResponse({this.status = false, this.data, this.message});

  factory PharmacyOrderPlacedResponse.fromJson(Map<String, dynamic> json) {
    return PharmacyOrderPlacedResponse(
      status: json['status'] is bool ? json['status'] : false,
      data: json['data'] is Map
          ? PharmacyOrderSummary.fromJson(Map<String, dynamic>.from(json['data']))
          : null,
      message: json['message'] is String ? json['message'] : null,
    );
  }
}
