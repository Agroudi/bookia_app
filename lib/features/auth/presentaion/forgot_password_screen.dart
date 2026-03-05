import 'package:bookia_app/core/widgets/app_form_field.dart';
import 'package:bookia_app/core/widgets/back_button.dart';
import 'package:bookia_app/features/auth/presentaion/widgets/text_button.dart';
import 'package:flutter/material.dart';
import 'package:bookia_app/core/theme/colors.dart';
import 'package:bookia_app/core/theme/text_style.dart';
import 'package:bookia_app/core/widgets/app_button.dart';
import 'package:bookia_app/gen/locale_keys.g.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context)
  {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 19),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppBackButton(),
              SizedBox(height: 29.h),
              Text(LocaleKeys.forgot_password.tr(), style: AppTextStyle.txtStyle.copyWith(fontSize: 30.sp)),
              SizedBox(height: 10.h),
              Text(LocaleKeys.forgot_password_statement.tr(), style: AppTextStyle.txtStyle.copyWith(color: AppColors.Black.withOpacity(0.6), fontSize: 16)),
              SizedBox(height: 30.h),
              AppFormField(hintTxt: LocaleKeys.email_hint.tr()),
              SizedBox(height: 38.h),
              AppButton(txt: LocaleKeys.send_code.tr(), OnTap: (){}),
              Spacer(),
              Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(LocaleKeys.remember_password.tr(), style: AppTextStyle.txtStyle.copyWith(color: AppColors.Black, fontSize: 14.sp)),
                    TxtButton(
                        txt: LocaleKeys.login.tr(),
                        txtColor: AppColors.Primary,
                        OnTap: (){}
                    )
                  ])
            ],
          ),
        ),
      ),
    );
  }
}