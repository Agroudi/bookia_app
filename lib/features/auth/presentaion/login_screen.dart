import 'package:bookia_app/core/theme/colors.dart';
import 'package:bookia_app/core/theme/text_style.dart';
import 'package:bookia_app/core/widgets/app_button.dart';
import 'package:bookia_app/core/widgets/app_form_field.dart';
import 'package:bookia_app/core/widgets/back_button.dart';
import 'package:bookia_app/features/auth/presentaion/widgets/sign_button.dart';
import 'package:bookia_app/features/auth/presentaion/widgets/text_button.dart';
import 'package:bookia_app/gen/assets.gen.dart';
import 'package:bookia_app/gen/locale_keys.g.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_svg/svg.dart';


class LoginScreen extends StatelessWidget
{
  const LoginScreen({super.key});

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
              Text(LocaleKeys.login_statement.tr(), style: AppTextStyle.txtStyle.copyWith(fontSize: 30.sp)),
              SizedBox(height: 32.h),
              AppFormField(hintTxt: "Enter your email"),
              SizedBox(height: 15.h),
              AppFormField(hintTxt: "Enter your password", obsecureText: false),
              SizedBox(height: 13.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TxtButton(
                      txt: "Forgot Password?",
                    txtColor: AppColors.Black.withOpacity(0.6),
                    OnTap: (){}
                  )
                ]),
              SizedBox(height: 30.h),
              AppButton(txt: "Login", OnTap: (){login();}),
              SizedBox(height: 34.h),
              Row(
                  children: [
                    Expanded(child: Divider(thickness: 2, color: AppColors.BorderColor, endIndent: 45,)),
                    Text('Or', style: AppTextStyle.txtStyle.copyWith(color: AppColors.Black.withOpacity(0.6), fontSize: 14.sp)),
                    Expanded(child: Divider(thickness: 2, color: AppColors.BorderColor, indent: 45)),
                  ]),
              SizedBox(height: 21.h),
              SignButton(txt: 'Sign in with Google',
                  $AssetsIconsGen: Assets.icons.google,
                  OnTap: (){}),
              SizedBox(height: 15.h),
              SignButton(txt: 'Sign in with Apple',
                $AssetsIconsGen: Assets.icons.apple,
                OnTap: (){}),
              Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Don't have an account?", style: AppTextStyle.txtStyle.copyWith(color: AppColors.Black, fontSize: 14.sp)),
                  SizedBox(width: 5.w),
                  TxtButton(
                      txt: "Register Now",
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
  login()
  async{
    Dio dio = Dio();

    final response = await dio.post('https://codingarabic.online/api/login',
        data:
        {
          "email" : "sayed332@gmail.com",
          "password" : "12345678"
        });
    debugPrint("Status Code: ${response.statusCode}");
    debugPrint("Response Data: ${response.data}");

  }
}