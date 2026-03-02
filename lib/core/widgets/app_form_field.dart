import 'package:bookia_app/core/theme/colors.dart';
import 'package:bookia_app/core/theme/text_style.dart';
import 'package:bookia_app/gen/assets.gen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_svg/svg.dart';

class AppFormField extends StatefulWidget
{
  AppFormField({super.key, required this.hintTxt, this.obsecureText = true});

  final String? hintTxt;
  bool obsecureText = true;

  @override
  State<AppFormField> createState() => _AppFormFieldState();
}

class _AppFormFieldState extends State<AppFormField> {
  @override
  Widget build(BuildContext context)
  {
    return TextFormField(
      autocorrect: true,
      keyboardType: widget.hintTxt == "Enter your email" ? TextInputType.emailAddress : widget.hintTxt == "Enter your password" ? TextInputType.visiblePassword : TextInputType.text,
      obscureText: widget.obsecureText,
      cursorColor: AppColors.Primary,
      onTapOutside: (event) => FocusScope.of(context).unfocus(),
      decoration:InputDecoration(
        filled: true,
        border: OutlineInputBorder(borderSide: BorderSide()),
        enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: AppColors.BorderColor)),
        focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: AppColors.Primary)),
        fillColor: AppColors.FormColor,
        hintText: widget.hintTxt,
        suffixIcon: widget.hintTxt == "Enter your password" ? Padding(
          padding: const EdgeInsets.all(12.0),
          child: InkWell(onTap: () => setState(() => widget.obsecureText = !widget.obsecureText),child: SvgPicture.asset(Assets.icons.eye)),) : null,
        hintStyle: AppTextStyle.txtStyle.copyWith(color: AppColors.Black.withOpacity(0.6))
      )
    );
  }
}