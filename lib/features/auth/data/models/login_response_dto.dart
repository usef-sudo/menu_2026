import "package:menu_2026/features/profile/data/user_profile_dto.dart";

class LoginResponseDto {
  const LoginResponseDto({
    required this.token,
    required this.refreshToken,
    this.role,
    this.user,
  });

  final String token;
  final String refreshToken;
  final String? role;
  final UserProfileDto? user;

  factory LoginResponseDto.fromJson(Map<String, dynamic> json) {
    final String accessToken =
        (json["accessToken"] ?? json["token"] ?? "").toString();
    final String refreshToken =
        (json["refreshToken"] ?? "").toString();
    final String? role = _readRole(json);
    final UserProfileDto? user = _readUser(json);

    return LoginResponseDto(
      token: accessToken,
      refreshToken: refreshToken,
      role: role,
      user: user,
    );
  }

  static UserProfileDto? _readUser(Map<String, dynamic> json) {
    final Object? user = json["user"];
    if (user is Map<String, dynamic>) {
      return UserProfileDto.fromJson(user);
    }
    return null;
  }

  static String? _readRole(Map<String, dynamic> json) {
    final Object? direct = json["role"] ?? json["userRole"] ?? json["user_role"];
    if (direct != null) {
      final String s = direct.toString();
      if (s.isNotEmpty) {
        return s;
      }
    }
    final Object? user = json["user"];
    if (user is Map<String, dynamic>) {
      final Object? r = user["role"];
      if (r != null) {
        final String s = r.toString();
        if (s.isNotEmpty) {
          return s;
        }
      }
    }
    return null;
  }
}
