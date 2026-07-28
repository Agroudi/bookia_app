import 'package:bookia_app/core/theme/colors.dart';
import 'package:bookia_app/core/theme/text_style.dart';
import 'package:bookia_app/core/widgets/app_button.dart';
import 'package:bookia_app/core/widgets/app_form_field.dart';
import 'package:bookia_app/core/widgets/back_button.dart';
import 'package:bookia_app/features/auth/widgets/text_button.dart';
import 'package:bookia_app/gen/locale_keys.g.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class RegisterScreen extends StatelessWidget
{
  const RegisterScreen({super.key});

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
              Text(LocaleKeys.register_statement.tr(), style: AppTextStyle.txtStyle.copyWith(fontSize: 30.sp)),
              SizedBox(height: 32.h),
              AppFormField(hintTxt: LocaleKeys.username_hint.tr()),
              SizedBox(height: 11.h),
              AppFormField(hintTxt: LocaleKeys.email.tr()),
              SizedBox(height: 11.h),
              AppFormField(hintTxt: LocaleKeys.password.tr()),
              SizedBox(height: 11.h),
              AppFormField(hintTxt: LocaleKeys.confirm_pass_hint.tr(), obsecureText: false),
              SizedBox(height: 30.h),
              AppButton(txt: LocaleKeys.register_btn.tr(), OnTap: (){}),
              Spacer(),
              Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(LocaleKeys.have_account_statement.tr(), style: AppTextStyle.txtStyle.copyWith(color: AppColors.Black, fontSize: 14.sp)),
                    TxtButton(
                        txt: LocaleKeys.login.tr(),
                        txtColor: AppColors.Primary,
                        OnTap: (){Navigator.pop(context);}
                    )
                  ])
            ],
          ),
        ),
      ),
    );
  }
}