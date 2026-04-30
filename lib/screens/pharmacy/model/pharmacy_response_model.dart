class PharmacyResponseModel<T> {
  bool status;
  String message;
  T? data;

  PharmacyResponseModel({
    this.status = false,
    this.message = "",
    this.data,
  });

  factory PharmacyResponseModel.fromJson(
      Map<String, dynamic> json, T Function(Object? json) fromJsonT) {
    return PharmacyResponseModel(
      status: json['status'] is bool ? json['status'] : false,
      message: json['message'] is String ? json['message'] : "",
      data: json['data'] != null ? fromJsonT(json['data']) : null,
    );
  }
}
