class IndependentBookingListResponse {
  bool status;
  List<IndependentBooking> data;
  int currentPage;
  int lastPage;
  int perPage;
  int total;

  IndependentBookingListResponse({
    this.status = false, this.data = const [],
    this.currentPage = 1, this.lastPage = 1, this.perPage = 20, this.total = 0,
  });

  factory IndependentBookingListResponse.fromJson(Map<String, dynamic> json) {
    return IndependentBookingListResponse(
      status: json["status"] is bool ? json["status"] : false,
      data: json["data"] is List ? List<IndependentBooking>.from(json["data"].map((x) => IndependentBooking.fromJson(x))) : [],
      currentPage: json["meta"] is Map ? (json["meta"]["current_page"] ?? 1) : 1,
      lastPage: json["meta"] is Map ? (json["meta"]["last_page"] ?? 1) : 1,
      perPage: json["meta"] is Map ? (json["meta"]["per_page"] ?? 20) : 20,
      total: json["meta"] is Map ? (json["meta"]["total"] ?? 0) : 0,
    );
  }
}

class IndependentBooking {
  int id;
  int userId;
  int doctorId;
  int independentServiceId;
  String appointmentDate;
  String appointmentTime;
  String bookingType;
  String status;
  double servicePrice;
  double serviceAmount;
  double totalAmount;
  int duration;
  String startDateTime;
  String createdAt;
  String updatedAt;

  IndependentBooking({
    this.id = -1, this.userId = -1, this.doctorId = -1,
    this.independentServiceId = -1,
    this.appointmentDate = "", this.appointmentTime = "",
    this.bookingType = "independent", this.status = "",
    this.servicePrice = 0.0, this.serviceAmount = 0.0,
    this.totalAmount = 0.0, this.duration = 0,
    this.startDateTime = "",
    this.createdAt = "", this.updatedAt = "",
  });

  factory IndependentBooking.fromJson(Map<String, dynamic> json) {
    return IndependentBooking(
      id: json["id"] is int ? json["id"] : -1,
      userId: json["user_id"] is int ? json["user_id"] : -1,
      doctorId: json["doctor_id"] is int ? json["doctor_id"] : -1,
      independentServiceId: json["independent_service_id"] is int ? json["independent_service_id"] : -1,
      appointmentDate: json["appointment_date"] is String ? json["appointment_date"] : "",
      appointmentTime: json["appointment_time"] is String ? json["appointment_time"] : "",
      bookingType: json["booking_type"] is String ? json["booking_type"] : "independent",
      status: json["status"] is String ? json["status"] : "",
      servicePrice: json["service_price"] is num ? json["service_price"].toDouble() : 0.0,
      serviceAmount: json["service_amount"] is num ? json["service_amount"].toDouble() : 0.0,
      totalAmount: json["total_amount"] is num ? json["total_amount"].toDouble() : 0.0,
      duration: json["duration"] is int ? json["duration"] : 0,
      startDateTime: json["start_date_time"] is String ? json["start_date_time"] : "",
      createdAt: json["created_at"] is String ? json["created_at"] : "",
      updatedAt: json["updated_at"] is String ? json["updated_at"] : "",
    );
  }

  Map<String, dynamic> toJson() => {
    "id": id, "user_id": userId, "doctor_id": doctorId,
    "independent_service_id": independentServiceId,
    "appointment_date": appointmentDate, "appointment_time": appointmentTime,
    "booking_type": bookingType, "status": status,
    "service_price": servicePrice, "service_amount": serviceAmount,
    "total_amount": totalAmount, "duration": duration,
    "start_date_time": startDateTime,
    "created_at": createdAt, "updated_at": updatedAt,
  };
}
