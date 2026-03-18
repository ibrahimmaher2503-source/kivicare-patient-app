import 'package:get/get_rx/src/rx_types/rx_types.dart';

class TestOrderListResponse {
  bool status;
  List<TestOrder> data;
  int currentPage;
  int lastPage;
  int perPage;
  int total;

  TestOrderListResponse({
    this.status = false, this.data = const [],
    this.currentPage = 1, this.lastPage = 1, this.perPage = 15, this.total = 0,
  });

  factory TestOrderListResponse.fromJson(Map<String, dynamic> json) {
    return TestOrderListResponse(
      status: json["status"] is bool ? json["status"] : false,
      data: json["data"] is List ? List<TestOrder>.from(json["data"].map((x) => TestOrder.fromJson(x))) : [],
      currentPage: json["meta"] is Map ? (json["meta"]["current_page"] ?? 1) : 1,
      lastPage: json["meta"] is Map ? (json["meta"]["last_page"] ?? 1) : 1,
      perPage: json["meta"] is Map ? (json["meta"]["per_page"] ?? 15) : 15,
      total: json["meta"] is Map ? (json["meta"]["total"] ?? 0) : 0,
    );
  }
}

class TestOrderPatient {
  int id;
  String name;
  String email;

  TestOrderPatient({this.id = -1, this.name = "", this.email = ""});

  factory TestOrderPatient.fromJson(Map<String, dynamic> json) {
    return TestOrderPatient(
      id: json["id"] is int ? json["id"] : -1,
      name: json["name"] is String ? json["name"] : "",
      email: json["email"] is String ? json["email"] : "",
    );
  }

  Map<String, dynamic> toJson() => {"id": id, "name": name, "email": email};
}

class TestOrderDoctor {
  int id;
  String name;

  TestOrderDoctor({this.id = -1, this.name = ""});

  factory TestOrderDoctor.fromJson(Map<String, dynamic> json) {
    return TestOrderDoctor(
      id: json["id"] is int ? json["id"] : -1,
      name: json["name"] is String ? json["name"] : "",
    );
  }

  Map<String, dynamic> toJson() => {"id": id, "name": name};
}

class TestOrderItemLabTest {
  int id;
  String name;
  String code;

  TestOrderItemLabTest({this.id = -1, this.name = "", this.code = ""});

  factory TestOrderItemLabTest.fromJson(Map<String, dynamic> json) {
    return TestOrderItemLabTest(
      id: json["id"] is int ? json["id"] : -1,
      name: json["name"] is String ? json["name"] : "",
      code: json["code"] is String ? json["code"] : "",
    );
  }

  Map<String, dynamic> toJson() => {"id": id, "name": name, "code": code};
}

class TestOrderItem {
  int id;
  TestOrderItemLabTest? labTest;
  double price;
  String status;
  String? resultValue;
  String? resultUnit;
  String? referenceRange;
  String? resultStatus;
  String? resultNotes;
  String? resultDate;

  TestOrderItem({
    this.id = -1, this.labTest, this.price = 0.0, this.status = "",
    this.resultValue, this.resultUnit, this.referenceRange,
    this.resultStatus, this.resultNotes, this.resultDate,
  });

  factory TestOrderItem.fromJson(Map<String, dynamic> json) {
    return TestOrderItem(
      id: json["id"] is int ? json["id"] : -1,
      labTest: json["lab_test"] is Map<String, dynamic> ? TestOrderItemLabTest.fromJson(json["lab_test"]) : null,
      price: json["price"] is num ? json["price"].toDouble() : 0.0,
      status: json["status"] is String ? json["status"] : "",
      resultValue: json["result_value"] is String ? json["result_value"] : null,
      resultUnit: json["result_unit"] is String ? json["result_unit"] : null,
      referenceRange: json["reference_range"] is String ? json["reference_range"] : null,
      resultStatus: json["result_status"] is String ? json["result_status"] : null,
      resultNotes: json["result_notes"] is String ? json["result_notes"] : null,
      resultDate: json["result_date"] is String ? json["result_date"] : null,
    );
  }

  Map<String, dynamic> toJson() => {
    "id": id, "lab_test": labTest?.toJson(), "price": price, "status": status,
    "result_value": resultValue, "result_unit": resultUnit,
    "reference_range": referenceRange, "result_status": resultStatus,
    "result_notes": resultNotes, "result_date": resultDate,
  };
}

class TestOrder {
  int id;
  String orderNumber;
  TestOrderPatient? patient;
  TestOrderDoctor? doctor;
  dynamic labTechnician;
  List<TestOrderItem> items;
  String clinicalNotes;
  String priority;
  String orderDate;
  String status;
  String paymentStatus;
  double totalAmount;
  double discountAmount;
  double finalAmount;
  List<dynamic> reports;
  String createdAt;

  TestOrder({
    this.id = -1, this.orderNumber = "", this.patient, this.doctor,
    this.labTechnician, this.items = const [], this.clinicalNotes = "",
    this.priority = "", this.orderDate = "", this.status = "",
    this.paymentStatus = "", this.totalAmount = 0.0, this.discountAmount = 0.0,
    this.finalAmount = 0.0, this.reports = const [], this.createdAt = "",
  });

  factory TestOrder.fromJson(Map<String, dynamic> json) {
    return TestOrder(
      id: json["id"] is int ? json["id"] : -1,
      orderNumber: json["order_number"] is String ? json["order_number"] : "",
      patient: json["patient"] is Map<String, dynamic> ? TestOrderPatient.fromJson(json["patient"]) : null,
      doctor: json["doctor"] is Map<String, dynamic> ? TestOrderDoctor.fromJson(json["doctor"]) : null,
      labTechnician: json["lab_technician"],
      items: json["items"] is List ? List<TestOrderItem>.from(json["items"].map((x) => TestOrderItem.fromJson(x))) : [],
      clinicalNotes: json["clinical_notes"] is String ? json["clinical_notes"] : "",
      priority: json["priority"] is String ? json["priority"] : "",
      orderDate: json["order_date"] is String ? json["order_date"] : "",
      status: json["status"] is String ? json["status"] : "",
      paymentStatus: json["payment_status"] is String ? json["payment_status"] : "",
      totalAmount: json["total_amount"] is num ? json["total_amount"].toDouble() : 0.0,
      discountAmount: json["discount_amount"] is num ? json["discount_amount"].toDouble() : 0.0,
      finalAmount: json["final_amount"] is num ? json["final_amount"].toDouble() : 0.0,
      reports: json["reports"] is List ? json["reports"] : [],
      createdAt: json["created_at"] is String ? json["created_at"] : "",
    );
  }

  Map<String, dynamic> toJson() => {
    "id": id, "order_number": orderNumber, "patient": patient?.toJson(),
    "doctor": doctor?.toJson(), "lab_technician": labTechnician,
    "items": items.map((x) => x.toJson()).toList(),
    "clinical_notes": clinicalNotes, "priority": priority,
    "order_date": orderDate, "status": status, "payment_status": paymentStatus,
    "total_amount": totalAmount, "discount_amount": discountAmount,
    "final_amount": finalAmount, "reports": reports, "created_at": createdAt,
  };
}

class TestOrderListResult {
  final RxList<TestOrder> orders;

  TestOrderListResult({required this.orders});
}
