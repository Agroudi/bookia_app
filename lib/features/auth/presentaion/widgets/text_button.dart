import 'package:bookia_app/core/theme/colors.dart';
import 'package:bookia_app/core/theme/text_style.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class TxtButton extends StatelessWidget
{
  const TxtButton({super.key, required this.txt, this.txtColor, this.OnTap});

  final String txt;
  final Color? txtColor;
  final void Function()? OnTap;


  @override
  Widget build(BuildContext context)
  {
    return InkWell(onTap: OnTap,
        child: Text(
            txt,
            style: AppTextStyle.txtStyle.copyWith(
                color: txtColor,
                fontSize: 14.sp
            )
        )
    );
  }
}
