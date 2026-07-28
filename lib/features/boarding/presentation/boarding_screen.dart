import 'package:bookia_app/core/routing/routes.dart';
import 'package:bookia_app/core/storage/app_storage.dart';
import 'package:bookia_app/core/theme/colors.dart';
import 'package:bookia_app/core/theme/text_style.dart';
import 'package:bookia_app/core/widgets/app_button.dart';
import 'package:bookia_app/core/widgets/exit_confirmation_scope.dart';
import 'package:bookia_app/di/service_locator.dart';
import 'package:bookia_app/gen/assets.gen.dart';
import 'package:bookia_app/gen/locale_keys.g.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class BoardingScreen extends StatelessWidget {
  const BoardingScreen({super.key});

  Future<void> _go(BuildContext context, String route) async {
    // Onboarding is a one-time screen; remember that it has been seen so a
    // returning user lands on login instead.
    await getIt<SessionStorage>().markOnboardingSeen();
    if (!context.mounted) return;
    Navigator.of(context).pushNamed(route);
  }

  @override
  Widget build(BuildContext context) {
    // Onboarding is a root route, so back here means leaving the app.
    return ExitConfirmationScope(
      child: Scaffold(
        body: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: Assets.images.onBoardingBg.provider(),
              fit: BoxFit.cover,
            ),
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 22.w),
            child: SafeArea(
              child: Column(
                children: [
                  const Align(
                    alignment: AlignmentDirectional.topStart,
                    child: _LanguageToggle(),
                  ),
                  SizedBox(height: 60.h),
                  Assets.icons.logo.image(width: 180.w),
                  SizedBox(height: 28.h),
                  Text(
                    LocaleKeys.on_boarding_statement.tr(),
                    textAlign: TextAlign.center,
                    style: AppTextStyle.title,
                  ),
                  const Spacer(),
                  AppButton(
                    label: LocaleKeys.login.tr(),
                    onTap: () => _go(context, Routes.loginScreen),
                  ),
                  SizedBox(height: 15.h),
                  AppButton(
                    label: LocaleKeys.register.tr(),
                    variant: AppButtonVariant.outlined,
                    onTap: () => _go(context, Routes.registerScreen),
                  ),
                  SizedBox(height: 60.h),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Switches between the app's two locales. easy_localization persists the
/// choice, so it survives a restart.
class _LanguageToggle extends StatelessWidget {
  const _LanguageToggle();

  @override
  Widget build(BuildContext context) {
    final isArabic = context.locale.languageCode == 'ar';

    return TextButton.icon(
      onPressed: () =>
          context.setLocale(isArabic ? const Locale('en') : const Locale('ar')),
      icon: Icon(Icons.language, size: 22.sp, color: AppColors.dark),
      label: Text(
        isArabic ? LocaleKeys.english.tr() : LocaleKeys.arabic.tr(),
        style: AppTextStyle.caption.copyWith(color: AppColors.dark),
      ),
    );
  }
}
