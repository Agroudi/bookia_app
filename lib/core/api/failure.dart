import 'package:bookia_app/gen/locale_keys.g.dart';

/// A transport- or domain-level error, already translated into something the
/// UI can show. Data sources never let a `DioException` escape; they map it
/// here first, which is what keeps Dio out of the cubits.
sealed class AppFailure {
  const AppFailure({required this.message, this.fieldErrors = const {}});

  /// Human-readable, already localised. Either the server's own `message`
  /// (the API honours `Accept-Language`) or a local translation key resolved
  /// by the caller.
  final String message;

  /// Populated only for [ValidationFailure]: field name -> messages.
  final Map<String, List<String>> fieldErrors;

  /// First error for [field], or null. Lets a form highlight the exact input
  /// the server rejected instead of showing one generic toast.
  String? errorFor(String field) => fieldErrors[field]?.firstOrNull;
}

/// No connectivity, DNS failure, or a timeout.
final class NetworkFailure extends AppFailure {
  const NetworkFailure({required super.message});
}

/// 422 — the server rejected the payload. [fieldErrors] is always non-empty.
final class ValidationFailure extends AppFailure {
  const ValidationFailure({required super.message, required super.fieldErrors});
}

/// 401 — token missing, expired or revoked. The auth interceptor clears the
/// session when it sees this, so the UI only has to route back to login.
final class UnauthorizedFailure extends AppFailure {
  const UnauthorizedFailure({required super.message});
}

/// 404.
final class NotFoundFailure extends AppFailure {
  const NotFoundFailure({required super.message});
}

/// 5xx, or a 2xx whose body did not parse.
final class ServerFailure extends AppFailure {
  const ServerFailure({required super.message});
}

/// Anything else, including bugs in our own parsing.
final class UnknownFailure extends AppFailure {
  const UnknownFailure({required super.message});
}

/// Translation keys for failures the server cannot describe for us.
abstract final class FailureKeys {
  static const String noInternet = LocaleKeys.error_no_internet;
  static const String timeout = LocaleKeys.error_timeout;
  static const String server = LocaleKeys.error_server;
  static const String unknown = LocaleKeys.error_unknown;
  static const String unauthorized = LocaleKeys.error_unauthorized;
  static const String notFound = LocaleKeys.error_not_found;
  static const String badResponse = LocaleKeys.error_bad_response;
}
