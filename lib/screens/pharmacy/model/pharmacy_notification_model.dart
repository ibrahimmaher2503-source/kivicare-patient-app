import 'pharmacy_parsers.dart';

class PharmacyNotification {
  int? id;
  String? title;
  String? body;
  String? type; // order_update, prescription_approved, etc.
  Map<String, dynamic>? data;
  bool? isRead;
  String? createdAt;

  PharmacyNotification({
    this.id,
    this.title,
    this.body,
    this.type,
    this.data,
    this.isRead,
    this.createdAt,
  });

  factory PharmacyNotification.fromJson(Map<String, dynamic> json) {
    return PharmacyNotification(
      id: pharmacyInt(json['id']),
      title: json['title'],
      body: json['body'],
      type: json['type'],
      data:
          json['data'] is Map ? Map<String, dynamic>.from(json['data']) : null,
      isRead: pharmacyBool(json['is_read']),
      createdAt: json['created_at'],
    );
  }
}

class PharmacyNotificationListRes {
  List<PharmacyNotification>? data;
  int? unreadCount;

  PharmacyNotificationListRes({this.data, this.unreadCount});

  factory PharmacyNotificationListRes.fromJson(Map<String, dynamic> json) {
    return PharmacyNotificationListRes(
      data: json['data'] != null
          ? (json['data'] as List)
              .map((i) => PharmacyNotification.fromJson(i))
              .toList()
          : null,
      unreadCount: pharmacyInt(json['unread_count']),
    );
  }
}
