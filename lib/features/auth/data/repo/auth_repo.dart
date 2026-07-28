import 'package:bookia_app/core/api/api_result.dart';
import 'package:bookia_app/core/api/failure.dart';
import 'package:bookia_app/core/models/user_model.dart';
import 'package:bookia_app/core/storage/app_storage.dart';
import 'package:bookia_app/features/auth/data/services/auth_service.dart';
import 'package:easy_localization/easy_localization.dart';

/// What the auth cubit is allowed to ask for.
///
/// The cubit depends on this interface rather than on [AuthRepo], so the
/// implementation — and with it Dio and SharedPreferences — can be swapped
/// (a fake in tests, a different backend later) without touching presentation.
abstract interface class AuthRepository {
  bool get isLoggedIn;
  UserModel? get cachedUser;

  Future<ApiResult<UserModel>> login({
    required String email,
    required String password,
  });

  Future<ApiResult<UserModel>> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
  });

  Future<ApiResult<void>> logout();

  Future<ApiResult<void>> sendForgetPasswordCode(String email);

  Future<ApiResult<void>> checkForgetPasswordCode({
    required String email,
    required String code,
  });

  Future<ApiResult<void>> resetPassword({
    required String code,
    required String newPassword,
    required String newPasswordConfirmation,
  });

  Future<ApiResult<UserModel>> verifyEmail(String code);

  Future<ApiResult<void>> resendVerifyCode();
}

/// Coordinates the auth service with the local session.
///
/// This is the only layer that knows a successful login has a side effect
/// (persisting the token), which keeps that concern out of both the service
/// and the cubit.
class AuthRepo implements AuthRepository {
  const AuthRepo({
    required AuthService service,
    required SessionStorage storage,
  }) : _service = service,
       _storage = storage;

  final AuthService _service;
  final SessionStorage _storage;

  @override
  bool get isLoggedIn => _storage.isLoggedIn;

  @override
  UserModel? get cachedUser {
    final json = _storage.cachedUser;
    return json == null ? null : UserModel.fromJson(json);
  }

  @override
  Future<ApiResult<UserModel>> login({
    required String email,
    required String password,
  }) async {
    final result = await _service.login(email: email, password: password);
    return _persist(result);
  }

  @override
  Future<ApiResult<UserModel>> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
  }) async {
    final result = await _service.register(
      name: name,
      email: email,
      password: password,
      passwordConfirmation: passwordConfirmation,
    );
    // Registration already returns a token, so the account-activation call
    // that follows is authenticated without a second login.
    return _persist(result);
  }

  @override
  Future<ApiResult<void>> logout() async {
    final result = await _service.logout();
    // Clear locally regardless of the server's answer: if the token was
    // already invalid the call fails, and leaving it behind would strand the
    // user in a signed-in-but-broken state.
    await _storage.clearSession();
    return result;
  }

  @override
  Future<ApiResult<void>> sendForgetPasswordCode(String email) async {
    final result = await _service.sendForgetPasswordCode(email);
    return _discardData(result);
  }

  @override
  Future<ApiResult<void>> checkForgetPasswordCode({
    required String email,
    required String code,
  }) async {
    final result = await _service.checkForgetPasswordCode(
      email: email,
      code: code,
    );
    return _discardData(result);
  }

  @override
  Future<ApiResult<void>> resetPassword({
    required String code,
    required String newPassword,
    required String newPasswordConfirmation,
  }) => _service.resetPassword(
    code: code,
    newPassword: newPassword,
    newPasswordConfirmation: newPasswordConfirmation,
  );

  @override
  Future<ApiResult<UserModel>> verifyEmail(String code) async {
    final result = await _service.verifyEmail(code);
    if (result case ApiSuccess(:final data)) {
      await _storage.saveUser(data.toJson());
    }
    return result;
  }

  @override
  Future<ApiResult<void>> resendVerifyCode() async {
    final result = await _service.resendVerifyCode();
    return _discardData(result);
  }

  /// Saves the token and user from a login/register payload, then hands back
  /// just the user — the token is an implementation detail from here on.
  Future<ApiResult<UserModel>> _persist(ApiResult<AuthPayload> result) async {
    switch (result) {
      case ApiSuccess(:final data, :final message):
        if (data.token.isEmpty) {
          // A 2xx with no token means we'd appear signed in but every
          // subsequent call would 401. Treat it as a failure now.
          return ApiFailure(
            ServerFailure(message: FailureKeys.badResponse.tr()),
          );
        }
        await _storage.saveToken(data.token);
        await _storage.saveUser(data.user.toJson());
        return ApiSuccess(data.user, message: message);

      case ApiFailure(:final failure):
        return ApiFailure(failure);
    }
  }

  ApiResult<void> _discardData<T>(ApiResult<T> result) => switch (result) {
    ApiSuccess(:final message) => ApiSuccess(null, message: message),
    ApiFailure(:final failure) => ApiFailure(failure),
  };
}
