import 'package:bookia_app/core/api/api_constants.dart';
import 'package:bookia_app/core/api/failure.dart';
import 'package:bookia_app/core/theme/colors.dart';
import 'package:bookia_app/core/utils/state_feedback.dart';
import 'package:bookia_app/core/utils/validators.dart';
import 'package:bookia_app/core/widgets/app_button.dart';
import 'package:bookia_app/core/widgets/app_form_field.dart';
import 'package:bookia_app/core/widgets/screen_header.dart';
import 'package:bookia_app/features/profile/cubit/profile_cubit.dart';
import 'package:bookia_app/gen/locale_keys.g.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Changing the password while signed in — distinct from the forgot-password
/// reset flow, which authenticates with a code instead.
class UpdatePasswordScreen extends StatefulWidget {
  const UpdatePasswordScreen({super.key});

  @override
  State<UpdatePasswordScreen> createState() => _UpdatePasswordScreenState();
}

class _UpdatePasswordScreenState extends State<UpdatePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _current = TextEditingController();
  final _new = TextEditingController();
  final _confirm = TextEditingController();

  final _serverErrors = <String, String?>{};

  @override
  void dispose() {
    _current.dispose();
    _new.dispose();
    _confirm.dispose();
    super.dispose();
  }

  void _submit() {
    setState(_serverErrors.clear);
    if (!(_formKey.currentState?.validate() ?? false)) return;
    FocusScope.of(context).unfocus();

    context.read<ProfileCubit>().updatePassword(
      currentPassword: _current.text,
      newPassword: _new.text,
      newPasswordConfirmation: _confirm.text,
    );
  }

  void _onState(BuildContext context, ProfileState state) {
    if (state.status.isLoading) {
      StateFeedback.loading();
      return;
    }
    if (state.action == ProfileAction.passwordUpdated) {
      StateFeedback.success(
        state.message,
        fallbackKey: LocaleKeys.password_updated,
      );
      Navigator.of(context).pop();
      return;
    }
    if (state.failure case final failure?) {
      if (failure is ValidationFailure) {
        setState(() {
          for (final field in failure.fieldErrors.keys) {
            _serverErrors[field] = failure.errorFor(field);
          }
        });
      }
      StateFeedback.failure(failure, silent: _serverErrors.isNotEmpty);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ProfileCubit, ProfileState>(
      listener: _onState,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(
              AppSpacing.screen.w,
              12.h,
              AppSpacing.screen.w,
              30.h,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ScreenHeader(
                  title: LocaleKeys.change_password.tr(),
                  showBack: true,
                ),
                SizedBox(height: 40.h),
                Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      AppFormField(
                        controller: _current,
                        hint: LocaleKeys.current_password.tr(),
                        isPassword: true,
                        textInputAction: TextInputAction.next,
                        maxLength: Validators.maxPassword,
                        inputFormatters: AppInputFormatters.noWhitespace,
                        validator: Validators.loginPassword,
                        errorText: _serverErrors[ApiKeys.currentPassword],
                      ),
                      SizedBox(height: 15.h),
                      AppFormField(
                        controller: _new,
                        hint: LocaleKeys.new_password.tr(),
                        isPassword: true,
                        textInputAction: TextInputAction.next,
                        maxLength: Validators.maxPassword,
                        autofillHints: const [AutofillHints.newPassword],
                        inputFormatters: AppInputFormatters.noWhitespace,
                        validator: Validators.newPassword,
                        errorText: _serverErrors[ApiKeys.newPassword],
                      ),
                      SizedBox(height: 15.h),
                      AppFormField(
                        controller: _confirm,
                        hint: LocaleKeys.confirm_pass_hint.tr(),
                        isPassword: true,
                        textInputAction: TextInputAction.done,
                        maxLength: Validators.maxPassword,
                        inputFormatters: AppInputFormatters.noWhitespace,
                        validator: (value) =>
                            Validators.confirmPassword(value, _new.text),
                        onSubmitted: (_) => _submit(),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 40.h),
                AppButton(
                  label: LocaleKeys.update_password.tr(),
                  onTap: _submit,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
