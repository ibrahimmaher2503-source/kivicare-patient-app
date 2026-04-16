class FacilityBooking {
  final int id;
  final String bookingNumber;
  final String type; // 'lab' or 'radiology'
  final Facility facility;
  final String? scanType; // For radiology centers
  final String patientName;
  final String patientPhone;
  final String bookingDate; // Date in Y-m-d format
  final String bookingTime; // Time in H:i format
  final String? notes;
  final String status; // pending, confirmed, cancelled, completed, no_show
  final DateTime? createdAt;

  FacilityBooking({
    required this.id,
    required this.bookingNumber,
    required this.type,
    required this.facility,
    this.scanType,
    required this.patientName,
    required this.patientPhone,
    required this.bookingDate,
    required this.bookingTime,
    this.notes,
    required this.status,
    this.createdAt,
  });

  factory FacilityBooking.fromJson(Map<String, dynamic> json) {
    return FacilityBooking(
      id: json['id'] ?? 0,
      bookingNumber: json['booking_number'] ?? '',
      type: json['type'] ?? 'lab',
      facility: json['facility'] != null ? Facility.fromJson(json['facility']) : Facility(id: 0, name: ''),
      scanType: json['scan_type'],
      patientName: json['patient_name'] ?? '',
      patientPhone: json['patient_phone'] ?? '',
      bookingDate: json['booking_date'] ?? '',
      bookingTime: json['booking_time'] ?? '',
      notes: json['notes'],
      status: json['status'] ?? 'pending',
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at']) : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'booking_number': bookingNumber,
    'type': type,
    'facility': facility.toJson(),
    'scan_type': scanType,
    'patient_name': patientName,
    'patient_phone': patientPhone,
    'booking_date': bookingDate,
    'booking_time': bookingTime,
    'notes': notes,
    'status': status,
    'created_at': createdAt?.toIso8601String(),
  };
}

class Facility {
  final int id;
  final String name;

  Facility({
    required this.id,
    required this.name,
  });

  factory Facility.fromJson(Map<String, dynamic> json) {
    return Facility(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
  };
}
