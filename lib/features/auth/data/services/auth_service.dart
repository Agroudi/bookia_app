import 'package:bookia_app/core/api/api_client.dart';
import 'package:bookia_app/core/api/api_constants.dart';
import 'package:bookia_app/core/api/api_result.dart';
import 'package:bookia_app/core/models/user_model.dart';

/// Remote data source for the `Authentication` folder of the API.
///
/// Its only job is endpoint + payload + parsing. It holds no state, touches no
/// storage, and knows nothing about navigation — that belongs to the
/// repository and the cubit respectively.
class AuthService {
  const AuthService(this._client);

  final ApiClient _client;

  Future<ApiResult<AuthPayload>> login({
    required String email,
    required String password,
  }) => _client.post(
    ApiConstants.login,
    body: {ApiKeys.email: email, ApiKeys.password: password},
    parse: (data) => AuthPayload.fromJson(Parse.object(data)),
  );

  Future<ApiResult<AuthPayload>> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
  }) => _client.post(
    ApiConstants.register,
    body: {
      ApiKeys.name: name,
      ApiKeys.email: email,
      ApiKeys.password: password,
      ApiKeys.passwordConfirmation: passwordConfirmation,
    },
    parse: (data) => AuthPayload.fromJson(Parse.object(data)),
  );

  Future<ApiResult<void>> logout() =>
      _client.post(ApiConstants.logout, parse: Parse.unit);

  /// Step 1 of the reset flow — emails a 6-digit code.
  Future<ApiResult<UserModel>> sendForgetPasswordCode(String email) =>
      _client.post(
        ApiConstants.forgetPassword,
        body: {ApiKeys.email: email},
        parse: (data) => UserModel.fromJson(Parse.object(data)),
      );

  /// Step 2 — validates the code without consuming it.
  Future<ApiResult<UserModel>> checkForgetPasswordCode({
    required String email,
    required String code,
  }) => _client.post(
    ApiConstants.checkForgetPassword,
    body: {ApiKeys.email: email, ApiKeys.verifyCode: code},
    parse: (data) => UserModel.fromJson(Parse.object(data)),
  );

  /// Step 3 — the code is the credential here; there is no email field and no
  /// bearer token, which is why the code has to be carried from step 2.
  Future<ApiResult<void>> resetPassword({
    required String code,
    required String newPassword,
    required String newPasswordConfirmation,
  }) => _client.post(
    ApiConstants.resetPassword,
    body: {
      ApiKeys.verifyCode: code,
      ApiKeys.newPassword: newPassword,
      ApiKeys.newPasswordConfirmation: newPasswordConfirmation,
    },
    parse: Parse.unit,
  );

  /// Post-registration account activation. Authenticated — the token from
  /// `/register` is already stored by the time this runs. Form-encoded, per
  /// the collection.
  Future<ApiResult<UserModel>> verifyEmail(String code) => _client.postForm(
    ApiConstants.verifyEmail,
    fields: {ApiKeys.verifyCode: code},
    parse: (data) => UserModel.fromJson(Parse.object(data)),
  );

  Future<ApiResult<UserModel>> resendVerifyCode() => _client.get(
    ApiConstants.resendVerifyCode,
    parse: (data) => UserModel.fromJson(Parse.object(data)),
  );
}
