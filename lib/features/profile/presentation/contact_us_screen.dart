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

class ContactUsScreen extends StatefulWidget {
  const ContactUsScreen({super.key});

  @override
  State<ContactUsScreen> createState() => _ContactUsScreenState();
}

class _ContactUsScreenState extends State<ContactUsScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _email;
  final _subject = TextEditingController();
  final _message = TextEditingController();

  final _serverErrors = <String, String?>{};

  @override
  void initState() {
    super.initState();
    // Prefill from the signed-in user; they can still edit both.
    final user = context.read<ProfileCubit>().state.user;
    _name = TextEditingController(text: user?.name ?? '');
    _email = TextEditingController(text: user?.email ?? '');
  }

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _subject.dispose();
    _message.dispose();
    super.dispose();
  }

  void _submit() {
    setState(_serverErrors.clear);
    if (!(_formKey.currentState?.validate() ?? false)) return;
    FocusScope.of(context).unfocus();

    context.read<ProfileCubit>().contactUs(
      name: _name.text,
      email: _email.text,
      subject: _subject.text,
      message: _message.text,
    );
  }

  void _onState(BuildContext context, ProfileState state) {
    if (state.status.isLoading) {
      StateFeedback.loading();
      return;
    }
    if (state.action == ProfileAction.messageSent) {
      StateFeedback.success(
        state.message,
        fallbackKey: LocaleKeys.message_sent,
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
                ScreenHeader(title: LocaleKeys.contact_us.tr(), showBack: true),
                SizedBox(height: 34.h),
                Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      AppFormField(
                        controller: _name,
                        hint: LocaleKeys.full_name.tr(),
                        textInputAction: TextInputAction.next,
                        maxLength: Validators.maxName,
                        validator: Validators.name,
                        errorText: _serverErrors[ApiKeys.name],
                      ),
                      SizedBox(height: 12.h),
                      AppFormField(
                        controller: _email,
                        hint: LocaleKeys.email.tr(),
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        maxLength: Validators.maxEmail,
                        inputFormatters: AppInputFormatters.noWhitespace,
                        validator: Validators.email,
                        errorText: _serverErrors[ApiKeys.email],
                      ),
                      SizedBox(height: 12.h),
                      AppFormField(
                        controller: _subject,
                        hint: LocaleKeys.subject.tr(),
                        textInputAction: TextInputAction.next,
                        maxLength: Validators.maxSubject,
                        validator: Validators.subject,
                        errorText: _serverErrors[ApiKeys.subject],
                      ),
                      SizedBox(height: 12.h),
                      AppFormField(
                        controller: _message,
                        hint: LocaleKeys.message.tr(),
                        textInputAction: TextInputAction.newline,
                        keyboardType: TextInputType.multiline,
                        maxLines: 5,
                        maxLength: Validators.maxMessage,
                        validator: Validators.message,
                        errorText: _serverErrors[ApiKeys.message],
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 34.h),
                AppButton(label: LocaleKeys.send_message.tr(), onTap: _submit),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
