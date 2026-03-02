import 'package:bookia_app/core/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AppBackButton extends StatelessWidget
{
  const AppBackButton({super.key});

  @override
  Widget build(BuildContext context)
  {
    return InkWell(
      onTap: (){Navigator.pop(context);},
      child: Container(
        padding: EdgeInsets.all(2.r),
        width: 41.w,
        height: 41.h,
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.BorderColor),
          borderRadius: BorderRadius.circular(12.r),
        ),
        child:Icon(Icons.arrow_back_ios_new, color: AppColors.Black, size: 23.sp),
      ),
    );
  }
}
