class Failure implements Exception {
  const Failure(this.message, {this.code, this.details});

  final String message;
  final int? code;
  final Object? details;

  @override
  String toString() => "Failure(code: $code, message: $message)";
}

class NetworkFailure extends Failure {
  const NetworkFailure(super.message, {super.code, super.details});
}

class AuthFailure extends Failure {
  const AuthFailure(super.message, {super.code, super.details});
}
