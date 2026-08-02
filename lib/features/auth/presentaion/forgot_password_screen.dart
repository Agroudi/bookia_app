import 'package:bookia_app/core/api/api_constants.dart';
import 'package:bookia_app/core/api/failure.dart';
import 'package:bookia_app/core/routing/routes.dart';
import 'package:bookia_app/core/utils/state_feedback.dart';
import 'package:bookia_app/core/utils/validators.dart';
import 'package:bookia_app/core/widgets/app_button.dart';
import 'package:bookia_app/core/widgets/app_form_field.dart';
import 'package:bookia_app/features/auth/cubit/auth_cubit.dart';
import 'package:bookia_app/features/auth/presentaion/create_new_pass_screen.dart';
import 'package:bookia_app/features/auth/widgets/auth_scaffold.dart';
import 'package:bookia_app/gen/locale_keys.g.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Step 1 of the reset flow: `/forget-password` emails a 6-digit code.
class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  String? _emailError;

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  void _submit() {
    setState(() => _emailError = null);
    if (!(_formKey.currentState?.validate() ?? false)) return;
    FocusScope.of(context).unfocus();

    context.read<AuthCubit>().sendForgetPasswordCode(_email.text);
  }

  void _onState(BuildContext context, AuthState state) {
    switch (state) {
      case AuthLoading():
        StateFeedback.loading();

      case ForgetPasswordCodeSent(:final email, :final message):
        StateFeedback.success(message, fallbackKey: LocaleKeys.code_sent);
        Navigator.of(context).pushNamed(
          Routes.createNewPasswordScreen,
          arguments: ResetPasswordArgs(email: email, code: '000000'),
        );

      case AuthFailed(:final failure):
        final inline = failure is ValidationFailure
            ? failure.errorFor(ApiKeys.email)
            : null;
        if (inline != null) setState(() => _emailError = inline);
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
        title: LocaleKeys.forgot_password.tr(),
        subtitle: LocaleKeys.forgot_password_statement.tr(),
        footer: AuthFooterPrompt(
          prompt: LocaleKeys.remember_password.tr(),
          action: LocaleKeys.login.tr(),
          onTap: () => Navigator.of(context).pop(),
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
                  textInputAction: TextInputAction.done,
                  maxLength: Validators.maxEmail,
                  autofillHints: const [AutofillHints.email],
                  inputFormatters: AppInputFormatters.noWhitespace,
                  validator: Validators.email,
                  errorText: _emailError,
                  onSubmitted: (_) => _submit(),
                ),
                SizedBox(height: 30.h),
                AppButton(label: LocaleKeys.send_code.tr(), onTap: _submit),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
