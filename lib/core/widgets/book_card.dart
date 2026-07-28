import 'package:bookia_app/core/models/product_model.dart';
import 'package:bookia_app/core/theme/colors.dart';
import 'package:bookia_app/core/theme/text_style.dart';
import 'package:bookia_app/core/utils/price_format.dart';
import 'package:bookia_app/core/widgets/app_button.dart';
import 'package:bookia_app/core/widgets/app_network_image.dart';
import 'package:bookia_app/core/widgets/remove_badge.dart';
import 'package:bookia_app/gen/locale_keys.g.dart';
import 'package:bookia_app/core/widgets/app_loader.dart';
import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// The 163x281 book card, in its two Figma variants.
enum BookCardVariant {
  /// Home and Search: title, price and a "Buy" pill.
  withBuyButton,

  /// Wishlist: no pill, plus a red remove badge over the cover.
  withRemoveBadge,
}

class BookCard extends StatelessWidget {
  const BookCard({
    super.key,
    required this.product,
    required this.onTap,
    this.variant = BookCardVariant.withBuyButton,
    this.onBuy,
    this.onRemove,
    this.isBusy = false,
  });

  final ProductModel product;
  final VoidCallback onTap;
  final BookCardVariant variant;
  final VoidCallback? onBuy;
  final VoidCallback? onRemove;

  /// Swaps the action control for a spinner while its request is in flight.
  final bool isBusy;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(AppRadius.card.r);

    return Material(
      color: AppColors.white,
      borderRadius: radius,
      child: InkWell(
        onTap: onTap,
        borderRadius: radius,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: radius,
            border: Border.all(color: AppColors.border),
          ),
          padding: EdgeInsets.all(11.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _Cover(product: product, onRemove: _removeAction),
              ),
              SizedBox(height: 10.h),
              Text(
                product.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyle.subtitle,
              ),
              SizedBox(height: 6.h),
              _PriceRow(
                product: product,
                showBuyButton: variant == BookCardVariant.withBuyButton,
                onBuy: onBuy,
                isBusy: isBusy,
              ),
            ],
          ),
        ),
      ),
    );
  }

  VoidCallback? get _removeAction =>
      variant == BookCardVariant.withRemoveBadge ? onRemove : null;
}

class _Cover extends StatelessWidget {
  const _Cover({required this.product, required this.onRemove});

  final ProductModel product;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    return Stack(
      // The badge deliberately overhangs the cover's corner; without this the
      // Stack's default hard edge slices it in half.
      clipBehavior: Clip.none,
      children: [
        Positioned.fill(
          child: AppNetworkImage(url: product.image, radius: AppRadius.card.r),
        ),
        if (product.hasDiscount)
          PositionedDirectional(
            top: 6.h,
            start: 6.w,
            child: _DiscountBadge(percentage: product.discount),
          ),
        if (onRemove != null)
          PositionedDirectional(
            bottom: -8.h,
            end: -8.w,
            child: RemoveBadge(onTap: onRemove, size: 26),
          ),
      ],
    );
  }
}

class _DiscountBadge extends StatelessWidget {
  const _DiscountBadge({required this.percentage});

  final int percentage;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(AppRadius.pill.r),
      ),
      // Forced LTR: under an Arabic locale the bidi algorithm moves the
      // leading minus to the end, rendering "35%-".
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: Text(
          '-$percentage%',
          style: AppTextStyle.orderMeta.copyWith(
            color: AppColors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class _PriceRow extends StatelessWidget {
  const _PriceRow({
    required this.product,
    required this.showBuyButton,
    required this.onBuy,
    required this.isBusy,
  });

  final ProductModel product;
  final bool showBuyButton;
  final VoidCallback? onBuy;
  final bool isBusy;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                PriceFormat.format(product.effectivePrice),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyle.body,
              ),
              if (product.hasDiscount)
                Text(
                  PriceFormat.format(product.price),
                  maxLines: 1,
                  style: AppTextStyle.description.copyWith(
                    color: AppColors.secondaryText,
                    decoration: TextDecoration.lineThrough,
                  ),
                ),
            ],
          ),
        ),
        if (showBuyButton)
          SizedBox(
            width: 72.w,
            child: isBusy
                ? const _MiniSpinner()
                : AppButton(
                    label: LocaleKeys.buy.tr(),
                    variant: AppButtonVariant.pill,
                    onTap: onBuy,
                    isEnabled: product.isInStock,
                  ),
          ),
      ],
    );
  }
}

class _MiniSpinner extends StatelessWidget {
  const _MiniSpinner();

  @override
  Widget build(BuildContext context) =>
      SizedBox(height: 28.h, child: const AppLoader.inline());
}

/// The two-column grid the design uses on Home, Search and Wishlist.
///
/// 163x281 at a 375 design width gives this aspect ratio; keeping it in one
/// place stops the three screens drifting apart.
abstract final class BookGrid {
  static const double aspectRatio = 163 / 281;
  static const double spacing = 18;
  static const double runSpacing = 15;

  static SliverGridDelegate get delegate =>
      SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: spacing.w,
        mainAxisSpacing: runSpacing.h,
        childAspectRatio: aspectRatio,
      );
}
