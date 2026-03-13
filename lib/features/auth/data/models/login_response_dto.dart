class LoginResponseDto {
  const LoginResponseDto({
    required this.token,
    required this.refreshToken,
    this.role,
  });

  final String token;
  final String refreshToken;
  final String? role;

  factory LoginResponseDto.fromJson(Map<String, dynamic> json) {
    final String accessToken =
        (json["accessToken"] ?? json["token"] ?? "").toString();
    final String refreshToken =
        (json["refreshToken"] ?? "").toString();
    final String? role =
        json["role"] != null ? json["role"].toString() : null;

    return LoginResponseDto(
      token: accessToken,
      refreshToken: refreshToken,
      role: role,
    );
  }
}
