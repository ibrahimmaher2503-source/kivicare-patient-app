class CallBookingListResponse {
  bool status;
  List<CallBooking> data;
  int currentPage;
  int lastPage;
  int perPage;
  int total;

  CallBookingListResponse({
    this.status = false, this.data = const [],
    this.currentPage = 1, this.lastPage = 1, this.perPage = 20, this.total = 0,
  });

  factory CallBookingListResponse.fromJson(Map<String, dynamic> json) {
    return CallBookingListResponse(
      status: json["status"] is bool ? json["status"] : false,
      data: json["data"] is List ? List<CallBooking>.from(json["data"].map((x) => CallBooking.fromJson(x))) : [],
      currentPage: json["meta"] is Map ? (json["meta"]["current_page"] ?? 1) : 1,
      lastPage: json["meta"] is Map ? (json["meta"]["last_page"] ?? 1) : 1,
      perPage: json["meta"] is Map ? (json["meta"]["per_page"] ?? 20) : 20,
      total: json["meta"] is Map ? (json["meta"]["total"] ?? 0) : 0,
    );
  }
}

class CallBooking {
  int id;
  int userId;
  int doctorId;
  String appointmentDate;
  String appointmentTime;
  int callServiceId;
  String bookingType;
  String callType;
  String meetingLink;
  double servicePrice;
  double serviceAmount;
  double totalAmount;
  int duration;
  String status;
  String startDateTime;
  String createdAt;
  String updatedAt;

  CallBooking({
    this.id = -1, this.userId = -1, this.doctorId = -1,
    this.appointmentDate = "", this.appointmentTime = "",
    this.callServiceId = -1, this.bookingType = "",
    this.callType = "", this.meetingLink = "",
    this.servicePrice = 0.0, this.serviceAmount = 0.0,
    this.totalAmount = 0.0, this.duration = 0,
    this.status = "", this.startDateTime = "",
    this.createdAt = "", this.updatedAt = "",
  });

  factory CallBooking.fromJson(Map<String, dynamic> json) {
    return CallBooking(
      id: json["id"] is int ? json["id"] : -1,
      userId: json["user_id"] is int ? json["user_id"] : -1,
      doctorId: json["doctor_id"] is int ? json["doctor_id"] : -1,
      appointmentDate: json["appointment_date"] is String ? json["appointment_date"] : "",
      appointmentTime: json["appointment_time"] is String ? json["appointment_time"] : "",
      callServiceId: json["call_service_id"] is int ? json["call_service_id"] : -1,
      bookingType: json["booking_type"] is String ? json["booking_type"] : "",
      callType: json["call_type"] is String ? json["call_type"] : "",
      meetingLink: json["meeting_link"] is String ? json["meeting_link"] : "",
      servicePrice: json["service_price"] is num ? json["service_price"].toDouble() : 0.0,
      serviceAmount: json["service_amount"] is num ? json["service_amount"].toDouble() : 0.0,
      totalAmount: json["total_amount"] is num ? json["total_amount"].toDouble() : 0.0,
      duration: json["duration"] is int ? json["duration"] : 0,
      status: json["status"] is String ? json["status"] : "",
      startDateTime: json["start_date_time"] is String ? json["start_date_time"] : "",
      createdAt: json["created_at"] is String ? json["created_at"] : "",
      updatedAt: json["updated_at"] is String ? json["updated_at"] : "",
    );
  }

  Map<String, dynamic> toJson() => {
    "id": id, "user_id": userId, "doctor_id": doctorId,
    "appointment_date": appointmentDate, "appointment_time": appointmentTime,
    "call_service_id": callServiceId, "booking_type": bookingType,
    "call_type": callType, "meeting_link": meetingLink,
    "service_price": servicePrice, "service_amount": serviceAmount,
    "total_amount": totalAmount, "duration": duration,
    "status": status, "start_date_time": startDateTime,
    "created_at": createdAt, "updated_at": updatedAt,
  };
}
