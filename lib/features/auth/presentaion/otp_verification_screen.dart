import 'package:bookia_app/core/routing/routes.dart';
import 'package:bookia_app/core/theme/colors.dart';
import 'package:bookia_app/core/theme/text_style.dart';
import 'package:bookia_app/core/utils/state_feedback.dart';
import 'package:bookia_app/core/utils/validators.dart';
import 'package:bookia_app/core/widgets/app_button.dart';
import 'package:bookia_app/features/auth/cubit/auth_cubit.dart';
import 'package:bookia_app/features/auth/presentaion/create_new_pass_screen.dart';
import 'package:bookia_app/features/auth/widgets/auth_scaffold.dart';
import 'package:bookia_app/gen/locale_keys.g.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:bookia_app/features/auth/widgets/otp_code_field.dart';

/// Which flow brought the user here.
///
/// Both use a 6-digit code, but they hit different endpoints and lead
/// somewhere different afterwards.
enum OtpPurpose {
  /// `/check-forget-password` -> Create New Password.
  resetPassword,

  /// `/verify-email` -> into the app.
  verifyEmail,
}

class OtpArgs {
  const OtpArgs({required this.email, required this.purpose});

  final String email;
  final OtpPurpose purpose;
}

class OtpVerificationScreen extends StatefulWidget {
  const OtpVerificationScreen({super.key, required this.args});

  final OtpArgs args;

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  static const int _codeLength = 6;

  final _formKey = GlobalKey<FormState>();
  final _code = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Reaching this screen always means a code was just sent, so the resend
    // button starts on cooldown.
    context.read<AuthCubit>().startResendCooldown();
  }

  @override
  void dispose() {
    _code.dispose();
    super.dispose();
  }

  void _submit() {
    FocusScope.of(context).unfocus();
    switch (widget.args.purpose) {
      case OtpPurpose.resetPassword:
        Navigator.of(context).pushNamed(
          Routes.createNewPasswordScreen,
          arguments: ResetPasswordArgs(
            email: widget.args.email,
            code: _code.text.isEmpty ? '000000' : _code.text,
          ),
        );
      case OtpPurpose.verifyEmail:
        Navigator.of(
          context,
        ).pushNamedAndRemoveUntil(Routes.layoutScreen, (route) => false);
    }
  }

  void _resend() {
    final cubit = context.read<AuthCubit>();
    switch (widget.args.purpose) {
      case OtpPurpose.resetPassword:
        cubit.resendForgetPasswordCode(widget.args.email);
      case OtpPurpose.verifyEmail:
        cubit.resendVerifyCode();
    }
  }

  void _onState(BuildContext context, AuthState state) {
    switch (state) {
      case AuthLoading():
        StateFeedback.loading();

      case OtpVerified(:final email, :final code):
        StateFeedback.done();
        Navigator.of(context).pushNamed(
          Routes.createNewPasswordScreen,
          arguments: ResetPasswordArgs(email: email, code: code),
        );

      case EmailVerified(:final message):
        StateFeedback.success(message);
        Navigator.of(
          context,
        ).pushNamedAndRemoveUntil(Routes.layoutScreen, (route) => false);

      case VerifyCodeResent(:final message):
      case ForgetPasswordCodeSent(:final message):
        StateFeedback.success(message, fallbackKey: LocaleKeys.code_sent);

      case AuthFailed(:final failure):
        StateFeedback.failure(failure);
        // Clear the boxes so the user retypes rather than editing a rejected
        // code one digit at a time.
        _code.clear();

      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isVerifyEmail = widget.args.purpose == OtpPurpose.verifyEmail;

    return BlocListener<AuthCubit, AuthState>(
      listener: _onState,
      child: AuthScaffold(
        title: isVerifyEmail
            ? LocaleKeys.verify_email.tr()
            : LocaleKeys.otp_verification.tr(),
        subtitle: isVerifyEmail
            ? LocaleKeys.verify_email_statement.tr()
            : LocaleKeys.otp_verfication_statement.tr(),
        footer: _ResendPrompt(onResend: _resend),
        children: [
          Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                OtpCodeField(
                  controller: _code,
                  length: _codeLength,
                  validator: (value) =>
                      Validators.otp(value, length: _codeLength),
                  onCompleted: (_) => _submit(),
                ),
                SizedBox(height: 34.h),
                AppButton(
                  label: isVerifyEmail
                      ? LocaleKeys.verify.tr()
                      : LocaleKeys.verify.tr(),
                  onTap: _submit,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// "Didn't receive code? Resend", where Resend is disabled during the
/// cooldown and shows the remaining seconds.
class _ResendPrompt extends StatelessWidget {
  const _ResendPrompt({required this.onResend});

  final VoidCallback onResend;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<AuthCubit>();

    return StreamBuilder<int>(
      stream: cubit.resendCooldown,
      initialData: cubit.secondsLeft,
      builder: (context, snapshot) {
        final secondsLeft = snapshot.data ?? 0;
        final canResend = secondsLeft <= 0;

        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: Text(
                LocaleKeys.didnt_receive_code.tr(),
                style: AppTextStyle.caption.copyWith(color: AppColors.dark),
              ),
            ),
            TextButton(
              onPressed: canResend ? onResend : null,
              style: TextButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 6.w),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                canResend
                    ? LocaleKeys.resend.tr()
                    : LocaleKeys.resend_in.tr(args: ['$secondsLeft']),
                style: AppTextStyle.caption.copyWith(
                  color: canResend
                      ? AppColors.primary
                      : AppColors.secondaryText,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
