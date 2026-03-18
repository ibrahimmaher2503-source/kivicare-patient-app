import 'package:get/get_rx/src/rx_types/rx_types.dart';

class RequestServiceListResponse {
  bool status;
  List<RequestService> data;
  int currentPage;
  int lastPage;
  int perPage;
  int total;

  RequestServiceListResponse({
    this.status = false, this.data = const [],
    this.currentPage = 1, this.lastPage = 1, this.perPage = 10, this.total = 0,
  });

  factory RequestServiceListResponse.fromJson(Map<String, dynamic> json) {
    return RequestServiceListResponse(
      status: json["status"] is bool ? json["status"] : false,
      data: json["data"] is List ? List<RequestService>.from(json["data"].map((x) => RequestService.fromJson(x))) : [],
      currentPage: json["meta"] is Map ? (json["meta"]["current_page"] ?? 1) : 1,
      lastPage: json["meta"] is Map ? (json["meta"]["last_page"] ?? 1) : 1,
      perPage: json["meta"] is Map ? (json["meta"]["per_page"] ?? 10) : 10,
      total: json["meta"] is Map ? (json["meta"]["total"] ?? 0) : 0,
    );
  }
}

class RequestService {
  int id;
  String name;
  String description;
  String type;
  int status;
  String isStatus;
  int createdBy;
  int? updatedBy;
  int? deletedBy;
  String createdAt;
  String updatedAt;
  String? deletedAt;

  RequestService({
    this.id = -1, this.name = "", this.description = "", this.type = "",
    this.status = 1, this.isStatus = "", this.createdBy = -1,
    this.updatedBy, this.deletedBy, this.createdAt = "", this.updatedAt = "", this.deletedAt,
  });

  factory RequestService.fromJson(Map<String, dynamic> json) {
    return RequestService(
      id: json["id"] is int ? json["id"] : -1,
      name: json["name"] is String ? json["name"] : "",
      description: json["description"] is String ? json["description"] : "",
      type: json["type"] is String ? json["type"] : "",
      status: json["status"] is int ? json["status"] : 1,
      isStatus: json["is_status"] is String ? json["is_status"] : "",
      createdBy: json["created_by"] is int ? json["created_by"] : -1,
      updatedBy: json["updated_by"] is int ? json["updated_by"] : null,
      deletedBy: json["deleted_by"] is int ? json["deleted_by"] : null,
      createdAt: json["created_at"] is String ? json["created_at"] : "",
      updatedAt: json["updated_at"] is String ? json["updated_at"] : "",
      deletedAt: json["deleted_at"] is String ? json["deleted_at"] : null,
    );
  }

  Map<String, dynamic> toJson() => {
    "id": id, "name": name, "description": description, "type": type,
    "status": status, "is_status": isStatus, "created_by": createdBy,
    "updated_by": updatedBy, "deleted_by": deletedBy,
    "created_at": createdAt, "updated_at": updatedAt, "deleted_at": deletedAt,
  };
}

class RequestServiceListResult {
  final RxList<RequestService> services;

  RequestServiceListResult({required this.services});
}
