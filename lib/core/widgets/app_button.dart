import 'package:bookia_app/core/theme/colors.dart';
import 'package:bookia_app/core/theme/text_style.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AppButton extends StatelessWidget {
  const AppButton({super.key, required this.txt, this.bgColor, this.txtColor, required this.OnTap});

   final String txt;
   final Color? bgColor;
   final Color? txtColor;
   final void Function()? OnTap;


  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: OnTap,
      child: Container(
        width: double.infinity,
        height: 50.h,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(color: bgColor == AppColors.White ? Color(0xFF2F2F2F) : Colors.transparent),
          color: bgColor ?? AppColors.Primary,),
        child: Center(
          child: Text(txt,
              style: AppTextStyle.txtStyle.copyWith(color: txtColor ?? AppColors.White, fontSize: 15.sp)),
        ),
      ),
    );
  }
}
