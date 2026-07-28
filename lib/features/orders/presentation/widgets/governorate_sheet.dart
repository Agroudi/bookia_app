import 'package:bookia_app/core/theme/colors.dart';
import 'package:bookia_app/core/theme/text_style.dart';
import 'package:bookia_app/features/orders/data/models/order_model.dart';
import 'package:bookia_app/gen/locale_keys.g.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// The governorate picker, from the design's "Checkout card" sheet
/// (373x546, 30px top corners).
///
/// The Figma frame drew its dividers in white on white and repeated "Cairo"
/// four times; this uses the real list from `/governorates` and a visible
/// divider.
class GovernorateSheet extends StatelessWidget {
  const GovernorateSheet({super.key, required this.options});

  final List<GovernorateModel> options;

  static Future<GovernorateModel?> show(
    BuildContext context, {
    required List<GovernorateModel> options,
  }) => showModalBottomSheet<GovernorateModel>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (_) => GovernorateSheet(options: options),
  );

  @override
  Widget build(BuildContext context) {
    final languageCode = context.locale.languageCode;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * 0.7,
      ),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppRadius.sheet.r),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(height: 12.h),
          Container(
            width: 44.w,
            height: 4.h,
            decoration: BoxDecoration(
              color: AppColors.border,
              borderRadius: BorderRadius.circular(4.r),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(27.w, 20.h, 27.w, 12.h),
            child: Align(
              alignment: AlignmentDirectional.centerStart,
              child: Text(
                LocaleKeys.select_governorate.tr(),
                style: AppTextStyle.title,
              ),
            ),
          ),
          Flexible(
            child: ListView.separated(
              shrinkWrap: true,
              padding: EdgeInsets.only(bottom: 24.h),
              itemCount: options.length,
              separatorBuilder: (_, _) => Divider(
                height: 1,
                thickness: 1,
                color: AppColors.border,
                indent: 27.w,
                endIndent: 27.w,
              ),
              itemBuilder: (context, index) {
                final governorate = options[index];
                return InkWell(
                  onTap: () => Navigator.of(context).pop(governorate),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 27.w,
                      vertical: 17.h,
                    ),
                    child: Text(
                      governorate.nameFor(languageCode),
                      style: AppTextStyle.subtitle.copyWith(
                        color: AppColors.label,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
