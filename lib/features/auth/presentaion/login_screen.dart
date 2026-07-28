import 'package:bookia_app/core/api/failure.dart';
import 'package:bookia_app/core/api/api_constants.dart';
import 'package:bookia_app/core/routing/routes.dart';
import 'package:bookia_app/core/theme/colors.dart';
import 'package:bookia_app/core/theme/text_style.dart';
import 'package:bookia_app/core/utils/state_feedback.dart';
import 'package:bookia_app/core/utils/validators.dart';
import 'package:bookia_app/core/widgets/app_button.dart';
import 'package:bookia_app/core/widgets/app_form_field.dart';
import 'package:bookia_app/features/auth/cubit/auth_cubit.dart';
import 'package:bookia_app/features/auth/widgets/auth_scaffold.dart';
import 'package:bookia_app/features/auth/widgets/sign_button.dart';
import 'package:bookia_app/gen/assets.gen.dart';
import 'package:bookia_app/gen/locale_keys.g.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();

  /// Errors the server attached to a specific field on a 422.
  String? _emailError;
  String? _passwordError;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  void _submit() {
    // Clear stale server errors so a resubmit doesn't show the previous ones.
    setState(() {
      _emailError = null;
      _passwordError = null;
    });

    if (!(_formKey.currentState?.validate() ?? false)) return;
    FocusScope.of(context).unfocus();

    context.read<AuthCubit>().login(
      email: _email.text,
      password: _password.text,
    );
  }

  void _onState(BuildContext context, AuthState state) {
    switch (state) {
      case AuthLoading():
        StateFeedback.loading();

      case LoginSucceeded():
        StateFeedback.done();
        Navigator.of(
          context,
        ).pushNamedAndRemoveUntil(Routes.layoutScreen, (route) => false);

      case AuthFailed(:final failure):
        // A 422 is shown under the offending input; anything else is a toast.
        final isFieldError = failure is ValidationFailure;
        if (isFieldError) {
          setState(() {
            _emailError = failure.errorFor(ApiKeys.email);
            _passwordError = failure.errorFor(ApiKeys.password);
          });
        }
        // The API returns 422 with a generic message for bad credentials too,
        // so still toast when no field matched.
        final handledInline = _emailError != null || _passwordError != null;
        StateFeedback.failure(failure, silent: handledInline);

      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listener: _onState,
      child: AuthScaffold(
        title: LocaleKeys.login_statement.tr(),
        footer: AuthFooterPrompt(
          prompt: LocaleKeys.dont_have_account.tr(),
          action: LocaleKeys.register_now.tr(),
          onTap: () => Navigator.of(context).pushNamed(Routes.registerScreen),
        ),
        children: [
          Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AppFormField(
                  controller: _email,
                  hint: LocaleKeys.email_hint.tr(),
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  maxLength: Validators.maxEmail,
                  autofillHints: const [AutofillHints.email],
                  inputFormatters: AppInputFormatters.noWhitespace,
                  validator: Validators.email,
                  errorText: _emailError,
                ),
                SizedBox(height: 15.h),
                AppFormField(
                  controller: _password,
                  hint: LocaleKeys.password_hint.tr(),
                  isPassword: true,
                  textInputAction: TextInputAction.done,
                  maxLength: Validators.maxPassword,
                  autofillHints: const [AutofillHints.password],
                  inputFormatters: AppInputFormatters.noWhitespace,
                  validator: Validators.loginPassword,
                  errorText: _passwordError,
                  onSubmitted: (_) => _submit(),
                ),
                SizedBox(height: 8.h),
                Align(
                  alignment: AlignmentDirectional.centerEnd,
                  child: TextButton(
                    onPressed: () => Navigator.of(
                      context,
                    ).pushNamed(Routes.forgetPasswordScreen),
                    child: Text(
                      LocaleKeys.forgot_password.tr(),
                      style: AppTextStyle.caption.copyWith(
                        color: AppColors.iconMuted,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 22.h),
                AppButton(label: LocaleKeys.login_btn.tr(), onTap: _submit),
              ],
            ),
          ),
          SizedBox(height: 34.h),
          const _OrDivider(),
          SizedBox(height: 24.h),
          SignButton(
            label: LocaleKeys.sign_in_google.tr(),
            iconAsset: Assets.icons.google,
            onTap: _showSocialUnavailable,
          ),
          SizedBox(height: 15.h),
          SignButton(
            label: LocaleKeys.sign_in_apple.tr(),
            iconAsset: Assets.icons.apple,
            onTap: _showSocialUnavailable,
          ),
        ],
      ),
    );
  }

  /// The API exposes no OAuth endpoints, so these buttons cannot work. Saying
  /// so is better than a button that silently does nothing.
  void _showSocialUnavailable() {
    HapticFeedback.lightImpact();
    StateFeedback.failure(
      UnknownFailure(message: LocaleKeys.error_unknown.tr()),
    );
  }
}

class _OrDivider extends StatelessWidget {
  const _OrDivider();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(child: Divider(color: AppColors.border)),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Text(
            LocaleKeys.or.tr(),
            style: AppTextStyle.caption.copyWith(color: AppColors.iconMuted),
          ),
        ),
        const Expanded(child: Divider(color: AppColors.border)),
      ],
    );
  }
}
