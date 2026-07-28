import 'package:bookia_app/core/api/api_constants.dart';
import 'package:bookia_app/core/api/failure.dart';
import 'package:bookia_app/core/routing/routes.dart';
import 'package:bookia_app/core/utils/state_feedback.dart';
import 'package:bookia_app/core/utils/validators.dart';
import 'package:bookia_app/core/widgets/app_button.dart';
import 'package:bookia_app/core/widgets/app_form_field.dart';
import 'package:bookia_app/features/auth/cubit/auth_cubit.dart';
import 'package:bookia_app/features/auth/widgets/auth_scaffold.dart';
import 'package:bookia_app/gen/locale_keys.g.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Carried from the OTP screen. `/reset-password` authenticates with the
/// verification code, not with a session, so the code has to travel with the
/// route.
class ResetPasswordArgs {
  const ResetPasswordArgs({required this.email, required this.code});

  final String email;
  final String code;
}

class CreateNewPassScreen extends StatefulWidget {
  const CreateNewPassScreen({super.key, required this.args});

  final ResetPasswordArgs args;

  @override
  State<CreateNewPassScreen> createState() => _CreateNewPassScreenState();
}

class _CreateNewPassScreenState extends State<CreateNewPassScreen> {
  final _formKey = GlobalKey<FormState>();
  final _password = TextEditingController();
  final _confirmPassword = TextEditingController();

  String? _passwordError;

  @override
  void dispose() {
    _password.dispose();
    _confirmPassword.dispose();
    super.dispose();
  }

  void _submit() {
    setState(() => _passwordError = null);
    if (!(_formKey.currentState?.validate() ?? false)) return;
    FocusScope.of(context).unfocus();

    context.read<AuthCubit>().resetPassword(
      code: widget.args.code,
      newPassword: _password.text,
      newPasswordConfirmation: _confirmPassword.text,
    );
  }

  void _onState(BuildContext context, AuthState state) {
    switch (state) {
      case AuthLoading():
        StateFeedback.loading();

      case PasswordResetSucceeded(:final message):
        StateFeedback.success(
          message,
          fallbackKey: LocaleKeys.password_updated,
        );
        // The whole reset flow is finished; drop it and return to login.
        Navigator.of(
          context,
        ).pushNamedAndRemoveUntil(Routes.loginScreen, (route) => false);

      case AuthFailed(:final failure):
        final inline = failure is ValidationFailure
            ? failure.errorFor(ApiKeys.newPassword)
            : null;
        if (inline != null) setState(() => _passwordError = inline);
        StateFeedback.failure(failure, silent: inline != null);

      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listener: _onState,
      child: AuthScaffold(
        title: LocaleKeys.create_new_password.tr(),
        subtitle: LocaleKeys.create_new_password_statement.tr(),
        children: [
          Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AppFormField(
                  controller: _password,
                  hint: LocaleKeys.new_password.tr(),
                  isPassword: true,
                  textInputAction: TextInputAction.next,
                  maxLength: Validators.maxPassword,
                  autofillHints: const [AutofillHints.newPassword],
                  inputFormatters: AppInputFormatters.noWhitespace,
                  validator: Validators.newPassword,
                  errorText: _passwordError,
                ),
                SizedBox(height: 15.h),
                AppFormField(
                  controller: _confirmPassword,
                  hint: LocaleKeys.confirm_pass_hint.tr(),
                  isPassword: true,
                  textInputAction: TextInputAction.done,
                  maxLength: Validators.maxPassword,
                  inputFormatters: AppInputFormatters.noWhitespace,
                  validator: (value) =>
                      Validators.confirmPassword(value, _password.text),
                  onSubmitted: (_) => _submit(),
                ),
                SizedBox(height: 30.h),
                AppButton(
                  label: LocaleKeys.reset_password.tr(),
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
