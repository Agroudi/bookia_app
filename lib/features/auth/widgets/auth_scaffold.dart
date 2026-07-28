import 'package:bookia_app/core/theme/colors.dart';
import 'package:bookia_app/core/theme/text_style.dart';
import 'package:bookia_app/core/widgets/back_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// The layout every auth screen shares: back button at (22, 56), a 30px
/// headline, an optional 16px subtitle, then the form.
///
/// Extracted because all five screens are the same page with different middles
/// — duplicating the padding and scroll behaviour five times is how they drift
/// apart.
class AuthScaffold extends StatelessWidget {
  const AuthScaffold({
    super.key,
    required this.title,
    required this.children,
    this.subtitle,
    this.footer,
  });

  final String title;
  final String? subtitle;
  final List<Widget> children;

  /// Pinned to the bottom of the viewport, as in the design (y765).
  final Widget? footer;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) => SingleChildScrollView(
            // Keeps the footer at the bottom on a tall screen while still
            // scrolling when the keyboard shrinks the viewport.
            physics: const ClampingScrollPhysics(),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: IntrinsicHeight(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 22.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 12.h),
                      const AppBackButton(),
                      SizedBox(height: 28.h),
                      Text(title, style: AppTextStyle.headlineLarge),
                      if (subtitle != null) ...[
                        SizedBox(height: 10.h),
                        Text(
                          subtitle!,
                          style: AppTextStyle.body.copyWith(
                            color: AppColors.hint,
                            height: 24 / 16,
                          ),
                        ),
                      ],
                      SizedBox(height: 30.h),
                      ...children,
                      if (footer != null) ...[
                        const Spacer(),
                        SizedBox(height: 24.h),
                        Center(child: footer!),
                        SizedBox(height: 20.h),
                      ] else
                        SizedBox(height: 24.h),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// The "Don't have an account? Register Now" line at the foot of each screen.
class AuthFooterPrompt extends StatelessWidget {
  const AuthFooterPrompt({
    super.key,
    required this.prompt,
    required this.action,
    required this.onTap,
  });

  final String prompt;
  final String action;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(
          child: Text(
            prompt,
            style: AppTextStyle.caption.copyWith(color: AppColors.dark),
          ),
        ),
        TextButton(
          onPressed: onTap,
          style: TextButton.styleFrom(
            padding: EdgeInsets.symmetric(horizontal: 6.w),
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: Text(
            action,
            style: AppTextStyle.caption.copyWith(color: AppColors.primary),
          ),
        ),
      ],
    );
  }
}
