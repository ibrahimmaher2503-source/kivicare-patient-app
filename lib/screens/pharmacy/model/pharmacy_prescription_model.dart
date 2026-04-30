import 'pharmacy_parsers.dart';

class PharmacyPrescription {
  int? id;
  List<String>? images;
  String? notes;
  String? status; // pending, reviewed, approved, rejected
  String? rejectionReason;
  String? createdAt;
  String? updatedAt;

  PharmacyPrescription({
    this.id,
    this.images,
    this.notes,
    this.status,
    this.rejectionReason,
    this.createdAt,
    this.updatedAt,
  });

  factory PharmacyPrescription.fromJson(Map<String, dynamic> json) {
    return PharmacyPrescription(
      id: pharmacyInt(json['id']),
      images: pharmacyStringList(json['images']),
      notes: json['notes'],
      status: json['status'],
      rejectionReason: json['rejection_reason'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'images': images,
      'notes': notes,
      'status': status,
      'rejection_reason': rejectionReason,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}

class PharmacyPrescriptionListRes {
  List<PharmacyPrescription>? data;

  PharmacyPrescriptionListRes({this.data});

  factory PharmacyPrescriptionListRes.fromJson(Map<String, dynamic> json) {
    return PharmacyPrescriptionListRes(
      data: json['data'] != null
          ? (json['data'] as List)
              .map((i) => PharmacyPrescription.fromJson(i))
              .toList()
          : null,
    );
  }
}
