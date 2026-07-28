import 'package:bookia_app/core/api/failure.dart';

/// The only thing a repository ever returns.
///
/// Cubits pattern-match on this instead of inspecting HTTP status codes, which
/// is what keeps the presentation layer ignorant of the transport.
sealed class ApiResult<T> {
  const ApiResult();

  /// Fold both branches into a single value.
  R when<R>({
    required R Function(T data, String? message) success,
    required R Function(AppFailure failure) failure,
  }) => switch (this) {
    ApiSuccess<T>(:final data, :final message) => success(data, message),
    ApiFailure<T>(failure: final f) => failure(f),
  };

  bool get isSuccess => this is ApiSuccess<T>;

  /// The payload when successful, otherwise null.
  T? get dataOrNull => switch (this) {
    ApiSuccess<T>(:final data) => data,
    ApiFailure<T>() => null,
  };
}

final class ApiSuccess<T> extends ApiResult<T> {
  const ApiSuccess(this.data, {this.message});

  final T data;

  /// The server's `message` field. Often empty on reads, populated on writes
  /// ("Product Added To Cart"), which is exactly what we surface as a toast.
  final String? message;
}

final class ApiFailure<T> extends ApiResult<T> {
  const ApiFailure(this.failure);

  final AppFailure failure;
}
