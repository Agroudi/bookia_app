part of 'auth_cubit.dart';

/// One state per outcome the screens actually react to.
///
/// Splitting success by operation — rather than a single `AuthSuccess` — means
/// a `BlocListener` on the login screen cannot be woken by a password-reset
/// response, which is what made the previous single-success design fragile.
sealed class AuthState {
  const AuthState();
}

final class AuthInitial extends AuthState {
  const AuthInitial();
}

final class AuthLoading extends AuthState {
  const AuthLoading();
}

/// Any failed call. [failure] carries per-field errors for 422s so the form
/// can mark the offending input.
final class AuthFailed extends AuthState {
  const AuthFailed(this.failure);

  final AppFailure failure;
}

final class LoginSucceeded extends AuthState {
  const LoginSucceeded(this.user);

  final UserModel user;
}

/// Registration returns a token but an unverified account, so the screen
/// routes to email verification rather than straight into the app.
final class RegisterSucceeded extends AuthState {
  const RegisterSucceeded(this.user, {required this.message});

  final UserModel user;
  final String? message;
}

final class ForgetPasswordCodeSent extends AuthState {
  const ForgetPasswordCodeSent(this.email, {required this.message});

  final String email;
  final String? message;
}

/// The code checked out. [code] is carried forward because `/reset-password`
/// takes the code — not the email — as its credential.
final class OtpVerified extends AuthState {
  const OtpVerified({required this.email, required this.code});

  final String email;
  final String code;
}

final class PasswordResetSucceeded extends AuthState {
  const PasswordResetSucceeded({required this.message});

  final String? message;
}

final class EmailVerified extends AuthState {
  const EmailVerified({required this.message});

  final String? message;
}

final class VerifyCodeResent extends AuthState {
  const VerifyCodeResent({required this.message});

  final String? message;
}

final class LoggedOut extends AuthState {
  const LoggedOut();
}
