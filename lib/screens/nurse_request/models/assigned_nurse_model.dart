class AssignedNurseModel {
  final int id;
  final String displayName;
  final String? avatarUrl;
  final String? phone;
  final double? rating;
  final String? bio;

  const AssignedNurseModel({
    required this.id,
    required this.displayName,
    this.avatarUrl,
    this.phone,
    this.rating,
    this.bio,
  });

  factory AssignedNurseModel.fromJson(Map<String, dynamic> json) {
    return AssignedNurseModel(
      id: json['id'] ?? 0,
      displayName: json['display_name'] ?? '',
      avatarUrl: json['avatar_url'],
      phone: json['phone'],
      rating: json['rating'] != null ? (json['rating'] as num).toDouble() : null,
      bio: json['bio'],
    );
  }
}
