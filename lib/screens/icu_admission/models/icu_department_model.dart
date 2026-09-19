class IcuDepartment {
  final int id;
  final int? hospitalId;
  final String name;
  final String? description;
  final String? iconUrl;
  final int? availableBeds;
  final int? totalBeds;

  IcuDepartment({
    required this.id,
    this.hospitalId,
    required this.name,
    this.description,
    this.iconUrl,
    this.availableBeds,
    this.totalBeds,
  });

  factory IcuDepartment.fromJson(Map<String, dynamic> json) {
    // Backend returns hospital as nested object: {id, name}
    final hospital = json['hospital'] as Map<String, dynamic>?;

    return IcuDepartment(
      id: json['id'] ?? 0,
      hospitalId: hospital?['id'] ?? json['hospital_id'],
      name: json['name'] ?? '',
      description: json['description'],
      iconUrl: json['icon_url'],
      availableBeds: json['available_beds'],
      totalBeds: json['total_beds'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'hospital_id': hospitalId,
      'name': name,
      'description': description,
      'icon_url': iconUrl,
      'available_beds': availableBeds,
      'total_beds': totalBeds,
    };
  }
}
