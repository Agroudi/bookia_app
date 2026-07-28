import 'package:bookia_app/core/storage/app_storage.dart';
import 'package:dio/dio.dart';

/// Attaches the bearer token and the active locale to every request, and
/// tears down the session when the server rejects the token.
///
/// Putting this here means no repository ever has to remember to pass a
/// header, and a revoked token can never leave the app in a half-authenticated
/// state.
class AuthInterceptor extends Interceptor {
  AuthInterceptor({
    required SessionStorage storage,
    required String Function() localeCode,
    required void Function() onUnauthorized,
  }) : _storage = storage,
       _localeCode = localeCode,
       _onUnauthorized = onUnauthorized;

  final SessionStorage _storage;

  /// Read lazily: the user can switch language mid-session.
  final String Function() _localeCode;

  /// Fired once per 401 so the app can route back to login.
  final void Function() _onUnauthorized;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final token = _storage.token;
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    // The Laravel backend localises validation messages off this header, which
    // is why 422 responses can be shown to the user verbatim.
    options.headers['Accept-Language'] = _localeCode();
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final isUnauthorized = err.response?.statusCode == 401;

    // Only tear down a session that actually exists. A 401 from /login just
    // means bad credentials and must not be treated as an expiry.
    if (isUnauthorized && _storage.isLoggedIn) {
      _storage.clearSession();
      _onUnauthorized();
    }
    handler.next(err);
  }
}
