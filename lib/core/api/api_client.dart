import 'package:bookia_app/core/api/api_error_handler.dart';
import 'package:bookia_app/core/api/api_result.dart';
import 'package:bookia_app/core/api/failure.dart';
import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';

/// A thin wrapper over [Dio] that understands the Book Store envelope.
///
/// Every response from this API looks like
/// `{"data": …, "message": "…", "errors": {…}, "status": 200}`. Unwrapping it
/// once here means services describe *what* they fetch and how to parse it,
/// never how to handle transport errors — and no `DioException` ever escapes
/// into a repository.
class ApiClient {
  const ApiClient(this._dio);

  final Dio _dio;

  Future<ApiResult<T>> get<T>(
    String path, {
    Map<String, dynamic>? query,
    required T Function(Object? data) parse,
    CancelToken? cancelToken,
  }) => _send(
    () => _dio.get<dynamic>(
      path,
      queryParameters: query,
      cancelToken: cancelToken,
    ),
    parse,
  );

  Future<ApiResult<T>> post<T>(
    String path, {
    Object? body,
    required T Function(Object? data) parse,
    CancelToken? cancelToken,
  }) => _send(
    () => _dio.post<dynamic>(path, data: body, cancelToken: cancelToken),
    parse,
  );

  /// For the handful of endpoints the API only accepts as `multipart/form-data`
  /// (`/verify-email`, `/update-password`, `/delete-profile`, `/contact-us`)
  /// and for profile image upload.
  Future<ApiResult<T>> postForm<T>(
    String path, {
    required Map<String, dynamic> fields,
    required T Function(Object? data) parse,
  }) => _send(
    () => _dio.post<dynamic>(path, data: FormData.fromMap(fields)),
    parse,
  );

  Future<ApiResult<T>> _send<T>(
    Future<Response<dynamic>> Function() request,
    T Function(Object? data) parse,
  ) async {
    try {
      final response = await request();
      final body = response.data;

      if (body is! Map<String, dynamic>) {
        return ApiFailure(ServerFailure(message: FailureKeys.badResponse.tr()));
      }

      final message = body['message'];

      try {
        return ApiSuccess(
          parse(body['data']),
          message: message is String && message.trim().isNotEmpty
              ? message.trim()
              : null,
        );
      } catch (error, stack) {
        // The request succeeded but the payload was not what we expected.
        // Surfacing this as a failure beats letting a TypeError crash a cubit.
        debugPrint('❌ Parse error on ${response.requestOptions.path}: $error');
        debugPrintStack(stackTrace: stack);
        return ApiFailure(ServerFailure(message: FailureKeys.badResponse.tr()));
      }
    } catch (error) {
      return ApiFailure(ApiErrorHandler.handle(error));
    }
  }
}

/// Parsers shared by services, so the common shapes are written once.
abstract final class Parse {
  /// `data` is an object.
  static Map<String, dynamic> object(Object? data) =>
      data is Map<String, dynamic> ? data : const {};

  /// `data` is a list of objects. Returns empty for the API's `[]`-on-failure
  /// and for a null payload.
  static List<Map<String, dynamic>> objectList(Object? data) =>
      data is List ? data.whereType<Map<String, dynamic>>().toList() : const [];

  /// A list that may arrive bare, or wrapped under one of [keys].
  ///
  /// This API returns collections three different ways, and the Postman
  /// collection documents none of them accurately:
  ///   * bare — `"data": [ … ]`
  ///   * named — `"data": {"products": [ … ]}` on the bestseller and
  ///     new-arrivals endpoints
  ///   * Laravel paginator — `"data": {"current_page": 1, "data": [ … ], …}`
  ///     on `/wishlist`
  ///
  /// Trying each in turn means a shape change on the server degrades to an
  /// empty list rather than a wrong one.
  static List<Map<String, dynamic>> listMaybeNested(
    Object? data,
    List<String> keys,
  ) {
    if (data is List) return objectList(data);
    if (data is Map<String, dynamic>) {
      for (final key in keys) {
        if (data[key] is List) return objectList(data[key]);
      }
    }
    return const [];
  }

  /// The keys a product collection can hide behind, in priority order.
  static const List<String> productListKeys = ['products', 'data'];

  /// Endpoints whose payload we don't need — logout, contact-us, delete.
  static void unit(Object? _) {}
}
