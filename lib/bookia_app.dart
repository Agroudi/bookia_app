import 'package:bookia_app/features/auth/presentaion/login_screen.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class BookiaApp extends StatelessWidget
{
  const BookiaApp({super.key});

  @override
  Widget build(BuildContext context)
  {
    return ScreenUtilInit
      (
        designSize: const Size(375, 812),
        splitScreenMode: true,
        minTextAdapt: true,
        child: MaterialApp(
            localizationsDelegates: context.localizationDelegates,
            supportedLocales: context.supportedLocales,
            locale: context.locale,
            home: LoginScreen()
        )
    );
  }
}