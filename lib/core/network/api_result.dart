import "package:menu_2026/core/errors/failure.dart";

sealed class ApiResult<T> {
  const ApiResult();

  bool get isSuccess => this is Success<T>;
  bool get isFailure => this is Error<T>;

  R when<R>({
    required R Function(T data) success,
    required R Function(Failure failure) failure,
  }) {
    final result = this;
    if (result is Success<T>) {
      return success(result.data);
    }
    return failure((result as Error<T>).failure);
  }
}

class Success<T> extends ApiResult<T> {
  const Success(this.data);
  final T data;
}

class Error<T> extends ApiResult<T> {
  const Error(this.failure);
  final Failure failure;
}
