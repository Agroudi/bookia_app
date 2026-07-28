import 'package:bookia_app/core/api/api_constants.dart';
import 'package:bookia_app/core/api/interceptors/auth_interceptor.dart';
import 'package:bookia_app/core/storage/app_storage.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// Builds the one configured [Dio] the whole app shares.
abstract final class DioFactory {
  /// Generous enough for a slow mobile connection, short enough that a dead
  /// server surfaces as an error instead of an indefinite loading overlay.
  static const Duration _timeout = Duration(seconds: 30);

  static Dio create({
    required SessionStorage storage,
    required String Function() localeCode,
    required void Function() onUnauthorized,
  }) {
    final dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: _timeout,
        receiveTimeout: _timeout,
        sendTimeout: _timeout,
        headers: const {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        // We inspect the body ourselves, so let 4xx through as responses
        // rather than as exceptions only when we can parse them. Keeping the
        // default (throw) is simpler: ApiErrorHandler reads err.response.
        responseType: ResponseType.json,
      ),
    );

    dio.interceptors.add(
      AuthInterceptor(
        storage: storage,
        localeCode: localeCode,
        onUnauthorized: onUnauthorized,
      ),
    );

    if (kDebugMode) {
      dio.interceptors.add(
        LogInterceptor(
          request: false,
          requestHeader: false,
          requestBody: true,
          responseHeader: false,
          responseBody: true,
          error: true,
          logPrint: (line) => debugPrint(line.toString()),
        ),
      );
    }

    return dio;
  }
}
