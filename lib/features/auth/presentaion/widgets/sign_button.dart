import 'package:bookia_app/core/theme/colors.dart';
import 'package:bookia_app/core/theme/text_style.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';

class SignButton extends StatelessWidget
{
  const SignButton({super.key, this.$AssetsIconsGen, this.OnTap, required this.txt});

  final String txt;
  final $AssetsIconsGen;
  final void Function()? OnTap;


  @override
  Widget build(BuildContext context)
  {
    return InkWell(
      onTap: OnTap,
      child: Container(
        height: 50.h,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: AppColors.BorderColor,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset($AssetsIconsGen),
            const SizedBox(width: 12),
            Text(
              txt,
              style: AppTextStyle.txtStyle.copyWith(color: AppColors.Black.withOpacity(0.6), fontSize: 14.sp)
            ),
          ],
        ),
      ),
    );
  }
}