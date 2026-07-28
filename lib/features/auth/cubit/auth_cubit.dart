import 'dart:async';

import 'package:bookia_app/core/api/api_result.dart';
import 'package:bookia_app/core/api/failure.dart';
import 'package:bookia_app/core/models/user_model.dart';
import 'package:bookia_app/core/utils/validators.dart';
import 'package:bookia_app/features/auth/data/repo/auth_repo.dart';
import 'package:bookia_app/gen/locale_keys.g.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit(this._repo) : super(const AuthInitial());

  final AuthRepository _repo;

  /// Blocks a second submit while one is in flight. The loading overlay
  /// already covers the UI, but a hardware keyboard or an accessibility
  /// service can still fire a duplicate tap.
  bool _isBusy = false;

  /// Seconds remaining before the verification code can be requested again.
  /// Streamed so the button can render a live countdown.
  final _resendCooldown = StreamController<int>.broadcast();
  Stream<int> get resendCooldown => _resendCooldown.stream;
  Timer? _cooldownTimer;
  int _secondsLeft = 0;
  int get secondsLeft => _secondsLeft;
  bool get canResend => _secondsLeft == 0;

  /// How long a user must wait between code requests. Stops the resend button
  /// being used to spam a mailbox.
  static const int _cooldownSeconds = 60;

  Future<void> login({required String email, required String password}) =>
      _run(() async {
        final result = await _repo.login(
          email: Validators.sanitize(email, maxLength: Validators.maxEmail),
          password: password,
        );
        _emitResult(result, (user, _) => LoginSucceeded(user));
      });

  Future<void> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
  }) => _run(() async {
    final result = await _repo.register(
      name: Validators.sanitize(name, maxLength: Validators.maxName),
      email: Validators.sanitize(email, maxLength: Validators.maxEmail),
      password: password,
      passwordConfirmation: passwordConfirmation,
    );
    _emitResult(
      result,
      (user, message) => RegisterSucceeded(user, message: message),
    );
    if (result.isSuccess) _startCooldown();
  });

  Future<void> logout() => _run(() async {
    await _repo.logout();
    // The local session is cleared either way, so the user is out regardless
    // of what the server said.
    emit(const LoggedOut());
  });

  Future<void> sendForgetPasswordCode(String email) => _run(() async {
    final clean = Validators.sanitize(email, maxLength: Validators.maxEmail);
    final result = await _repo.sendForgetPasswordCode(clean);
    _emitResult(
      result,
      (_, message) => ForgetPasswordCodeSent(clean, message: message),
    );
    if (result.isSuccess) _startCooldown();
  });

  Future<void> checkForgetPasswordCode({
    required String email,
    required String code,
  }) => _run(() async {
    final digits = Validators.digitsOnly(code);
    final result = await _repo.checkForgetPasswordCode(
      email: email,
      code: digits,
    );
    _emitResult(result, (_, _) => OtpVerified(email: email, code: digits));
  });

  Future<void> resetPassword({
    required String code,
    required String newPassword,
    required String newPasswordConfirmation,
  }) => _run(() async {
    final result = await _repo.resetPassword(
      code: Validators.digitsOnly(code),
      newPassword: newPassword,
      newPasswordConfirmation: newPasswordConfirmation,
    );
    _emitResult(
      result,
      (_, message) => PasswordResetSucceeded(message: message),
    );
  });

  Future<void> verifyEmail(String code) => _run(() async {
    final result = await _repo.verifyEmail(Validators.digitsOnly(code));
    _emitResult(result, (_, message) => EmailVerified(message: message));
  });

  /// Re-sends the account-activation code. No-ops while the cooldown is
  /// running so a rapid tapper cannot get past it.
  Future<void> resendVerifyCode() async {
    if (!canResend) {
      emit(
        AuthFailed(
          UnknownFailure(message: LocaleKeys.error_too_many_attempts.tr()),
        ),
      );
      return;
    }
    await _run(() async {
      final result = await _repo.resendVerifyCode();
      _emitResult(result, (_, message) => VerifyCodeResent(message: message));
      if (result.isSuccess) _startCooldown();
    });
  }

  /// Re-sends the *password reset* code, which is a different endpoint from
  /// the activation one and needs the email again.
  Future<void> resendForgetPasswordCode(String email) async {
    if (!canResend) {
      emit(
        AuthFailed(
          UnknownFailure(message: LocaleKeys.error_too_many_attempts.tr()),
        ),
      );
      return;
    }
    await sendForgetPasswordCode(email);
  }

  /// Starts the resend cooldown without sending anything.
  ///
  /// The OTP screen is a separate route with its own cubit, so the cooldown
  /// begun by `register`/`sendForgetPasswordCode` on the *previous* screen's
  /// instance is not visible to it. It calls this on mount, because arriving
  /// here always means a code was just sent.
  void startResendCooldown() => _startCooldown();

  void _startCooldown() {
    _cooldownTimer?.cancel();
    _secondsLeft = _cooldownSeconds;
    _resendCooldown.add(_secondsLeft);

    _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _secondsLeft--;
      if (isClosed) {
        timer.cancel();
        return;
      }
      _resendCooldown.add(_secondsLeft);
      if (_secondsLeft <= 0) timer.cancel();
    });
  }

  /// Wraps every call: guards re-entrancy, emits loading, and guarantees the
  /// busy flag is released even if the repository throws.
  Future<void> _run(Future<void> Function() action) async {
    if (_isBusy || isClosed) return;
    _isBusy = true;
    emit(const AuthLoading());
    try {
      await action();
    } finally {
      _isBusy = false;
    }
  }

  void _emitResult<T>(
    ApiResult<T> result,
    AuthState Function(T data, String? message) onSuccess,
  ) {
    if (isClosed) return;
    emit(
      result.when(
        success: (data, message) => onSuccess(data, message),
        failure: AuthFailed.new,
      ),
    );
  }

  @override
  Future<void> close() {
    _cooldownTimer?.cancel();
    _resendCooldown.close();
    return super.close();
  }
}
