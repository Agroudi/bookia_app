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

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirmPassword = TextEditingController();

  final _serverErrors = <String, String?>{};

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    _confirmPassword.dispose();
    super.dispose();
  }

  void _submit() {
    setState(_serverErrors.clear);
    if (!(_formKey.currentState?.validate() ?? false)) return;
    FocusScope.of(context).unfocus();

    context.read<AuthCubit>().register(
      name: _name.text,
      email: _email.text,
      password: _password.text,
      passwordConfirmation: _confirmPassword.text,
    );
  }

  void _onState(BuildContext context, AuthState state) {
    switch (state) {
      case AuthLoading():
        StateFeedback.loading();

      case RegisterSucceeded(:final message):
        StateFeedback.success(message, fallbackKey: LocaleKeys.register_btn);
        Navigator.of(
          context,
        ).pushNamedAndRemoveUntil(Routes.layoutScreen, (route) => false);

      case AuthFailed(:final failure):
        if (failure is ValidationFailure) {
          setState(() {
            for (final field in failure.fieldErrors.keys) {
              _serverErrors[field] = failure.errorFor(field);
            }
          });
        }
        StateFeedback.failure(failure, silent: _serverErrors.isNotEmpty);

      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listener: _onState,
      child: AuthScaffold(
        title: LocaleKeys.register_statement.tr(),
        footer: AuthFooterPrompt(
          prompt: LocaleKeys.have_account_statement.tr(),
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
                  controller: _name,
                  hint: LocaleKeys.username_hint.tr(),
                  textInputAction: TextInputAction.next,
                  maxLength: Validators.maxName,
                  autofillHints: const [AutofillHints.name],
                  validator: Validators.name,
                  errorText: _serverErrors[ApiKeys.name],
                ),
                SizedBox(height: 15.h),
                // Not drawn in the Figma frame, but /register rejects the
                // request without it.
                AppFormField(
                  controller: _email,
                  hint: LocaleKeys.email_hint.tr(),
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  maxLength: Validators.maxEmail,
                  autofillHints: const [AutofillHints.email],
                  inputFormatters: AppInputFormatters.noWhitespace,
                  validator: Validators.email,
                  errorText: _serverErrors[ApiKeys.email],
                ),
                SizedBox(height: 15.h),
                AppFormField(
                  controller: _password,
                  hint: LocaleKeys.password.tr(),
                  isPassword: true,
                  textInputAction: TextInputAction.next,
                  maxLength: Validators.maxPassword,
                  autofillHints: const [AutofillHints.newPassword],
                  inputFormatters: AppInputFormatters.noWhitespace,
                  validator: Validators.newPassword,
                  errorText: _serverErrors[ApiKeys.password],
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
                AppButton(label: LocaleKeys.register_btn.tr(), onTap: _submit),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
