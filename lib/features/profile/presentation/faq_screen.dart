import 'package:bookia_app/core/api/api_result.dart';
import 'package:bookia_app/core/theme/colors.dart';
import 'package:bookia_app/core/theme/text_style.dart';
import 'package:bookia_app/core/widgets/screen_header.dart';
import 'package:bookia_app/features/profile/data/profile_repo.dart';
import 'package:bookia_app/gen/locale_keys.g.dart';
import 'package:bookia_app/core/widgets/app_loader.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// A read-only list with no writes and no shared state, so it reads the
/// repository directly through a `FutureBuilder` rather than carrying a cubit
/// that would only ever emit loading/success/failure.
class FaqScreen extends StatefulWidget {
  const FaqScreen({super.key, required this.repo});

  final ProfileRepository repo;

  @override
  State<FaqScreen> createState() => _FaqScreenState();
}

class _FaqScreenState extends State<FaqScreen> {
  late Future<ApiResult<List<FaqModel>>> _future = widget.repo.faqs();

  void _retry() => setState(() => _future = widget.repo.faqs());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(
                AppSpacing.screen.w,
                12.h,
                AppSpacing.screen.w,
                12.h,
              ),
              child: ScreenHeader(title: LocaleKeys.faq.tr(), showBack: true),
            ),
            Expanded(
              child: FutureBuilder<ApiResult<List<FaqModel>>>(
                future: _future,
                builder: (context, snapshot) {
                  if (snapshot.connectionState != ConnectionState.done) {
                    return const AppLoader();
                  }

                  final result = snapshot.data;
                  if (result == null) {
                    return _error(LocaleKeys.error_unknown.tr());
                  }

                  return result.when(
                    failure: (failure) => _error(failure.message),
                    success: (faqs, _) => faqs.isEmpty
                        ? EmptyState(
                            icon: Icons.help_outline_rounded,
                            title: LocaleKeys.empty_faq.tr(),
                            message: LocaleKeys.empty_faq_hint.tr(),
                          )
                        : ListView.separated(
                            padding: EdgeInsets.fromLTRB(
                              AppSpacing.screen.w,
                              0,
                              AppSpacing.screen.w,
                              30.h,
                            ),
                            itemCount: faqs.length,
                            separatorBuilder: (_, _) => SizedBox(height: 10.h),
                            itemBuilder: (context, index) =>
                                _FaqTile(faq: faqs[index]),
                          ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _error(String message) => EmptyState(
    icon: Icons.error_outline_rounded,
    title: LocaleKeys.error_unknown.tr(),
    message: message,
    action: TextButton(
      onPressed: _retry,
      child: Text(
        LocaleKeys.retry.tr(),
        style: AppTextStyle.body.copyWith(color: AppColors.primary),
      ),
    ),
  );
}

class _FaqTile extends StatelessWidget {
  const _FaqTile({required this.faq});

  final FaqModel faq;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppRadius.tile.r),
        border: Border.all(color: AppColors.border),
      ),
      child: Theme(
        // Removes the default ExpansionTile divider lines, which fight the
        // card border.
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          shape: const Border(),
          collapsedShape: const Border(),
          tilePadding: EdgeInsets.symmetric(horizontal: 20.w),
          childrenPadding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 16.h),
          expandedCrossAxisAlignment: CrossAxisAlignment.start,
          iconColor: AppColors.primary,
          collapsedIconColor: AppColors.dark,
          title: Text(
            faq.question,
            style: AppTextStyle.subtitle.copyWith(color: AppColors.label),
          ),
          children: [
            Text(
              faq.answer,
              style: AppTextStyle.body.copyWith(color: AppColors.secondaryText),
            ),
          ],
        ),
      ),
    );
  }
}
