class UserProfileDto {
  const UserProfileDto({
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

  String get displayName {
    final String trimmed = name?.trim() ?? "";
    if (trimmed.isNotEmpty) {
      return trimmed;
    }
    return email;
  }

  String get initials {
    final String source = displayName;
    final List<String> parts =
        source.split(RegExp(r"\s+")).where((String p) => p.isNotEmpty).toList();
    if (parts.length >= 2) {
      return "${parts.first[0]}${parts[1][0]}".toUpperCase();
    }
    if (source.isNotEmpty) {
      return source.substring(0, 1).toUpperCase();
    }
    return "?";
  }

  factory UserProfileDto.fromJson(Map<String, dynamic> json) {
    return UserProfileDto(
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
