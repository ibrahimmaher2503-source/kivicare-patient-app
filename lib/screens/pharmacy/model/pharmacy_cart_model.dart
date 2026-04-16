class PharmacyCartResponse {
  bool status;
  PharmacyCart? data;

  PharmacyCartResponse({this.status = false, this.data});

  factory PharmacyCartResponse.fromJson(Map<String, dynamic> json) {
    return PharmacyCartResponse(
      status: json['status'] is bool ? json['status'] : false,
      data: json['data'] is Map
          ? PharmacyCart.fromJson(Map<String, dynamic>.from(json['data']))
          : null,
    );
  }
}

class PharmacyCart {
  List<PharmacyCartItem> items;
  int itemCount;

  PharmacyCart({this.items = const [], this.itemCount = 0});

  factory PharmacyCart.fromJson(Map<String, dynamic> json) {
    List<dynamic> rawItems = json['items'] is List ? json['items'] : [];
    return PharmacyCart(
      items: rawItems.map((x) => PharmacyCartItem.fromJson(Map<String, dynamic>.from(x))).toList(),
      itemCount: json['item_count'] is int ? json['item_count'] : rawItems.length,
    );
  }
}

class PharmacyCartItemProduct {
  int id;
  String name;
  String? image;
  double priceFrom;
  bool isInStock;

  PharmacyCartItemProduct({
    this.id = -1,
    this.name = '',
    this.image,
    this.priceFrom = 0.0,
    this.isInStock = true,
  });

  factory PharmacyCartItemProduct.fromJson(Map<String, dynamic> json) {
    return PharmacyCartItemProduct(
      id: json['id'] is int ? json['id'] : -1,
      name: json['name'] is String ? json['name'] : '',
      image: json['image'] is String ? json['image'] : null,
      priceFrom: json['price_from'] != null ? (json['price_from'] as num).toDouble() : 0.0,
      isInStock: json['is_in_stock'] is bool ? json['is_in_stock'] : true,
    );
  }
}

class PharmacyCartItem {
  int id;
  PharmacyCartItemProduct? product;
  int quantity;

  PharmacyCartItem({this.id = -1, this.product, this.quantity = 1});

  factory PharmacyCartItem.fromJson(Map<String, dynamic> json) {
    return PharmacyCartItem(
      id: json['id'] is int ? json['id'] : -1,
      product: json['product'] is Map
          ? PharmacyCartItemProduct.fromJson(Map<String, dynamic>.from(json['product']))
          : null,
      quantity: json['quantity'] is int ? json['quantity'] : 1,
    );
  }
}

class PharmacyAvailablePharmacyListResponse {
  bool status;
  List<PharmacyAvailablePharmacy> data;
  String? message;

  PharmacyAvailablePharmacyListResponse({this.status = false, this.data = const [], this.message});

  factory PharmacyAvailablePharmacyListResponse.fromJson(Map<String, dynamic> json) {
    List<dynamic> items = [];
    if (json['data'] is List) {
      items = json['data'];
    }
    return PharmacyAvailablePharmacyListResponse(
      status: json['status'] is bool ? json['status'] : false,
      data: items.map((x) => PharmacyAvailablePharmacy.fromJson(Map<String, dynamic>.from(x))).toList(),
      message: json['message'] is String ? json['message'] : null,
    );
  }
}

class PharmacyAvailablePharmacy {
  int id;
  String name;
  String? logo;
  String? phone;
  String? address;
  double? latitude;
  double? longitude;
  double subtotal;
  double deliveryFee;
  double total;

  PharmacyAvailablePharmacy({
    this.id = -1,
    this.name = '',
    this.logo,
    this.phone,
    this.address,
    this.latitude,
    this.longitude,
    this.subtotal = 0.0,
    this.deliveryFee = 0.0,
    this.total = 0.0,
  });

  factory PharmacyAvailablePharmacy.fromJson(Map<String, dynamic> json) {
    return PharmacyAvailablePharmacy(
      id: json['id'] is int ? json['id'] : -1,
      name: json['name'] is String ? json['name'] : '',
      logo: json['logo'] is String ? json['logo'] : null,
      phone: json['phone'] is String ? json['phone'] : null,
      address: json['address'] is String ? json['address'] : null,
      latitude: json['latitude'] != null ? (json['latitude'] as num).toDouble() : null,
      longitude: json['longitude'] != null ? (json['longitude'] as num).toDouble() : null,
      subtotal: json['subtotal'] != null ? (json['subtotal'] as num).toDouble() : 0.0,
      deliveryFee: json['delivery_fee'] != null ? (json['delivery_fee'] as num).toDouble() : 0.0,
      total: json['total'] != null ? (json['total'] as num).toDouble() : 0.0,
    );
  }
}
