import 'package:bookia_app/core/theme/colors.dart';
import 'package:bookia_app/core/theme/text_style.dart';
import 'package:bookia_app/core/widgets/app_button.dart';
import 'package:bookia_app/gen/assets.gen.dart';
import 'package:bookia_app/gen/locale_keys.g.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';


class BoardingScreen extends StatelessWidget {
  const BoardingScreen({super.key});

  @override
  Widget build(BuildContext context)
  {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          image: DecorationImage(image:Assets.images.onBoardingBg.image().image, fit: BoxFit.cover)),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 22.w),
            child: Column(
            children: [
              SizedBox(height: 135.h),
              Assets.icons.logo.image(),
              SizedBox(height: 28.h),
              Text(LocaleKeys.on_boarding_statement.tr(), style: AppTextStyle.txtStyle),
              Spacer(),
              AppButton(txt: LocaleKeys.login.tr()),
              SizedBox(height: 15.h),
              AppButton(txt: LocaleKeys.register.tr(), bgColor: AppColors.White, txtColor: AppColors.Black),
              SizedBox(height: 94.h),
                    ],
                  ),
          ),
        ),
      );
  }
}