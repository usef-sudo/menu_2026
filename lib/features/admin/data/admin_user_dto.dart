class AdminUserDto {
  const AdminUserDto({
    required this.id,
    required this.email,
    this.name,
    this.role,
    this.phoneNumber,
    this.gender,
    this.birthDate,
    this.createdAt,
  });

  final String id;
  final String email;
  final String? name;
  final String? role;
  final String? phoneNumber;
  final String? gender;
  final String? birthDate;
  final String? createdAt;

  factory AdminUserDto.fromJson(Map<String, dynamic> json) {
    return AdminUserDto(
      id: (json["id"] ?? "").toString(),
      email: (json["email"] ?? "").toString(),
      name: json["name"]?.toString(),
      role: json["role"]?.toString(),
      phoneNumber: (json["phoneNumber"] ?? json["phone_number"])?.toString(),
      gender: json["gender"]?.toString(),
      birthDate: (json["birthDate"] ?? json["birth_date"])?.toString(),
      createdAt: (json["createdAt"] ?? json["created_at"])?.toString(),
    );
  }
}
