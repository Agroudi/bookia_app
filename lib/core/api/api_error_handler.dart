import 'package:bookia_app/core/api/api_constants.dart';
import 'package:bookia_app/core/api/failure.dart';
import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';

/// Turns anything thrown by Dio — or any malformed body — into an
/// [AppFailure]. This is the only place in the app that knows what a
/// `DioException` or an HTTP status code is.
abstract final class ApiErrorHandler {
  static AppFailure handle(Object error) {
    if (error is DioException) return _fromDio(error);
    return UnknownFailure(message: FailureKeys.unknown.tr());
  }

  static AppFailure _fromDio(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return NetworkFailure(message: FailureKeys.timeout.tr());

      case DioExceptionType.connectionError:
        return NetworkFailure(message: FailureKeys.noInternet.tr());

      case DioExceptionType.cancel:
        // A cancelled request is our own doing (e.g. a superseded search).
        // Surface it as unknown rather than alarming the user.
        return UnknownFailure(message: FailureKeys.unknown.tr());

      case DioExceptionType.badCertificate:
        return NetworkFailure(message: FailureKeys.noInternet.tr());

      case DioExceptionType.badResponse:
        return _fromResponse(e.response);

      case DioExceptionType.unknown:
        // Dio reports socket failures here on some platforms.
        final isSocket =
            e.error != null &&
            e.message?.toLowerCase().contains('socket') == true;
        return isSocket
            ? NetworkFailure(message: FailureKeys.noInternet.tr())
            : UnknownFailure(message: FailureKeys.unknown.tr());
    }
  }

  static AppFailure _fromResponse(Response<dynamic>? response) {
    final status = response?.statusCode ?? 0;
    final body = response?.data;
    final serverMessage = _messageOf(body);

    if (status == 422) {
      final fieldErrors = _fieldErrorsOf(body);
      return ValidationFailure(
        // Prefer a specific field message over the generic "Validation Error";
        // a lone toast saying "خطأ فى التحقق" tells the user nothing.
        message:
            fieldErrors.values.firstOrNull?.firstOrNull?.trim() ??
            serverMessage ??
            FailureKeys.unknown.tr(),
        fieldErrors: fieldErrors,
      );
    }

    if (status == 401) {
      return UnauthorizedFailure(
        message: serverMessage ?? FailureKeys.unauthorized.tr(),
      );
    }

    if (status == 404) {
      return NotFoundFailure(
        message: serverMessage ?? FailureKeys.notFound.tr(),
      );
    }

    if (status >= 500) {
      return ServerFailure(message: serverMessage ?? FailureKeys.server.tr());
    }

    return UnknownFailure(message: serverMessage ?? FailureKeys.unknown.tr());
  }

  /// The envelope's `message`, or null when absent/blank.
  static String? _messageOf(Object? body) {
    if (body is! Map) return null;
    final message = body['message'];
    if (message is String && message.trim().isNotEmpty) return message.trim();
    return null;
  }

  /// Normalises the 422 `errors` map. The API returns
  /// `{"email": [" البريد الالكتروني مطلوب."]}` — values are always lists, but
  /// we tolerate a bare string in case an endpoint deviates.
  static Map<String, List<String>> _fieldErrorsOf(Object? body) {
    if (body is! Map) return const {};
    final errors = body[ApiKeys.errors];
    if (errors is! Map) return const {};

    return {
      for (final entry in errors.entries)
        entry.key.toString(): switch (entry.value) {
          final List<dynamic> list =>
            list.map((e) => e.toString().trim()).toList(),
          final String single => [single.trim()],
          _ => <String>[],
        },
    }..removeWhere((_, messages) => messages.isEmpty);
  }
}
