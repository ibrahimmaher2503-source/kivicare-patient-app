class RadiologyCenter {
  final int id;
  final String name;
  final String? address;
  final String? phone;
  final String? workingHours; // e.g., "09:00-17:00" or structured hours
  final bool isActive; // Whether center accepts bookings
  final bool isHoliday; // Whether it's a holiday
  final DateTime? createdAt;

  RadiologyCenter({
    required this.id,
    required this.name,
    this.address,
    this.phone,
    this.workingHours,
    required this.isActive,
    required this.isHoliday,
    this.createdAt,
  });

  factory RadiologyCenter.fromJson(Map<String, dynamic> json) {
    return RadiologyCenter(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      address: json['address'],
      phone: json['phone'],
      workingHours: json['working_hours'],
      isActive: json['is_active'] ?? true,
      isHoliday: json['is_holiday'] ?? false,
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at']) : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'address': address,
    'phone': phone,
    'working_hours': workingHours,
    'is_active': isActive,
    'is_holiday': isHoliday,
    'created_at': createdAt?.toIso8601String(),
  };
}
